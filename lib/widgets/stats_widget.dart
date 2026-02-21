import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/stats.dart';

/// Widget de statistiques - style compteurs de presse
class StatsWidget extends StatelessWidget {
  final Stats stats;

  const StatsWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceDark,
      child: Column(
        children: [
          // En-tête section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 2,
                  height: 12,
                  color: AppTheme.primaryRed,
                  margin: const EdgeInsets.only(right: 7),
                ),
                const Text(
                  'TABLEAU DE BORD',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          // Grille de statistiques
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: _StatCounter(
                    value: stats.totalThreats,
                    label: 'MENACES',
                    color: AppTheme.categoryThreat,
                  ),
                ),
                Container(width: 1, height: 40, color: AppTheme.dividerColor),
                Expanded(
                  child: _StatCounter(
                    value: stats.totalIncidents,
                    label: 'INCIDENTS',
                    color: AppTheme.categoryIncident,
                  ),
                ),
                Container(width: 1, height: 40, color: AppTheme.dividerColor),
                Expanded(
                  child: _StatCounter(
                    value: stats.criticalThreats,
                    label: 'CRITIQUES',
                    color: AppTheme.severityCritical,
                  ),
                ),
                Container(width: 1, height: 40, color: AppTheme.dividerColor),
                Expanded(
                  child: _StatCounter(
                    value: stats.totalFeedItems,
                    label: 'ARTICLES',
                    color: AppTheme.categoryNews,
                  ),
                ),
              ],
            ),
          ),
          // Ligne de tendances
          if (stats.newThreatsLast7Days > 0 || stats.newIncidentsLast7Days > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.dividerColor)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, size: 12, color: AppTheme.textDisabled),
                  const SizedBox(width: 6),
                  Text(
                    '${stats.newThreatsLast7Days} nouvelles menaces · '
                    '${stats.newIncidentsLast7Days} nouveaux incidents — 7 jours',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textDisabled,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCounter extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _StatCounter({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDisabled,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}
