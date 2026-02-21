import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/threat_provider.dart';
import '../../providers/incident_provider.dart';
import '../../providers/rss_provider.dart';

/// Écran principal de l'application Sentinelle - Style News
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threatsState = ref.watch(threatNotifierProvider);
    final incidentsState = ref.watch(incidentNotifierProvider);
    final feedState = ref.watch(rssNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
          const SizedBox(width: 8),
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
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Breaking News (Carousel style)
              _buildSectionHeader(context, 'Breaking News', onSeeAll: () {}),
              _buildBreakingNews(context, feedState),
              
              const SizedBox(height: 30),
              
              // 2. Recommendation (List style)
              _buildSectionHeader(context, 'Recommendation', onSeeAll: () {}),
              _buildRecommendations(context, feedState, incidentsState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {required VoidCallback onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          TextButton(
            onPressed: onSeeAll,
            child: const Text('View all', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakingNews(BuildContext context, RssState feed) {
    if (feed.isLoading) return const _LoadingPlaceholder(height: 250);
    if (feed.items.isEmpty) return const SizedBox();

    final item = feed.items.first;
    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1550751827-4bd374c3f58b?q=80&w=1000&auto=format&fit=crop'), // Placeholder cyber
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Cybersecurity', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              '${item.sourceName} • 2 hours ago',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context, RssState feed, IncidentState incidents) {
    final items = feed.items.skip(1).take(5).toList();
    if (feed.isLoading) return const _LoadingPlaceholder(height: 100);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final item = items[index];
        return Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                'https://images.unsplash.com/photo-1563986768609-322da13575f3?q=80&w=200&auto=format&fit=crop',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('News', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(item.sourceName ?? 'Sentinelle', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Feb 21, 2026', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  final double height;
  const _LoadingPlaceholder({required this.height});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
