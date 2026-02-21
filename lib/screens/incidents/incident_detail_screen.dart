import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/incident.dart';
import '../../providers/incident_provider.dart';

/// Écran détail d'un incident CVE
class IncidentDetailScreen extends ConsumerWidget {
  final String incidentId;

  const IncidentDetailScreen({super.key, required this.incidentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentAsync = ref.watch(incidentDetailProvider(incidentId));

    return incidentAsync.when(
      data: (incident) => _IncidentDetailContent(incident: incident),
      loading: () => Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: Center(child: Text('Erreur: ${e.toString()}')),
      ),
    );
  }
}

class _IncidentDetailContent extends StatelessWidget {
  final Incident incident;

  const _IncidentDetailContent({required this.incident});

  Color _cvssColor(double? score) {
    if (score == null) return Colors.grey;
    if (score >= 9.0) return Colors.red;
    if (score >= 7.0) return Colors.orange;
    if (score >= 4.0) return Colors.yellow.shade700;
    return Colors.green;
  }

  String _cvssLabel(double? score) {
    if (score == null) return 'Non évalué';
    if (score >= 9.0) return 'CRITIQUE';
    if (score >= 7.0) return 'HAUTE';
    if (score >= 4.0) return 'MOYENNE';
    return 'FAIBLE';
  }

  @override
  Widget build(BuildContext context) {
    final color = _cvssColor(incident.cvssScore);

    return Scaffold(
      appBar: AppBar(
        title: Text(incident.cveId),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score CVSS
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: color.withOpacity(0.2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            incident.cvssScore?.toStringAsFixed(1) ?? '?',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'CVSS',
                            style: TextStyle(color: color, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            incident.cveId,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _cvssLabel(incident.cvssScore),
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Description / Résumé
            _buildSection(
              context,
              title: 'Description',
              children: [
                Text(
                  incident.summary,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Métriques
            _buildSection(
              context,
              title: 'Métriques',
              children: [
                if (incident.cvssScore != null)
                  _buildInfoRow(context, 'Score CVSS', incident.cvssScore!.toStringAsFixed(1)),
                _buildInfoRow(context, 'Sévérité', incident.severity),
                if (incident.publishedAt.isNotEmpty)
                  _buildInfoRow(context, 'Publié le', incident.publishedAt),
                if (incident.updatedAt.isNotEmpty)
                  _buildInfoRow(context, 'Mis à jour', incident.updatedAt),
                if (incident.vendor != null)
                  _buildInfoRow(context, 'Fournisseur', incident.vendor!),
                if (incident.patchUrl != null)
                  _buildInfoRow(context, 'Patch URL', incident.patchUrl!),
              ],
            ),
            const SizedBox(height: 16),
            // Produits affectés
            if (incident.affectedProducts.isNotEmpty) ...[
              _buildSection(
                context,
                title: 'Produits affectés',
                children: incident.affectedProducts
                    .map((p) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              const Icon(Icons.chevron_right, size: 16),
                              const SizedBox(width: 4),
                              Text(p, style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
            // Références
            if (incident.references.isNotEmpty) ...[
              Text(
                'Références',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              ...incident.references.map(
                (ref) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    ref,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
