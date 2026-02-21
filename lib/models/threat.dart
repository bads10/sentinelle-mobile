/// Modèle d'une menace/ransomware (source: MalwareBazaar, abuse.ch)
class Threat {
  final String id;
  final String name;
  final String family;
  final String severity; // critical, high, medium, low
  final String description;
  final String reportedAt;
  final List<String> tags;
  final int iocCount;
  final bool isActive;
  final String? source;
  final String? sourceUrl;

  const Threat({
    required this.id,
    required this.name,
    required this.family,
    required this.severity,
    required this.description,
    required this.reportedAt,
    required this.tags,
    required this.iocCount,
    required this.isActive,
    this.source,
    this.sourceUrl,
  });

  factory Threat.fromJson(Map<String, dynamic> json) {
    return Threat(
      id: json['id'] as String,
      name: json['name'] as String,
      family: json['family'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String? ?? '',
      reportedAt: json['reported_at'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      iocCount: json['ioc_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? false,
      source: json['source'] as String?,
      sourceUrl: json['source_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'family': family,
      'severity': severity,
      'description': description,
      'reported_at': reportedAt,
      'tags': tags,
      'ioc_count': iocCount,
      'is_active': isActive,
      if (source != null) 'source': source,
      if (sourceUrl != null) 'source_url': sourceUrl,
    };
  }

  Threat copyWith({
    String? id,
    String? name,
    String? family,
    String? severity,
    String? description,
    String? reportedAt,
    List<String>? tags,
    int? iocCount,
    bool? isActive,
    String? source,
    String? sourceUrl,
  }) {
    return Threat(
      id: id ?? this.id,
      name: name ?? this.name,
      family: family ?? this.family,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      reportedAt: reportedAt ?? this.reportedAt,
      tags: tags ?? this.tags,
      iocCount: iocCount ?? this.iocCount,
      isActive: isActive ?? this.isActive,
      source: source ?? this.source,
      sourceUrl: sourceUrl ?? this.sourceUrl,
    );
  }

  /// Retourne true si la menace est critique ou à haut risque
  bool get isCritical =>
      severity.toLowerCase() == 'critical' ||
      severity.toLowerCase() == 'high';

  @override
  String toString() =>
      'Threat(id: $id, name: $name, family: $family, severity: $severity)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Threat && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
