import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_theme.dart';
import '../models/rss_item.dart';

/// Carte RSS - style article de journal/magazine
class RssCard extends StatelessWidget {
  final RssItem item;
  final VoidCallback? onTap;

  const RssCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _launchUrl(item.link),
      child: Container(
        color: AppTheme.backgroundDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contenu principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source
                  if (item.sourceName != null && item.sourceName!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        item.sourceName!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.categoryNews,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  // Titre article
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      height: 1.35,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Description
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Meta + tags
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 10, color: AppTheme.textDisabled),
                      const SizedBox(width: 3),
                      Text(
                        item.publishedAt,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textDisabled,
                        ),
                      ),
                      if (item.tags.isNotEmpty) ...[
                        const Text(
                          '  ·  ',
                          style: TextStyle(color: AppTheme.textDisabled, fontSize: 10),
                        ),
                        Expanded(
                          child: Text(
                            item.tags.take(2).join(', ').toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppTheme.textDisabled,
                              letterSpacing: 0.4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Thumbnail placeholder
            const SizedBox(width: 12),
            Container(
              width: 68,
              height: 68,
              color: AppTheme.cardDark,
              child: const Icon(
                Icons.article_outlined,
                color: AppTheme.dividerColor,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
