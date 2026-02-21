import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/threat.dart';
import '../services/threat_service.dart';

// State class for threats
class ThreatState {
  final List<Threat> threats;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;

  const ThreatState({
    this.threats = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  ThreatState copyWith({
    List<Threat>? threats,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return ThreatState(
      threats: threats ?? this.threats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// ThreatNotifier
class ThreatNotifier extends StateNotifier<ThreatState> {
  final ThreatService _threatService;
  ThreatNotifier(this._threatService) : super(const ThreatState());

  Future<void> loadThreats({bool refresh = false}) async {
    if (state.isLoading) return;
    if (refresh) {
      state = const ThreatState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }
    try {
      final page = refresh ? 1 : state.currentPage;
      final response = await _threatService.getThreats(page: page);
      final newThreats = response.items;
      if (refresh) {
        state = ThreatState(
          threats: newThreats,
          isLoading: false,
          currentPage: 2,
          hasMore: newThreats.isNotEmpty,
        );
      } else {
        state = state.copyWith(
          threats: [...state.threats, ...newThreats],
          isLoading: false,
          currentPage: state.currentPage + 1,
          hasMore: newThreats.isNotEmpty,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() => loadThreats(refresh: true);
}

// StateNotifierProvider for threats list
final threatNotifierProvider =
    StateNotifierProvider<ThreatNotifier, ThreatState>((ref) {
  final threatService = ref.watch(threatServiceProvider);
  return ThreatNotifier(threatService);
});

// FutureProvider for single threat detail
final threatDetailProvider =
    FutureProvider.family<Threat, String>((ref, id) async {
  final threatService = ref.watch(threatServiceProvider);
  return threatService.getThreatById(id);
});

// Provider for filtered threats by severity
final filteredThreatsProvider =
    Provider.family<List<Threat>, String?>((ref, severity) {
  final state = ref.watch(threatNotifierProvider);
  if (severity == null || severity.isEmpty) {
    return state.threats;
  }
  return state.threats
      .where((t) => t.severity.toLowerCase() == severity.toLowerCase())
      .toList();
});

// Provider for threat statistics summary
final threatSummaryProvider = Provider<Map<String, int>>((ref) {
  final state = ref.watch(threatNotifierProvider);
  final summary = <String, int>{};
  for (final threat in state.threats) {
    final sev = threat.severity.toLowerCase();
    summary[sev] = (summary[sev] ?? 0) + 1;
  }
  return summary;
});
