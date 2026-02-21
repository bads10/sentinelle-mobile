import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelle_mobile/providers/notification_provider.dart';

void main() {
  group('NotificationState', () {
    test('état initial est correct', () {
      const state = NotificationState();

      expect(state.permissionsGranted, isFalse);
      expect(state.isInitialized, isFalse);
      expect(state.unreadThreats, equals(0));
      expect(state.unreadIncidents, equals(0));
      expect(state.totalUnread, equals(0));
    });

    test('copyWith modifie les champs spécifiés', () {
      const original = NotificationState();
      final updated = original.copyWith(
        permissionsGranted: true,
        isInitialized: true,
        unreadThreats: 5,
        unreadIncidents: 3,
      );

      expect(updated.permissionsGranted, isTrue);
      expect(updated.isInitialized, isTrue);
      expect(updated.unreadThreats, equals(5));
      expect(updated.unreadIncidents, equals(3));
      expect(updated.totalUnread, equals(8));
    });

    test('copyWith préserve les champs non modifiés', () {
      const state = NotificationState(
        permissionsGranted: true,
        isInitialized: true,
        unreadThreats: 2,
        unreadIncidents: 1,
      );

      final updated = state.copyWith(unreadThreats: 10);

      expect(updated.permissionsGranted, isTrue);
      expect(updated.isInitialized, isTrue);
      expect(updated.unreadThreats, equals(10));
      expect(updated.unreadIncidents, equals(1)); // préservé
    });

    test('totalUnread est la somme des non-lus', () {
      const state = NotificationState(
        unreadThreats: 7,
        unreadIncidents: 4,
      );

      expect(state.totalUnread, equals(11));
    });

    test('remise à zéro via copyWith', () {
      const state = NotificationState(
        unreadThreats: 5,
        unreadIncidents: 3,
      );

      final cleared = state.copyWith(unreadThreats: 0, unreadIncidents: 0);

      expect(cleared.totalUnread, equals(0));
    });
  });

  group('NotificationState const constructor', () {
    test('supporte la comparaison', () {
      const state1 = NotificationState();
      const state2 = NotificationState();

      // Les états par défaut sont égaux
      expect(state1.permissionsGranted, equals(state2.permissionsGranted));
      expect(state1.totalUnread, equals(state2.totalUnread));
    });
  });
}
