import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stats.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';

// AsyncNotifier pour les statistiques avec cache Hive
class StatsNotifier extends AsyncNotifier<AppStats> {
  static const _cacheKey = 'stats_cache';

  @override
  Future<AppStats> build() async {
    return _fetchStats();
  }

  Future<AppStats> _fetchStats() async {
    final cacheService = ref.read(cacheServiceProvider);

    // Retourner le cache si valide
    if (cacheService.isCacheValid(_cacheKey)) {
      final cached = cacheService.getStats();
      if (cached != null) return cached;
    }

    // Sinon, fetch depuis l'API
    final apiService = ref.read(apiServiceProvider);
    final stats = await apiService.fetchStats();

    // Sauvegarder en cache
    await cacheService.saveStats(stats);
    return stats;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchStats);
  }

  Future<void> clearCache() async {
    final cacheService = ref.read(cacheServiceProvider);
    await cacheService.clearStats();
    await refresh();
  }
}

final statsProvider = AsyncNotifierProvider<StatsNotifier, AppStats>(
  StatsNotifier.new,
);

// Provider pour les stats de menaces
final threatStatsProvider = Provider<ThreatStats?>((ref) {
  return ref.watch(statsProvider).valueOrNull?.threats;
});

// Provider pour les stats d'incidents
final incidentStatsProvider = Provider<IncidentStats?>((ref) {
  return ref.watch(statsProvider).valueOrNull?.incidents;
});

// Provider pour les stats RSS
final rssStatsProvider = Provider<RssStats?>((ref) {
  return ref.watch(statsProvider).valueOrNull?.rss;
});

// Provider d'état de chargement
final isStatsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(statsProvider).isLoading;
});

// Provider d'erreur
final statsErrorProvider = Provider<String?>((ref) {
  final stats = ref.watch(statsProvider);
  return stats.hasError ? stats.error.toString() : null;
});

// Provider pour le provider de service API
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Provider pour le cache service
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});
