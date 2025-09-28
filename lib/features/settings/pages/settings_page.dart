import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../common/widgets/custom_bottom_navigation.dart';
import '../../../core/navigation/app_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: colorScheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection(
            context,
            'Rutinas',
            [
              _buildSettingsTile(
                context,
                icon: Icons.settings_suggest,
                title: 'Configurar Secciones',
                subtitle: 'Personalizar secciones de entrenamiento',
                onTap: () => context.push(AppRouter.sectionTemplates),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            'Aplicación',
            [
              _buildSettingsTile(
                context,
                icon: Icons.palette,
                title: 'Tema',
                subtitle: 'Cambiar tema claro/oscuro',
                onTap: () {
                  // TODO: Implementar cambio de tema
                },
              ),
              _buildSettingsTile(
                context,
                icon: Icons.language,
                title: 'Idioma',
                subtitle: 'Cambiar idioma de la aplicación',
                onTap: () {
                  // TODO: Implementar cambio de idioma
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            'Datos',
            [
              _buildSettingsTile(
                context,
                icon: Icons.backup,
                title: 'Exportar Datos',
                subtitle: 'Exportar rutinas y progreso',
                onTap: () {
                  // TODO: Implementar exportación
                },
              ),
              _buildSettingsTile(
                context,
                icon: Icons.restore,
                title: 'Importar Datos',
                subtitle: 'Importar rutinas y progreso',
                onTap: () {
                  // TODO: Implementar importación
                },
              ),
              _buildSettingsTile(
                context,
                icon: Icons.delete_forever,
                title: 'Eliminar Todos los Datos',
                subtitle: 'Eliminar todas las rutinas y progreso',
                onTap: () {
                  // TODO: Implementar eliminación de datos
                },
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 4),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? colorScheme.error : colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? colorScheme.error : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
