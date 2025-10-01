import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/custom_bottom_navigation.dart';
import '../widgets/export_section.dart';
import '../widgets/import_section.dart';
import '../widgets/backup_section.dart';
import '../widgets/sharing_section.dart';
import '../widgets/history_section.dart';

class DataManagementPage extends ConsumerWidget {
  const DataManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Datos'),
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            tooltip: 'Configuración',
            onPressed: () => _showSettingsDialog(context),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de Exportación
          _buildSectionCard(
            context: context,
            title: 'Exportar Datos',
            subtitle: 'Exporta tus rutinas, sesiones y progreso',
            icon: Icons.download,
            color: colorScheme.primary,
            child: const ExportSection(),
          ),
          
          const SizedBox(height: 16),
          
          // Sección de Importación
          _buildSectionCard(
            context: context,
            title: 'Importar Datos',
            subtitle: 'Importa datos desde archivos externos',
            icon: Icons.upload,
            color: colorScheme.secondary,
            child: const ImportSection(),
          ),
          
          const SizedBox(height: 16),
          
          // Sección de Backup en la Nube
          _buildSectionCard(
            context: context,
            title: 'Backup en la Nube',
            subtitle: 'Respaldo automático y manual',
            icon: Icons.cloud_upload,
            color: colorScheme.tertiary,
            child: const BackupSection(),
          ),
          
          const SizedBox(height: 16),
          
          // Sección de Compartición
          _buildSectionCard(
            context: context,
            title: 'Compartir Rutinas',
            subtitle: 'Comparte tus rutinas con otros usuarios',
            icon: Icons.share,
            color: colorScheme.primaryContainer,
            child: const SharingSection(),
          ),
          
          const SizedBox(height: 16),
          
          // Sección de Historial
          _buildSectionCard(
            context: context,
            title: 'Historial de Cambios',
            subtitle: 'Revisa el historial de modificaciones',
            icon: Icons.history,
            color: colorScheme.secondaryContainer,
            child: const HistorySection(),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 4),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración de Gestión de Datos'),
        content: const Text(
          'Aquí podrás configurar:\n'
          '• Frecuencia de backup automático\n'
          '• Configuración de compartición\n'
          '• Retención de historial\n'
          '• Formatos de exportación preferidos',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
