import 'package:freezed_annotation/freezed_annotation.dart';

part 'rss_item.freezed.dart';
part 'rss_item.g.dart';

/// Modèle d'un article RSS cybersécurité
@freezed
class RssItem with _$RssItem {
  const factory RssItem({
    required String id,
    required String title,
    required String link,
    required DateTime publishedAt,
    String? description,
    String? content,
    String? author,
    String? sourceName,             // Krebs on Security, The Hacker News, etc.
    String? sourceUrl,
    String? imageUrl,
    List<String>? tags,
    List<String>? categories,
    @Default(false) bool isRead,
    @Default(false) bool isBookmarked,
  }) = _RssItem;

  factory RssItem.fromJson(Map<String, dynamic> json) =>
      _$RssItemFromJson(json);
}

/// Réponse paginée de l'API pour le flux RSS
@freezed
class FeedResponse with _$FeedResponse {
  const factory FeedResponse({
    required List<RssItem> items,
    required int total,
    required int page,
    required int pageSize,
    required bool hasMore,
    DateTime? lastUpdated,
  }) = _FeedResponse;

  factory FeedResponse.fromJson(Map<String, dynamic> json) =>
      _$FeedResponseFromJson(json);
}
