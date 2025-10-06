import 'package:flutter/material.dart';

class AppTheme {
  // Modern Color Palette - Liftly Identity
  // Primary: Teal-Blue (vibrant, fresh, fitness-tech vibe)
  static const Color primaryColor = Color(0xFF0EA5A4); // teal-600
  static const Color primaryLight = Color(0xFF2DD4BF); // teal-400
  static const Color primaryDark = Color(0xFF0F766E); // teal-700

  // Secondary: Electric Purple (energy/innovation)
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color secondaryLight = Color(0xFFA78BFA);
  static const Color secondaryDark = Color(0xFF7C3AED);

  // Tertiary: Fresh Mint (success/progress)
  static const Color tertiaryColor = Color(0xFF10B981);
  static const Color tertiaryLight = Color(0xFF34D399);
  static const Color tertiaryDark = Color(0xFF059669);

  // Accent: Coral (calls to action)
  static const Color accentColor = Color(0xFFF97316);
  static const Color accentLight = Color(0xFFFB923C);
  static const Color accentDark = Color(0xFFEA580C);

  // Neutral colors - Modern grays
  static const Color neutral50 = Color(0xFFF8FAFC);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);

  // Status colors
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  static const Color infoColor = Color(0xFF3B82F6);

  // Surface colors
  static const Color surfaceColor = Color(0xFFFFFBFE);
  static const Color backgroundColor = Color(0xFFFAFAFA);

  // Spacing constants following 8px rhythm
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border radius constants
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // Elevation constants
  static const double elevationS = 1.0;
  static const double elevationM = 2.0;
  static const double elevationL = 4.0;
  static const double elevationXL = 8.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: primaryLight.withValues(alpha: 0.12),
        onPrimaryContainer: primaryDark,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        secondaryContainer: secondaryLight.withValues(alpha: 0.12),
        onSecondaryContainer: secondaryDark,
        tertiary: tertiaryColor,
        onTertiary: Colors.white,
        tertiaryContainer: tertiaryLight.withValues(alpha: 0.12),
        onTertiaryContainer: tertiaryDark,
        error: errorColor,
        onError: Colors.white,
        errorContainer: errorColor.withValues(alpha: 0.12),
        onErrorContainer: errorColor,
        surface: surfaceColor,
        onSurface: neutral800,
        surfaceContainerHighest: neutral100,
        onSurfaceVariant: neutral600,
        outline: neutral300,
        outlineVariant: neutral200,
        shadow: neutral900.withValues(alpha: 0.08),
        scrim: neutral900.withValues(alpha: 0.5),
        inverseSurface: neutral800,
        onInverseSurface: neutral100,
        inversePrimary: primaryLight,
        surfaceTint: primaryColor,
      ),
      // App Bar Theme - Modern and clean
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: elevationS,
        surfaceTintColor: Colors.transparent,
        backgroundColor: surfaceColor,
        foregroundColor: neutral800,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: neutral800,
          letterSpacing: -0.5,
        ),
      ),
      // Card Theme - Consistent elevation and radius
      cardTheme: CardThemeData(
        elevation: elevationS,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
        margin: EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
      ),
      // Button Themes - Consistent styling and accessibility
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
          padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
          minimumSize: const Size(64, 48), // Accessibility: min 48dp height
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
          padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
          minimumSize: const Size(64, 48), // Accessibility: min 48dp height
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: primaryColor.withValues(alpha: 0.6)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
          padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
          minimumSize: const Size(64, 48), // Accessibility: min 48dp height
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
          padding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
          minimumSize: const Size(64, 48), // Accessibility: min 48dp height
        ),
      ),
      // Input Decoration Theme - Modern and accessible
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusM)),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingM),
        isDense: true,
      ),
      // Bottom Navigation Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(type: BottomNavigationBarType.fixed, elevation: 0),
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: elevationM,
        shape: CircleBorder(),
        extendedSizeConstraints: BoxConstraints(minHeight: 48, minWidth: 48),
      ),
      // List Tile Theme - Consistent spacing
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
        minVerticalPadding: spacingS,
        minLeadingWidth: 40,
      ),
      // Chip Theme - Modern styling
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusS)),
        padding: const EdgeInsets.symmetric(horizontal: spacingS, vertical: spacingXS),
        labelPadding: const EdgeInsets.symmetric(horizontal: spacingXS),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDark,
        brightness: Brightness.dark,
        primary: primaryLight,
        onPrimary: neutral900,
        primaryContainer: primaryDark,
        onPrimaryContainer: primaryLight,
        secondary: secondaryLight,
        onSecondary: neutral900,
        secondaryContainer: secondaryDark,
        onSecondaryContainer: secondaryLight,
        tertiary: tertiaryLight,
        onTertiary: neutral900,
        tertiaryContainer: tertiaryDark,
        onTertiaryContainer: tertiaryLight,
        error: const Color(0xFFFF6B6B),
        onError: neutral900,
        errorContainer: errorColor.withValues(alpha: 0.2),
        onErrorContainer: const Color(0xFFFF6B6B),
        surface: neutral900,
        onSurface: neutral100,
        surfaceContainerHighest: neutral800,
        onSurfaceVariant: neutral400,
        outline: neutral600,
        outlineVariant: neutral700,
        shadow: Colors.black.withValues(alpha: 0.3),
        scrim: Colors.black.withValues(alpha: 0.7),
        inverseSurface: neutral100,
        onInverseSurface: neutral800,
        inversePrimary: primaryDark,
        surfaceTint: primaryLight,
      ),
      // App Bar Theme - Dark mode
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: elevationS,
        surfaceTintColor: Colors.transparent,
        backgroundColor: neutral900,
        foregroundColor: neutral100,
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: neutral100, letterSpacing: -0.5),
      ),
      // Card Theme - Dark mode
      cardTheme: CardThemeData(
        elevation: elevationS,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
        margin: EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
      ),
      // Button Themes - Dark mode with accessibility
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: neutral900,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
          padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
          minimumSize: const Size(64, 48),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryLight,
          foregroundColor: neutral900,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
          padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
          minimumSize: const Size(64, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: primaryLight.withValues(alpha: 0.6)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
          padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
          minimumSize: const Size(64, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
          padding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
          minimumSize: const Size(64, 48),
        ),
      ),
      // Input Decoration Theme - Dark mode
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusM)),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingM),
        isDense: true,
      ),
      // Bottom Navigation Theme - Dark mode
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(type: BottomNavigationBarType.fixed, elevation: 0),
      // Floating Action Button Theme - Dark mode
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: elevationM,
        shape: CircleBorder(),
        extendedSizeConstraints: BoxConstraints(minHeight: 48, minWidth: 48),
      ),
      // List Tile Theme - Dark mode
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
        minVerticalPadding: spacingS,
        minLeadingWidth: 40,
      ),
      // Chip Theme - Dark mode
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusS)),
        padding: const EdgeInsets.symmetric(horizontal: spacingS, vertical: spacingXS),
        labelPadding: const EdgeInsets.symmetric(horizontal: spacingXS),
      ),
    );
  }
}
