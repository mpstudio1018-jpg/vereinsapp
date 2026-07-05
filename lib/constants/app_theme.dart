import 'package:flutter/material.dart';

/// Premium Design System für TV Friedrichstein App
/// Moderne, professionelle Ästhetik für Vorstandspräsentation

class AppTheme {
  // ========== Primäre Farbpalette ==========
  /// Dunkles, edles Marineblau - Hauptfarbe
  static const Color primaryDark = Color.fromARGB(255, 26, 45, 77);

  /// Warmes, modernes Orange/Gold - Akzent
  static const Color accentOrange = Color.fromARGB(255, 217, 119, 6);

  /// Sekundäre Akzentfarbe
  static const Color accentGold = Color.fromARGB(255, 245, 158, 11);

  // ========== Hintergrund & Oberflächen ==========
  /// Haupthintergrund - Sehr dunkles Grau/Blau
  static const Color backgroundDark = Color.fromARGB(255, 15, 23, 42);

  /// Card-Hintergrund - Etwas heller
  static const Color cardBackground = Color.fromARGB(255, 30, 41, 59);

  /// Leichte Oberfläche für Hover-Effekte
  static const Color surfaceLight = Color.fromARGB(255, 51, 65, 85);

  // ========== Text-Farben ==========
  /// Primärer Text - Fast weiß
  static const Color textPrimary = Color.fromARGB(255, 248, 250, 252);

  /// Sekundärer Text - Graulich
  static const Color textSecondary = Color.fromARGB(255, 164, 172, 186);

  /// Subtiler Text - Noch grauer
  static const Color textTertiary = Color.fromARGB(255, 100, 116, 139);

  // ========== Zustands-Farben ==========
  static const Color successGreen = Color.fromARGB(255, 16, 185, 129);
  static const Color warningYellow = Color.fromARGB(255, 251, 191, 36);
  static const Color errorRed = Color.fromARGB(255, 254, 242, 242);
  static const Color infoBlue = Color.fromARGB(255, 59, 130, 246);

  // ========== Schatten & Tiefe ==========
  static const BoxShadow shadowSmall = BoxShadow(
    color: Color.fromARGB(26, 0, 0, 0),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow shadowMedium = BoxShadow(
    color: Color.fromARGB(38, 0, 0, 0),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static const BoxShadow shadowLarge = BoxShadow(
    color: Color.fromARGB(51, 0, 0, 0),
    blurRadius: 16,
    offset: Offset(0, 8),
  );

  // ========== Border Radius (Kurven) ==========
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXL = 20;

  // ========== Spacing (Abstände) ==========
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 12;
  static const double spacingL = 16;
  static const double spacingXL = 24;
  static const double spacing2XL = 32;

  // ========== Typography (Schriften) ==========
  static const String fontFamily = 'Segoe UI';

  static TextStyle headingLarge = const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle headingMedium = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle headingSmall = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle titleLarge = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle titleMedium = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle bodyLarge = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle bodySmall = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.4,
  );

  static TextStyle labelLarge = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle labelMedium = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textSecondary,
  );

  // ========== Material Theme Data ==========
  static ThemeData buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryDark,
      scaffoldBackgroundColor: backgroundDark,
      cardColor: cardBackground,
      fontFamily: fontFamily,
      // Colors
      colorScheme: ColorScheme.dark(
        primary: primaryDark,
        secondary: accentOrange,
        surface: cardBackground,
        error: errorRed,
      ),
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: cardBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headingMedium,
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      // Card Theme
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          textStyle: titleMedium,
        ),
      ),
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        fillColor: surfaceLight,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: accentOrange, width: 2),
        ),
        hintStyle: bodyMedium.copyWith(color: textTertiary),
        labelStyle: labelMedium,
      ),
    );
  }
}
