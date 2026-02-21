import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../models/rss_item.dart';
import '../../providers/rss_provider.dart';

/// Écran flux RSS - style magazine news
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _searchController = TextEditingController();
  String? _selectedSource;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(rssNotifierProvider);
    final items = feedState.items;

    final sources = items
        .map((i) => i.sourceName ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final filtered = items.where((item) {
      final matchesSource =
          _selectedSource == null || (item.sourceName ?? '') == _selectedSource;
      final matchesSearch = _searchController.text.isEmpty ||
          item.title.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesSource && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ── AppBar journal ──
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            backgroundColor: AppTheme.backgroundDark,
            title: Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  color: AppTheme.categoryNews,
                  margin: const EdgeInsets.only(right: 8),
                ),
                const Text(
                  'ACTUALITÉS',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Text(
                  '${filtered.length} articles',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textDisabled,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.textSecondary, size: 20),
                onPressed: () => ref.read(rssNotifierProvider.notifier).loadFeed(refresh: true),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppTheme.categoryNews),
            ),
          ),

          // ── Barre de recherche ──
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.surfaceDark,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Rechercher dans les actualités...',
                  prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.textDisabled),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 16, color: AppTheme.textDisabled),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),

          // ── Filtres sources - style onglets journal ──
          if (sources.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                color: AppTheme.backgroundDark,
                height: 38,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      _SourceTab(
                        label: 'TOUTES',
                        selected: _selectedSource == null,
                        onTap: () => setState(() => _selectedSource = null),
                        color: AppTheme.categoryNews,
                      ),
                      const SizedBox(width: 6),
                      ...sources.map((s) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _SourceTab(
                              label: s.toUpperCase(),
                              selected: _selectedSource == s,
                              onTap: () => setState(
                                () => _selectedSource = _selectedSource == s ? null : s,
                              ),
                              color: AppTheme.categoryNews,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),

          // Ligne séparatrice
          SliverToBoxAdapter(
            child: Container(height: 1, color: AppTheme.dividerColor),
          ),
        ],
        body: feedState.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryRed,
                  strokeWidth: 2,
                ),
              )
            : feedState.error != null
                ? _ErrorView(
                    message: feedState.error!,
                    onRetry: () => ref.read(rssNotifierProvider.notifier).loadFeed(refresh: true),
                  )
                : filtered.isEmpty
                    ? const _EmptyView()
                    : RefreshIndicator(
                        color: AppTheme.primaryRed,
                        backgroundColor: AppTheme.surfaceDark,
                        onRefresh: () async => ref.read(rssNotifierProvider.notifier).loadFeed(refresh: true),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            // Premier article : format Hero
                            if (index == 0 && _searchController.text.isEmpty) {
                              return _HeroArticleCard(item: filtered[0]);
                            }
                            return _ArticleListItem(
                              item: filtered[index],
                              showDivider: index < filtered.length - 1,
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}

// ── Source Tab ────────────────────────────────────────────────────────────────
class _SourceTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _SourceTab({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          border: Border.all(
            color: selected ? color : AppTheme.dividerColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : AppTheme.textDisabled,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

// ── Hero Article Card (premier résultat) ──────────────────────────────────────
class _HeroArticleCard extends StatelessWidget {
  final RssItem item;
  const _HeroArticleCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchUrl(item.link),
      child: Container(
        color: AppTheme.surfaceDark,
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder image area avec gradient
            Container(
              height: 180,
              color: AppTheme.cardDark,
              child: Stack(
                children: [
                  // Background pattern
                  Positioned.fill(
                    child: CustomPaint(painter: _NewspaperPatternPainter()),
                  ),
                  // Overlay gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppTheme.surfaceDark.withOpacity(0.95),
                          ],
                          stops: const [0.3, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Source badge en haut à gauche
                  if (item.sourceName != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        color: AppTheme.categoryNews,
                        child: Text(
                          item.sourceName!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  // Titre en bas de l'image
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Description + meta
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.description != null && item.description!.isNotEmpty)
                    Text(
                      item.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 11, color: AppTheme.textDisabled),
                      const SizedBox(width: 4),
                      Text(
                        item.publishedAt,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textDisabled,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.open_in_new, size: 12, color: AppTheme.categoryNews),
                      const SizedBox(width: 3),
                      const Text(
                        'LIRE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.categoryNews,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  // Tags
                  if (item.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: item.tags.take(4).map((tag) => _Tag(label: tag)).toList(),
                    ),
                  ],
                ],
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

// ── Article List Item (compact - style journal) ───────────────────────────────
class _ArticleListItem extends StatelessWidget {
  final RssItem item;
  final bool showDivider;

  const _ArticleListItem({required this.item, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _launchUrl(item.link),
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
                      // Source tag
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
                      // Titre
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontFamily: 'Georgia',
                            ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Meta
                      Row(
                        children: [
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
                                item.tags.take(2).join(', '),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textDisabled,
                                ),
                                overflow: TextOverflow.ellipsis,
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
                  width: 72,
                  height: 72,
                  color: AppTheme.cardDark,
                  child: const Icon(
                    Icons.article_outlined,
                    color: AppTheme.dividerColor,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(height: 1, color: AppTheme.dividerColor),
          ),
      ],
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

// ── Tag ───────────────────────────────────────────────────────────────────────
class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 9,
          color: AppTheme.textDisabled,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Newspaper pattern background ──────────────────────────────────────────────
class _NewspaperPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.dividerColor.withOpacity(0.4)
      ..strokeWidth = 1;

    const spacing = 24.0;
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width * 0.7, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Error View ────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              color: AppTheme.primaryRed,
              child: const Text(
                'ERREUR DE CONNEXION',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(border: Border.all(color: AppTheme.primaryRed)),
                child: const Text(
                  'RÉESSAYER',
                  style: TextStyle(
                    color: AppTheme.primaryRed,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty View ────────────────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Aucun article trouvé',
        style: TextStyle(color: AppTheme.textDisabled, fontSize: 14),
      ),
    );
  }
}
