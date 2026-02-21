import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelle_mobile/models/threat.dart';

void main() {
  group('Threat model', () {
    test('fromJson crée un Threat valide', () {
      final json = {
        'id': 'abc123',
        'name': 'LockBit 3.0',
        'family': 'LockBit',
        'severity': 'critical',
        'description': 'Ransomware à double extorsion',
        'reported_at': '2024-01-15T10:30:00Z',
        'tags': ['ransomware', 'lockbit'],
        'ioc_count': 42,
        'is_active': true,
      };

      final threat = Threat.fromJson(json);

      expect(threat.id, equals('abc123'));
      expect(threat.name, equals('LockBit 3.0'));
      expect(threat.family, equals('LockBit'));
      expect(threat.severity, equals('critical'));
      expect(threat.description, equals('Ransomware à double extorsion'));
      expect(threat.iocCount, equals(42));
      expect(threat.isActive, isTrue);
      expect(threat.tags, contains('ransomware'));
    });

    test('toJson retourne un Map valide', () {
      final threat = Threat(
        id: 'xyz789',
        name: 'BlackCat',
        family: 'ALPHV',
        severity: 'high',
        description: 'Ransomware en Rust',
        reportedAt: '2024-02-01T08:00:00Z',
        tags: ['ransomware', 'rust'],
        iocCount: 15,
        isActive: true,
      );

      final json = threat.toJson();

      expect(json['id'], equals('xyz789'));
      expect(json['name'], equals('BlackCat'));
      expect(json['severity'], equals('high'));
      expect(json['ioc_count'], equals(15));
    });

    test('copyWith crée une copie modifiée', () {
      final original = Threat(
        id: '1',
        name: 'Original',
        family: 'TestFamily',
        severity: 'low',
        description: 'desc',
        reportedAt: '2024-01-01T00:00:00Z',
        tags: [],
        iocCount: 0,
        isActive: false,
      );

      final copy = original.copyWith(severity: 'critical', isActive: true);

      expect(copy.id, equals('1'));
      expect(copy.name, equals('Original'));
      expect(copy.severity, equals('critical'));
      expect(copy.isActive, isTrue);
    });

    test('isCritical retourne true pour severity critical ou high', () {
      final critical = Threat(
        id: '1', name: 'Test', family: 'F',
        severity: 'critical', description: '',
        reportedAt: '', tags: [], iocCount: 0, isActive: true,
      );
      final high = critical.copyWith(severity: 'high');
      final low = critical.copyWith(severity: 'low');

      expect(critical.isCritical, isTrue);
      expect(high.isCritical, isTrue);
      expect(low.isCritical, isFalse);
    });
  });
}
