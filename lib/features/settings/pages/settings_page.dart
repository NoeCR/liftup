import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../common/widgets/custom_bottom_navigation.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/database/database_service.dart';
import '../notifiers/rest_prefs.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../../home/notifiers/routine_notifier.dart';
import '../../exercise/notifiers/exercise_notifier.dart';
import '../../sessions/notifiers/session_notifier.dart';
import '../../statistics/notifiers/progress_notifier.dart';

// Clave global para el ScaffoldMessenger
final GlobalKey<ScaffoldMessengerState> globalScaffoldKey = GlobalKey<ScaffoldMessengerState>();

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String? _confirmationText;
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ScaffoldMessenger(
      key: globalScaffoldKey,
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: colorScheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection(context, 'Rutinas', [
            _buildSettingsTile(
              context,
              icon: Icons.list_alt,
              title: 'Mis Rutinas',
              subtitle: 'Ver y gestionar todas tus rutinas',
              onTap: () => context.push(AppRouter.routineList),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.settings_suggest,
              title: 'Configurar Secciones',
              subtitle: 'Personalizar secciones de entrenamiento',
              onTap: () => context.push(AppRouter.sectionTemplates),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection(context, 'Aplicación', [
            _buildSettingsTile(
              context,
              icon: Icons.palette,
              title: 'Tema',
              subtitle: 'Cambiar tema claro/oscuro',
              onTap: () {
                // Theme selection functionality
              },
            ),
            _buildSettingsTile(
              context,
              icon: Icons.language,
              title: 'Idioma',
              subtitle: 'Cambiar idioma de la aplicación',
              onTap: () {
                // Language selection functionality
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection(context, 'Entrenamiento', [
            SwitchListTile(
              value: ref.watch(restSoundEnabledProvider),
              onChanged:
                  (v) => ref.read(restSoundEnabledProvider.notifier).state = v,
              title: const Text('Sonido al finalizar descanso'),
              subtitle: const Text(
                'Reproducir aviso sonoro al terminar el contador',
              ),
              secondary: const Icon(Icons.volume_up),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.music_note),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<RestSoundType>(
                      value: ref.watch(restSoundTypeProvider),
                      decoration: const InputDecoration(
                        labelText: 'Tipo de sonido',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: RestSoundType.notification,
                          child: Text('Notificación'),
                        ),
                        DropdownMenuItem(
                          value: RestSoundType.alarm,
                          child: Text('Alarma (mayor prioridad)'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          ref.read(restSoundTypeProvider.notifier).state = v;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            SwitchListTile(
              value: ref.watch(restVibrationEnabledProvider),
              onChanged:
                  (v) =>
                      ref.read(restVibrationEnabledProvider.notifier).state = v,
              title: const Text('Vibración al finalizar descanso'),
              subtitle: const Text('Activar vibración al terminar el contador'),
              secondary: const Icon(Icons.vibration),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    final soundEnabled = ref.read(restSoundEnabledProvider);
                    if (!soundEnabled) return;
                    final soundType = ref.read(restSoundTypeProvider);
                    final androidSound =
                        soundType == RestSoundType.alarm
                            ? AndroidSounds.alarm
                            : AndroidSounds.notification;
                    final iosSound =
                        soundType == RestSoundType.alarm
                            ? IosSounds.alarm
                            : IosSounds.triTone;
                    FlutterRingtonePlayer().play(
                      android: androidSound,
                      ios: iosSound,
                      looping: false,
                      volume: 1.0,
                      asAlarm: soundType == RestSoundType.alarm,
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Probar sonido de descanso'),
                ),
              ),
            ),
          ]),
          _buildSettingsSection(context, 'Datos', [
            _buildSettingsTile(
              context,
              icon: Icons.storage,
              title: 'Gestión de Datos',
              subtitle: 'Exportar, importar, backup y compartir',
              onTap: () => context.push(AppRouter.dataManagement),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.delete_forever,
              title: 'Eliminar Todos los Datos',
              subtitle: 'Eliminar todas las rutinas y progreso',
              onTap: () => _showClearDatabaseDialog(context),
              isDestructive: true,
            ),
          ]),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 4),
      ),
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
        Card(child: Column(children: children)),
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
        style: TextStyle(color: isDestructive ? colorScheme.error : null),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showClearDatabaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('⚠️ Eliminar Todos los Datos'),
            content: const Text(
              'Esta acción eliminará PERMANENTEMENTE todas las rutinas, ejercicios, sesiones y datos de progreso.\n\n'
              'Esta acción NO se puede deshacer.\n\n'
              '¿Estás completamente seguro de que quieres continuar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showSecondConfirmationDialog(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Continuar'),
              ),
            ],
          ),
    );
  }

  void _showSecondConfirmationDialog(BuildContext context) {
    _confirmationText = null; // Reset confirmation text
    _isDeleting = false; // Reset deleting state
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isValid = _confirmationText?.toUpperCase() == 'ELIMINAR';
          
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                const Text('Confirmación Final'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ÚLTIMA ADVERTENCIA:\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  '• Todas las rutinas serán eliminadas\n'
                  '• Todos los ejercicios serán eliminados\n'
                  '• Todas las sesiones de entrenamiento serán eliminadas\n'
                  '• Todos los datos de progreso serán eliminados\n'
                  '• Esta acción es IRREVERSIBLE\n\n',
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Escribe "ELIMINAR" para confirmar:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  enabled: !_isDeleting,
                  decoration: const InputDecoration(
                    hintText: 'Escribe ELIMINAR aquí',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setDialogState(() {
                      _confirmationText = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: _isDeleting || !isValid ? null : () async {
                  setDialogState(() {
                    _isDeleting = true;
                  });
                  
                  try {
                    await _clearAllData();
                    // Cerrar el diálogo
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    // En caso de error, permitir reintentar
                    setDialogState(() {
                      _isDeleting = false;
                    });
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: _isDeleting
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Eliminando...'),
                        ],
                      )
                    : const Text('ELIMINAR TODO'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _clearAllData() async {
    try {
      final databaseService = DatabaseService.getInstance();
      await databaseService.forceResetDatabase();

      // Invalidar todos los providers para forzar la recarga
      this.ref.invalidate(routineNotifierProvider);
      this.ref.invalidate(exerciseNotifierProvider);
      this.ref.invalidate(sessionNotifierProvider);
      this.ref.invalidate(progressNotifierProvider);

      // Esperar un momento para que se complete la invalidación
      await Future.delayed(const Duration(milliseconds: 500));

      // Mostrar SnackBar de éxito usando la clave global
      globalScaffoldKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('✅ Todos los datos han sido eliminados exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Error clearing database: $e');

      // Mostrar SnackBar de error usando la clave global
      globalScaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('❌ Error al eliminar datos: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      
      // Re-lanzar el error para que el diálogo pueda manejarlo
      rethrow;
    }
  }
}
