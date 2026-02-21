import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
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

/// Shell principal - Navigation style News App
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

  // Données de navigation style journal
  static const _navItems = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'UNE',
      color: AppTheme.primaryRed,
    ),
    _NavItem(
      icon: Icons.warning_amber_outlined,
      activeIcon: Icons.warning_amber,
      label: 'MENACES',
      color: AppTheme.categoryThreat,
    ),
    _NavItem(
      icon: Icons.bug_report_outlined,
      activeIcon: Icons.bug_report,
      label: 'CVE',
      color: AppTheme.categoryIncident,
    ),
    _NavItem(
      icon: Icons.article_outlined,
      activeIcon: Icons.article,
      label: 'ACTUALITÉS',
      color: AppTheme.categoryNews,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: widget.child,
      bottomNavigationBar: _NewsBottomNav(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) {
          setState(() => _currentIndex = index);
          context.go(_routes[index]);
        },
      ),
    );
  }
}

// ── Modèle item navigation ────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}

// ── Navigation bar style journal ──────────────────────────────────────────────
class _NewsBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _NewsBottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          top: BorderSide(color: AppTheme.dividerColor, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: Row(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isSelected ? item.color : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 20,
                          color: isSelected ? item.color : AppTheme.textDisabled,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                            color: isSelected ? item.color : AppTheme.textDisabled,
                            letterSpacing: isSelected ? 0.8 : 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
