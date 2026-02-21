import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cache_service.dart';

// Provider for CacheService singleton
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService.instance;
});

// CacheStatusNotifier: expose l'etat du cache (validite TTL)
class CacheStatusNotifier extends StateNotifier<CacheStatusState> {
  final CacheService _cache;

  CacheStatusNotifier(this._cache) : super(const CacheStatusState());

  Future<void> refresh() async {
    state = CacheStatusState(
      threatsValid: _cache.isCacheValid('threats_cache'),
      incidentsValid: _cache.isCacheValid('incidents_cache'),
      rssValid: _cache.isCacheValid('rss_cache'),
      statsValid: _cache.isCacheValid('stats_cache'),
    );
  }

  Future<void> clearAll() async {
    await _cache.clearAll();
    await refresh();
  }

  Future<void> clearThreats() async {
    await _cache.clearThreats();
    await refresh();
  }
}

final cacheStatusProvider =
    StateNotifierProvider<CacheStatusNotifier, CacheStatusState>((ref) {
  final cache = ref.watch(cacheServiceProvider);
  return CacheStatusNotifier(cache);
});

// Provider bool utilitaires
final isThreatsCachedProvider = Provider<bool>((ref) {
  return ref.watch(cacheStatusProvider).threatsValid;
});

final isIncidentsCachedProvider = Provider<bool>((ref) {
  return ref.watch(cacheStatusProvider).incidentsValid;
});

final isRssCachedProvider = Provider<bool>((ref) {
  return ref.watch(cacheStatusProvider).rssValid;
});

final isStatsCachedProvider = Provider<bool>((ref) {
  return ref.watch(cacheStatusProvider).statsValid;
});

// Etat du cache (immutable)
class CacheStatusState {
  final bool threatsValid;
  final bool incidentsValid;
  final bool rssValid;
  final bool statsValid;

  const CacheStatusState({
    this.threatsValid = false,
    this.incidentsValid = false,
    this.rssValid = false,
    this.statsValid = false,
  });

  CacheStatusState copyWith({
    bool? threatsValid,
    bool? incidentsValid,
    bool? rssValid,
    bool? statsValid,
  }) {
    return CacheStatusState(
      threatsValid: threatsValid ?? this.threatsValid,
      incidentsValid: incidentsValid ?? this.incidentsValid,
      rssValid: rssValid ?? this.rssValid,
      statsValid: statsValid ?? this.statsValid,
    );
  }
}
