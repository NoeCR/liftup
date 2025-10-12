import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/enums/progression_type_enum.dart';
import '../../exercise/models/exercise.dart';
import '../configs/adaptive_increment_config.dart';
import '../models/progression_config.dart';
import 'advanced_progression_config.dart';

/// Ejemplo de integración del sistema de incrementos adaptativos
/// en la configuración de progresión
class AdaptiveConfigIntegrationExample extends ConsumerStatefulWidget {
  const AdaptiveConfigIntegrationExample({super.key});

  @override
  ConsumerState<AdaptiveConfigIntegrationExample> createState() => _AdaptiveConfigIntegrationExampleState();
}

class _AdaptiveConfigIntegrationExampleState extends ConsumerState<AdaptiveConfigIntegrationExample> {
  ProgressionType _selectedProgressionType = ProgressionType.linear;
  Exercise? _selectedExercise;
  ProgressionConfig? _currentConfig;

  // Ejemplos de ejercicios
  final List<Exercise> exampleExercises = [
    Exercise(
      id: 'bench_press',
      name: 'Press de Banca',
      description: 'Ejercicio multiarticular con barra',
      imageUrl: '',
      muscleGroups: [],
      tips: [],
      commonMistakes: [],
      category: ExerciseCategory.chest,
      difficulty: ExerciseDifficulty.intermediate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      exerciseType: ExerciseType.multiJoint,
      loadType: LoadType.barbell,
    ),
    Exercise(
      id: 'dumbbell_press',
      name: 'Press con Mancuernas',
      description: 'Ejercicio multiarticular con mancuernas',
      imageUrl: '',
      muscleGroups: [],
      tips: [],
      commonMistakes: [],
      category: ExerciseCategory.chest,
      difficulty: ExerciseDifficulty.intermediate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      exerciseType: ExerciseType.multiJoint,
      loadType: LoadType.dumbbell,
    ),
    Exercise(
      id: 'bicep_curl',
      name: 'Curl de Bíceps',
      description: 'Ejercicio aislado con mancuernas',
      imageUrl: '',
      muscleGroups: [],
      tips: [],
      commonMistakes: [],
      category: ExerciseCategory.biceps,
      difficulty: ExerciseDifficulty.beginner,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      exerciseType: ExerciseType.isolation,
      loadType: LoadType.dumbbell,
    ),
    Exercise(
      id: 'tricep_extension',
      name: 'Extensión de Tríceps',
      description: 'Ejercicio aislado con cable',
      imageUrl: '',
      muscleGroups: [],
      tips: [],
      commonMistakes: [],
      category: ExerciseCategory.triceps,
      difficulty: ExerciseDifficulty.beginner,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      exerciseType: ExerciseType.isolation,
      loadType: LoadType.cable,
    ),
    Exercise(
      id: 'push_ups',
      name: 'Flexiones',
      description: 'Ejercicio de peso corporal',
      imageUrl: '',
      muscleGroups: [],
      tips: [],
      commonMistakes: [],
      category: ExerciseCategory.chest,
      difficulty: ExerciseDifficulty.beginner,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      exerciseType: ExerciseType.multiJoint,
      loadType: LoadType.bodyweight,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración Adaptativa - Ejemplo'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título y descripción
            Text(
              'Sistema de Configuración Adaptativa',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Este ejemplo muestra cómo el sistema de incrementos adaptativos se integra en la configuración de progresión.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Selector de tipo de progresión
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1. Tipo de Progresión',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<ProgressionType>(
                      value: _selectedProgressionType,
                      decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Tipo de Progresión'),
                      items:
                          ProgressionType.values.map((type) {
                            return DropdownMenuItem(value: type, child: Text(type.displayName));
                          }).toList(),
                      onChanged: (type) {
                        setState(() {
                          _selectedProgressionType = type!;
                          _currentConfig = null; // Reset config when type changes
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Selector de ejercicio
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2. Ejercicio (Opcional)',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selecciona un ejercicio para ver cómo se adaptan los incrementos automáticamente.',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Exercise>(
                      value: _selectedExercise,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Ejercicio',
                        helperText: 'Opcional: para incrementos adaptativos',
                      ),
                      items: [
                        const DropdownMenuItem<Exercise>(value: null, child: Text('Sin ejercicio específico')),
                        ...exampleExercises.map((exercise) {
                          return DropdownMenuItem(
                            value: exercise,
                            child: Text('${exercise.name} (${exercise.exerciseType.name} + ${exercise.loadType.name})'),
                          );
                        }),
                      ],
                      onChanged: (exercise) {
                        setState(() {
                          _selectedExercise = exercise;
                        });
                      },
                    ),

                    // Mostrar información del ejercicio seleccionado
                    if (_selectedExercise != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información del Ejercicio:',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            _buildInfoRow('Tipo', _selectedExercise!.exerciseType.name),
                            _buildInfoRow('Carga', _selectedExercise!.loadType.name),
                            _buildInfoRow(
                              'Incremento recomendado',
                              '${AdaptiveIncrementConfig.getDefaultIncrement(_selectedExercise!)} kg',
                            ),
                            _buildInfoRow(
                              'Descripción',
                              AdaptiveIncrementConfig.getIncrementDescription(_selectedExercise!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Configuración avanzada
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3. Configuración Avanzada',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configura la progresión con presets adaptativos o configuración manual.',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 16),

                    // Widget de configuración avanzada
                    AdvancedProgressionConfig(
                      progressionType: _selectedProgressionType,
                      initialConfig: _currentConfig,
                      onConfigChanged: (config) {
                        setState(() {
                          _currentConfig = config;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Mostrar configuración final
            if (_currentConfig != null) ...[
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Configuración Final',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Tipo de Progresión', _currentConfig!.type.displayName),
                      _buildInfoRow('Incremento', '${_currentConfig!.incrementValue} kg'),
                      _buildInfoRow(
                        'Frecuencia',
                        'Cada ${_currentConfig!.incrementFrequency} ${_currentConfig!.unit.name}',
                      ),
                      _buildInfoRow('Rango de Reps', '${_currentConfig!.minReps}-${_currentConfig!.maxReps}'),
                      _buildInfoRow('Series Base', '${_currentConfig!.baseSets}'),
                      _buildInfoRow(
                        'Duración del Ciclo',
                        '${_currentConfig!.cycleLength} ${_currentConfig!.unit.name}',
                      ),
                      if (_selectedExercise != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)),
                          child: Row(
                            children: [
                              Icon(Icons.auto_awesome, size: 16, color: Colors.blue[600]),
                              const SizedBox(width: 8),
                              Text(
                                'Incremento adaptativo para ${_selectedExercise!.name}: ${_currentConfig!.incrementValue} kg',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Explicación del sistema
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Cómo funciona el sistema adaptativo?',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Selecciona un tipo de progresión (lineal, escalonada, etc.)\n'
                      '2. Opcionalmente, selecciona un ejercicio específico\n'
                      '3. El sistema adapta automáticamente los incrementos según:\n'
                      '   • Tipo de ejercicio (multiarticular vs aislado)\n'
                      '   • Tipo de carga (barra, mancuerna, máquina, etc.)\n'
                      '4. Los presets se ajustan para ser más efectivos para ese ejercicio específico',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
