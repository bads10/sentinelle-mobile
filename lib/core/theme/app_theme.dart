import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Thème News App de Sentinelle
class AppTheme {
  AppTheme._();

  // --- Palette News App (dark editorial) ---
  static const Color primaryRed = Color(0xFFD32F2F);      // Rouge breaking news
  static const Color accentRed = Color(0xFFFF5252);       // Rouge vif accent
  static const Color backgroundDark = Color(0xFF0D0D0D);  // Noir journal
  static const Color surfaceDark = Color(0xFF1A1A1A);     // Surface card
  static const Color cardDark = Color(0xFF242424);        // Card
  static const Color dividerColor = Color(0xFF2E2E2E);    // Séparateur

  // Couleurs sévérité (conservées)
  static const Color severityCritical = Color(0xFFD32F2F);
  static const Color severityHigh = Color(0xFFFF6D00);
  static const Color severityMedium = Color(0xFFFFD600);
  static const Color severityLow = Color(0xFF00C853);
  static const Color severityInfo = Color(0xFF2979FF);

  // Textes
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFF616161);
  static const Color textOnRed = Color(0xFFFFFFFF);

  // Catégories couleurs
  static const Color categoryThreat = Color(0xFFD32F2F);
  static const Color categoryIncident = Color(0xFFE65100);
  static const Color categoryNews = Color(0xFF1565C0);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryRed,
        secondary: accentRed,
        tertiary: Color(0xFF2979FF),
        surface: surfaceDark,
        onPrimary: textOnRed,
        onSecondary: textOnRed,
        onSurface: textPrimary,
        error: severityCritical,
      ),
      scaffoldBackgroundColor: backgroundDark,
      fontFamily: 'Georgia',
      // AppBar - style journal avec ligne rouge
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      // Cards - style papier sombre
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      // Bottom Navigation - propre, minimaliste
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundDark,
        selectedItemColor: primaryRed,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
      // Chips - style tag éditorial
      chipTheme: ChipThemeData(
        backgroundColor: surfaceDark,
        selectedColor: primaryRed,
        labelStyle: const TextStyle(
          color: textPrimary,
          fontSize: 11,
          letterSpacing: 0.3,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: const BorderSide(color: dividerColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      // Divider
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 0,
      ),
      // TextField - style recherche news
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        hintStyle: const TextStyle(color: textDisabled, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: primaryRed, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      // TextTheme - typographie éditoriale
      textTheme: const TextTheme(
        // Gros titres - style manchette
        headlineLarge: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.15,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.2,
          letterSpacing: -0.3,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.25,
        ),
        // Titres articles
        titleLarge: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.3,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.35,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.35,
        ),
        // Corps de texte
        bodyLarge: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 15,
          color: textSecondary,
          height: 1.55,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 13,
          color: textSecondary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 11,
          color: textDisabled,
          height: 1.4,
          letterSpacing: 0.2,
        ),
        // Labels (catégories, tags)
        labelLarge: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: textSecondary,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: textSecondary,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: textDisabled,
        ),
      ),
    );
  }

  /// Couleur selon sévérité
  static Color severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return severityCritical;
      case 'high':
        return severityHigh;
      case 'medium':
        return severityMedium;
      case 'low':
        return severityLow;
      default:
        return severityInfo;
    }
  }

  /// Couleur selon score CVSS
  static Color cvssColor(double score) {
    if (score >= 9.0) return severityCritical;
    if (score >= 7.0) return severityHigh;
    if (score >= 4.0) return severityMedium;
    if (score >= 0.1) return severityLow;
    return severityInfo;
  }

  /// Label de sévérité en français
  static String severityLabel(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return 'CRITIQUE';
      case 'high':
        return 'ÉLEVÉ';
      case 'medium':
        return 'MOYEN';
      case 'low':
        return 'FAIBLE';
      default:
        return 'INFO';
    }
  }
}
