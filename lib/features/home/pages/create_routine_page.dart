import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../notifiers/routine_notifier.dart';
import '../notifiers/routine_section_template_notifier.dart';
import '../models/routine.dart';
import '../models/routine_section_template.dart';
import '../../../common/enums/week_day_enum.dart';
import '../../../common/enums/section_muscle_group_enum.dart';
import '../../../core/navigation/app_router.dart';
import 'package:easy_localization/easy_localization.dart';

class CreateRoutinePage extends ConsumerStatefulWidget {
  final Routine? routineToEdit; // For editing existing routines

  const CreateRoutinePage({super.key, this.routineToEdit});

  @override
  ConsumerState<CreateRoutinePage> createState() => _CreateRoutinePageState();
}

class _CreateRoutinePageState extends ConsumerState<CreateRoutinePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final Set<String> _selectedDays = <String>{};
  final Set<String> _selectedSectionIds = <String>{};
  late final String _routineId;
  late final bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.routineToEdit != null;
    _routineId = widget.routineToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    if (_isEditing) {
      _nameController.text = widget.routineToEdit!.name;
      _descriptionController.text = widget.routineToEdit!.description;
      _selectedDays.addAll(widget.routineToEdit!.days.map((day) => day.displayName));
      _selectedSectionIds.addAll(widget.routineToEdit!.sections.map((section) => section.sectionTemplateId ?? ''));
    }

    // Add listeners to update button state
    _nameController.addListener(_updateButtonState);
    _descriptionController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      // This will force rebuild and update the button
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateButtonState);
    _descriptionController.removeListener(_updateButtonState);
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Rutina' : 'Crear Nueva Rutina'),
        backgroundColor: colorScheme.surface,
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: () => _showDeleteConfirmation(context),
              icon: const Icon(Icons.delete),
              tooltip: 'Eliminar rutina',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Routine Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre de la rutina', hintText: context.tr('routine.nameHint')),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre para la rutina';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Routine Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: context.tr('routine.description'),
                  hintText: 'Describe tu rutina...',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.tr('routine.descriptionRequired');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Days of Week Section
              Text(
                context.tr('routine.weekDays'),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Days Selection
              _buildDaysSelection(),
              const SizedBox(height: 24),

              // Sections Selection
              Text('Secciones de la rutina', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Sections Selection
              _buildSectionsSelection(),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _canSaveRoutine() ? _saveRoutine : null,
                  icon: Icon(_isEditing ? Icons.save : Icons.add),
                  label: Text(_isEditing ? 'Guardar Cambios' : 'Crear Rutina'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaysSelection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final days = WeekDayExtension.allDisplayNames;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          days.map((day) {
            return FilterChip(
              label: Text(day),
              selected: _selectedDays.contains(day),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDays.add(day);
                  } else {
                    _selectedDays.remove(day);
                  }
                });
              },
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.onPrimaryContainer,
            );
          }).toList(),
    );
  }

  Widget _buildSectionsSelection() {
    return Consumer(
      builder: (context, ref, child) {
        final sectionTemplatesAsync = ref.watch(routineSectionTemplateNotifierProvider);

        return sectionTemplatesAsync.when(
          data: (templates) {
            if (templates.isEmpty) {
              return _buildEmptySectionsState();
            }

            // Group by categories
            final groupedTemplates = <String, List<RoutineSectionTemplate>>{};
            for (final template in templates) {
              final category = _getCategoryName(template.muscleGroup);
              groupedTemplates.putIfAbsent(category, () => []).add(template);
            }

            return Column(
              children:
                  groupedTemplates.entries.map((entry) {
                    return _buildCategorySection(entry.key, entry.value);
                  }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(error),
        );
      },
    );
  }

  Widget _buildCategorySection(String category, List<RoutineSectionTemplate> templates) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            category,
            style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
          ),
        ),
        ...templates.map((template) => _buildSectionTemplateCard(template)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSectionTemplateCard(RoutineSectionTemplate template) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedSectionIds.contains(template.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              _selectedSectionIds.add(template.id);
            } else {
              _selectedSectionIds.remove(template.id);
            }
          });
        },
        title: Text(template.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle:
            template.description != null
                ? Text(
                  template.description!,
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                )
                : null,
        secondary: Icon(
          _getIconData(template.iconName),
          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        activeColor: colorScheme.primary,
        checkColor: colorScheme.onPrimary,
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
      ),
    );
  }

  Widget _buildEmptySectionsState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.settings_suggest, size: 48, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            'No hay secciones disponibles',
            style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('routine.goToSettingsToCreateTemplates'),
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.push(AppRouter.sectionTemplates),
            icon: const Icon(Icons.settings),
            label: Text(context.tr('routine.configureSections')),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: colorScheme.error),
          const SizedBox(height: 12),
          Text('Error al cargar secciones', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.error)),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  bool _canSaveRoutine() {
    return _nameController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _selectedDays.isNotEmpty &&
        _selectedSectionIds.isNotEmpty;
  }

  void _saveRoutine() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('routine.selectAtLeastOneDay')), backgroundColor: Colors.red));
      return;
    }

    if (_selectedSectionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('routine.selectAtLeastOneSection')), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      if (_isEditing) {
        await _updateRoutine();
      } else {
        await _createNewRoutine();
      }

      // Cerrar indicador de carga
      if (mounted) Navigator.of(context).pop();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Rutina actualizada exitosamente'
                  : 'Rutina "${_nameController.text.trim()}" creada exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar al home
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go('/');
        }
      }
    } catch (e) {
      // Close loading indicator if open
      if (mounted) Navigator.of(context).pop();

      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al ${_isEditing ? 'actualizar' : 'crear'} rutina: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _createNewRoutine() async {
    // Create basic routine first
    final routine = Routine(
      id: _routineId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      days: _selectedDays.map((day) => WeekDayExtension.fromString(day)).toList(),
      sections: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Guardar rutina
    await ref.read(routineNotifierProvider.notifier).addRoutine(routine);

    // Agregar secciones seleccionadas
    await ref.read(routineNotifierProvider.notifier).addSectionsToRoutine(_routineId, _selectedSectionIds.toList());
  }

  Future<void> _updateRoutine() async {
    if (widget.routineToEdit == null) return;

    // Crear rutina actualizada
    final updatedRoutine = widget.routineToEdit!.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      days: _selectedDays.map((day) => WeekDayExtension.fromString(day)).toList(),
      updatedAt: DateTime.now(),
    );

    // Actualizar rutina
    await ref.read(routineNotifierProvider.notifier).updateRoutine(updatedRoutine);

    // Actualizar secciones si han cambiado
    final currentSectionIds =
        widget.routineToEdit!.sections
            .map((section) => section.sectionTemplateId ?? '')
            .where((id) => id.isNotEmpty)
            .toSet();

    if (currentSectionIds != _selectedSectionIds) {
      // Eliminar secciones existentes y agregar las nuevas
      final routineWithEmptySections = updatedRoutine.copyWith(sections: []);
      await ref.read(routineNotifierProvider.notifier).updateRoutine(routineWithEmptySections);

      // Agregar nuevas secciones
      await ref.read(routineNotifierProvider.notifier).addSectionsToRoutine(_routineId, _selectedSectionIds.toList());
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.tr('routine.deleteRoutine')),
            content: Text(
              context.tr('routine.deleteRoutineDescription', namedArgs: {'routineName': _nameController.text.trim()}),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.tr('common.cancel'))),
              FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _deleteRoutine();
                },
                style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                child: Text(context.tr('common.delete')),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteRoutine() async {
    try {
      await ref.read(routineNotifierProvider.notifier).deleteRoutine(_routineId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('routine.routineDeletedSuccess')), backgroundColor: Colors.green),
        );

        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('routine.routineDeleteError'.tr(namedArgs: {'error': e.toString()})),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getCategoryName(SectionMuscleGroup? muscleGroup) {
    if (muscleGroup == null) return 'Otros';

    switch (muscleGroup) {
      case SectionMuscleGroup.warmup:
      case SectionMuscleGroup.cooldown:
        return context.tr('routine.preparationAndRecovery');
      case SectionMuscleGroup.chest:
      case SectionMuscleGroup.back:
      case SectionMuscleGroup.shoulders:
      case SectionMuscleGroup.trapezius:
        return 'Torso Superior';
      case SectionMuscleGroup.biceps:
      case SectionMuscleGroup.triceps:
        return 'Brazos';
      case SectionMuscleGroup.quadriceps:
      case SectionMuscleGroup.hamstrings:
      case SectionMuscleGroup.calves:
        return 'Piernas';
      case SectionMuscleGroup.core:
        return 'Core';
      case SectionMuscleGroup.cardio:
        return 'Cardio';
    }
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
      case 'spa':
        return Icons.spa;
      case 'air':
        return Icons.air;
      case 'thermostat':
        return Icons.thermostat;
      default:
        return Icons.fitness_center;
    }
  }
}
