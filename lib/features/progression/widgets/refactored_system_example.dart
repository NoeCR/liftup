import 'package:flutter/material.dart';

import '../../../common/enums/muscle_group_enum.dart';
import '../../exercise/models/exercise.dart';
import '../configs/adaptive_increment_config.dart';
import '../configs/preset_progression_configs.dart';
import '../models/progression_config.dart';

/// Widget de ejemplo que demuestra el sistema refactorizado
/// donde AdaptiveIncrementConfig es la única fuente de verdad
/// para incrementos por exerciseType y loadType
class RefactoredSystemExample extends StatefulWidget {
  const RefactoredSystemExample({super.key});

  @override
  State<RefactoredSystemExample> createState() => _RefactoredSystemExampleState();
}

class _RefactoredSystemExampleState extends State<RefactoredSystemExample> {
  ProgressionConfig? _selectedPreset;
  Exercise? _selectedExercise;

  final List<Exercise> _exampleExercises = [
    Exercise(
      id: '1',
      name: 'Press de Banca',
      description: 'Ejercicio compuesto para el desarrollo del pecho',
      imageUrl: '',
      muscleGroups: [MuscleGroup.pectoralMajor, MuscleGroup.anteriorDeltoid, MuscleGroup.tricepsLongHead],
      tips: ['Mantén los pies firmes en el suelo', 'Contrae el core durante el movimiento'],
      commonMistakes: ['Arquear demasiado la espalda', 'Rebotar el peso en el pecho'],
      category: ExerciseCategory.chest,
      difficulty: ExerciseDifficulty.intermediate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      exerciseType: ExerciseType.multiJoint,
      loadType: LoadType.barbell,
    ),
    Exercise(
      id: '2',
      name: 'Curl de Bíceps',
      description: 'Ejercicio de aislamiento para el desarrollo del bíceps',
      imageUrl: '',
      muscleGroups: [MuscleGroup.bicepsLongHead, MuscleGroup.bicepsShortHead],
      tips: ['Mantén los codos pegados al cuerpo', 'Controla el movimiento en ambas direcciones'],
      commonMistakes: ['Balancear el peso', 'Usar demasiado peso'],
      category: ExerciseCategory.biceps,
      difficulty: ExerciseDifficulty.beginner,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      exerciseType: ExerciseType.isolation,
      loadType: LoadType.dumbbell,
    ),
    Exercise(
      id: '3',
      name: 'Flexiones',
      description: 'Ejercicio de peso corporal para el desarrollo del pecho',
      imageUrl: '',
      muscleGroups: [MuscleGroup.pectoralMajor, MuscleGroup.anteriorDeltoid, MuscleGroup.tricepsLongHead],
      tips: ['Mantén el cuerpo recto', 'Baja hasta tocar el suelo con el pecho'],
      commonMistakes: ['Arquear la espalda', 'No bajar lo suficiente'],
      category: ExerciseCategory.chest,
      difficulty: ExerciseDifficulty.beginner,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      exerciseType: ExerciseType.multiJoint,
      loadType: LoadType.bodyweight,
    ),
    Exercise(
      id: '4',
      name: 'Prensa de Piernas',
      description: 'Ejercicio en máquina para el desarrollo de las piernas',
      imageUrl: '',
      muscleGroups: [MuscleGroup.rectusFemoris, MuscleGroup.gluteusMaximus],
      tips: ['Mantén los pies separados al ancho de los hombros', 'No bloquees las rodillas'],
      commonMistakes: ['Bajar demasiado las rodillas', 'Usar solo los dedos de los pies'],
      category: ExerciseCategory.quadriceps,
      difficulty: ExerciseDifficulty.beginner,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      exerciseType: ExerciseType.multiJoint,
      loadType: LoadType.machine,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema Refactorizado - Ejemplo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título y descripción
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sistema Refactorizado',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ahora AdaptiveIncrementConfig es la única fuente de verdad para incrementos por exerciseType y loadType. Los presets ya no duplican esta lógica.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Selector de preset
            _buildPresetSelector(),

            const SizedBox(height: 24),

            // Selector de ejercicio
            _buildExerciseSelector(),

            const SizedBox(height: 24),

            // Resultado
            if (_selectedPreset != null && _selectedExercise != null) _buildResult(),
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
          'Seleccionar Preset',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              presets.map((preset) {
                final isSelected = _selectedPreset == preset;
                return FilterChip(
                  label: Text(_getPresetDisplayName(preset)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPreset = selected ? preset : null;
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

  Widget _buildResult() {
    final config = _selectedPreset!;
    final exercise = _selectedExercise!;

    // Obtener incrementos usando AdaptiveIncrementConfig
    final weightIncrement = config.getAdaptiveIncrement(exercise);
    final seriesIncrement = config.getAdaptiveSeriesIncrement(exercise);

    // Obtener información adicional
    final weightRange = AdaptiveIncrementConfig.getIncrementRange(exercise);
    final seriesRange = AdaptiveIncrementConfig.getSeriesIncrementRange(exercise);

    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Resultado del Sistema Refactorizado',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Información del preset
            _buildResultRow('Preset', _getPresetDisplayName(config)),
            _buildResultRow('Objetivo', config.getTrainingObjective()),

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
            if (weightRange != null) _buildResultRow('Rango de Peso', '${weightRange.min}-${weightRange.max} kg'),

            _buildResultRow('Incremento de Series', '$seriesIncrement serie(s)'),
            if (seriesRange != null)
              _buildResultRow('Rango de Series', '${seriesRange.min}-${seriesRange.max} serie(s)'),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Explicación
            Text(
              'Explicación:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getExplanation(config, exercise, weightIncrement, seriesIncrement),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }

  String _getPresetDisplayName(ProgressionConfig config) {
    final objective = config.getTrainingObjective();
    final type = config.type.displayName;
    return '$objective - $type';
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

    explanation += 'Estos valores se obtienen automáticamente de AdaptiveIncrementConfig ';
    explanation += 'basándose en el tipo de ejercicio ($exerciseType) y el tipo de carga ($loadType). ';

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
