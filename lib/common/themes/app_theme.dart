import 'package:flutter/material.dart';

class AppTheme {
  // Color palette - Material 3 compliant
  static const Color primaryColor = Color(0xFF6750A4);
  static const Color secondaryColor = Color(0xFF625B71);
  static const Color tertiaryColor = Color(0xFF7D5260);
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color surfaceColor = Color(0xFFFFFBFE);
  static const Color backgroundColor = Color(0xFFFFFBFE);

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
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        error: errorColor,
        surface: surfaceColor,
      ),
      // App Bar Theme - Modern and clean
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: elevationS,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
      ),
      // Card Theme - Consistent elevation and radius
      cardTheme: CardThemeData(
        elevation: elevationS,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
        margin: EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
      ),
      // Button Themes - Consistent styling and accessibility
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          minimumSize: const Size(64, 48), // Accessibility: min 48dp height
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          minimumSize: const Size(64, 48), // Accessibility: min 48dp height
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          minimumSize: const Size(64, 48), // Accessibility: min 48dp height
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingM,
            vertical: spacingS,
          ),
          minimumSize: const Size(64, 48), // Accessibility: min 48dp height
        ),
      ),
      // Input Decoration Theme - Modern and accessible
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingM,
        ),
        isDense: true,
      ),
      // Bottom Navigation Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: elevationM,
        shape: CircleBorder(),
        extendedSizeConstraints: BoxConstraints(minHeight: 48, minWidth: 48),
      ),
      // List Tile Theme - Consistent spacing
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingS,
        ),
        minVerticalPadding: spacingS,
        minLeadingWidth: 40,
      ),
      // Chip Theme - Modern styling
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusS),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingS,
          vertical: spacingXS,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: spacingXS),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: const Color(0xFFD0BCFF),
        secondary: const Color(0xFFCCC2DC),
        tertiary: const Color(0xFFEFB8C8),
        error: const Color(0xFFFFB4AB),
        surface: const Color(0xFF1C1B1F),
      ),
      // App Bar Theme - Dark mode
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: elevationS,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFD0BCFF),
        ),
      ),
      // Card Theme - Dark mode
      cardTheme: CardThemeData(
        elevation: elevationS,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
        margin: EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
      ),
      // Button Themes - Dark mode with accessibility
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          minimumSize: const Size(64, 48),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          minimumSize: const Size(64, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          minimumSize: const Size(64, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingM,
            vertical: spacingS,
          ),
          minimumSize: const Size(64, 48),
        ),
      ),
      // Input Decoration Theme - Dark mode
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingM,
        ),
        isDense: true,
      ),
      // Bottom Navigation Theme - Dark mode
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      // Floating Action Button Theme - Dark mode
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: elevationM,
        shape: CircleBorder(),
        extendedSizeConstraints: BoxConstraints(minHeight: 48, minWidth: 48),
      ),
      // List Tile Theme - Dark mode
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingS,
        ),
        minVerticalPadding: spacingS,
        minLeadingWidth: 40,
      ),
      // Chip Theme - Dark mode
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusS),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingS,
          vertical: spacingXS,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: spacingXS),
      ),
    );
  }
}
