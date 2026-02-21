import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/threat.dart';
import '../models/incident.dart';

/// Service de notifications push locales pour Sentinelle
/// Utilise flutter_local_notifications pour Android et iOS
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Canaux de notification
  static const String _threatChannelId = 'sentinelle_threats';
  static const String _threatChannelName = 'Alertes Ransomware';
  static const String _incidentChannelId = 'sentinelle_incidents';
  static const String _incidentChannelName = 'Incidents CVE';
  static const String _generalChannelId = 'sentinelle_general';
  static const String _generalChannelName = 'Notifications Générales';

  // IDs de notification
  static const int _threatBaseId = 1000;
  static const int _incidentBaseId = 2000;
  static const int _generalId = 3000;

  /// Initialise le plugin de notifications
  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Créer les canaux Android
    if (Platform.isAndroid) {
      await _createAndroidChannels();
    }

    _initialized = true;
  }

  /// Crée les canaux de notification Android
  Future<void> _createAndroidChannels() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _threatChannelId,
        _threatChannelName,
        description: 'Alertes de nouvelles menaces ransomware détectées',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _incidentChannelId,
        _incidentChannelName,
        description: 'Nouveaux incidents CVE à haute sévérité',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _generalChannelId,
        _generalChannelName,
        description: 'Notifications générales Sentinelle',
        importance: Importance.defaultImportance,
      ),
    );
  }

  /// Callback lors du tap sur une notification
  void _onNotificationTapped(NotificationResponse response) {
    // Navigation vers l'écran concerné via payload
    // Géré par le router dans app.dart
  }

  /// Demande les permissions de notification (iOS)
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    // Android 13+ demande de permission
    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final result = await androidPlugin?.requestNotificationsPermission();
      return result ?? false;
    }
    return true;
  }

  /// Envoie une notification pour une nouvelle menace
  Future<void> notifyNewThreat(Threat threat) async {
    await _ensureInitialized();

    final severityLabel = _getSeverityLabel(threat.severity);
    final notifId = _threatBaseId + (threat.id.hashCode % 900);

    await _plugin.show(
      notifId,
      '⚠️ Nouvelle menace: $severityLabel',
      threat.name,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _threatChannelId,
          _threatChannelName,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            '${threat.name}\nFamille: ${threat.family}\nSignalé: ${threat.reportedAt}',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'threat:${threat.id}',
    );
  }

  /// Envoie une notification pour un nouvel incident CVE critique
  Future<void> notifyNewIncident(Incident incident) async {
    await _ensureInitialized();

    if (!_isCritical(incident.severity)) return;

    final notifId = _incidentBaseId + (incident.id.hashCode % 900);

    await _plugin.show(
      notifId,
      '🛡️ Incident critique: ${incident.cveId}',
      incident.summary,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _incidentChannelId,
          _incidentChannelName,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            '${incident.summary}\nCVSS: ${incident.cvssScore}',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'incident:${incident.id}',
    );
  }

  /// Envoie une notification générale
  Future<void> notifyGeneral({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _ensureInitialized();

    await _plugin.show(
      _generalId,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _generalChannelId,
          _generalChannelName,
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
      ),
      payload: payload,
    );
  }

  /// Annule toutes les notifications
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Annule une notification spécifique
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  // Helpers privés
  Future<void> _ensureInitialized() async {
    if (!_initialized) await initialize();
  }

  String _getSeverityLabel(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical': return 'CRITIQUE';
      case 'high': return 'HAUTE';
      case 'medium': return 'MOYENNE';
      case 'low': return 'FAIBLE';
      default: return severity.toUpperCase();
    }
  }

  bool _isCritical(String severity) {
    return severity.toLowerCase() == 'critical' ||
        severity.toLowerCase() == 'high';
  }
}
