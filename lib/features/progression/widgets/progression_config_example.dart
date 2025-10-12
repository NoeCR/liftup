import 'package:flutter/material.dart';

import '../../../common/enums/muscle_group_enum.dart';
import '../../../common/enums/progression_type_enum.dart';
import '../../exercise/models/exercise.dart';
import '../configs/preset_progression_configs.dart';
import '../models/progression_config.dart';

/// Widget de ejemplo que demuestra cómo usar el sistema de presets
/// con incrementos adaptativos basados en loadType
class ProgressionConfigExample extends StatefulWidget {
  const ProgressionConfigExample({super.key});

  @override
  State<ProgressionConfigExample> createState() => _ProgressionConfigExampleState();
}

class _ProgressionConfigExampleState extends State<ProgressionConfigExample> {
  ProgressionConfig? _selectedConfig;
  Exercise? _selectedExercise;

  final List<Exercise> _exampleExercises = [
    Exercise(
      id: 'bench_press',
      name: 'Press de Banca',
      description: 'Ejercicio compuesto para pecho',
      imageUrl: 'assets/images/bench_press.png',
      exerciseType: ExerciseType.multiJoint,
      loadType: LoadType.barbell,
      muscleGroups: [MuscleGroup.pectoralMajor, MuscleGroup.anteriorDeltoid, MuscleGroup.tricepsLongHead],
      tips: ['Mantén los pies firmes en el suelo', 'Contrae el core durante el movimiento'],
      commonMistakes: ['Arquear demasiado la espalda', 'Rebotar el peso en el pecho'],
      category: ExerciseCategory.chest,
      difficulty: ExerciseDifficulty.intermediate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Exercise(
      id: 'dumbbell_curls',
      name: 'Curls con Mancuernas',
      description: 'Ejercicio de aislamiento para bíceps',
      imageUrl: 'assets/images/dumbbell_curls.png',
      exerciseType: ExerciseType.isolation,
      loadType: LoadType.dumbbell,
      muscleGroups: [MuscleGroup.bicepsLongHead, MuscleGroup.bicepsShortHead],
      tips: ['Mantén los codos pegados al cuerpo', 'Controla el movimiento en ambas direcciones'],
      commonMistakes: ['Balancear el peso', 'Usar demasiado peso'],
      category: ExerciseCategory.biceps,
      difficulty: ExerciseDifficulty.beginner,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Exercise(
      id: 'push_ups',
      name: 'Flexiones',
      description: 'Ejercicio de peso corporal',
      imageUrl: 'assets/images/push_ups.png',
      exerciseType: ExerciseType.multiJoint,
      loadType: LoadType.bodyweight,
      muscleGroups: [MuscleGroup.pectoralMajor, MuscleGroup.anteriorDeltoid, MuscleGroup.tricepsLongHead],
      tips: ['Mantén el cuerpo recto', 'Baja hasta tocar el suelo con el pecho'],
      commonMistakes: ['Arquear la espalda', 'No bajar lo suficiente'],
      category: ExerciseCategory.chest,
      difficulty: ExerciseDifficulty.beginner,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ejemplo de Configuración de Progresión')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sistema de Presets con Incrementos Adaptativos',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              'Este ejemplo muestra cómo el sistema de presets se integra con '
              'los incrementos adaptativos basados en el loadType del ejercicio.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Selector de preset
            _buildPresetSelector(),

            const SizedBox(height: 24),

            // Selector de ejercicio
            _buildExerciseSelector(),

            const SizedBox(height: 24),

            // Resultado de la configuración
            if (_selectedConfig != null && _selectedExercise != null) _buildConfigurationResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetSelector() {
    final presets = PresetProgressionConfigs.getAllPresets();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleccionar Preset de Progresión',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              presets.map((preset) {
                final isSelected = _selectedConfig == preset;
                return FilterChip(
                  label: Text(_getPresetDisplayName(preset)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedConfig = selected ? preset : null;
                    });
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildExerciseSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleccionar Ejercicio',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _exampleExercises.map((exercise) {
                final isSelected = _selectedExercise == exercise;
                return FilterChip(
                  label: Text(exercise.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedExercise = selected ? exercise : null;
                    });
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildConfigurationResult() {
    final config = _selectedConfig!;
    final exercise = _selectedExercise!;

    // Obtener incrementos adaptativos
    final weightIncrement = config.getAdaptiveIncrement(exercise);
    final seriesIncrement = config.getAdaptiveSeriesIncrement(exercise);
    final minReps = config.getAdaptiveMinReps(exercise);
    final maxReps = config.getAdaptiveMaxReps(exercise);
    final baseSets = config.getAdaptiveBaseSets(exercise);

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración Adaptativa Resultante',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),

            // Información del preset
            _buildResultRow('Preset', _getPresetDisplayName(config)),
            _buildResultRow('Objetivo', config.getTrainingObjective()),
            _buildResultRow('Tipo de Progresión', _getProgressionTypeName(config.type)),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Información del ejercicio
            _buildResultRow('Ejercicio', exercise.name),
            _buildResultRow('Tipo', exercise.exerciseType.name),
            _buildResultRow('Carga', exercise.loadType.name),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Incrementos adaptativos
            _buildResultRow('Incremento de Peso', '${weightIncrement.toStringAsFixed(1)} kg'),
            _buildResultRow('Incremento de Series', '$seriesIncrement serie(s)'),
            _buildResultRow('Rango de Reps', '$minReps-$maxReps'),
            _buildResultRow('Series Base', '$baseSets'),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Explicación
            Text(
              'Explicación:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getExplanation(config, exercise, weightIncrement, seriesIncrement),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }

  String _getPresetDisplayName(ProgressionConfig config) {
    final objective = config.getTrainingObjective();
    final type = _getProgressionTypeName(config.type);
    return '$type - ${objective.toUpperCase()}';
  }

  String _getProgressionTypeName(ProgressionType type) {
    switch (type) {
      case ProgressionType.linear:
        return 'Lineal';
      case ProgressionType.stepped:
        return 'Escalonada';
      case ProgressionType.double:
        return 'Doble';
      case ProgressionType.undulating:
        return 'Ondulante';
      case ProgressionType.autoregulated:
        return 'Autoregulada';
      default:
        return type.name;
    }
  }

  String _getExplanation(ProgressionConfig config, Exercise exercise, double weightIncrement, int seriesIncrement) {
    final objective = config.getTrainingObjective();
    final loadType = exercise.loadType.name;
    final exerciseType = exercise.exerciseType.name;

    String explanation = 'Para el objetivo de $objective, ';

    if (weightIncrement == 0.0) {
      explanation += 'este ejercicio ($loadType) no incrementa peso, ';
    } else {
      explanation += 'el incremento de peso es de ${weightIncrement.toStringAsFixed(1)}kg ';
    }

    explanation += 'y el incremento de series es de $seriesIncrement. ';

    if (exerciseType == 'multiJoint') {
      explanation +=
          'Al ser un ejercicio compuesto, los incrementos están optimizados para movimientos multiarticulares.';
    } else {
      explanation +=
          'Al ser un ejercicio de aislamiento, los incrementos están ajustados para movimientos uniarticulares.';
    }

    return explanation;
  }
}
