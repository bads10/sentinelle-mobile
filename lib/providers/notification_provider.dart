import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../models/threat.dart';
import '../models/incident.dart';

// Provider pour le NotificationService singleton
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// État des notifications
class NotificationState {
  final bool permissionsGranted;
  final bool isInitialized;
  final int unreadThreats;
  final int unreadIncidents;

  const NotificationState({
    this.permissionsGranted = false,
    this.isInitialized = false,
    this.unreadThreats = 0,
    this.unreadIncidents = 0,
  });

  NotificationState copyWith({
    bool? permissionsGranted,
    bool? isInitialized,
    int? unreadThreats,
    int? unreadIncidents,
  }) {
    return NotificationState(
      permissionsGranted: permissionsGranted ?? this.permissionsGranted,
      isInitialized: isInitialized ?? this.isInitialized,
      unreadThreats: unreadThreats ?? this.unreadThreats,
      unreadIncidents: unreadIncidents ?? this.unreadIncidents,
    );
  }

  int get totalUnread => unreadThreats + unreadIncidents;
}

// Notifier pour gérer les notifications
class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _service;

  NotificationNotifier(this._service) : super(const NotificationState());

  /// Initialise et demande les permissions
  Future<void> initialize() async {
    await _service.initialize();
    final granted = await _service.requestPermissions();
    state = state.copyWith(
      isInitialized: true,
      permissionsGranted: granted,
    );
  }

  /// Notifie une nouvelle menace ransomware
  Future<void> notifyThreat(Threat threat) async {
    if (!state.isInitialized) await initialize();
    if (!state.permissionsGranted) return;

    await _service.notifyNewThreat(threat);
    state = state.copyWith(unreadThreats: state.unreadThreats + 1);
  }

  /// Notifie un nouvel incident CVE critique
  Future<void> notifyIncident(Incident incident) async {
    if (!state.isInitialized) await initialize();
    if (!state.permissionsGranted) return;

    await _service.notifyNewIncident(incident);
    final isCritical = incident.severity.toLowerCase() == 'critical' ||
        incident.severity.toLowerCase() == 'high';
    if (isCritical) {
      state = state.copyWith(unreadIncidents: state.unreadIncidents + 1);
    }
  }

  /// Envoie une notification générale
  Future<void> notifyGeneral({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!state.isInitialized) await initialize();
    if (!state.permissionsGranted) return;

    await _service.notifyGeneral(title: title, body: body, payload: payload);
  }

  /// Annule toutes les notifications et remet à zéro les compteurs
  Future<void> clearAll() async {
    await _service.cancelAll();
    state = state.copyWith(unreadThreats: 0, unreadIncidents: 0);
  }

  /// Marque toutes les menaces comme lues
  void markThreatsRead() {
    state = state.copyWith(unreadThreats: 0);
  }

  /// Marque tous les incidents comme lus
  void markIncidentsRead() {
    state = state.copyWith(unreadIncidents: 0);
  }
}

// Provider principal des notifications
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationNotifier(service);
});

// Providers dérivés
final notificationsPermittedProvider = Provider<bool>((ref) {
  return ref.watch(notificationProvider).permissionsGranted;
});

final unreadThreatsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).unreadThreats;
});

final unreadIncidentsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).unreadIncidents;
});

final totalUnreadProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).totalUnread;
});
