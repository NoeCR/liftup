import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para gestionar el estado del tema de la aplicación
class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'app_theme_mode';
  
  ThemeNotifier() : super(ThemeMode.system) {
    _loadThemePreference();
  }

  /// Carga la preferencia de tema guardada
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
      state = ThemeMode.values[themeIndex];
    } catch (e) {
      // Si hay error, mantener el tema del sistema
      state = ThemeMode.system;
    }
  }

  /// Cambia el tema y guarda la preferencia
  Future<void> setTheme(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeMode.index);
      state = themeMode;
    } catch (e) {
      // Si hay error al guardar, aún cambiar el tema en memoria
      state = themeMode;
    }
  }

  /// Alterna entre tema claro y oscuro
  Future<void> toggleTheme() async {
    final newTheme = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setTheme(newTheme);
  }

  /// Obtiene el nombre del tema actual para mostrar en la UI
  String getCurrentThemeName() {
    switch (state) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }

  /// Obtiene el icono del tema actual
  IconData getCurrentThemeIcon() {
    switch (state) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}

/// Provider para acceder al notifier del tema
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// Provider para obtener el nombre del tema actual
final currentThemeNameProvider = Provider<String>((ref) {
  final themeNotifier = ref.watch(themeProvider.notifier);
  return themeNotifier.getCurrentThemeName();
});

/// Provider para obtener el icono del tema actual
final currentThemeIconProvider = Provider<IconData>((ref) {
  final themeNotifier = ref.watch(themeProvider.notifier);
  return themeNotifier.getCurrentThemeIcon();
});
