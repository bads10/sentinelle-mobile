import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rss_item.dart';
import '../services/rss_service.dart';

// State class for RSS feed
class RssState {
  final List<RssItem> items;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String? selectedSource;

  const RssState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.selectedSource,
  });

  RssState copyWith({
    List<RssItem>? items,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? selectedSource,
  }) {
    return RssState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      selectedSource: selectedSource ?? this.selectedSource,
    );
  }
}

// RssNotifier
class RssNotifier extends StateNotifier<RssState> {
  final RssService _rssService;
  RssNotifier(this._rssService) : super(const RssState());

  Future<void> loadFeed({bool refresh = false}) async {
    if (state.isLoading) return;
    if (refresh) {
      state = const RssState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }
    try {
      final page = refresh ? 1 : state.currentPage;
      final response = await _rssService.getFeed(page: page);
      final newItems = response.items;
      if (refresh) {
        state = RssState(
          items: newItems,
          isLoading: false,
          currentPage: 2,
          hasMore: newItems.isNotEmpty,
        );
      } else {
        state = state.copyWith(
          items: [...state.items, ...newItems],
          isLoading: false,
          currentPage: state.currentPage + 1,
          hasMore: newItems.isNotEmpty,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() => loadFeed(refresh: true);

  void setSourceFilter(String? source) {
    state = state.copyWith(selectedSource: source);
  }
}

// StateNotifierProvider for RSS feed
final rssNotifierProvider =
    StateNotifierProvider<RssNotifier, RssState>((ref) {
  final rssService = ref.watch(rssServiceProvider);
  return RssNotifier(rssService);
});

// Provider for filtered RSS items by source
final filteredRssProvider = Provider<List<RssItem>>((ref) {
  final state = ref.watch(rssNotifierProvider);
  if (state.selectedSource == null || state.selectedSource!.isEmpty) {
    return state.items;
  }
  return state.items
      .where((item) =>
          item.sourceName?.toLowerCase() ==
          state.selectedSource!.toLowerCase())
      .toList();
});

// Provider for available RSS sources
final rssSourcesProvider = Provider<List<String>>((ref) {
  final state = ref.watch(rssNotifierProvider);
  final sources = state.items
      .map((item) => item.sourceName ?? '')
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList();
  sources.sort();
  return sources;
});

// Provider for latest RSS items (last 5)
final latestRssItemsProvider = Provider<List<RssItem>>((ref) {
  final state = ref.watch(rssNotifierProvider);
  final sorted = List<RssItem>.from(state.items);
  sorted.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  return sorted.take(5).toList();
});
