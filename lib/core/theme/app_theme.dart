import 'package:flutter/material.dart';

/// Thème Sentinelle - Design moderne inspiré news app
class AppTheme {
  AppTheme._();

  // --- Palette principale (light & dark) ---
  static const Color primary      = Color(0xFF1877F2); // Bleu action
  static const Color primaryDark  = Color(0xFF0D5EBF);
  static const Color accent       = Color(0xFF0EA5E9); // Cyan clair

  // Backgrounds light
  static const Color bgLight      = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight    = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFEEEEEE);

  // Backgrounds dark
  static const Color bgDark       = Color(0xFF0D1117);
  static const Color surfaceDark  = Color(0xFF161B22);
  static const Color cardDark     = Color(0xFF21262D);
  static const Color dividerDark  = Color(0xFF30363D);

  // Texte light
  static const Color textDark1    = Color(0xFF0D1117);
  static const Color textDark2    = Color(0xFF57606A);
  static const Color textDark3    = Color(0xFF8B949E);

  // Texte dark
  static const Color textLight1   = Color(0xFFF0F6FF);
  static const Color textLight2   = Color(0xFF8B949E);
  static const Color textLight3   = Color(0xFF484F58);

  // Badges sévérité
  static const Color severityCritical = Color(0xFFFF3B30);
  static const Color severityHigh     = Color(0xFFFF9500);
  static const Color severityMedium   = Color(0xFFFFCC00);
  static const Color severityLow      = Color(0xFF34C759);
  static const Color severityInfo     = Color(0xFF1877F2);

  // Compatibilité ancienne API
  static const Color primaryColor     = primary;
  static const Color secondaryColor   = Color(0xFF7B2FBE);
  static const Color accentColor      = accent;
  static const Color backgroundDark   = bgDark;
  static const Color textPrimary      = textLight1;
  static const Color textSecondary    = textLight2;
  static const Color textDisabled     = textLight3;

  // --- Thème clair (inspiré maquette) ---
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: accent,
      surface: surfaceLight,
      error: severityCritical,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textDark1,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: bgLight,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceLight,
      foregroundColor: textDark1,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textDark1,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: textDark1),
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.zero,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Color(0xFFEBF5FB),
      selectedColor: primary,
      labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      shape: StadiumBorder(),
      side: BorderSide.none,
      padding: EdgeInsets.symmetric(horizontal: 4),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF1F3F4),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      hintStyle: TextStyle(color: textDark3, fontSize: 14),
    ),
    dividerTheme: const DividerThemeData(
      color: dividerLight,
      thickness: 1,
      space: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: primary,
      unselectedItemColor: textDark3,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    textTheme: const TextTheme(
      displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: textDark1, letterSpacing: -0.5),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: textDark1, letterSpacing: -0.5),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textDark1, letterSpacing: -0.3),
      headlineMedium:TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textDark1, letterSpacing: -0.3),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textDark1),
      titleLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textDark1),
      titleMedium:   TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textDark1),
      titleSmall:    TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textDark1),
      bodyLarge:     TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: textDark1, height: 1.6),
      bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textDark2, height: 1.5),
      bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textDark3),
      labelLarge:    TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary),
      labelSmall:    TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textDark3, letterSpacing: 0.3),
    ),
  );

  // --- Thème sombre (compatible ancien code) ---
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: surfaceDark,
      error: severityCritical,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textLight1,
    ),
    scaffoldBackgroundColor: bgDark,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: textLight1,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textLight1,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: textLight1),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: dividerDark, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Color(0xFF21262D),
      selectedColor: primary,
      labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textLight1),
      shape: StadiumBorder(),
      side: BorderSide(color: dividerDark, width: 1),
      padding: EdgeInsets.symmetric(horizontal: 4),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF21262D),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: dividerDark, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      hintStyle: TextStyle(color: textLight2, fontSize: 14),
    ),
    dividerTheme: const DividerThemeData(
      color: dividerDark,
      thickness: 1,
      space: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: primary,
      unselectedItemColor: textLight2,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: textLight1, letterSpacing: -0.5),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: textLight1, letterSpacing: -0.5),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textLight1, letterSpacing: -0.3),
      headlineMedium:TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textLight1, letterSpacing: -0.3),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textLight1),
      titleLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textLight1),
      titleMedium:   TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textLight1),
      titleSmall:    TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textLight1),
      bodyLarge:     TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: textLight1, height: 1.6),
      bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textLight2, height: 1.5),
      bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textLight3),
      labelLarge:    TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary),
      labelSmall:    TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textLight3, letterSpacing: 0.3),
    ),
  );

  /// Couleur selon severite
  static Color severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical': return severityCritical;
      case 'high':     return severityHigh;
      case 'medium':   return severityMedium;
      case 'low':      return severityLow;
      default:         return severityInfo;
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
}
