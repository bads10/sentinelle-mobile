import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';
import '../models/threat.dart';
import 'api_service.dart';

/// Provider du service Threats
final threatServiceProvider = Provider<ThreatService>((ref) {
  final dio = ref.watch(dioProvider);
  return ThreatService(dio);
});

/// Service pour les menaces/ransomware
class ThreatService {
  final Dio _dio;

  ThreatService(this._dio);

  /// Récupère la liste des menaces avec pagination et filtres
  Future<ThreatsResponse> getThreats({
    int page = 1,
    int pageSize = 20,
    String? severity,
    String? type,
    String? search,
    String? sortBy,
    bool? sortDesc,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.threats,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (severity != null) 'severity': severity,
          if (type != null) 'type': type,
          if (search != null) 'search': search,
          if (sortBy != null) 'sort_by': sortBy,
          if (sortDesc != null) 'sort_desc': sortDesc,
        },
      );
      return ThreatsResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          ApiException(message: e.message ?? 'Erreur inconnue', statusCode: 500);
    }
  }

  /// Récupère le détail d'une menace par son ID
  Future<Threat> getThreatById(String id) async {
    try {
      final response = await _dio.get(ApiConstants.threatById(id));
      return Threat.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          ApiException(message: e.message ?? 'Erreur inconnue', statusCode: 500);
    }
  }

  /// Récupère les menaces critiques récentes
  Future<List<Threat>> getCriticalThreats({int limit = 5}) async {
    final response = await getThreats(
      severity: 'critical',
      pageSize: limit,
      sortBy: 'first_seen',
      sortDesc: true,
    );
    return response.items;
  }
}
