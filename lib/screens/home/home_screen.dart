import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/threat_provider.dart';
import '../../providers/incident_provider.dart';
import '../../providers/rss_provider.dart';

/// Écran principal de l'application Sentinelle
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threatsState = ref.watch(threatNotifierProvider);
    final incidentsState = ref.watch(incidentNotifierProvider);
    final feedState = ref.watch(rssNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentinelle'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(threatNotifierProvider);
              ref.invalidate(incidentNotifierProvider);
              ref.invalidate(rssNotifierProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(threatNotifierProvider);
          ref.invalidate(incidentNotifierProvider);
          ref.invalidate(rssNotifierProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de bienvenue
              _buildHeader(context),
              const SizedBox(height: 24),
              // Section statistiques rapides
              _buildQuickStats(context, threatsState, incidentsState),
              const SizedBox(height: 24),
              // Section menaces récentes
              _buildSection(
                context,
                title: 'Menaces ransomware récentes',
                icon: Icons.bug_report,
                color: Colors.red,
                onSeeAll: () => Navigator.pushNamed(context, '/threats'),
                child: threatsState.isLoading
                    ? const _LoadingIndicator()
                    : threatsState.error != null
                        ? _ErrorState(message: threatsState.error!)
                        : threatsState.threats.isEmpty
                            ? const _EmptyState(
                                message: 'Aucune menace détectée')
                            : Column(
                                children: threatsState.threats
                                    .take(3)
                                    .map(
                                      (t) => _ThreatListTile(
                                        name: t.name,
                                        severity: t.severity,
                                        reportedAt: t.reportedAt,
                                      ),
                                    )
                                    .toList(),
                              ),
              ),
              const SizedBox(height: 24),
              // Section incidents CVE
              _buildSection(
                context,
                title: 'Incidents CVE récents',
                icon: Icons.warning_amber,
                color: Colors.orange,
                onSeeAll: () => Navigator.pushNamed(context, '/incidents'),
                child: incidentsState.isLoading
                    ? const _LoadingIndicator()
                    : incidentsState.error != null
                        ? _ErrorState(message: incidentsState.error!)
                        : incidentsState.incidents.isEmpty
                            ? const _EmptyState(
                                message: 'Aucun incident récent')
                            : Column(
                                children: incidentsState.incidents
                                    .take(3)
                                    .map(
                                      (i) => _IncidentListTile(
                                        cveId: i.cveId,
                                        summary: i.summary,
                                        cvssScore: i.cvssScore,
                                      ),
                                    )
                                    .toList(),
                              ),
              ),
              const SizedBox(height: 24),
              // Section flux RSS
              _buildSection(
                context,
                title: 'Actualités cybersécurité',
                icon: Icons.rss_feed,
                color: Colors.green,
                onSeeAll: () => Navigator.pushNamed(context, '/feed'),
                child: feedState.isLoading
                    ? const _LoadingIndicator()
                    : feedState.error != null
                        ? _ErrorState(message: feedState.error!)
                        : feedState.items.isEmpty
                            ? const _EmptyState(
                                message: 'Aucun article disponible')
                            : Column(
                                children: feedState.items
                                    .take(3)
                                    .map(
                                      (item) => _RssListTile(
                                        title: item.title,
                                        source: item.sourceName ?? '',
                                        publishedAt: item.publishedAt,
                                      ),
                                    )
                                    .toList(),
                              ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tableau de bord',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          'Surveillance cybersécurité en temps réel',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    ThreatState threats,
    IncidentState incidents,
  ) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Menaces',
            value: threats.isLoading
                ? '...'
                : threats.threats.length.toString(),
            icon: Icons.bug_report,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Incidents',
            value: incidents.isLoading
                ? '...'
                : incidents.incidents.length.toString(),
            icon: Icons.warning_amber,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Statut',
            value: 'En ligne',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onSeeAll,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            TextButton(
              onPressed: onSeeAll,
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

// Widgets privés de l'écran home
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ThreatListTile extends StatelessWidget {
  final String name;
  final String severity;
  final String reportedAt;
  const _ThreatListTile({
    required this.name,
    required this.severity,
    required this.reportedAt,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.bug_report, color: Colors.red),
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(severity.toUpperCase()),
      trailing: reportedAt.isNotEmpty
          ? Text(
              reportedAt,
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
    );
  }
}

class _IncidentListTile extends StatelessWidget {
  final String cveId;
  final String summary;
  final double cvssScore;
  const _IncidentListTile({
    required this.cveId,
    required this.summary,
    required this.cvssScore,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.warning_amber, color: Colors.orange),
      title: Text(cveId),
      subtitle:
          Text(summary, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(
        cvssScore.toStringAsFixed(1),
        style: const TextStyle(
            color: Colors.orange, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _RssListTile extends StatelessWidget {
  final String title;
  final String source;
  final String publishedAt;
  const _RssListTile({
    required this.title,
    required this.source,
    required this.publishedAt,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.article, color: Colors.green),
      title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(source),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(message,
            style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Erreur: $message',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
