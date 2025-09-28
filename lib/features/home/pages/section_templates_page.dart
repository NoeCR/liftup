import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/routine_section_template_notifier.dart';
import '../models/routine_section_template.dart';
import '../../../common/widgets/custom_bottom_navigation.dart';

class SectionTemplatesPage extends ConsumerStatefulWidget {
  const SectionTemplatesPage({super.key});

  @override
  ConsumerState<SectionTemplatesPage> createState() => _SectionTemplatesPageState();
}

class _SectionTemplatesPageState extends ConsumerState<SectionTemplatesPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Secciones'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSectionDialog(context),
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final sectionTemplatesAsync = ref.watch(routineSectionTemplateNotifierProvider);

          return sectionTemplatesAsync.when(
            data: (templates) => _buildSectionTemplatesList(templates, colorScheme),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorState(error, colorScheme),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 3),
    );
  }

  Widget _buildSectionTemplatesList(
    List<RoutineSectionTemplate> templates,
    ColorScheme colorScheme,
  ) {
    if (templates.isEmpty) {
      return _buildEmptyState(colorScheme);
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: templates.length,
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final item = templates.removeAt(oldIndex);
        templates.insert(newIndex, item);
        ref.read(routineSectionTemplateNotifierProvider.notifier)
            .reorderSectionTemplates(templates);
      },
      itemBuilder: (context, index) {
        final template = templates[index];
        return _buildSectionTemplateCard(template, colorScheme);
      },
    );
  }

  Widget _buildSectionTemplateCard(
    RoutineSectionTemplate template,
    ColorScheme colorScheme,
  ) {
    return Card(
      key: ValueKey(template.id),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(
            _getIconData(template.iconName),
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(template.name),
        subtitle: template.description != null
            ? Text(template.description!)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!template.isDefault)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditSectionDialog(context, template),
              ),
            if (!template.isDefault)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmation(context, template),
              ),
            const Icon(Icons.drag_handle),
          ],
        ),
        onTap: () => _showEditSectionDialog(context, template),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings_suggest_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay secciones configuradas',
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón + para agregar tu primera sección',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar las secciones',
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'warm_up':
        return Icons.whatshot;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'sports_gymnastics':
        return Icons.sports_gymnastics;
      case 'pool':
        return Icons.pool;
      case 'directions_run':
        return Icons.directions_run;
      case 'sports_martial_arts':
        return Icons.sports_martial_arts;
      case 'sports_tennis':
        return Icons.sports_tennis;
      case 'sports_basketball':
        return Icons.sports_basketball;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'sports_volleyball':
        return Icons.sports_volleyball;
      case 'sports_handball':
        return Icons.sports_handball;
      case 'sports_kabaddi':
        return Icons.sports_kabaddi;
      case 'sports_motorsports':
        return Icons.sports_motorsports;
      case 'sports_mma':
        return Icons.sports_mma;
      case 'sports_rugby':
        return Icons.sports_rugby;
      case 'sports_cricket':
        return Icons.sports_cricket;
      case 'sports_golf':
        return Icons.sports_golf;
      case 'sports_hockey':
        return Icons.sports_hockey;
      case 'sports_baseball':
        return Icons.sports_baseball;
      case 'sports_football':
        return Icons.sports_football;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'sports':
        return Icons.sports;
      case 'sports_score':
        return Icons.sports_score;
      case 'sports_bar':
        return Icons.sports_bar;
      case 'sports_cafe':
        return Icons.local_cafe;
      default:
        return Icons.fitness_center;
    }
  }

  void _showAddSectionDialog(BuildContext context) {
    _showSectionDialog(context, null);
  }

  void _showEditSectionDialog(BuildContext context, RoutineSectionTemplate template) {
    _showSectionDialog(context, template);
  }

  void _showSectionDialog(BuildContext context, RoutineSectionTemplate? template) {
    final nameController = TextEditingController(text: template?.name ?? '');
    final descriptionController = TextEditingController(text: template?.description ?? '');
    String selectedIcon = template?.iconName ?? 'fitness_center';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(template == null ? 'Agregar Sección' : 'Editar Sección'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la sección',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Text(
                  'Seleccionar ícono:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    'warm_up',
                    'fitness_center',
                    'self_improvement',
                    'sports_gymnastics',
                    'pool',
                    'directions_run',
                    'sports_martial_arts',
                    'sports_tennis',
                    'sports_basketball',
                    'sports_soccer',
                  ].map((iconName) {
                    return GestureDetector(
                      onTap: () => setState(() => selectedIcon = iconName),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selectedIcon == iconName
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getIconData(iconName),
                          color: selectedIcon == iconName
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  if (template == null) {
                    ref.read(routineSectionTemplateNotifierProvider.notifier)
                        .addSectionTemplate(
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim().isEmpty
                          ? null
                          : descriptionController.text.trim(),
                      iconName: selectedIcon,
                    );
                  } else {
                    ref.read(routineSectionTemplateNotifierProvider.notifier)
                        .updateSectionTemplate(
                      template.copyWith(
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text.trim(),
                        iconName: selectedIcon,
                      ),
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text(template == null ? 'Agregar' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, RoutineSectionTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Sección'),
        content: Text('¿Estás seguro de que quieres eliminar la sección "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(routineSectionTemplateNotifierProvider.notifier)
                  .deleteSectionTemplate(template.id);
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
