import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/incident.dart';
import '../../providers/incident_provider.dart';

/// Écran détail d'un incident CVE - style article de presse
class IncidentDetailScreen extends ConsumerWidget {
  final String incidentId;

  const IncidentDetailScreen({super.key, required this.incidentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentAsync = ref.watch(incidentDetailProvider(incidentId));

    return incidentAsync.when(
      data: (incident) => _IncidentDetailContent(incident: incident),
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

class _IncidentDetailContent extends StatelessWidget {
  final Incident incident;

  const _IncidentDetailContent({required this.incident});

  @override
  Widget build(BuildContext context) {
    final score = incident.cvssScore;
    final color = AppTheme.cvssColor(score);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ──
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
                        // CVE ID + CVSS badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              color: AppTheme.categoryIncident,
                              child: Text(
                                incident.cveId,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  fontFamily: 'Courier',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
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
                                        fontSize: 7,
                                        fontWeight: FontWeight.w700,
                                        color: color.withOpacity(0.7),
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Résumé - gros titre
                        Text(
                          incident.summary,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                height: 1.25,
                              ),
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
                            if (incident.vendor != null) ...[
                              const Text('  ·  ', style: TextStyle(color: AppTheme.textDisabled)),
                              Text(
                                incident.vendor!.toUpperCase(),
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

          SliverToBoxAdapter(child: Container(height: 8, color: AppTheme.backgroundDark)),

          // ── Métriques ──
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.surfaceDark,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(title: 'MÉTRIQUES'),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'SCORE CVSS', value: score.toStringAsFixed(1), valueColor: color),
                  _InfoRow(label: 'SÉVÉRITÉ', value: incident.severity.toUpperCase()),
                  _InfoRow(label: 'PUBLIÉ LE', value: incident.publishedAt),
                  if (incident.updatedAt.isNotEmpty)
                    _InfoRow(label: 'MIS À JOUR', value: incident.updatedAt),
                  if (incident.vendor != null)
                    _InfoRow(label: 'FOURNISSEUR', value: incident.vendor!),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(child: Container(height: 8, color: AppTheme.backgroundDark)),

          // ── Produits affectés ──
          if (incident.affectedProducts.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                color: AppTheme.surfaceDark,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'PRODUITS AFFECTÉS'),
                    const SizedBox(height: 10),
                    ...incident.affectedProducts.map((p) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  color: AppTheme.textDisabled,
                                  shape: BoxShape.circle,
                                ),
                                margin: const EdgeInsets.only(right: 10),
                              ),
                              Expanded(
                                child: Text(
                                  p,
                                  style: const TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),

          // ── Patch URL ──
          if (incident.patchUrl != null) ...[
            SliverToBoxAdapter(child: Container(height: 8, color: AppTheme.backgroundDark)),
            SliverToBoxAdapter(
              child: Container(
                color: AppTheme.surfaceDark,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'CORRECTIF'),
                    const SizedBox(height: 10),
                    Text(
                      incident.patchUrl!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.categoryNews,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ── Références ──
          if (incident.references.isNotEmpty) ...[
            SliverToBoxAdapter(child: Container(height: 8, color: AppTheme.backgroundDark)),
            SliverToBoxAdapter(
              child: Container(
                color: AppTheme.surfaceDark,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'RÉFÉRENCES'),
                    const SizedBox(height: 10),
                    ...incident.references.map((ref) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text(
                            ref,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.categoryNews,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )),
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
          color: AppTheme.categoryIncident,
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
