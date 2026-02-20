import 'package:freezed_annotation/freezed_annotation.dart';

part 'stats.freezed.dart';
part 'stats.g.dart';

/// Statistiques globales de la plateforme Sentinelle
@freezed
class Stats with _$Stats {
  const factory Stats({
    // Compteurs globaux
    required int totalThreats,
    required int totalIncidents,
    required int totalFeedItems,

    // Derniers 7 jours
    required int newThreatsLast7Days,
    required int newIncidentsLast7Days,
    required int criticalThreats,
    required int highSeverityIncidents,

    // Répartition par sévérité (threats)
    required int threatsCritical,
    required int threatsHigh,
    required int threatsMedium,
    required int threatsLow,

    // Répartition par sévérité (incidents CVE)
    required int incidentsCritical,
    required int incidentsHigh,
    required int incidentsMedium,
    required int incidentsLow,

    // Tendances (comparaison semaine précédente)
    @Default(0.0) double threatsTrend,    // % d'évolution
    @Default(0.0) double incidentsTrend,

    // Top menaces
    @Default([]) List<String> topThreatTypes,
    @Default([]) List<String> topTargetedSectors,

    // Dernière mise à jour
    required DateTime lastUpdated,
  }) = _Stats;

  factory Stats.fromJson(Map<String, dynamic> json) => _$StatsFromJson(json);
}

/// Point de données pour les graphiques de tendances
@freezed
class TrendPoint with _$TrendPoint {
  const factory TrendPoint({
    required DateTime date,
    required int count,
    String? label,
  }) = _TrendPoint;

  factory TrendPoint.fromJson(Map<String, dynamic> json) =>
      _$TrendPointFromJson(json);
}
