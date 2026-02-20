import 'package:flutter/material.dart';
import '../../models/incident.dart';

/// Écran détail d'un incident CVE
class IncidentDetailScreen extends StatelessWidget {
  final Incident incident;

  const IncidentDetailScreen({super.key, required this.incident});

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

            // Description
            _buildSection(
              context,
              title: 'Description',
              children: [
                Text(
                  incident.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Métriques CVSS
            _buildSection(
              context,
              title: 'Métriques',
              children: [
                if (incident.cvssScore != null)
                  _buildInfoRow(context, 'Score CVSS', incident.cvssScore!.toStringAsFixed(1)),
                if (incident.cvssVector != null)
                  _buildInfoRow(context, 'Vecteur CVSS', incident.cvssVector!),
                if (incident.publishedDate != null)
                  _buildInfoRow(
                    context,
                    'Publié le',
                    '${incident.publishedDate!.day}/${incident.publishedDate!.month}/${incident.publishedDate!.year}',
                  ),
                if (incident.lastModifiedDate != null)
                  _buildInfoRow(
                    context,
                    'Modifié le',
                    '${incident.lastModifiedDate!.day}/${incident.lastModifiedDate!.month}/${incident.lastModifiedDate!.year}',
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Logiciels affectés
            if (incident.affectedSoftware != null && incident.affectedSoftware!.isNotEmpty) ...
              [
                _buildSection(
                  context,
                  title: 'Logiciels affectés',
                  children: incident.affectedSoftware!
                      .map((sw) => _buildInfoRow(context, sw['vendor'] ?? '', sw['product'] ?? ''))
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],

            // Références
            if (incident.references != null && incident.references!.isNotEmpty) ...
              [
                Text(
                  'Références',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Divider(),
                ...incident.references!.map(
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
