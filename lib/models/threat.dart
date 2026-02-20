import 'package:freezed_annotation/freezed_annotation.dart';

part 'threat.freezed.dart';
part 'threat.g.dart';

/// Modèle d'une menace/ransomware (source: MalwareBazaar, abuse.ch)
@freezed
class Threat with _$Threat {
  const factory Threat({
    required String id,
    required String name,
    required String type,           // ransomware, malware, trojan, etc.
    required String severity,       // critical, high, medium, low
    required DateTime firstSeen,
    DateTime? lastSeen,
    String? description,
    String? sha256Hash,
    String? md5Hash,
    List<String>? tags,
    List<String>? targetCountries,
    List<String>? targetSectors,
    String? source,                 // malwarebazaar, abuse.ch, etc.
    String? sourceUrl,
    Map<String, dynamic>? metadata,
    @Default(false) bool isNew,
  }) = _Threat;

  factory Threat.fromJson(Map<String, dynamic> json) => _$ThreatFromJson(json);
}

/// Réponse paginée de l'API pour les threats
@freezed
class ThreatsResponse with _$ThreatsResponse {
  const factory ThreatsResponse({
    required List<Threat> items,
    required int total,
    required int page,
    required int pageSize,
    required bool hasMore,
  }) = _ThreatsResponse;

  factory ThreatsResponse.fromJson(Map<String, dynamic> json) =>
      _$ThreatsResponseFromJson(json);
}
