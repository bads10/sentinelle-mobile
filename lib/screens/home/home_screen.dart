import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/threat_provider.dart';
import '../../providers/incident_provider.dart';
import '../../providers/rss_provider.dart';

/// Écran principal - style News App
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threatsState = ref.watch(threatNotifierProvider);
    final incidentsState = ref.watch(incidentNotifierProvider);
    final feedState = ref.watch(rssNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: RefreshIndicator(
        color: AppTheme.primaryRed,
        backgroundColor: AppTheme.surfaceDark,
        onRefresh: () async {
          await Future.wait([
            ref.read(threatNotifierProvider.notifier).loadThreats(refresh: true),
            ref.read(incidentNotifierProvider.notifier).loadIncidents(refresh: true),
            ref.read(rssNotifierProvider.notifier).loadFeed(refresh: true),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── AppBar style journal ──
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: AppTheme.backgroundDark,
              expandedHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          color: AppTheme.primaryRed,
                          margin: const EdgeInsets.only(right: 8),
                        ),
                        const Text(
                          'SENTINELLE',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppTheme.textSecondary, size: 20),
                  onPressed: () {
                    ref.read(threatNotifierProvider.notifier).loadThreats(refresh: true);
                    ref.read(incidentNotifierProvider.notifier).loadIncidents(refresh: true);
                    ref.read(rssNotifierProvider.notifier).loadFeed(refresh: true);
                  },
                ),
              ],
            ),

            // ── Ligne rouge éditoriale ──
            SliverToBoxAdapter(
              child: Container(
                height: 1,
                color: AppTheme.primaryRed,
              ),
            ),

            // ── Ticker BREAKING NEWS ──
            SliverToBoxAdapter(
              child: _BreakingNewsBanner(threatsState: threatsState),
            ),

            // ── Statistiques rapides - style compteurs de presse ──
            SliverToBoxAdapter(
              child: _NewsStatsBar(
                threatsState: threatsState,
                incidentsState: incidentsState,
              ),
            ),

            SliverToBoxAdapter(
              child: Container(height: 1, color: AppTheme.dividerColor),
            ),

            // ── Section : Menaces récentes ──
            SliverToBoxAdapter(
              child: _SectionHeader(
                category: 'MENACES',
                categoryColor: AppTheme.categoryThreat,
                onSeeAll: () => context.go('/threats'),
              ),
            ),
            SliverToBoxAdapter(
              child: _ThreatsSection(threatsState: threatsState),
            ),

            SliverToBoxAdapter(
              child: Container(height: 8, color: AppTheme.surfaceDark),
            ),

            // ── Section : Incidents CVE ──
            SliverToBoxAdapter(
              child: _SectionHeader(
                category: 'INCIDENTS CVE',
                categoryColor: AppTheme.categoryIncident,
                onSeeAll: () => context.go('/incidents'),
              ),
            ),
            SliverToBoxAdapter(
              child: _IncidentsSection(incidentsState: incidentsState),
            ),

            SliverToBoxAdapter(
              child: Container(height: 8, color: AppTheme.surfaceDark),
            ),

            // ── Section : Actualités cybersécurité ──
            SliverToBoxAdapter(
              child: _SectionHeader(
                category: 'ACTUALITÉS',
                categoryColor: AppTheme.categoryNews,
                onSeeAll: () => context.go('/feed'),
              ),
            ),
            SliverToBoxAdapter(
              child: _FeedSection(feedState: feedState),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ── Breaking News Banner ──────────────────────────────────────────────────────
class _BreakingNewsBanner extends StatelessWidget {
  final ThreatState threatsState;
  const _BreakingNewsBanner({required this.threatsState});

  @override
  Widget build(BuildContext context) {
    final criticalCount = threatsState.threats
        .where((t) => t.severity.toLowerCase() == 'critical')
        .length;
    if (criticalCount == 0) return const SizedBox.shrink();

    return Container(
      color: AppTheme.primaryRed,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            color: Colors.white,
            child: const Text(
              'ALERTE',
              style: TextStyle(
                color: AppTheme.primaryRed,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$criticalCount menace${criticalCount > 1 ? 's' : ''} critique${criticalCount > 1 ? 's' : ''} détectée${criticalCount > 1 ? 's' : ''}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white, size: 18),
        ],
      ),
    );
  }
}

// ── Barre statistiques ────────────────────────────────────────────────────────
class _NewsStatsBar extends StatelessWidget {
  final ThreatState threatsState;
  final IncidentState incidentsState;

  const _NewsStatsBar({
    required this.threatsState,
    required this.incidentsState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceDark,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _StatItem(
            value: threatsState.isLoading ? '--' : threatsState.threats.length.toString(),
            label: 'MENACES',
            color: AppTheme.categoryThreat,
          ),
          _Separator(),
          _StatItem(
            value: incidentsState.isLoading ? '--' : incidentsState.incidents.length.toString(),
            label: 'CVE',
            color: AppTheme.categoryIncident,
          ),
          _Separator(),
          _StatItem(
            value: '•',
            label: 'EN DIRECT',
            color: AppTheme.severityLow,
            valueLarge: false,
            pulseValue: true,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool valueLarge;
  final bool pulseValue;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
    this.valueLarge = true,
    this.pulseValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: valueLarge ? 24 : 18,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDisabled,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppTheme.dividerColor,
    );
  }
}

// ── En-tête de section ────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String category;
  final Color categoryColor;
  final VoidCallback onSeeAll;

  const _SectionHeader({
    required this.category,
    required this.categoryColor,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundDark,
      padding: const EdgeInsets.fromLTRB(16, 20, 12, 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            color: categoryColor,
            margin: const EdgeInsets.only(right: 8),
          ),
          Text(
            category,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: categoryColor,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'VOIR TOUT →',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDisabled,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Menaces ───────────────────────────────────────────────────────────
class _ThreatsSection extends StatelessWidget {
  final ThreatState threatsState;
  const _ThreatsSection({required this.threatsState});

  @override
  Widget build(BuildContext context) {
    if (threatsState.isLoading) return const _NewsLoader();
    if (threatsState.error != null) return _NewsError(message: threatsState.error!);
    if (threatsState.threats.isEmpty) return const _NewsEmpty(message: 'Aucune menace détectée');

    final threats = threatsState.threats.take(4).toList();

    return Column(
      children: [
        // Hero threat (première - grande)
        _HeroThreatCard(
          name: threats[0].name,
          severity: threats[0].severity,
          family: threats[0].family,
          reportedAt: threats[0].reportedAt,
        ),
        if (threats.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: threats
                  .skip(1)
                  .map((t) => _CompactNewsRow(
                        title: t.name,
                        badge: t.severity.toUpperCase(),
                        badgeColor: AppTheme.severityColor(t.severity),
                        meta: t.reportedAt,
                        separator: threats.indexOf(t) < threats.length - 1,
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _HeroThreatCard extends StatelessWidget {
  final String name;
  final String severity;
  final String family;
  final String reportedAt;

  const _HeroThreatCard({
    required this.name,
    required this.severity,
    required this.family,
    required this.reportedAt,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.severityColor(severity);
    return Container(
      color: AppTheme.surfaceDark,
      margin: const EdgeInsets.only(bottom: 1),
      child: Stack(
        children: [
          // Barre colorée sur la gauche
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 3, color: color),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge sévérité
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: color,
                  child: Text(
                    AppTheme.severityLabel(severity),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Titre principal
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        height: 1.2,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Meta
                Row(
                  children: [
                    Text(
                      family.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDisabled,
                        letterSpacing: 0.8,
                      ),
                    ),
                    if (reportedAt.isNotEmpty) ...[
                      const Text(
                        '  ·  ',
                        style: TextStyle(color: AppTheme.textDisabled, fontSize: 10),
                      ),
                      Text(
                        reportedAt,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textDisabled,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Incidents ─────────────────────────────────────────────────────────
class _IncidentsSection extends StatelessWidget {
  final IncidentState incidentsState;
  const _IncidentsSection({required this.incidentsState});

  @override
  Widget build(BuildContext context) {
    if (incidentsState.isLoading) return const _NewsLoader();
    if (incidentsState.error != null) return _NewsError(message: incidentsState.error!);
    if (incidentsState.incidents.isEmpty) return const _NewsEmpty(message: 'Aucun incident récent');

    final incidents = incidentsState.incidents.take(4).toList();

    return Container(
      color: AppTheme.surfaceDark,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: incidents
            .asMap()
            .entries
            .map((e) => _CompactNewsRow(
                  title: '${e.value.cveId} — ${e.value.summary}',
                  badge: 'CVSS ${e.value.cvssScore.toStringAsFixed(1)}',
                  badgeColor: AppTheme.cvssColor(e.value.cvssScore),
                  meta: e.value.publishedAt,
                  separator: e.key < incidents.length - 1,
                ))
            .toList(),
      ),
    );
  }
}

// ── Section Feed ──────────────────────────────────────────────────────────────
class _FeedSection extends StatelessWidget {
  final RssState feedState;
  const _FeedSection({required this.feedState});

  @override
  Widget build(BuildContext context) {
    if (feedState.isLoading) return const _NewsLoader();
    if (feedState.error != null) return _NewsError(message: feedState.error!);
    if (feedState.items.isEmpty) return const _NewsEmpty(message: 'Aucun article disponible');

    final items = feedState.items.take(5).toList();

    return Column(
      children: [
        // Premier article en hero
        _HeroNewsCard(
          title: items[0].title,
          source: items[0].sourceName ?? '',
          description: items[0].description,
          publishedAt: items[0].publishedAt,
        ),
        if (items.length > 1)
          Container(
            color: AppTheme.surfaceDark,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: items
                  .skip(1)
                  .map((item) => _CompactNewsRow(
                        title: item.title,
                        badge: (item.sourceName ?? '').toUpperCase(),
                        badgeColor: AppTheme.categoryNews,
                        meta: item.publishedAt,
                        separator: items.indexOf(item) < items.length - 1,
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _HeroNewsCard extends StatelessWidget {
  final String title;
  final String source;
  final String? description;
  final String publishedAt;

  const _HeroNewsCard({
    required this.title,
    required this.source,
    this.description,
    required this.publishedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceDark,
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source tag
          if (source.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: AppTheme.categoryNews,
              child: Text(
                source.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              description!,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            publishedAt,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textDisabled,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ligne d'article compact (style liste journal) ─────────────────────────────
class _CompactNewsRow extends StatelessWidget {
  final String title;
  final String badge;
  final Color badgeColor;
  final String meta;
  final bool separator;

  const _CompactNewsRow({
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.meta,
    this.separator = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meta,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: badgeColor.withOpacity(0.6)),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (separator)
          Container(height: 1, color: AppTheme.dividerColor),
      ],
    );
  }
}

// ── États ─────────────────────────────────────────────────────────────────────
class _NewsLoader extends StatelessWidget {
  const _NewsLoader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceDark,
      padding: const EdgeInsets.all(32),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryRed,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _NewsError extends StatelessWidget {
  final String message;
  const _NewsError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceDark,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.primaryRed, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsEmpty extends StatelessWidget {
  final String message;
  const _NewsEmpty({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceDark,
      padding: const EdgeInsets.all(20),
      child: Text(
        message,
        style: const TextStyle(color: AppTheme.textDisabled, fontSize: 12),
      ),
    );
  }
}
