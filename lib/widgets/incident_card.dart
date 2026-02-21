import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../models/incident.dart';

/// Carte incident CVE - style article de journal
class IncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback? onTap;

  const IncidentCard({
    super.key,
    required this.incident,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.cvssColor(incident.cvssScore);

    return GestureDetector(
      onTap: onTap ?? () => context.push('/incidents/${incident.id}'),
      child: Container(
        child: Stack(
          children: [
            // Indicateur CVSS coloré gauche
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 3, color: color),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(19, 14, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contenu principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // CVE ID badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          color: AppTheme.categoryIncident,
                          child: Text(
                            incident.cveId,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              fontFamily: 'Courier',
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        // Résumé (= titre)
                        Text(
                          incident.summary,
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Date
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 10,
                              color: AppTheme.textDisabled,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              incident.publishedAt,
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppTheme.textDisabled,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Score CVSS badge
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          incident.cvssScore.toStringAsFixed(1),
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: color,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'CVSS',
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w700,
                            color: color.withOpacity(0.7),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
