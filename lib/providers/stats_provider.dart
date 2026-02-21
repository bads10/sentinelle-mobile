import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stats.dart';
import '../services/api_service.dart';
import 'cache_provider.dart';

// AsyncNotifier pour les statistiques avec cache
class StatsNotifier extends AsyncNotifier<Stats> {
  static const _cacheKey = 'stats_cache';

  @override
  Future<Stats> build() async {
    return _fetchStats();
  }

  Future<Stats> _fetchStats() async {
    final cacheService = ref.read(cacheServiceProvider);

    // Retourner le cache si valide
    if (cacheService.isCacheValid(_cacheKey)) {
      final cachedData = await cacheService.getCachedStats();
      if (cachedData != null) return Stats.fromJson(cachedData);
    }

    // Sinon, fetch depuis l'API
    final apiService = ref.read(apiServiceProvider);
    final stats = await apiService.fetchStats();

    // Sauvegarder en cache
    await cacheService.cacheStats(stats.toJson());

    return stats;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchStats);
  }

  Future<void> clearCache() async {
    final cacheService = ref.read(cacheServiceProvider);
    await cacheService.clearAll();
    await refresh();
  }
}

final statsProvider = AsyncNotifierProvider<StatsNotifier, Stats>(
  StatsNotifier.new,
);

// Provider d'etat de chargement
final isStatsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(statsProvider).isLoading;
});

// Provider d'erreur
final statsErrorProvider = Provider<String?>((ref) {
  final stats = ref.watch(statsProvider);
  return stats.hasError ? stats.error.toString() : null;
});

// Provider pour le nombre total de menaces critiques
final criticalThreatsCountProvider = Provider<int>((ref) {
  return ref.watch(statsProvider).valueOrNull?.criticalThreats ?? 0;
});

// Provider pour le nombre total d'incidents a haute severite
final highSeverityIncidentsCountProvider = Provider<int>((ref) {
  return ref.watch(statsProvider).valueOrNull?.highSeverityIncidents ?? 0;
});

// Provider pour les totaux globaux
final statsTotalsProvider = Provider<Map<String, int>>((ref) {
  final stats = ref.watch(statsProvider).valueOrNull;
  if (stats == null) return {};
  return {
    'threats': stats.totalThreats,
    'incidents': stats.totalIncidents,
    'feed': stats.totalFeedItems,
  };
});
