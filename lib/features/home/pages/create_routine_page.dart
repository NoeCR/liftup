import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../notifiers/routine_notifier.dart';
import '../notifiers/routine_section_template_notifier.dart';
import '../models/routine.dart';
import '../../../common/enums/week_day_enum.dart';
import '../../../common/enums/section_muscle_group_enum.dart';

class CreateRoutinePage extends ConsumerStatefulWidget {
  const CreateRoutinePage({super.key});

  @override
  ConsumerState<CreateRoutinePage> createState() => _CreateRoutinePageState();
}

class _CreateRoutinePageState extends ConsumerState<CreateRoutinePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final Set<String> _selectedDays = <String>{};
  final String _routineId = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void dispose() {
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
        title: const Text('Crear Rutina'),
        backgroundColor: colorScheme.surface,
        actions: [
          TextButton(onPressed: _saveRoutine, child: const Text('Guardar')),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Routine Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la rutina',
                  hintText: 'Ej: Rutina de Pecho y Tríceps',
                ),
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
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe tu rutina...',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Days of Week Section
              Text(
                'Días de la semana',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Days Selection
              _buildDaysSelection(),
              const SizedBox(height: 24),

              // Add Exercise Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (_selectedDays.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Primero selecciona los días de la semana',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    // Navigate to exercise selection with routine context
                    context.push(
                      '/exercise-selection?title=Agregar Ejercicios&subtitle=Selecciona ejercicios para tu rutina&routineId=$_routineId',
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Ejercicios'),
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

  void _saveRoutine() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona al menos un día de la semana'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create routine with selected days
      final routine = Routine(
        id: _routineId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        days:
            _selectedDays.map((day) {
              final dayId = '${day}_${DateTime.now().millisecondsSinceEpoch}';
              return RoutineDay(
                id: dayId,
                routineId: _routineId,
                dayOfWeek: WeekDayExtension.fromString(day),
                name: day,
                sections: _buildSectionsFromTemplates(dayId),
                isActive: true,
              );
            }).toList(),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save routine using the notifier
      ref.read(routineNotifierProvider.notifier).addRoutine(routine);

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rutina "${routine.name}" creada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to section selection page for the first day
      if (routineDays.isNotEmpty) {
        final firstDay = routineDays.first;
        context.push(
          '${AppRouter.sectionSelection}?routineId=${_routineId}&dayId=${firstDay.id}',
        );
      } else {
        // Navigate back to home
        Navigator.of(context).pop();
      }
    }
  }

  List<RoutineSection> _buildSectionsFromTemplates(String dayId) {
    final sectionTemplates =
        ref.read(routineSectionTemplateNotifierProvider).value ?? [];

    return sectionTemplates.map((template) {
      return RoutineSection(
        id: '${template.id}_${DateTime.now().millisecondsSinceEpoch}',
        routineDayId: dayId,
        name: template.name,
        exercises: [],
        isCollapsed: false,
        order: template.order,
        sectionTemplateId: template.id,
        iconName: template.iconName,
        muscleGroup: template.muscleGroup ?? SectionMuscleGroup.chest,
      );
    }).toList();
  }
}
