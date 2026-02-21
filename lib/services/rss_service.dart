import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rss_item.dart';
import '../core/constants/api_constants.dart';
import 'api_service.dart';

/// Reponse paginee pour les articles RSS
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

/// Provider du service RSS
final rssServiceProvider = Provider<RssService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return RssService(apiService);
});

/// Service pour les flux RSS cybersecurite via l'API Sentinelle
class RssService {
  final ApiService _apiService;
  RssService(this._apiService);

  /// Recupere le flux RSS pagine
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
          ApiException(message: e.message ?? 'Erreur inconnue', statusCode: 500);
    }
  }

  /// Recupere le detail d'un article RSS par ID
  Future<RssItem> getFeedItemById(String id) async {
    try {
      final response = await _apiService.dio.get(
        '${ApiConstants.feed}/$id',
      );
      return RssItem.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          ApiException(message: e.message ?? 'Erreur inconnue', statusCode: 500);
    }
  }

  /// Recupere les derniers articles RSS (tri par date)
  Future<List<RssItem>> getLatestArticles({int limit = 20}) async {
    final response = await getFeed(
      pageSize: limit,
    );
    return response.items;
  }

  /// Recupere les articles par source (ex: 'krebs', 'hackernews')
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
