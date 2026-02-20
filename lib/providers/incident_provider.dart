import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/incident.dart';
import '../services/incident_service.dart';
import '../services/api_service.dart';

// Provider for IncidentService
final incidentServiceProvider = Provider<IncidentService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return IncidentService(apiService);
});

// State class for incidents
class IncidentState {
  final List<Incident> incidents;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String? selectedSeverity;

  const IncidentState({
    this.incidents = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.selectedSeverity,
  });

  IncidentState copyWith({
    List<Incident>? incidents,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? selectedSeverity,
  }) {
    return IncidentState(
      incidents: incidents ?? this.incidents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      selectedSeverity: selectedSeverity ?? this.selectedSeverity,
    );
  }
}

// IncidentNotifier
class IncidentNotifier extends StateNotifier<IncidentState> {
  final IncidentService _incidentService;

  IncidentNotifier(this._incidentService) : super(const IncidentState());

  Future<void> loadIncidents({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = const IncidentState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final page = refresh ? 1 : state.currentPage;
      final newIncidents = await _incidentService.getIncidents(page: page);

      if (refresh) {
        state = IncidentState(
          incidents: newIncidents,
          isLoading: false,
          currentPage: 2,
          hasMore: newIncidents.isNotEmpty,
        );
      } else {
        state = state.copyWith(
          incidents: [...state.incidents, ...newIncidents],
          isLoading: false,
          currentPage: state.currentPage + 1,
          hasMore: newIncidents.isNotEmpty,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() => loadIncidents(refresh: true);

  void setSeverityFilter(String? severity) {
    state = state.copyWith(selectedSeverity: severity);
  }
}

// StateNotifierProvider for incidents list
final incidentNotifierProvider =
    StateNotifierProvider<IncidentNotifier, IncidentState>((ref) {
  final incidentService = ref.watch(incidentServiceProvider);
  return IncidentNotifier(incidentService);
});

// FutureProvider for single incident detail
final incidentDetailProvider =
    FutureProvider.family<Incident, String>((ref, id) async {
  final incidentService = ref.watch(incidentServiceProvider);
  return incidentService.getIncidentById(id);
});

// Provider for filtered incidents
final filteredIncidentsProvider = Provider<List<Incident>>((ref) {
  final state = ref.watch(incidentNotifierProvider);
  if (state.selectedSeverity == null || state.selectedSeverity!.isEmpty) {
    return state.incidents;
  }
  return state.incidents
      .where((i) =>
          i.severity?.toLowerCase() == state.selectedSeverity!.toLowerCase())
      .toList();
});

// Provider for recent incidents (last 10)
final recentIncidentsProvider = Provider<List<Incident>>((ref) {
  final state = ref.watch(incidentNotifierProvider);
  final sorted = List<Incident>.from(state.incidents);
  sorted.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  return sorted.take(10).toList();
});
