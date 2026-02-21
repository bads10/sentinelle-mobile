import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

/// Service de cache local basé sur Hive
/// Gère la persistance offline des données Sentinelle
class CacheService {
  static const String _threatsBox = 'threats_cache';
  static const String _incidentsBox = 'incidents_cache';
  static const String _rssBox = 'rss_cache';
  static const String _statsBox = 'stats_cache';
  static const String _metaBox = 'cache_meta';

  // TTL en secondes
  static const int _defaultTtl = 300; // 5 minutes
  static const int _statsTtl = 60;    // 1 minute

  static CacheService? _instance;
  CacheService._internal();

  static CacheService get instance {
    _instance ??= CacheService._internal();
    return _instance!;
  }

  /// Initialise Hive et ouvre les boîtes
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_threatsBox);
    await Hive.openBox<String>(_incidentsBox);
    await Hive.openBox<String>(_rssBox);
    await Hive.openBox<String>(_statsBox);
    await Hive.openBox<String>(_metaBox);
  }

  /// Ferme toutes les boîtes
  static Future<void> close() async {
    await Hive.closeAllBoxes();
  }

  // ---- THREATS ----

  Future<void> cacheThreats(List<Map<String, dynamic>> threats) async {
    final box = Hive.box<String>(_threatsBox);
    await box.put('data', jsonEncode(threats));
    await _setTimestamp(_threatsBox);
  }

  Future<List<Map<String, dynamic>>?> getCachedThreats() async {
    if (!_isValid(_threatsBox)) return null;
    final box = Hive.box<String>(_threatsBox);
    final data = box.get('data');
    if (data == null) return null;
    final decoded = jsonDecode(data) as List;
    return decoded.cast<Map<String, dynamic>>();
  }

  // ---- INCIDENTS ----

  Future<void> cacheIncidents(List<Map<String, dynamic>> incidents) async {
    final box = Hive.box<String>(_incidentsBox);
    await box.put('data', jsonEncode(incidents));
    await _setTimestamp(_incidentsBox);
  }

  Future<List<Map<String, dynamic>>?> getCachedIncidents() async {
    if (!_isValid(_incidentsBox)) return null;
    final box = Hive.box<String>(_incidentsBox);
    final data = box.get('data');
    if (data == null) return null;
    final decoded = jsonDecode(data) as List;
    return decoded.cast<Map<String, dynamic>>();
  }

  // ---- RSS FEED ----

  Future<void> cacheRssFeed(List<Map<String, dynamic>> items) async {
    final box = Hive.box<String>(_rssBox);
    await box.put('data', jsonEncode(items));
    await _setTimestamp(_rssBox);
  }

  Future<List<Map<String, dynamic>>?> getCachedRssFeed() async {
    if (!_isValid(_rssBox)) return null;
    final box = Hive.box<String>(_rssBox);
    final data = box.get('data');
    if (data == null) return null;
    final decoded = jsonDecode(data) as List;
    return decoded.cast<Map<String, dynamic>>();
  }

  // ---- STATS ----

  Future<void> cacheStats(Map<String, dynamic> stats) async {
    final box = Hive.box<String>(_statsBox);
    await box.put('data', jsonEncode(stats));
    await _setTimestamp(_statsBox, ttl: _statsTtl);
  }

  Future<Map<String, dynamic>?> getCachedStats() async {
    if (!_isValid(_statsBox, ttl: _statsTtl)) return null;
    final box = Hive.box<String>(_statsBox);
    final data = box.get('data');
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  // ---- UTILITAIRES ----

  Future<void> clearAll() async {
    await Hive.box<String>(_threatsBox).clear();
    await Hive.box<String>(_incidentsBox).clear();
    await Hive.box<String>(_rssBox).clear();
    await Hive.box<String>(_statsBox).clear();
    await Hive.box<String>(_metaBox).clear();
  }

  Future<void> clearThreats() async {
    await Hive.box<String>(_threatsBox).clear();
    await Hive.box<String>(_metaBox).delete('${_threatsBox}_ts');
  }

  bool isCacheValid(String key) => _isValid(key);

  Future<void> _setTimestamp(String key, {int ttl = _defaultTtl}) async {
    final box = Hive.box<String>(_metaBox);
    final expiry = DateTime.now()
        .add(Duration(seconds: ttl))
        .millisecondsSinceEpoch
        .toString();
    await box.put('${key}_ts', expiry);
  }

  bool _isValid(String key, {int ttl = _defaultTtl}) {
    final box = Hive.box<String>(_metaBox);
    final expiryStr = box.get('${key}_ts');
    if (expiryStr == null) return false;
    final expiry = int.tryParse(expiryStr);
    if (expiry == null) return false;
    return DateTime.now().millisecondsSinceEpoch < expiry;
  }
}
