import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/threat.dart';
import '../../providers/threat_provider.dart';

/// Écran détail d'une menace ransomware - style article de presse
class ThreatDetailScreen extends ConsumerWidget {
  final String threatId;

  const ThreatDetailScreen({super.key, required this.threatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threatAsync = ref.watch(threatDetailProvider(threatId));

    return threatAsync.when(
      data: (threat) => _ThreatDetailContent(threat: threat),
      loading: () => Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundDark,
          leading: const BackButton(color: AppTheme.textPrimary),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryRed, strokeWidth: 2),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundDark,
          leading: const BackButton(color: AppTheme.textPrimary),
        ),
        body: Center(
          child: Text(
            'Erreur: ${e.toString()}',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _ThreatDetailContent extends StatelessWidget {
  final Threat threat;

  const _ThreatDetailContent({required this.threat});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.severityColor(threat.severity);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // ── AppBar style article ──
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.backgroundDark,
            leading: const BackButton(color: AppTheme.textPrimary),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: color),
            ),
          ),

          // ── Hero header ──
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.surfaceDark,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 4, color: color),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badges
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
                              child: const Text(
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
                        const SizedBox(height: 12),
                        // Nom - gros titre
                        Text(
                          threat.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 6),
                        // Famille
                        Text(
                          threat.family,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Meta
                        Row(
                          children: [
                            if (threat.reportedAt.isNotEmpty) ...[
                              const Icon(Icons.schedule, size: 11, color: AppTheme.textDisabled),
                              const SizedBox(width: 4),
                              Text(
                                threat.reportedAt,
                                style: const TextStyle(fontSize: 10, color: AppTheme.textDisabled),
                              ),
                            ],
                            if (threat.source != null) ...[
                              const Text('  ·  ', style: TextStyle(color: AppTheme.textDisabled)),
                              Text(
                                threat.source!.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDisabled,
                                  letterSpacing: 0.5,
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
            ),
          ),

          // Espaceur
          SliverToBoxAdapter(
            child: Container(height: 8, color: AppTheme.backgroundDark),
          ),

          // ── Description ──
          if (threat.description.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                color: AppTheme.surfaceDark,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'DESCRIPTION'),
                    const SizedBox(height: 10),
                    Text(
                      threat.description,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: Container(height: 8, color: AppTheme.backgroundDark),
          ),

          // ── Informations techniques ──
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.surfaceDark,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(title: 'INFORMATIONS TECHNIQUES'),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'IDENTIFIANT', value: threat.id),
                  _InfoRow(label: 'FAMILLE', value: threat.family),
                  _InfoRow(label: 'ACTIF', value: threat.isActive ? 'OUI' : 'NON',
                      valueColor: threat.isActive ? AppTheme.severityCritical : AppTheme.severityLow),
                  _InfoRow(label: 'INDICATEURS', value: '${threat.iocCount}'),
                  if (threat.source != null)
                    _InfoRow(label: 'SOURCE', value: threat.source!),
                ],
              ),
            ),
          ),

          // ── Tags ──
          if (threat.tags.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Container(height: 8, color: AppTheme.backgroundDark),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: AppTheme.surfaceDark,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'TAGS'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: threat.tags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.dividerColor),
                        ),
                        child: Text(
                          tag.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppTheme.textDisabled,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 2,
          height: 12,
          color: AppTheme.primaryRed,
          margin: const EdgeInsets.only(right: 7),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppTheme.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDisabled,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 13,
                color: valueColor ?? AppTheme.textPrimary,
                fontWeight: valueColor != null ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
