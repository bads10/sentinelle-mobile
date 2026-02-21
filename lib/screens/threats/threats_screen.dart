import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/threat.dart';
import '../../providers/threat_provider.dart';

/// Écran liste des menaces ransomware
class ThreatsScreen extends ConsumerStatefulWidget {
  const ThreatsScreen({super.key});

  @override
  ConsumerState<ThreatsScreen> createState() => _ThreatsScreenState();
}

class _ThreatsScreenState extends ConsumerState<ThreatsScreen> {
  final _searchController = TextEditingController();
  String? _selectedSeverity;

  final List<String> _severities = ['critical', 'high', 'medium', 'low'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final threatState = ref.watch(threatNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menaces Ransomware'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(threatNotifierProvider.notifier).loadThreats(refresh: true),
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
                hintText: 'Rechercher une menace...',
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
          // Filtres de sévérité
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Tous'),
                  selected: _selectedSeverity == null,
                  onSelected: (_) => setState(() => _selectedSeverity = null),
                ),
                const SizedBox(width: 8),
                ..._severities.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(s.toUpperCase()),
                      selected: _selectedSeverity == s,
                      onSelected: (_) => setState(
                        () => _selectedSeverity = _selectedSeverity == s ? null : s,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Liste des menaces
          Expanded(
            child: Builder(
              builder: (context) {
                if (threatState.isLoading && threatState.threats.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (threatState.error != null && threatState.threats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 48),
                        const SizedBox(height: 8),
                        Text('Erreur: ${threatState.error}'),
                        TextButton(
                          onPressed: () => ref.read(threatNotifierProvider.notifier).loadThreats(refresh: true),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }
                final filtered = threatState.threats.where((t) {
                  final matchesSeverity = _selectedSeverity == null ||
                      t.severity == _selectedSeverity;
                  final matchesSearch = _searchController.text.isEmpty ||
                      t.name.toLowerCase()
                          .contains(_searchController.text.toLowerCase());
                  return matchesSeverity && matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('Aucune menace correspondante'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.read(threatNotifierProvider.notifier).loadThreats(refresh: true),
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final threat = filtered[index];
                      return _ThreatCard(
                        threat: threat,
                        onTap: () => context.push('/threats/${threat.id}'),
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

class _ThreatCard extends StatelessWidget {
  final Threat threat;
  final VoidCallback onTap;

  const _ThreatCard({required this.threat, required this.onTap});

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.bug_report, color: color),
        ),
        title: Text(
          threat.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(threat.family),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                threat.severity.toUpperCase(),
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        trailing: threat.reportedAt.isNotEmpty
            ? Text(
                threat.reportedAt,
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        isThreeLine: true,
        onTap: onTap,
      ),
    );
  }
}
