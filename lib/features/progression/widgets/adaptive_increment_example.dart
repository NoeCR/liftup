import 'package:flutter/material.dart';

import '../../../common/enums/muscle_group_enum.dart';
import '../../exercise/models/exercise.dart';
import '../configs/adaptive_increment_config.dart';

/// Widget de ejemplo que demuestra el uso del sistema de incrementos adaptativos
/// con soporte para incrementos de peso y series basados en loadType
class AdaptiveIncrementExample extends StatelessWidget {
  const AdaptiveIncrementExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ejemplo de Incrementos Adaptativos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sistema de Incrementos Adaptativos',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              'Este sistema determina automáticamente los incrementos de peso y series '
              'apropiados según el tipo de ejercicio (multiJoint vs isolation) y el tipo '
              'de carga (barbell, dumbbell, machine, etc.).',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Ejemplos de ejercicios
            ..._buildExerciseExamples(context),

            const SizedBox(height: 24),

            // Información sobre rangos
            _buildRangeInformation(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildExerciseExamples(BuildContext context) {
    final exercises = [
      // Ejercicios multiJoint
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
      Exercise(
        id: 'leg_press',
        name: 'Prensa de Piernas',
        description: 'Ejercicio en máquina',
        imageUrl: 'assets/images/leg_press.png',
        exerciseType: ExerciseType.multiJoint,
        loadType: LoadType.machine,
        muscleGroups: [MuscleGroup.rectusFemoris, MuscleGroup.gluteusMaximus],
        tips: ['Mantén los pies separados al ancho de los hombros', 'No bloquees las rodillas'],
        commonMistakes: ['Bajar demasiado las rodillas', 'Usar solo los dedos de los pies'],
        category: ExerciseCategory.quadriceps,
        difficulty: ExerciseDifficulty.beginner,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    return exercises.map((exercise) => _buildExerciseCard(context, exercise)).toList();
  }

  Widget _buildExerciseCard(BuildContext context, Exercise exercise) {
    final weightIncrement = AdaptiveIncrementConfig.getDefaultIncrement(exercise);
    final seriesIncrement = AdaptiveIncrementConfig.getDefaultSeriesIncrement(exercise);
    final weightRange = AdaptiveIncrementConfig.getIncrementRange(exercise);
    final seriesRange = AdaptiveIncrementConfig.getSeriesIncrementRange(exercise);
    final weightDescription = AdaptiveIncrementConfig.getIncrementDescription(exercise);
    final seriesDescription = AdaptiveIncrementConfig.getSeriesIncrementDescription(exercise);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                _buildTypeChip(context, exercise.exerciseType.name),
                const SizedBox(width: 8),
                _buildLoadTypeChip(context, exercise.loadType.name),
              ],
            ),
            const SizedBox(height: 12),

            // Incrementos de peso
            _buildIncrementSection(
              context,
              'Incremento de Peso',
              weightIncrement,
              weightRange,
              weightDescription,
              'kg',
            ),

            const SizedBox(height: 12),

            // Incrementos de series
            _buildIncrementSection(
              context,
              'Incremento de Series',
              seriesIncrement.toDouble(),
              seriesRange != null
                  ? IncrementRange(
                    min: seriesRange.min.toDouble(),
                    max: seriesRange.max.toDouble(),
                    defaultValue: seriesRange.defaultValue.toDouble(),
                  )
                  : null,
              seriesDescription,
              'serie(s)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncrementSection(
    BuildContext context,
    String title,
    double value,
    IncrementRange? range,
    String description,
    String unit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              'Por defecto: ${value.toStringAsFixed(1)}$unit',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            if (range != null) ...[
              const SizedBox(width: 16),
              Text(
                'Rango: ${range.min.toStringAsFixed(1)}-${range.max.toStringAsFixed(1)}$unit',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ),
      ],
    );
  }

  Widget _buildTypeChip(BuildContext context, String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type == 'multiJoint' ? 'Compuesto' : 'Aislamiento',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLoadTypeChip(BuildContext context, String loadType) {
    final color = _getLoadTypeColor(loadType);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _getLoadTypeDisplayName(loadType),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  Color _getLoadTypeColor(String loadType) {
    switch (loadType) {
      case 'barbell':
        return Colors.blue;
      case 'dumbbell':
        return Colors.green;
      case 'machine':
        return Colors.orange;
      case 'cable':
        return Colors.purple;
      case 'kettlebell':
        return Colors.red;
      case 'plate':
        return Colors.teal;
      case 'bodyweight':
        return Colors.brown;
      case 'resistanceBand':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String _getLoadTypeDisplayName(String loadType) {
    switch (loadType) {
      case 'barbell':
        return 'Barra';
      case 'dumbbell':
        return 'Mancuernas';
      case 'machine':
        return 'Máquina';
      case 'cable':
        return 'Cable';
      case 'kettlebell':
        return 'Kettlebell';
      case 'plate':
        return 'Discos';
      case 'bodyweight':
        return 'Peso Corporal';
      case 'resistanceBand':
        return 'Banda Elástica';
      default:
        return loadType;
    }
  }

  Widget _buildRangeInformation(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información sobre Rangos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildInfoRow(
              context,
              'Ejercicios Compuestos',
              'Mayores incrementos de peso, incrementos de series moderados',
            ),
            _buildInfoRow(
              context,
              'Ejercicios de Aislamiento',
              'Menores incrementos de peso, incrementos de series moderados',
            ),
            _buildInfoRow(context, 'Peso Corporal', 'Sin incremento de peso, mayor flexibilidad en series'),
            _buildInfoRow(context, 'Bandas Elásticas', 'Sin incremento de peso, mayor flexibilidad en series'),
            _buildInfoRow(context, 'Máquinas', 'Incrementos moderados, mayor flexibilidad en series'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(description, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}
