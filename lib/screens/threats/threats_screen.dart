import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/threat.dart';
import '../../providers/threat_provider.dart';

/// Écran liste des menaces - style Breaking News
class ThreatsScreen extends ConsumerStatefulWidget {
  const ThreatsScreen({super.key});

  @override
  ConsumerState<ThreatsScreen> createState() => _ThreatsScreenState();
}

class _ThreatsScreenState extends ConsumerState<ThreatsScreen> {
  final _searchController = TextEditingController();
  String? _selectedSeverity;

  final List<({String value, String label, Color color})> _severityFilters = [
    (value: 'critical', label: 'CRITIQUE', color: AppTheme.severityCritical),
    (value: 'high', label: 'ÉLEVÉ', color: AppTheme.severityHigh),
    (value: 'medium', label: 'MOYEN', color: AppTheme.severityMedium),
    (value: 'low', label: 'FAIBLE', color: AppTheme.severityLow),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final threatState = ref.watch(threatNotifierProvider);

    final filtered = threatState.threats.where((t) {
      final matchesSeverity = _selectedSeverity == null || t.severity == _selectedSeverity;
      final matchesSearch = _searchController.text.isEmpty ||
          t.name.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesSeverity && matchesSearch;
    }).toList();

    // Stats par sévérité
    final criticalCount = threatState.threats.where((t) => t.severity == 'critical').length;
    final highCount = threatState.threats.where((t) => t.severity == 'high').length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ── AppBar breaking news ──
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
                  color: AppTheme.categoryThreat,
                  margin: const EdgeInsets.only(right: 8),
                ),
                const Text(
                  'MENACES',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                if (!threatState.isLoading)
                  Text(
                    '${filtered.length} résultats',
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
                onPressed: () => ref.read(threatNotifierProvider.notifier).loadThreats(refresh: true),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppTheme.categoryThreat),
            ),
          ),

          // ── Ticker stats menaces ──
          if (!threatState.isLoading && threatState.threats.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                color: AppTheme.surfaceDark,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    if (criticalCount > 0)
                      _AlertCounter(
                        count: criticalCount,
                        label: 'CRITIQUES',
                        color: AppTheme.severityCritical,
                      ),
                    if (criticalCount > 0 && highCount > 0)
                      Container(
                        width: 1,
                        height: 28,
                        color: AppTheme.dividerColor,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    if (highCount > 0)
                      _AlertCounter(
                        count: highCount,
                        label: 'ÉLEVÉES',
                        color: AppTheme.severityHigh,
                      ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      color: AppTheme.severityLow.withOpacity(0.15),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppTheme.severityLow,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'EN DIRECT',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.severityLow,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Recherche ──
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.surfaceDark,
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Rechercher une menace ransomware...',
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

          // ── Filtres sévérité ──
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.backgroundDark,
              height: 38,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    _SeverityTab(
                      label: 'TOUTES',
                      selected: _selectedSeverity == null,
                      color: AppTheme.textSecondary,
                      onTap: () => setState(() => _selectedSeverity = null),
                    ),
                    const SizedBox(width: 6),
                    ..._severityFilters.map((f) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _SeverityTab(
                            label: f.label,
                            selected: _selectedSeverity == f.value,
                            color: f.color,
                            onTap: () => setState(
                              () => _selectedSeverity = _selectedSeverity == f.value ? null : f.value,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(height: 1, color: AppTheme.dividerColor),
          ),
        ],
        body: Builder(
          builder: (context) {
            if (threatState.isLoading && threatState.threats.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryRed,
                  strokeWidth: 2,
                ),
              );
            }

            if (threatState.error != null && threatState.threats.isEmpty) {
              return _ErrorView(
                message: threatState.error!,
                onRetry: () => ref.read(threatNotifierProvider.notifier).loadThreats(refresh: true),
              );
            }

            if (filtered.isEmpty) {
              return const _EmptyView(message: 'Aucune menace correspondante');
            }

            return RefreshIndicator(
              color: AppTheme.primaryRed,
              backgroundColor: AppTheme.surfaceDark,
              onRefresh: () async =>
                  ref.read(threatNotifierProvider.notifier).loadThreats(refresh: true),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final threat = filtered[index];
                  // Premier élément en hero si pas de filtre
                  if (index == 0 && _searchController.text.isEmpty && _selectedSeverity == null) {
                    return _HeroThreatCard(
                      threat: threat,
                      onTap: () => context.push('/threats/${threat.id}'),
                    );
                  }
                  return _ThreatListItem(
                    threat: threat,
                    showDivider: index < filtered.length - 1,
                    onTap: () => context.push('/threats/${threat.id}'),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Counter d'alerte ──────────────────────────────────────────────────────────
class _AlertCounter extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _AlertCounter({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDisabled,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

// ── Onglet sévérité ───────────────────────────────────────────────────────────
class _SeverityTab extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _SeverityTab({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.transparent,
          border: Border.all(
            color: selected ? color : AppTheme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: selected ? color : AppTheme.textDisabled,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

// ── Hero Threat Card (premier résultat) ───────────────────────────────────────
class _HeroThreatCard extends StatelessWidget {
  final Threat threat;
  final VoidCallback onTap;

  const _HeroThreatCard({required this.threat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.severityColor(threat.severity);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppTheme.surfaceDark,
        margin: const EdgeInsets.only(bottom: 8),
        child: Stack(
          children: [
            // Barre colorée gauche
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 4, color: color),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge + icône
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        color: color,
                        child: Text(
                          AppTheme.severityLabel(threat.severity),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.dividerColor),
                        ),
                        child: Text(
                          'RANSOMWARE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDisabled,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Nom de la menace - titre principal
                  Text(
                    threat.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Famille
                  Text(
                    threat.family,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Meta row
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 11, color: AppTheme.textDisabled),
                      const SizedBox(width: 4),
                      Text(
                        threat.reportedAt.isNotEmpty ? threat.reportedAt : 'Date inconnue',
                        style: const TextStyle(fontSize: 10, color: AppTheme.textDisabled),
                      ),
                      const Spacer(),
                      Text(
                        'VOIR DÉTAILS →',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: color,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Threat List Item (compact) ────────────────────────────────────────────────
class _ThreatListItem extends StatelessWidget {
  final Threat threat;
  final bool showDivider;
  final VoidCallback onTap;

  const _ThreatListItem({
    required this.threat,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.severityColor(threat.severity);
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            color: AppTheme.backgroundDark,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indicateur couleur
                Container(
                  width: 3,
                  height: 48,
                  color: color,
                  margin: const EdgeInsets.only(right: 12),
                ),
                // Contenu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom
                      Text(
                        threat.name,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        threat.family,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        threat.reportedAt,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textDisabled,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge sévérité
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: color.withOpacity(0.5)),
                  ),
                  child: Text(
                    AppTheme.severityLabel(threat.severity),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 0.5,
                    ),
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
}

// ── Error/Empty states ────────────────────────────────────────────────────────
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
                'ERREUR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

class _EmptyView extends StatelessWidget {
  final String message;
  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: AppTheme.textDisabled, fontSize: 14),
      ),
    );
  }
}
