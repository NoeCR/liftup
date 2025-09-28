import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../notifiers/routine_notifier.dart';
import '../models/routine.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: CreateRoutinePage build() llamado');
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

                    // Navigate to exercise selection
                    context.push(
                      '/exercise-selection?title=Agregar Ejercicios&subtitle=Selecciona ejercicios para tu rutina',
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

    final days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

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
      final routineId = DateTime.now().millisecondsSinceEpoch.toString();
      final routine = Routine(
        id: routineId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        days:
            _selectedDays.map((day) {
              final dayId = '${day}_${DateTime.now().millisecondsSinceEpoch}';
              return RoutineDay(
                id: dayId,
                routineId: routineId,
                dayOfWeek: _getWeekDayFromString(day),
                name: day,
                sections: [
                  RoutineSection(
                    id: 'warmup_${DateTime.now().millisecondsSinceEpoch}',
                    routineDayId: dayId,
                    name: 'Calentamiento',
                    exercises: [],
                    isCollapsed: false,
                    order: 0,
                  ),
                  RoutineSection(
                    id: 'main_${DateTime.now().millisecondsSinceEpoch}',
                    routineDayId: dayId,
                    name: 'Ejercicios Principales',
                    exercises: [],
                    isCollapsed: false,
                    order: 1,
                  ),
                  RoutineSection(
                    id: 'cooldown_${DateTime.now().millisecondsSinceEpoch}',
                    routineDayId: dayId,
                    name: 'Enfriamiento',
                    exercises: [],
                    isCollapsed: false,
                    order: 2,
                  ),
                ],
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

      // Navigate back to home
      Navigator.of(context).pop();
    }
  }

  WeekDay _getWeekDayFromString(String day) {
    switch (day.toLowerCase()) {
      case 'lunes':
        return WeekDay.monday;
      case 'martes':
        return WeekDay.tuesday;
      case 'miércoles':
        return WeekDay.wednesday;
      case 'jueves':
        return WeekDay.thursday;
      case 'viernes':
        return WeekDay.friday;
      case 'sábado':
        return WeekDay.saturday;
      case 'domingo':
        return WeekDay.sunday;
      default:
        return WeekDay.monday;
    }
  }
}
