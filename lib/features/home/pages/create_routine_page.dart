import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../notifiers/routine_notifier.dart';
import '../models/routine.dart';
import '../../../common/enums/week_day_enum.dart';
import '../../../core/navigation/app_router.dart';

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
        title: const Text('Crear Nueva Rutina'),
        backgroundColor: colorScheme.surface,
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

              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Después de crear la rutina, podrás añadir secciones personalizadas (Pecho, Espalda, Cardio, etc.) y luego ejercicios específicos a cada sección.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Add Sections Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
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

                    // Save routine first, then navigate to section selection
                    _saveRoutineAndNavigateToSections();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Crear Rutina y Añadir Secciones'),
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

  void _saveRoutineAndNavigateToSections() {
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
      final routine = _createRoutine();

      // Save routine using the notifier
      ref.read(routineNotifierProvider.notifier).addRoutine(routine);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rutina "${routine.name}" creada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to section selection page
      context.push('${AppRouter.sectionSelection}?routineId=${_routineId}');
    }
  }

  Routine _createRoutine() {
    return Routine(
      id: _routineId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      days:
          _selectedDays.map((day) => WeekDayExtension.fromString(day)).toList(),
      sections: [], // No crear secciones automáticamente
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
