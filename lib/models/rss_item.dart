/// Modèle d'un article RSS cybersécurité
class RssItem {
  final String id;
  final String title;
  final String link;
  final String publishedAt;
  final String? description;
  final String? content;
  final String? author;
  final String? sourceName; // Krebs on Security, The Hacker News, etc.
  final String? sourceUrl;
  final String? imageUrl;
  final List<String> tags;
  final List<String> categories;
  final bool isRead;
  final bool isBookmarked;

  const RssItem({
    required this.id,
    required this.title,
    required this.link,
    required this.publishedAt,
    this.description,
    this.content,
    this.author,
    this.sourceName,
    this.sourceUrl,
    this.imageUrl,
    this.tags = const [],
    this.categories = const [],
    this.isRead = false,
    this.isBookmarked = false,
  });

  factory RssItem.fromJson(Map<String, dynamic> json) {
    return RssItem(
      id: json['id'] as String,
      title: json['title'] as String,
      link: json['link'] as String,
      publishedAt: json['published_at'] as String? ?? '',
      description: json['description'] as String?,
      content: json['content'] as String?,
      author: json['author'] as String?,
      sourceName: json['source_name'] as String?,
      sourceUrl: json['source_url'] as String?,
      imageUrl: json['image_url'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      categories:
          (json['categories'] as List<dynamic>?)?.cast<String>() ?? [],
      isRead: json['is_read'] as bool? ?? false,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'link': link,
      'published_at': publishedAt,
      if (description != null) 'description': description,
      if (content != null) 'content': content,
      if (author != null) 'author': author,
      if (sourceName != null) 'source_name': sourceName,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (imageUrl != null) 'image_url': imageUrl,
      'tags': tags,
      'categories': categories,
      'is_read': isRead,
      'is_bookmarked': isBookmarked,
    };
  }

  RssItem copyWith({
    String? id,
    String? title,
    String? link,
    String? publishedAt,
    String? description,
    String? content,
    String? author,
    String? sourceName,
    String? sourceUrl,
    String? imageUrl,
    List<String>? tags,
    List<String>? categories,
    bool? isRead,
    bool? isBookmarked,
  }) {
    return RssItem(
      id: id ?? this.id,
      title: title ?? this.title,
      link: link ?? this.link,
      publishedAt: publishedAt ?? this.publishedAt,
      description: description ?? this.description,
      content: content ?? this.content,
      author: author ?? this.author,
      sourceName: sourceName ?? this.sourceName,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      categories: categories ?? this.categories,
      isRead: isRead ?? this.isRead,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  @override
  String toString() => 'RssItem(id: $id, title: $title, source: $sourceName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RssItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
