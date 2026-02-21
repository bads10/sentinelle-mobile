import 'package:flutter/material.dart';

class SeverityBadge extends StatelessWidget {
  final String severity;
  final bool compact;

  const SeverityBadge({
    super.key,
    required this.severity,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getSeverityConfig(severity.toLowerCase());
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.15),
        border: Border.all(color: config.color.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 6 : 8,
            height: compact ? 6 : 8,
            decoration: BoxDecoration(
              color: config.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  _SeverityConfig _getSeverityConfig(String severity) {
    switch (severity) {
      case 'critical':
        return _SeverityConfig(
          color: const Color(0xFFFF1744),
          label: 'CRITIQUE',
        );
      case 'high':
        return _SeverityConfig(
          color: const Color(0xFFFF6D00),
          label: 'HAUTE',
        );
      case 'medium':
        return _SeverityConfig(
          color: const Color(0xFFFFD600),
          label: 'MOYENNE',
        );
      case 'low':
        return _SeverityConfig(
          color: const Color(0xFF00E676),
          label: 'BASSE',
        );
      default:
        return _SeverityConfig(
          color: const Color(0xFF90A4AE),
          label: severity.toUpperCase(),
        );
    }
  }
}

class _SeverityConfig {
  final Color color;
  final String label;

  _SeverityConfig({required this.color, required this.label});
}
