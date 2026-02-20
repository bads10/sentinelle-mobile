import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../screens/home/home_screen.dart';
import '../../screens/threats/threats_screen.dart';
import '../../screens/threats/threat_detail_screen.dart';
import '../../screens/incidents/incidents_screen.dart';
import '../../screens/incidents/incident_detail_screen.dart';
import '../../screens/feed/feed_screen.dart';

/// Noms des routes
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String threats = '/threats';
  static const String threatDetail = '/threats/:id';
  static const String incidents = '/incidents';
  static const String incidentDetail = '/incidents/:id';
  static const String feed = '/feed';
}

/// Provider GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: false,
    routes: [
      // Home - Écran principal avec bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.threats,
            name: 'threats',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ThreatsScreen(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                name: 'threat-detail',
                builder: (context, state) => ThreatDetailScreen(
                  threatId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.incidents,
            name: 'incidents',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: IncidentsScreen(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                name: 'incident-detail',
                builder: (context, state) => IncidentDetailScreen(
                  incidentId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.feed,
            name: 'feed',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FeedScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

/// Shell principal avec Bottom Navigation Bar
class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<String> _routes = [
    AppRoutes.home,
    AppRoutes.threats,
    AppRoutes.incidents,
    AppRoutes.feed,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          context.go(_routes[index]);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_outlined),
            activeIcon: Icon(Icons.warning_amber),
            label: 'Menaces',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bug_report_outlined),
            activeIcon: Icon(Icons.bug_report),
            label: 'Incidents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rss_feed_outlined),
            activeIcon: Icon(Icons.rss_feed),
            label: 'Flux RSS',
          ),
        ],
      ),
    );
  }
}
