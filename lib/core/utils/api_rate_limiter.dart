import 'dart:async';
import 'dart:collection';

/// Politique de rate-limiting pour une source d'API.
class RateLimitPolicy {
  /// Nombre maximum d'appels autorisés dans la fenêtre.
  final int maxCalls;

  /// Durée de la fenêtre glissante.
  final Duration window;

  /// Délai minimum entre deux appels consécutifs (optionnel).
  final Duration? minInterval;

  const RateLimitPolicy({
    required this.maxCalls,
    required this.window,
    this.minInterval,
  });

  // Politiques prédéfinies par source
  static const nvd = RateLimitPolicy(
    maxCalls: 5,
    window: Duration(seconds: 30),
    minInterval: Duration(seconds: 6),
  );

  static const alienvault = RateLimitPolicy(
    maxCalls: 60,
    window: Duration(minutes: 1),
  );

  static const rss = RateLimitPolicy(
    maxCalls: 10,
    window: Duration(minutes: 1),
  );

  static const defaultPolicy = RateLimitPolicy(
    maxCalls: 30,
    window: Duration(minutes: 1),
  );
}

/// Gestionnaire de rate-limit basé sur une fenêtre glissante.
class ApiRateLimiter {
  ApiRateLimiter._();
  static final ApiRateLimiter instance = ApiRateLimiter._();

  /// Table des compteurs par identifiant de source.
  final Map<String, _SourceBucket> _buckets = {};

  // Politiques enregistrées (source id -> policy)
  final Map<String, RateLimitPolicy> _policies = {
    'nvd': RateLimitPolicy.nvd,
    'alienvault': RateLimitPolicy.alienvault,
    'rss': RateLimitPolicy.rss,
  };

  // ---------------------------------------------------------------------------
  // Configuration
  // ---------------------------------------------------------------------------

  /// Enregistre ou remplace la politique pour [sourceId].
  void registerPolicy(String sourceId, RateLimitPolicy policy) {
    _policies[sourceId] = policy;
  }

  // ---------------------------------------------------------------------------
  // Rate-limit check
  // ---------------------------------------------------------------------------

  /// Renvoie true si un appel est autorisé pour [sourceId] maintenant.
  bool canCall(String sourceId) {
    final policy = _policies[sourceId] ?? RateLimitPolicy.defaultPolicy;
    final bucket = _getOrCreate(sourceId, policy);
    return bucket.canCall(policy);
  }

  /// Enregistre un appel effectué pour [sourceId].
  void recordCall(String sourceId) {
    final policy = _policies[sourceId] ?? RateLimitPolicy.defaultPolicy;
    final bucket = _getOrCreate(sourceId, policy);
    bucket.recordCall();
  }

  /// Combine [canCall] + [recordCall].
  /// Renvoie true et enregistre si autorisé, false sinon.
  bool tryCall(String sourceId) {
    if (canCall(sourceId)) {
      recordCall(sourceId);
      return true;
    }
    return false;
  }

  /// Retourne le délai à attendre avant le prochain appel autorisé.
  /// Renvoie [Duration.zero] si un appel est immédiatement possible.
  Duration timeUntilNextCall(String sourceId) {
    final policy = _policies[sourceId] ?? RateLimitPolicy.defaultPolicy;
    final bucket = _getOrCreate(sourceId, policy);
    return bucket.timeUntilNextCall(policy);
  }

  /// Attend que le rate-limit autorise un appel, puis l'enregistre.
  Future<void> waitAndRecord(String sourceId) async {
    final delay = timeUntilNextCall(sourceId);
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    recordCall(sourceId);
  }

  // ---------------------------------------------------------------------------
  // Stats
  // ---------------------------------------------------------------------------

  /// Nombre d'appels dans la fenêtre courante pour [sourceId].
  int callsInWindow(String sourceId) {
    final policy = _policies[sourceId] ?? RateLimitPolicy.defaultPolicy;
    final bucket = _getOrCreate(sourceId, policy);
    bucket._purge(policy);
    return bucket._timestamps.length;
  }

  void reset(String sourceId) => _buckets[sourceId]?._timestamps.clear();
  void resetAll() => _buckets.forEach((_, b) => b._timestamps.clear());

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  _SourceBucket _getOrCreate(String sourceId, RateLimitPolicy policy) =>
      _buckets.putIfAbsent(sourceId, () => _SourceBucket());
}

class _SourceBucket {
  final Queue<DateTime> _timestamps = Queue();

  void _purge(RateLimitPolicy policy) {
    final cutoff = DateTime.now().toUtc().subtract(policy.window);
    while (_timestamps.isNotEmpty && _timestamps.first.isBefore(cutoff)) {
      _timestamps.removeFirst();
    }
  }

  bool canCall(RateLimitPolicy policy) {
    _purge(policy);
    if (_timestamps.length >= policy.maxCalls) return false;
    if (policy.minInterval != null && _timestamps.isNotEmpty) {
      final elapsed = DateTime.now().toUtc().difference(_timestamps.last);
      if (elapsed < policy.minInterval!) return false;
    }
    return true;
  }

  void recordCall() => _timestamps.addLast(DateTime.now().toUtc());

  Duration timeUntilNextCall(RateLimitPolicy policy) {
    _purge(policy);
    Duration wait = Duration.zero;

    // Contrainte: fenêtre glissante
    if (_timestamps.length >= policy.maxCalls) {
      final oldest = _timestamps.first;
      final reset = oldest.add(policy.window);
      final diff = reset.difference(DateTime.now().toUtc());
      if (diff > wait) wait = diff;
    }

    // Contrainte: intervalle minimum
    if (policy.minInterval != null && _timestamps.isNotEmpty) {
      final nextAllowed = _timestamps.last.add(policy.minInterval!);
      final diff = nextAllowed.difference(DateTime.now().toUtc());
      if (diff > wait) wait = diff;
    }

    return wait < Duration.zero ? Duration.zero : wait;
  }
}
