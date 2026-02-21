import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelle_mobile/models/incident.dart';

void main() {
  group('Incident model', () {
    test('fromJson crée un Incident valide', () {
      final json = {
        'id': 'inc001',
        'cve_id': 'CVE-2024-1234',
        'summary': 'Buffer overflow dans libssl',
        'severity': 'critical',
        'cvss_score': 9.8,
        'published_at': '2024-01-20T12:00:00Z',
        'updated_at': '2024-01-21T08:00:00Z',
        'affected_products': ['openssl', 'ubuntu'],
        'references': ['https://nvd.nist.gov/vuln/detail/CVE-2024-1234'],
      };

      final incident = Incident.fromJson(json);

      expect(incident.id, equals('inc001'));
      expect(incident.cveId, equals('CVE-2024-1234'));
      expect(incident.summary, equals('Buffer overflow dans libssl'));
      expect(incident.severity, equals('critical'));
      expect(incident.cvssScore, equals(9.8));
      expect(incident.affectedProducts, contains('openssl'));
    });

    test('toJson retourne un Map valide', () {
      final incident = Incident(
        id: 'inc002',
        cveId: 'CVE-2024-5678',
        summary: 'SQL injection',
        severity: 'high',
        cvssScore: 8.1,
        publishedAt: '2024-02-10T00:00:00Z',
        updatedAt: '2024-02-10T00:00:00Z',
        affectedProducts: ['mysql'],
        references: [],
      );

      final json = incident.toJson();

      expect(json['id'], equals('inc002'));
      expect(json['cve_id'], equals('CVE-2024-5678'));
      expect(json['cvss_score'], equals(8.1));
    });

    test('isCritical retourne true pour score CVSS >= 9.0', () {
      final critical = Incident(
        id: '1', cveId: 'CVE-2024-0001',
        summary: '', severity: 'critical',
        cvssScore: 9.5,
        publishedAt: '', updatedAt: '',
        affectedProducts: [], references: [],
      );
      final medium = critical.copyWith(cvssScore: 6.5, severity: 'medium');

      expect(critical.isCritical, isTrue);
      expect(medium.isCritical, isFalse);
    });

    test('copyWith fonctionne correctement', () {
      final original = Incident(
        id: '1', cveId: 'CVE-2024-0002',
        summary: 'Original', severity: 'low',
        cvssScore: 3.0,
        publishedAt: '2024-01-01', updatedAt: '2024-01-01',
        affectedProducts: [], references: [],
      );

      final updated = original.copyWith(
        summary: 'Updated',
        cvssScore: 9.9,
        severity: 'critical',
      );

      expect(updated.id, equals('1'));
      expect(updated.summary, equals('Updated'));
      expect(updated.cvssScore, equals(9.9));
      expect(updated.severity, equals('critical'));
    });
  });
}
