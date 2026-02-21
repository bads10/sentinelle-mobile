/// Modèle d'un incident CVE (source: CIRCL, NVD)
class Incident {
  final String id;
  final String cveId;
  final String summary;
  final String severity; // critical, high, medium, low
  final double cvssScore; // 0.0 - 10.0
  final String publishedAt;
  final String updatedAt;
  final List<String> affectedProducts;
  final List<String> references;
  final String? vendor;
  final String? patchUrl;

  const Incident({
    required this.id,
    required this.cveId,
    required this.summary,
    required this.severity,
    required this.cvssScore,
    required this.publishedAt,
    required this.updatedAt,
    required this.affectedProducts,
    required this.references,
    this.vendor,
    this.patchUrl,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] as String,
      cveId: json['cve_id'] as String,
      summary: json['summary'] as String? ?? '',
      severity: json['severity'] as String,
      cvssScore: (json['cvss_score'] as num).toDouble(),
      publishedAt: json['published_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      affectedProducts:
          (json['affected_products'] as List<dynamic>?)?.cast<String>() ?? [],
      references:
          (json['references'] as List<dynamic>?)?.cast<String>() ?? [],
      vendor: json['vendor'] as String?,
      patchUrl: json['patch_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cve_id': cveId,
      'summary': summary,
      'severity': severity,
      'cvss_score': cvssScore,
      'published_at': publishedAt,
      'updated_at': updatedAt,
      'affected_products': affectedProducts,
      'references': references,
      if (vendor != null) 'vendor': vendor,
      if (patchUrl != null) 'patch_url': patchUrl,
    };
  }

  Incident copyWith({
    String? id,
    String? cveId,
    String? summary,
    String? severity,
    double? cvssScore,
    String? publishedAt,
    String? updatedAt,
    List<String>? affectedProducts,
    List<String>? references,
    String? vendor,
    String? patchUrl,
  }) {
    return Incident(
      id: id ?? this.id,
      cveId: cveId ?? this.cveId,
      summary: summary ?? this.summary,
      severity: severity ?? this.severity,
      cvssScore: cvssScore ?? this.cvssScore,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      affectedProducts: affectedProducts ?? this.affectedProducts,
      references: references ?? this.references,
      vendor: vendor ?? this.vendor,
      patchUrl: patchUrl ?? this.patchUrl,
    );
  }

  /// Retourne true si le score CVSS est critique (≥ 9.0)
  bool get isCritical => cvssScore >= 9.0;

  @override
  String toString() =>
      'Incident(id: $id, cveId: $cveId, severity: $severity, cvssScore: $cvssScore)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Incident && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
