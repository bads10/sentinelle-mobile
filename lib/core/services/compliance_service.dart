import '../utils/api_rate_limiter.dart';
import '../utils/content_policy_checker.dart';
import '../utils/ingestion_logger.dart';
import '../utils/pii_sanitizer.dart';

/// Façade de conformité regroupant :
///   - Sanitisation PII
///   - Logging d'ingestion + retry
///   - Rate-limiting par source
///   - Vérification de la politique de contenu (store-friendly)
///
/// À utiliser dans tous les services d'ingestion (RSS, NVD, AlienVault…)
class ComplianceService {
  ComplianceService._();
  static final ComplianceService instance = ComplianceService._();

  final PiiSanitizer _pii = PiiSanitizer.instance;
  final IngestionLogger _logger = IngestionLogger.instance;
  final ApiRateLimiter _rateLimit = ApiRateLimiter.instance;
  final ContentPolicyChecker _policy = ContentPolicyChecker.instance;

  // ---------------------------------------------------------------------------
  // PII sanitization
  // ---------------------------------------------------------------------------

  /// Assainit un champ texte libre (description, titre, etc.).
  String sanitizeText(String text) => _pii.sanitizeText(text);

  /// Assainit une URL avant stockage / affichage.
  String sanitizeUrl(String url) => _pii.sanitizeUrl(url);

  /// Assainit une Map<String, dynamic> en nettoyant les valeurs définies
  /// comme sensibles (champs PII).
  Map<String, dynamic> sanitizeMap(
    Map<String, dynamic> data, {
    List<String> sensitiveFields = const [
      'email',
      'phone',
      'ip',
      'author',
      'reporter',
    ],
  }) {
    return Map.fromEntries(data.entries.map((e) {
      if (sensitiveFields.contains(e.key.toLowerCase()) &&
          e.value is String) {
        return MapEntry(e.key, _pii.sanitizeText(e.value as String));
      }
      return e;
    }));
  }

  // ---------------------------------------------------------------------------
  // Content policy
  // ---------------------------------------------------------------------------

  /// Retourne true si l'item (url + titre + description) est conforme aux
  /// règles du store. Logge les violations éventuelles.
  bool isCompliant({
    required String sourceId,
    required String url,
    required String title,
    String description = '',
  }) {
    final result = _policy.checkNewsItem(
      url: url,
      title: title,
      description: description,
    );
    if (!result.isCompliant) {
      _logger.warning(
        sourceId,
        'Contenu non conforme écarté: ${result.violations.join(", ")}',
      );
    }
    return result.isCompliant;
  }

  /// Expurge les hash bruts (IOC) d'un texte pour affichage public.
  String redactHashes(String text) => _policy.redactRawHashes(text);

  // ---------------------------------------------------------------------------
  // Rate limiting
  // ---------------------------------------------------------------------------

  /// Tente d'enregistrer un appel pour [sourceId].
  /// Renvoie false et logge un avertissement si le rate-limit est atteint.
  bool tryCallOrWarn(String sourceId) {
    final allowed = _rateLimit.tryCall(sourceId);
    if (!allowed) {
      final wait = _rateLimit.timeUntilNextCall(sourceId);
      _logger.warning(
        sourceId,
        'Rate-limit atteint - prochain appel dans ${wait.inSeconds}s',
      );
    }
    return allowed;
  }

  /// Attend que le rate-limit autorise un appel, puis l'enregistre.
  Future<void> waitForRateLimit(String sourceId) =>
      _rateLimit.waitAndRecord(sourceId);

  // ---------------------------------------------------------------------------
  // Retry + logging
  // ---------------------------------------------------------------------------

  /// Exécute [fn] avec retry exponentiel et logging automatique.
  Future<T> withRetry<T>(
    String sourceId,
    Future<T> Function() fn, {
    int maxAttempts = 3,
    Duration baseDelay = const Duration(seconds: 2),
  }) =>
      IngestionLogger.withRetry(
        sourceId,
        fn,
        maxAttempts: maxAttempts,
        baseDelay: baseDelay,
      );

  void logInfo(String sourceId, String msg) => _logger.info(sourceId, msg);
  void logWarning(String sourceId, String msg) =>
      _logger.warning(sourceId, msg);
  void logError(String sourceId, String msg,
          {Object? error, StackTrace? stackTrace}) =>
      _logger.error(sourceId, msg, error: error, stackTrace: stackTrace);

  // ---------------------------------------------------------------------------
  // Combo helper: fetch conforme + retry + rate-limit
  // ---------------------------------------------------------------------------

  /// Fetch « conforme » d'une source:
  ///   1. Vérifie le rate-limit (attend si nécessaire)
  ///   2. Exécute [fn] avec retry
  ///   3. Logge succès/échec
  Future<T> fetchCompliant<T>(
    String sourceId,
    Future<T> Function() fn, {
    int maxAttempts = 3,
  }) async {
    await waitForRateLimit(sourceId);
    return withRetry(sourceId, fn, maxAttempts: maxAttempts);
  }
}
