import 'package:flutter/material.dart';

/// Thème dark cybersécurité de Sentinelle
class AppTheme {
  AppTheme._();

  // Couleurs primaires
  static const Color primaryColor = Color(0xFF00D4FF);    // Cyan cybersécurité
  static const Color secondaryColor = Color(0xFF7B2FBE);  // Violet accent
  static const Color accentColor = Color(0xFF00FF88);     // Vert terminal

  // Couleurs de fond
  static const Color backgroundDark = Color(0xFF0A0E1A);  // Bleu nuit très sombre
  static const Color surfaceDark = Color(0xFF0F1629);     // Surface cards
  static const Color cardDark = Color(0xFF1A2035);        // Cards

  // Couleurs sévérité
  static const Color severityCritical = Color(0xFFFF2D55); // Rouge critique
  static const Color severityHigh = Color(0xFFFF6B35);     // Orange haute
  static const Color severityMedium = Color(0xFFFFCC02);   // Jaune moyenne
  static const Color severityLow = Color(0xFF34C759);      // Vert basse
  static const Color severityInfo = Color(0xFF00D4FF);     // Cyan info

  // Couleurs texte
  static const Color textPrimary = Color(0xFFE8EAF6);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFF616161);

  // Thème principal
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      background: backgroundDark,
      surface: surfaceDark,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onBackground: textPrimary,
      onSurface: textPrimary,
      error: severityCritical,
    ),
    scaffoldBackgroundColor: backgroundDark,
    fontFamily: 'Inter',

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.5,
      ),
    ),

    // Cards
    cardTheme: CardTheme(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF1E2D4A), width: 1),
      ),
    ),

    // Bottom Navigation
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: cardDark,
      labelStyle: const TextStyle(color: textPrimary, fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: Color(0xFF1E2D4A),
      thickness: 1,
    ),
  );

  /// Retourne la couleur selon le niveau de sévérité
  static Color severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical': return severityCritical;
      case 'high': return severityHigh;
      case 'medium': return severityMedium;
      case 'low': return severityLow;
      default: return severityInfo;
    }
  }

  /// Retourne la couleur selon le score CVSS
  static Color cvssColor(double score) {
    if (score >= 9.0) return severityCritical;
    if (score >= 7.0) return severityHigh;
    if (score >= 4.0) return severityMedium;
    if (score >= 0.1) return severityLow;
    return severityInfo;
  }
}
