import 'package:freezed_annotation/freezed_annotation.dart';

part 'incident.freezed.dart';
part 'incident.g.dart';

/// Modèle d'un incident CVE (source: CIRCL, NVD)
@freezed
class Incident with _$Incident {
  const factory Incident({
    required String id,
    required String cveId,           // CVE-2024-XXXXX
    required String title,
    required String description,
    required double cvssScore,       // 0.0 - 10.0
    required String severity,        // critical, high, medium, low
    required DateTime publishedAt,
    DateTime? modifiedAt,
    List<String>? affectedProducts,
    List<String>? affectedVersions,
    String? vendor,
    String? cweId,                   // CWE-XXX
    String? patchUrl,
    String? referenceUrl,
    String? source,                  // nvd, circl, etc.
    List<String>? references,
    @Default(false) bool hasPatch,
    @Default(false) bool isNew,
  }) = _Incident;

  factory Incident.fromJson(Map<String, dynamic> json) =>
      _$IncidentFromJson(json);
}

/// Réponse paginée de l'API pour les incidents
@freezed
class IncidentsResponse with _$IncidentsResponse {
  const factory IncidentsResponse({
    required List<Incident> items,
    required int total,
    required int page,
    required int pageSize,
    required bool hasMore,
  }) = _IncidentsResponse;

  factory IncidentsResponse.fromJson(Map<String, dynamic> json) =>
      _$IncidentsResponseFromJson(json);
}
