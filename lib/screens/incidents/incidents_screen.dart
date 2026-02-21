import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/incident.dart';
import '../../providers/incident_provider.dart';

/// Écran liste des incidents CVE
class IncidentsScreen extends ConsumerStatefulWidget {
  const IncidentsScreen({super.key});

  @override
  ConsumerState<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends ConsumerState<IncidentsScreen> {
  final _searchController = TextEditingController();
  String? _selectedSeverity;
  double _minCvssScore = 0.0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final incidentState = ref.watch(incidentNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidents CVE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(incidentNotifierProvider.notifier).loadIncidents(refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un CVE...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          // Filtre score CVSS minimum
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Text('Score CVSS min: ${_minCvssScore.toStringAsFixed(1)}'),
                Expanded(
                  child: Slider(
                    value: _minCvssScore,
                    min: 0.0,
                    max: 10.0,
                    divisions: 20,
                    label: _minCvssScore.toStringAsFixed(1),
                    onChanged: (val) => setState(() => _minCvssScore = val),
                  ),
                ),
              ],
            ),
          ),
          // Liste des incidents
          Expanded(
            child: Builder(
              builder: (context) {
                if (incidentState.isLoading && incidentState.incidents.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (incidentState.error != null && incidentState.incidents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 48),
                        const SizedBox(height: 8),
                        Text('Erreur: ${incidentState.error}'),
                        TextButton(
                          onPressed: () => ref.read(incidentNotifierProvider.notifier).loadIncidents(refresh: true),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }
                final filtered = incidentState.incidents.where((i) {
                  final matchesSearch = _searchController.text.isEmpty ||
                      i.cveId.toLowerCase()
                          .contains(_searchController.text.toLowerCase()) ||
                      i.summary.toLowerCase()
                          .contains(_searchController.text.toLowerCase());
                  final matchesCvss = _minCvssScore == 0.0 ||
                      (i.cvssScore != null && i.cvssScore! >= _minCvssScore);
                  return matchesSearch && matchesCvss;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('Aucun incident correspondant'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.read(incidentNotifierProvider.notifier).loadIncidents(refresh: true),
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final incident = filtered[index];
                      return _IncidentCard(
                        incident: incident,
                        onTap: () => context.push('/incidents/${incident.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback onTap;

  const _IncidentCard({required this.incident, required this.onTap});

  Color _cvssColor(double? score) {
    if (score == null) return Colors.grey;
    if (score >= 9.0) return Colors.red;
    if (score >= 7.0) return Colors.orange;
    if (score >= 4.0) return Colors.yellow.shade700;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final color = _cvssColor(incident.cvssScore);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            incident.cvssScore?.toStringAsFixed(1) ?? '?',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          incident.cveId,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          incident.summary,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: incident.publishedAt.isNotEmpty
            ? Text(
                incident.publishedAt,
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
