/// Constantes globales de l'application Sentinelle
class AppConstants {
  AppConstants._();

  // Informations app
  static const String appName = 'Sentinelle';
  static const String appVersion = '0.1.0';
  static const String appDescription = 'Veille cybersécurité temps réel';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache
  static const String threatsBoxName = 'threats_cache';
  static const String incidentsBoxName = 'incidents_cache';
  static const String feedBoxName = 'feed_cache';
  static const String statsBoxName = 'stats_cache';
  static const Duration cacheDuration = Duration(minutes: 15);

  // Refresh auto
  static const Duration autoRefreshInterval = Duration(minutes: 5);

  // Sévérités
  static const String severityCritical = 'critical';
  static const String severityHigh = 'high';
  static const String severityMedium = 'medium';
  static const String severityLow = 'low';
  static const String severityInfo = 'info';

  // Niveaux CVSS
  static const double cvssThresholdCritical = 9.0;
  static const double cvssThresholdHigh = 7.0;
  static const double cvssThresholdMedium = 4.0;
  static const double cvssThresholdLow = 0.1;

  // Animations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);
}
