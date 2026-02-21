import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../models/threat.dart';

/// Carte menace - style article de journal
class ThreatCard extends StatelessWidget {
  final Threat threat;
  final VoidCallback? onTap;

  const ThreatCard({
    super.key,
    required this.threat,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.severityColor(threat.severity);

    return GestureDetector(
      onTap: onTap ?? () => context.push('/threats/${threat.id}'),
      child: Container(
        child: Stack(
          children: [
            // Indicateur coloré gauche
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 3, color: color),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(19, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header : badge sévérité
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        color: color,
                        child: Text(
                          AppTheme.severityLabel(threat.severity),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'RANSOMWARE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDisabled,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Titre
                  Text(
                    threat.name,
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
                  // Description
                  if (threat.description.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      threat.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  // Meta row
                  Row(
                    children: [
                      Text(
                        threat.family.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDisabled,
                          letterSpacing: 0.6,
                        ),
                      ),
                      if (threat.reportedAt.isNotEmpty) ...[
                        const Text(
                          '  ·  ',
                          style: TextStyle(color: AppTheme.textDisabled, fontSize: 9),
                        ),
                        Text(
                          threat.reportedAt,
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppTheme.textDisabled,
                          ),
                        ),
                      ],
                      const Spacer(),
                      const Icon(Icons.chevron_right, size: 14, color: AppTheme.textDisabled),
                    ],
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
