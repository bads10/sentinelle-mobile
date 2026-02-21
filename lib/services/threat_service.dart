import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';
import '../models/threat.dart';
import 'api_service.dart';

/// Reponse paginee pour les menaces
class ThreatsResponse {
  final List<Threat> items;
  final int total;
  final int page;
  final int pageSize;

  const ThreatsResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory ThreatsResponse.fromJson(Map<String, dynamic> json) {
    return ThreatsResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => Threat.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
    );
  }
}

/// Provider du service Threats
final threatServiceProvider = Provider<ThreatService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ThreatService(apiService);
});

/// Service pour les menaces/ransomware
class ThreatService {
  final ApiService _apiService;
  ThreatService(this._apiService);

  /// Recupere la liste des menaces avec pagination et filtres
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
      final response = await _apiService.dio.get(
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

  /// Recupere le detail d'une menace par son ID
  Future<Threat> getThreatById(String id) async {
    try {
      final response = await _apiService.dio.get(ApiConstants.threatById(id));
      return Threat.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          ApiException(message: e.message ?? 'Erreur inconnue', statusCode: 500);
    }
  }

  /// Recupere les menaces critiques recentes
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
