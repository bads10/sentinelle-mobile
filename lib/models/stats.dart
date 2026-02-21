/// Statistiques globales de la plateforme Sentinelle
class Stats {
  final int totalThreats;
  final int totalIncidents;
  final int totalFeedItems;

  // Derniers 7 jours
  final int newThreatsLast7Days;
  final int newIncidentsLast7Days;
  final int criticalThreats;
  final int highSeverityIncidents;

  // Repartition par severite (threats)
  final int threatsCritical;
  final int threatsHigh;
  final int threatsMedium;
  final int threatsLow;

  // Repartition par severite (incidents CVE)
  final int incidentsCritical;
  final int incidentsHigh;
  final int incidentsMedium;
  final int incidentsLow;

  // Tendances (comparaison semaine precedente)
  final double threatsTrend;
  final double incidentsTrend;

  // Top menaces
  final List<String> topThreatTypes;
  final List<String> topTargetedSectors;

  // Derniere mise a jour
  final DateTime lastUpdated;

  const Stats({
    required this.totalThreats,
    required this.totalIncidents,
    required this.totalFeedItems,
    required this.newThreatsLast7Days,
    required this.newIncidentsLast7Days,
    required this.criticalThreats,
    required this.highSeverityIncidents,
    required this.threatsCritical,
    required this.threatsHigh,
    required this.threatsMedium,
    required this.threatsLow,
    required this.incidentsCritical,
    required this.incidentsHigh,
    required this.incidentsMedium,
    required this.incidentsLow,
    this.threatsTrend = 0.0,
    this.incidentsTrend = 0.0,
    this.topThreatTypes = const [],
    this.topTargetedSectors = const [],
    required this.lastUpdated,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      totalThreats: json['total_threats'] as int? ?? 0,
      totalIncidents: json['total_incidents'] as int? ?? 0,
      totalFeedItems: json['total_feed_items'] as int? ?? 0,
      newThreatsLast7Days: json['new_threats_last_7_days'] as int? ?? 0,
      newIncidentsLast7Days: json['new_incidents_last_7_days'] as int? ?? 0,
      criticalThreats: json['critical_threats'] as int? ?? 0,
      highSeverityIncidents: json['high_severity_incidents'] as int? ?? 0,
      threatsCritical: json['threats_critical'] as int? ?? 0,
      threatsHigh: json['threats_high'] as int? ?? 0,
      threatsMedium: json['threats_medium'] as int? ?? 0,
      threatsLow: json['threats_low'] as int? ?? 0,
      incidentsCritical: json['incidents_critical'] as int? ?? 0,
      incidentsHigh: json['incidents_high'] as int? ?? 0,
      incidentsMedium: json['incidents_medium'] as int? ?? 0,
      incidentsLow: json['incidents_low'] as int? ?? 0,
      threatsTrend: (json['threats_trend'] as num?)?.toDouble() ?? 0.0,
      incidentsTrend: (json['incidents_trend'] as num?)?.toDouble() ?? 0.0,
      topThreatTypes: (json['top_threat_types'] as List<dynamic>?)
              ?.cast<String>() ??
          [],
      topTargetedSectors: (json['top_targeted_sectors'] as List<dynamic>?)
              ?.cast<String>() ??
          [],
      lastUpdated: DateTime.parse(
          json['last_updated'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_threats': totalThreats,
      'total_incidents': totalIncidents,
      'total_feed_items': totalFeedItems,
      'new_threats_last_7_days': newThreatsLast7Days,
      'new_incidents_last_7_days': newIncidentsLast7Days,
      'critical_threats': criticalThreats,
      'high_severity_incidents': highSeverityIncidents,
      'threats_critical': threatsCritical,
      'threats_high': threatsHigh,
      'threats_medium': threatsMedium,
      'threats_low': threatsLow,
      'incidents_critical': incidentsCritical,
      'incidents_high': incidentsHigh,
      'incidents_medium': incidentsMedium,
      'incidents_low': incidentsLow,
      'threats_trend': threatsTrend,
      'incidents_trend': incidentsTrend,
      'top_threat_types': topThreatTypes,
      'top_targeted_sectors': topTargetedSectors,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  Stats copyWith({
    int? totalThreats,
    int? totalIncidents,
    int? totalFeedItems,
    int? newThreatsLast7Days,
    int? newIncidentsLast7Days,
    int? criticalThreats,
    int? highSeverityIncidents,
    int? threatsCritical,
    int? threatsHigh,
    int? threatsMedium,
    int? threatsLow,
    int? incidentsCritical,
    int? incidentsHigh,
    int? incidentsMedium,
    int? incidentsLow,
    double? threatsTrend,
    double? incidentsTrend,
    List<String>? topThreatTypes,
    List<String>? topTargetedSectors,
    DateTime? lastUpdated,
  }) {
    return Stats(
      totalThreats: totalThreats ?? this.totalThreats,
      totalIncidents: totalIncidents ?? this.totalIncidents,
      totalFeedItems: totalFeedItems ?? this.totalFeedItems,
      newThreatsLast7Days: newThreatsLast7Days ?? this.newThreatsLast7Days,
      newIncidentsLast7Days: newIncidentsLast7Days ?? this.newIncidentsLast7Days,
      criticalThreats: criticalThreats ?? this.criticalThreats,
      highSeverityIncidents: highSeverityIncidents ?? this.highSeverityIncidents,
      threatsCritical: threatsCritical ?? this.threatsCritical,
      threatsHigh: threatsHigh ?? this.threatsHigh,
      threatsMedium: threatsMedium ?? this.threatsMedium,
      threatsLow: threatsLow ?? this.threatsLow,
      incidentsCritical: incidentsCritical ?? this.incidentsCritical,
      incidentsHigh: incidentsHigh ?? this.incidentsHigh,
      incidentsMedium: incidentsMedium ?? this.incidentsMedium,
      incidentsLow: incidentsLow ?? this.incidentsLow,
      threatsTrend: threatsTrend ?? this.threatsTrend,
      incidentsTrend: incidentsTrend ?? this.incidentsTrend,
      topThreatTypes: topThreatTypes ?? this.topThreatTypes,
      topTargetedSectors: topTargetedSectors ?? this.topTargetedSectors,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Point de donnees pour les graphiques de tendances
class TrendPoint {
  final DateTime date;
  final int count;
  final String? label;

  const TrendPoint({
    required this.date,
    required this.count,
    this.label,
  });

  factory TrendPoint.fromJson(Map<String, dynamic> json) {
    return TrendPoint(
      date: DateTime.parse(json['date'] as String),
      count: json['count'] as int? ?? 0,
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'count': count,
      if (label != null) 'label': label,
    };
  }
}
