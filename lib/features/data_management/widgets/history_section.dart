import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/data_management/data_management.dart';

class HistorySection extends ConsumerStatefulWidget {
  const HistorySection({super.key});

  @override
  ConsumerState<HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends ConsumerState<HistorySection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Información sobre historial
        _buildHistoryInfo(),

        const SizedBox(height: 16),

        // Botones de historial
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _viewChangeHistory(context),
                icon: const Icon(Icons.history),
                label: Text(context.tr('dataManagement.viewHistory')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportHistory(context),
                icon: const Icon(Icons.download),
                label: Text(context.tr('dataManagement.export')),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Botón para limpiar historial
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _cleanupHistory(context),
            icon: const Icon(Icons.cleaning_services),
            label: Text(context.tr('dataManagement.cleanOldHistory')),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryInfo() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.secondary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Revisa todos los cambios realizados en tus rutinas, ejercicios y sesiones',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _viewChangeHistory(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.tr('dataManagement.changeHistory')),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  // Filtros
                  _buildHistoryFilters(),

                  const SizedBox(height: 16),

                  // Lista de cambios
                  Expanded(
                    child: ListView(
                      children: [
                        _buildChangeItem(
                          'Rutina de Fuerza',
                          'Actualizada',
                          'Hace 2 horas',
                          ChangeType.update,
                          EntityType.routine,
                        ),
                        _buildChangeItem(
                          'Press de Banca',
                          'Creado',
                          '1 day ago',
                          ChangeType.create,
                          EntityType.exercise,
                        ),
                        _buildChangeItem(
                          'Morning Session',
                          'Completada',
                          '2 days ago',
                          ChangeType.update,
                          EntityType.session,
                        ),
                        _buildChangeItem(
                          'Rutina de Cardio',
                          'Eliminada',
                          'Hace 1 semana',
                          ChangeType.delete,
                          EntityType.routine,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.tr('common.close')),
              ),
            ],
          ),
    );
  }

  Widget _buildHistoryFilters() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<EntityType>(
            decoration: InputDecoration(
              labelText: context.tr('dataManagement.type'),
              isDense: true,
            ),
            items:
                EntityType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getEntityTypeLabel(type)),
                  );
                }).toList(),
            onChanged: (value) {
              // TODO: Implementar filtrado
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<ChangeType>(
            decoration: InputDecoration(
              labelText: context.tr('dataManagement.action'),
              isDense: true,
            ),
            items:
                ChangeType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getChangeTypeLabel(type)),
                  );
                }).toList(),
            onChanged: (value) {
              // TODO: Implementar filtrado
            },
          ),
        ),
      ],
    );
  }

  String _getEntityTypeLabel(EntityType type) {
    switch (type) {
      case EntityType.routine:
        return 'Rutinas';
      case EntityType.exercise:
        return 'Ejercicios';
      case EntityType.session:
        return 'Sesiones';
      case EntityType.progressData:
        return 'Progreso';
      case EntityType.userSettings:
        return 'Configuration';
    }
  }

  String _getChangeTypeLabel(ChangeType type) {
    switch (type) {
      case ChangeType.create:
        return 'Crear';
      case ChangeType.update:
        return 'Actualizar';
      case ChangeType.delete:
        return 'Eliminar';
      case ChangeType.restore:
        return 'Restaurar';
    }
  }

  Widget _buildChangeItem(
    String entityName,
    String action,
    String timestamp,
    ChangeType changeType,
    EntityType entityType,
  ) {
    final changeColor = _getChangeTypeColor(changeType);
    final entityIcon = _getEntityTypeIcon(entityType);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: changeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(entityIcon, color: changeColor, size: 20),
        ),
        title: Text(entityName),
        subtitle: Text('$action • $timestamp'),
        trailing: Icon(
          _getChangeTypeIcon(changeType),
          color: changeColor,
          size: 16,
        ),
        onTap: () => _showChangeDetails(context, entityName, action, timestamp),
      ),
    );
  }

  Color _getChangeTypeColor(ChangeType type) {
    switch (type) {
      case ChangeType.create:
        return Colors.green;
      case ChangeType.update:
        return Colors.blue;
      case ChangeType.delete:
        return Colors.red;
      case ChangeType.restore:
        return Colors.orange;
    }
  }

  IconData _getEntityTypeIcon(EntityType type) {
    switch (type) {
      case EntityType.routine:
        return Icons.fitness_center;
      case EntityType.exercise:
        return Icons.sports_gymnastics;
      case EntityType.session:
        return Icons.timer;
      case EntityType.progressData:
        return Icons.trending_up;
      case EntityType.userSettings:
        return Icons.settings;
    }
  }

  IconData _getChangeTypeIcon(ChangeType type) {
    switch (type) {
      case ChangeType.create:
        return Icons.add;
      case ChangeType.update:
        return Icons.edit;
      case ChangeType.delete:
        return Icons.delete;
      case ChangeType.restore:
        return Icons.restore;
    }
  }

  void _showChangeDetails(
    BuildContext context,
    String entityName,
    String action,
    String timestamp,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.tr('dataManagement.changeDetails')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(
                    'dataManagement.entity',
                    namedArgs: {'entityName': entityName},
                  ),
                ),
                Text(
                  context.tr(
                    'dataManagement.actionLabel',
                    namedArgs: {'action': action},
                  ),
                ),
                Text(
                  context.tr(
                    'dataManagement.date',
                    namedArgs: {'timestamp': timestamp},
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('dataManagement.changesMade'),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(context.tr('dataManagement.routineNameModified')),
                Text(context.tr('dataManagement.exercisesAdded')),
                Text(context.tr('dataManagement.sectionOrderUpdated')),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.tr('common.close')),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _restoreFromHistory(context, entityName);
                },
                child: Text(context.tr('dataManagement.restore')),
              ),
            ],
          ),
    );
  }

  void _restoreFromHistory(BuildContext context, String entityName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.tr('dataManagement.restoreFromHistory')),
            content: Text(
              'Are you sure you want to restore "$entityName" to its previous state? '
              'This will overwrite current changes.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.tr('common.cancel')),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.tr('dataManagement.entityRestoredSuccessfully'),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text(context.tr('dataManagement.restore')),
              ),
            ],
          ),
    );
  }

  Future<void> _exportHistory(BuildContext context) async {
    try {
      // Mostrar indicador de progreso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text(context.tr('dataManagement.exportingHistory')),
                ],
              ),
            ),
      );

      // TODO: Implementar exportación de historial
      // Simular tiempo de exportación
      await Future.delayed(const Duration(seconds: 2));

      // Cerrar indicador de progreso
      if (mounted) Navigator.of(context).pop();

      // Mostrar resultado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('dataManagement.historyExportedSuccessfully'),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Cerrar indicador de progreso si está abierto
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr(
                'dataManagement.historyExportError',
                namedArgs: {'error': e.toString()},
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cleanupHistory(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.tr('dataManagement.cleanOldHistory')),
            content: Text(
              context.tr('dataManagement.cleanOldHistoryDescription'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.tr('common.cancel')),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _confirmCleanupHistory(context);
                },
                child: Text(context.tr('dataManagement.clean')),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmCleanupHistory(BuildContext context) async {
    try {
      // Mostrar indicador de progreso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text(context.tr('dataManagement.cleaningHistory')),
                ],
              ),
            ),
      );

      // TODO: Implementar limpieza de historial
      // Simular tiempo de limpieza
      await Future.delayed(const Duration(seconds: 1));

      // Cerrar indicador de progreso
      if (mounted) Navigator.of(context).pop();

      // Mostrar resultado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Historial limpiado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Cerrar indicador de progreso si está abierto
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al limpiar historial: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
