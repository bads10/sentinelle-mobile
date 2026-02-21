import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/rss_item.dart';
import '../../providers/rss_provider.dart';

/// Écran Discover / Flux RSS - Style moderne
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Politic', 'Sport', 'Education', 'Game'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(rssNotifierProvider);
    final items = feedState.items;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Discover', style: Theme.of(context).textTheme.displayLarge),
                const SizedBox(height: 4),
                Text('News from all around the world', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // 2. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: const Icon(Icons.tune, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // 4. List of News
          Expanded(
            child: feedState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _DiscoverNewsCard(item: item);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DiscoverNewsCard extends StatelessWidget {
  final RssItem item;
  const _DiscoverNewsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?q=80&w=200&auto=format&fit=crop',
            width: 110,
            height: 110,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sports', // Category placeholder
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Text(
                item.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
              const SizedBox(height: 12),
             
                children: [
                  CircleAvatar(radius: 10, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=orcusium')),
                  const SizedBox(width: 8),
                  Text(item.sourceName ?? 'Sentinelle', style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(width: 8),
                  const Text('•', style: TextStyle(color: Colors.grey)),
                  const SizedBox(width: 8),
                  Text('Feb 27, 2023', style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
