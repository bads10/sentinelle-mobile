import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/incident.dart';
import '../../providers/incident_provider.dart';

/// Écran liste des incidents CVE - style News Feed
class IncidentsScreen extends ConsumerStatefulWidget {
  const IncidentsScreen({super.key});

  @override
  ConsumerState<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends ConsumerState<IncidentsScreen> {
  final _searchController = TextEditingController();
  double _minCvssScore = 0.0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final incidentState = ref.watch(incidentNotifierProvider);

    final filtered = incidentState.incidents.where((i) {
      final matchesSearch = _searchController.text.isEmpty ||
          i.cveId.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          i.summary.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesCvss = _minCvssScore == 0.0 || i.cvssScore >= _minCvssScore;
      return matchesSearch && matchesCvss;
    }).toList();

    // Stats CVSS
    final criticalCount = incidentState.incidents.where((i) => i.cvssScore >= 9.0).length;
    final highCount = incidentState.incidents.where((i) => i.cvssScore >= 7.0 && i.cvssScore < 9.0).length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ── AppBar ──
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
                  color: AppTheme.categoryIncident,
                  margin: const EdgeInsets.only(right: 8),
                ),
                const Text(
                  'INCIDENTS CVE',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                if (!incidentState.isLoading)
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
                onPressed: () => ref.read(incidentNotifierProvider.notifier).loadIncidents(refresh: true),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppTheme.categoryIncident),
            ),
          ),

          // ── Stats CVSS ──
          if (!incidentState.isLoading && incidentState.incidents.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                color: AppTheme.surfaceDark,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    if (criticalCount > 0)
                      _CvssCounter(
                        count: criticalCount,
                        label: 'CRITIQUES ≥9.0',
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
                      _CvssCounter(
                        count: highCount,
                        label: 'ÉLEVÉES ≥7.0',
                        color: AppTheme.severityHigh,
                      ),
                    const Spacer(),
                    Text(
                      '${incidentState.incidents.length} CVE',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDisabled,
                        letterSpacing: 0.5,
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
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Rechercher CVE-XXXX-XXXXX...',
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

          // ── Filtre score CVSS ──
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.surfaceDark,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'CVSS MIN',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDisabled,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                        activeTrackColor: AppTheme.categoryIncident,
                        inactiveTrackColor: AppTheme.dividerColor,
                        thumbColor: AppTheme.categoryIncident,
                        overlayColor: AppTheme.categoryIncident.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: _minCvssScore,
                        min: 0.0,
                        max: 10.0,
                        divisions: 20,
                        onChanged: (val) => setState(() => _minCvssScore = val),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 32,
                    child: Text(
                      _minCvssScore == 0.0 ? 'Tous' : _minCvssScore.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _minCvssScore > 0 ? AppTheme.categoryIncident : AppTheme.textDisabled,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(height: 1, color: AppTheme.dividerColor),
          ),
        ],
        body: Builder(
          builder: (context) {
            if (incidentState.isLoading && incidentState.incidents.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryRed,
                  strokeWidth: 2,
                ),
              );
            }

            if (incidentState.error != null && incidentState.incidents.isEmpty) {
              return _ErrorView(
                message: incidentState.error!,
                onRetry: () => ref.read(incidentNotifierProvider.notifier).loadIncidents(refresh: true),
              );
            }

            if (filtered.isEmpty) {
              return const _EmptyView(message: 'Aucun incident correspondant');
            }

            return RefreshIndicator(
              color: AppTheme.primaryRed,
              backgroundColor: AppTheme.surfaceDark,
              onRefresh: () async =>
                  ref.read(incidentNotifierProvider.notifier).loadIncidents(refresh: true),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final incident = filtered[index];
                  if (index == 0 && _searchController.text.isEmpty && _minCvssScore == 0.0) {
                    return _HeroIncidentCard(
                      incident: incident,
                      onTap: () => context.push('/incidents/${incident.id}'),
                    );
                  }
                  return _IncidentListItem(
                    incident: incident,
                    showDivider: index < filtered.length - 1,
                    onTap: () => context.push('/incidents/${incident.id}'),
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

// ── CVSS Counter ──────────────────────────────────────────────────────────────
class _CvssCounter extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _CvssCounter({required this.count, required this.label, required this.color});

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
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ── Hero Incident Card ────────────────────────────────────────────────────────
class _HeroIncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback onTap;

  const _HeroIncidentCard({required this.incident, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final score = incident.cvssScore;
    final color = AppTheme.cvssColor(score);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppTheme.surfaceDark,
        margin: const EdgeInsets.only(bottom: 8),
        child: Stack(
          children: [
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
                  // CVE ID + Score CVSS
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // CVE ID badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        color: AppTheme.categoryIncident,
                        child: Text(
                          incident.cveId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Score CVSS
                      _CvssScoreBadge(score: score, color: color),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Résumé - titre principal
                  Text(
                    incident.summary,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Meta
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 11, color: AppTheme.textDisabled),
                      const SizedBox(width: 4),
                      Text(
                        incident.publishedAt,
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

// ── Incident List Item ────────────────────────────────────────────────────────
class _IncidentListItem extends StatelessWidget {
  final Incident incident;
  final bool showDivider;
  final VoidCallback onTap;

  const _IncidentListItem({
    required this.incident,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final score = incident.cvssScore;
    final color = AppTheme.cvssColor(score);

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
                // Barre CVSS colorée
                Container(
                  width: 3,
                  height: 56,
                  color: color,
                  margin: const EdgeInsets.only(right: 12),
                ),
                // Contenu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CVE ID
                      Text(
                        incident.cveId,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.categoryIncident,
                          letterSpacing: 0.8,
                          fontFamily: 'Courier',
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Summary
                      Text(
                        incident.summary,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        incident.publishedAt,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textDisabled,
                        ),
                      ),
                    ],
                  ),
                ),
                // Score CVSS
                const SizedBox(width: 10),
                _CvssScoreBadge(score: score, color: color),
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

// ── CVSS Score Badge ──────────────────────────────────────────────────────────
class _CvssScoreBadge extends StatelessWidget {
  final double score;
  final Color color;

  const _CvssScoreBadge({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            score.toStringAsFixed(1),
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1,
            ),
          ),
          Text(
            'CVSS',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: color.withOpacity(0.7),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
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
