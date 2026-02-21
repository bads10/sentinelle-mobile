import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/threat.dart';
import '../../providers/threat_provider.dart';

/// Écran détail d'une menace ransomware
class ThreatDetailScreen extends ConsumerWidget {
  final String threatId;

  const ThreatDetailScreen({super.key, required this.threatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threatAsync = ref.watch(threatDetailProvider(threatId));

    return threatAsync.when(
      data: (threat) => _ThreatDetailContent(threat: threat),
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

class _ThreatDetailContent extends StatelessWidget {
  final Threat threat;

  const _ThreatDetailContent({required this.threat});

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow.shade700;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(threat.severity);

    return Scaffold(
      appBar: AppBar(
        title: Text(threat.name),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de la menace
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: color.withOpacity(0.2),
                      child: Icon(Icons.bug_report, color: color, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            threat.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            threat.family,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              threat.severity.toUpperCase(),
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
            // Informations générales
            _buildSection(
              context,
              title: 'Informations',
              children: [
                _buildInfoRow(context, 'ID', threat.id),
                if (threat.reportedAt.isNotEmpty)
                  _buildInfoRow(context, 'Signalement', threat.reportedAt),
                if (threat.source != null)
                  _buildInfoRow(context, 'Source', threat.source!),
                if (threat.sourceUrl != null)
                  _buildInfoRow(context, 'URL Source', threat.sourceUrl!),
                _buildInfoRow(context, 'IoC Count', threat.iocCount.toString()),
                _buildInfoRow(context, 'Actif', threat.isActive ? 'Oui' : 'Non'),
              ],
            ),
            const SizedBox(height: 16),
            // Description
            if (threat.description.isNotEmpty) ...[
              _buildSection(
                context,
                title: 'Description',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      threat.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            // Tags
            if (threat.tags.isNotEmpty) ...[
              Text(
                'Tags',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: threat.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 12)),
                        backgroundColor: color.withOpacity(0.1),
                      ),
                    )
                    .toList(),
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
