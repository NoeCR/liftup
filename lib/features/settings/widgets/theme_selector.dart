import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';

/// Widget para seleccionar el tema de la aplicación
class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return _buildSettingsTile(
      context,
      icon: _getThemeIcon(currentTheme),
      title: 'Tema',
      subtitle: _getThemeSubtitle(currentTheme),
      onTap: () => _showThemeDialog(context, ref, themeNotifier),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(subtitle, style: theme.textTheme.bodyMedium),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }

  IconData _getThemeIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  String _getThemeSubtitle(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Siempre usar tema claro';
      case ThemeMode.dark:
        return 'Siempre usar tema oscuro';
      case ThemeMode.system:
        return 'Seguir configuración del sistema';
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, ThemeNotifier themeNotifier) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Seleccionar Tema'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildThemeOption(
                  context,
                  ref,
                  themeNotifier,
                  ThemeMode.light,
                  Icons.light_mode,
                  'Tema Claro',
                  'Usar siempre el tema claro',
                ),
                _buildThemeOption(
                  context,
                  ref,
                  themeNotifier,
                  ThemeMode.dark,
                  Icons.dark_mode,
                  'Tema Oscuro',
                  'Usar siempre el tema oscuro',
                ),
                _buildThemeOption(
                  context,
                  ref,
                  themeNotifier,
                  ThemeMode.system,
                  Icons.brightness_auto,
                  'Sistema',
                  'Seguir configuración del sistema',
                ),
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar'))],
          ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    ThemeNotifier themeNotifier,
    ThemeMode themeMode,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final currentTheme = ref.watch(themeProvider);
    final isSelected = currentTheme == themeMode;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isSelected ? colorScheme.primaryContainer : null,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.primary),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(color: isSelected ? colorScheme.onPrimaryContainer : null),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(color: isSelected ? colorScheme.onPrimaryContainer : null),
        ),
        trailing: isSelected ? Icon(Icons.check_circle, color: colorScheme.primary) : null,
        onTap: () {
          themeNotifier.setTheme(themeMode);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
