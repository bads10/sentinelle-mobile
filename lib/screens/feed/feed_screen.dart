import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/rss_item.dart';
import '../../providers/rss_provider.dart';

/// Écran flux RSS cybersécurité
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _searchController = TextEditingController();
  String? _selectedSource;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(rssNotifierProvider);
    final items = feedState.items;

    // Filtrage
    final sources = items
        .map((i) => i.sourceName ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();

    final filtered = items.where((item) {
      final matchesSource =
          _selectedSource == null || (item.sourceName ?? '') == _selectedSource;
      final matchesSearch = _searchController.text.isEmpty ||
          item.title
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
      return matchesSource && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flux RSS Cybersécurité'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(rssNotifierProvider),
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
                hintText: 'Rechercher un article...',
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
          // Filtres par source
          if (sources.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Toutes'),
                    selected: _selectedSource == null,
                    onSelected: (_) =>
                        setState(() => _selectedSource = null),
                  ),
                  const SizedBox(width: 8),
                  ...sources.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(s),
                        selected: _selectedSource == s,
                        onSelected: (_) => setState(
                          () => _selectedSource =
                              _selectedSource == s ? null : s,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          // Liste des articles
          Expanded(
            child: feedState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : feedState.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error,
                                color: Colors.red, size: 48),
                            const SizedBox(height: 8),
                            Text('Erreur: ${feedState.error}'),
                            TextButton(
                              onPressed: () =>
                                  ref.invalidate(rssNotifierProvider),
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                    : filtered.isEmpty
                        ? const Center(
                            child: Text('Aucun article correspondant'),
                          )
                        : RefreshIndicator(
                            onRefresh: () async =>
                                ref.invalidate(rssNotifierProvider),
                            child: ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                return _RssCard(item: filtered[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _RssCard extends StatelessWidget {
  final RssItem item;
  const _RssCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source et date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.sourceName ?? '',
                    style: const TextStyle(
                        color: Colors.green, fontSize: 11),
                  ),
                ),
                if (item.publishedAt.isNotEmpty)
                  Text(
                    item.publishedAt,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Titre
            Text(
              item.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Description
            if (item.description != null &&
                item.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                item.description!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // Tags
            if (item.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: item.tags
                    .take(3)
                    .map(
                      (tag) => Chip(
                        label: Text(tag,
                            style: const TextStyle(fontSize: 10)),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
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
}
