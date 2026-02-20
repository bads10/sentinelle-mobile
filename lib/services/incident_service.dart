import 'package:dio/dio.dart';
import '../models/incident.dart';
import '../core/constants/api_constants.dart';
import 'api_service.dart';

/// Réponse paginée pour les incidents CVE
class IncidentsResponse {
  final List<Incident> items;
  final int total;
  final int page;
  final int pageSize;

  const IncidentsResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory IncidentsResponse.fromJson(Map<String, dynamic> json) {
    return IncidentsResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => Incident.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
    );
  }
}

/// Service pour les incidents CVE via l'API Sentinelle
class IncidentService {
  final ApiService _apiService;

  IncidentService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Récupère la liste paginée des incidents CVE
  Future<IncidentsResponse> getIncidents({
    int page = 1,
    int pageSize = 20,
    String? severity,
    String? search,
    String? sortBy,
    bool? sortDesc,
  }) async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.incidents,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (severity != null) 'severity': severity,
          if (search != null) 'search': search,
          if (sortBy != null) 'sort_by': sortBy,
          if (sortDesc != null) 'sort_desc': sortDesc,
        },
      );
      return IncidentsResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          ApiException(message: e.message ?? 'Erreur inconnue');
    }
  }

  /// Récupère le détail d'un incident CVE par ID
  Future<Incident> getIncidentById(String id) async {
    try {
      final response = await _apiService.dio.get(
        '${ApiConstants.incidents}/$id',
      );
      return Incident.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          ApiException(message: e.message ?? 'Erreur inconnue');
    }
  }

  /// Récupère les incidents critiques récents
  Future<List<Incident>> getCriticalIncidents({int limit = 10}) async {
    final response = await getIncidents(
      severity: 'critical',
      pageSize: limit,
      sortBy: 'published_date',
      sortDesc: true,
    );
    return response.items;
  }

  /// Récupère les incidents par score CVSS minimum
  Future<List<Incident>> getIncidentsByCvssScore({
    double minScore = 7.0,
    int limit = 20,
  }) async {
    final response = await getIncidents(
      pageSize: limit,
      sortBy: 'cvss_score',
      sortDesc: true,
    );
    return response.items
        .where((i) => (i.cvssScore ?? 0.0) >= minScore)
        .toList();
  }
}
