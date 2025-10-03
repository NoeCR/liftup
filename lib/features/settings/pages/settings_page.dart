import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../common/widgets/custom_bottom_navigation.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/database/database_service.dart';
import '../../../core/logging/logging.dart';
import '../notifiers/rest_prefs.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../../home/notifiers/routine_notifier.dart';
import '../../exercise/notifiers/exercise_notifier.dart';
import '../../sessions/notifiers/session_notifier.dart';
import '../../statistics/notifiers/progress_notifier.dart';
import '../../progression/notifiers/progression_notifier.dart';
import '../widgets/language_selector.dart';
import 'package:easy_localization/easy_localization.dart';

// Clave global para el ScaffoldMessenger
final GlobalKey<ScaffoldMessengerState> globalScaffoldKey =
    GlobalKey<ScaffoldMessengerState>();

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
          title: Text(context.tr('settings.title')),
          backgroundColor: colorScheme.surface,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSettingsSection(context, context.tr('settings.routines'), [
              _buildSettingsTile(
                context,
                icon: Icons.list_alt,
                title: context.tr('settings.myRoutines'),
                subtitle: context.tr('settings.myRoutinesDescription'),
                onTap: () => context.push(AppRouter.routineList),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.settings_suggest,
                title: context.tr('routine.configureSections'),
                subtitle: 'Personalizar secciones de entrenamiento',
                onTap: () => context.push(AppRouter.sectionTemplates),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSettingsSection(context, context.tr('settings.application'), [
              _buildSettingsTile(
                context,
                icon: Icons.palette,
                title: 'Tema',
                subtitle: 'Cambiar tema claro/oscuro',
                onTap: () {
                  // Theme selection functionality
                },
              ),
              const LanguageSelector(),
            ]),
            const SizedBox(height: 24),
            _buildSettingsSection(context, 'Progresión', [
              _buildProgressionSettings(),
            ]),
            const SizedBox(height: 24),
            _buildSettingsSection(context, context.tr('settings.training'), [
              SwitchListTile(
                value: ref.watch(restSoundEnabledProvider),
                onChanged:
                    (v) =>
                        ref.read(restSoundEnabledProvider.notifier).state = v,
                title: Text(context.tr('settings.restSoundEnabled')),
                subtitle: Text(
                  context.tr('settings.restSoundEnabledDescription'),
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
                        decoration: InputDecoration(
                          labelText: context.tr('settings.soundType'),
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: RestSoundType.notification,
                            child: Text(context.tr('settings.notification')),
                          ),
                          DropdownMenuItem(
                            value: RestSoundType.alarm,
                            child: Text(context.tr('settings.alarm')),
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
                        ref.read(restVibrationEnabledProvider.notifier).state =
                            v,
                title: Text(context.tr('settings.restVibrationEnabled')),
                subtitle: Text(
                  context.tr('settings.restVibrationEnabledDescription'),
                ),
                secondary: const Icon(Icons.vibration),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                    label: Text(context.tr('settings.testRestSound')),
                  ),
                ),
              ),
            ]),
            _buildSettingsSection(context, context.tr('settings.data'), [
              _buildSettingsTile(
                context,
                icon: Icons.storage,
                title: context.tr('settings.dataManagement'),
                subtitle: 'Exportar, importar, backup y compartir',
                onTap: () => context.push(AppRouter.dataManagement),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.delete_forever,
                title: context.tr('settings.deleteAllData'),
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

  Widget _buildProgressionSettings() {
    return Consumer(
      builder: (context, ref, child) {
        final progressionAsync = ref.watch(progressionNotifierProvider);
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return progressionAsync.when(
          data: (config) {
            if (config == null) {
              return ListTile(
                leading: Icon(Icons.trending_up, color: colorScheme.primary),
                title: const Text('Configurar Progresión'),
                subtitle: const Text(
                  'Activar progresión automática para tus entrenamientos',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/progression-selection'),
              );
            }

            return Column(
              children: [
                ListTile(
                  leading: Icon(Icons.trending_up, color: colorScheme.primary),
                  title: Text('Progresión: ${config.type.displayName}'),
                  subtitle: Text(config.type.description),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/progression-selection'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.settings, color: colorScheme.secondary),
                  title: const Text('Configuración Avanzada'),
                  subtitle: const Text('Ajustar parámetros de la progresión'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap:
                      () => context.push(
                        '/progression-configuration',
                        extra: {'progressionType': config.type},
                      ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.stop, color: colorScheme.error),
                  title: const Text('Desactivar Progresión'),
                  subtitle: const Text('Volver al entrenamiento libre'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDisableProgressionDialog(context, ref),
                ),
              ],
            );
          },
          loading:
              () => const ListTile(
                leading: CircularProgressIndicator(),
                title: Text('Cargando progresión...'),
              ),
          error:
              (error, stack) => ListTile(
                leading: Icon(Icons.error_outline, color: colorScheme.error),
                title: const Text('Error al cargar progresión'),
                subtitle: Text(error.toString()),
                trailing: const Icon(Icons.refresh),
                onTap: () => ref.invalidate(progressionNotifierProvider),
              ),
        );
      },
    );
  }

  void _showDisableProgressionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Desactivar Progresión'),
            content: const Text(
              '¿Estás seguro de que quieres desactivar la progresión automática? '
              'Esto volverá al entrenamiento libre y no se aplicarán incrementos automáticos.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    await ref
                        .read(progressionNotifierProvider.notifier)
                        .disableProgression();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Progresión desactivada exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al desactivar progresión: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Desactivar'),
              ),
            ],
          ),
    );
  }

  void _showClearDatabaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.tr('settings.deleteAllData')),
            content: Text(context.tr('settings.deleteAllDataDescription')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.tr('common.cancel')),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showSecondConfirmationDialog(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(context.tr('dataManagement.continue')),
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
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              final isValid =
                  _confirmationText?.toUpperCase() ==
                  context.tr('settings.deleteConfirm').toUpperCase();

              return AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(context.tr('settings.finalConfirmation')),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('settings.finalWarning'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(context.tr('settings.finalWarningDetails')),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.tr('settings.typeToConfirm'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      enabled: !_isDeleting,
                      decoration: InputDecoration(
                        hintText: context.tr('settings.typeHere'),
                        border: const OutlineInputBorder(),
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
                    onPressed:
                        _isDeleting ? null : () => Navigator.of(context).pop(),
                    child: Text(context.tr('common.cancel')),
                  ),
                  FilledButton(
                    onPressed:
                        _isDeleting || !isValid
                            ? null
                            : () async {
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
                    child:
                        _isDeleting
                            ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(context.tr('settings.deleting')),
                              ],
                            )
                            : Text(context.tr('settings.deleteAllData')),
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

      // Limpiar el estado de series realizadas
      this.ref.read(sessionNotifierProvider.notifier).clearPerformedSets();

      // Invalidar todos los providers para forzar la recarga
      this.ref.invalidate(routineNotifierProvider);
      this.ref.invalidate(exerciseNotifierProvider);
      this.ref.invalidate(sessionNotifierProvider);
      this.ref.invalidate(progressNotifierProvider);

      // Esperar un momento para que se complete la invalidación
      await Future.delayed(const Duration(milliseconds: 500));

      // Mostrar SnackBar de éxito usando la clave global
      globalScaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(context.tr('settings.deleteAllDataSuccess')),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error clearing database from settings',
        e,
        stackTrace,
        {'component': 'settings_page'},
      );

      // Mostrar SnackBar de error usando la clave global
      globalScaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            'settings.deleteAllDataError'.tr(
              namedArgs: {'error': e.toString()},
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );

      // Re-lanzar el error para que el diálogo pueda manejarlo
      rethrow;
    }
  }
}
