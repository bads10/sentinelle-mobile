import 'package:dio/dio.dart';
import '../models/rss_item.dart';
import '../core/constants/api_constants.dart';
import 'api_service.dart';

/// Réponse paginée pour les articles RSS
class RssFeedResponse {
  final List<RssItem> items;
  final int total;
  final int page;
  final int pageSize;

  const RssFeedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory RssFeedResponse.fromJson(Map<String, dynamic> json) {
    return RssFeedResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => RssItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
    );
  }
}

/// Service pour les flux RSS cybersécurité via l'API Sentinelle
class RssService {
  final ApiService _apiService;

  RssService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Récupère le flux RSS paginé
  Future<RssFeedResponse> getFeed({
    int page = 1,
    int pageSize = 20,
    String? source,
    String? search,
    String? category,
  }) async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.feed,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (source != null) 'source': source,
          if (search != null) 'search': search,
          if (category != null) 'category': category,
        },
      );
      return RssFeedResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          ApiException(message: e.message ?? 'Erreur inconnue');
    }
  }

  /// Récupère le détail d'un article RSS par ID
  Future<RssItem> getFeedItemById(String id) async {
    try {
      final response = await _apiService.dio.get(
        '${ApiConstants.feed}/$id',
      );
      return RssItem.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          ApiException(message: e.message ?? 'Erreur inconnue');
    }
  }

  /// Récupère les derniers articles RSS (tri par date)
  Future<List<RssItem>> getLatestArticles({int limit = 20}) async {
    final response = await getFeed(
      pageSize: limit,
    );
    return response.items;
  }

  /// Récupère les articles par source (ex: 'krebs', 'hackernews')
  Future<List<RssItem>> getArticlesBySource(String source, {int limit = 20}) async {
    final response = await getFeed(
      source: source,
      pageSize: limit,
    );
    return response.items;
  }

  /// Recherche dans les articles RSS
  Future<List<RssItem>> searchArticles(String query, {int limit = 20}) async {
    final response = await getFeed(
      search: query,
      pageSize: limit,
    );
    return response.items;
  }
}
