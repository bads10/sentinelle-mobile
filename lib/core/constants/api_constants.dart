/// Constantes de l'API Sentinelle Backend
class ApiConstants {
  ApiConstants._();

  // URL de base (modifier via env si besoin)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const String apiVersion = 'v1';
  static const String apiPrefix = '/api/$apiVersion';

  // Endpoints Threats
  static const String threats = '$apiPrefix/threats/';
  static String threatById(String id) => '$apiPrefix/threats/$id';

  // Endpoints Incidents
  static const String incidents = '$apiPrefix/incidents/';
  static String incidentById(String id) => '$apiPrefix/incidents/$id';

  // Endpoints Feed RSS
  static const String feed = '$apiPrefix/feed/';

  // Endpoints Statistiques
  static const String stats = '$apiPrefix/stats/';

  // Health check
  static const String health = '/health';

  // Timeouts
  static const int connectTimeout = 10000; // ms
  static const int receiveTimeout = 30000; // ms
  static const int sendTimeout = 10000; // ms
}
