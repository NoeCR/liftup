import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data_management/data_management.dart';
import 'package:easy_localization/easy_localization.dart';

class SharingSection extends ConsumerStatefulWidget {
  const SharingSection({super.key});

  @override
  ConsumerState<SharingSection> createState() => _SharingSectionState();
}

class _SharingSectionState extends ConsumerState<SharingSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Información sobre compartición
        _buildSharingInfo(),

        const SizedBox(height: 16),

        // Botones de compartición
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _shareRoutine(context),
                icon: const Icon(Icons.share),
                label: Text(context.tr('dataManagement.shareRoutine')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _viewSharedRoutines(context),
                icon: const Icon(Icons.list),
                label: Text(context.tr('dataManagement.myShared')),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Botón para importar rutinas compartidas
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _importSharedRoutine(context),
            icon: const Icon(Icons.download),
            label: Text(context.tr('dataManagement.importSharedRoutine')),
          ),
        ),
      ],
    );
  }

  Widget _buildSharingInfo() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.tr('dataManagement.sharingDescription'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareRoutine(BuildContext context) async {
    // TODO: Implementar selección de rutina para compartir
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.tr('dataManagement.shareRoutineTitle')),
            content: Text(context.tr('dataManagement.shareRoutineDescription')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.tr('common.cancel')),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showShareConfigDialog(context);
                },
                child: Text(context.tr('dataManagement.continue')),
              ),
            ],
          ),
    );
  }

  void _showShareConfigDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    RoutineVisibility visibility = RoutineVisibility.public;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(context.tr('dataManagement.configureSharing')),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: context.tr('dataManagement.title'),
                            hintText: context.tr(
                              'dataManagement.sharedRoutineName',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: context.tr('dataManagement.description'),
                            hintText: context.tr(
                              'dataManagement.describeRoutine',
                            ),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<RoutineVisibility>(
                          value: visibility,
                          decoration: InputDecoration(
                            labelText: context.tr('dataManagement.visibility'),
                          ),
                          items:
                              RoutineVisibility.values.map((v) {
                                return DropdownMenuItem(
                                  value: v,
                                  child: Text(_getVisibilityLabel(v)),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => visibility = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(context.tr('common.cancel')),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _createSharedRoutine(
                          context,
                          titleController.text,
                          descriptionController.text,
                          visibility,
                        );
                      },
                      child: Text(context.tr('common.share')),
                    ),
                  ],
                ),
          ),
    );
  }

  String _getVisibilityLabel(RoutineVisibility visibility) {
    switch (visibility) {
      case RoutineVisibility.public:
        return context.tr('dataManagement.public');
      case RoutineVisibility.unlisted:
        return context.tr('dataManagement.unlisted');
      case RoutineVisibility.private:
        return context.tr('dataManagement.private');
    }
  }

  Future<void> _createSharedRoutine(
    BuildContext context,
    String title,
    String description,
    RoutineVisibility visibility,
  ) async {
    try {
      // Mostrar indicador de progreso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              content: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Text(context.tr('dataManagement.sharingRoutine')),
                ],
              ),
            ),
      );

      // TODO: Implementar creación de rutina compartida
      // final shareConfig = ShareConfig(
      //   title: title,
      //   description: description,
      //   visibility: visibility,
      //   allowDownload: true,
      //   allowComments: true,
      // );

      // Simular tiempo de compartición
      await Future.delayed(const Duration(seconds: 2));

      // Cerrar indicador de progreso
      if (mounted) Navigator.of(context).pop();

      // Mostrar resultado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('dataManagement.shareSuccess')),
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
                'dataManagement.shareError',
                namedArgs: {'error': e.toString()},
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewSharedRoutines(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Mis Rutinas Compartidas'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView(
                children: [
                  _buildSharedRoutineItem(
                    'Rutina de Fuerza',
                    context.tr('dataManagement.public'),
                    '15 vistas • 3 descargas',
                    SharedRoutineStatus.active,
                  ),
                  _buildSharedRoutineItem(
                    'Rutina de Cardio',
                    'No listado',
                    '5 vistas • 1 descarga',
                    SharedRoutineStatus.active,
                  ),
                ],
              ),
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

  Widget _buildSharedRoutineItem(
    String name,
    String visibility,
    String stats,
    SharedRoutineStatus status,
  ) {
    final statusColor =
        status == SharedRoutineStatus.active
            ? Colors.green
            : status == SharedRoutineStatus.expired
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(Icons.share, color: statusColor),
        title: Text(name),
        subtitle: Text('$visibility • $stats'),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showSharedRoutineOptions(context, name),
        ),
      ),
    );
  }

  void _showSharedRoutineOptions(BuildContext context, String routineName) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Editando rutina compartida...'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Copiar Enlace'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enlace copiado al portapapeles'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Eliminar'),
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmDeleteSharedRoutine(context, routineName);
                },
              ),
            ],
          ),
    );
  }

  void _confirmDeleteSharedRoutine(BuildContext context, String routineName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Rutina Compartida'),
            content: Text(
              context.tr(
                'dataManagement.deleteSharedRoutineDescription',
                namedArgs: {'routineName': routineName},
              ),
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
                    const SnackBar(
                      content: Text('Rutina compartida eliminada'),
                    ),
                  );
                },
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  Future<void> _importSharedRoutine(BuildContext context) async {
    final shareIdController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Importar Rutina Compartida'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ingresa el ID o enlace de la rutina compartida que quieres importar.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: shareIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID o Enlace',
                    hintText: 'https://liftup.app/share/abc123',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.tr('common.cancel')),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _processSharedRoutineImport(context, shareIdController.text);
                },
                child: const Text('Importar'),
              ),
            ],
          ),
    );
  }

  Future<void> _processSharedRoutineImport(
    BuildContext context,
    String shareId,
  ) async {
    try {
      // Mostrar indicador de progreso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Importando rutina...'),
                ],
              ),
            ),
      );

      // TODO: Implementar importación de rutina compartida
      // Simular tiempo de importación
      await Future.delayed(const Duration(seconds: 2));

      // Cerrar indicador de progreso
      if (mounted) Navigator.of(context).pop();

      // Mostrar resultado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Rutina importada exitosamente'),
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
            content: Text('❌ Error al importar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
