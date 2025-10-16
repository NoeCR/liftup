import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/configs/adaptive_increment_config.dart';
import 'package:liftly/features/progression/configs/training_objective.dart';

void main() {
  group('AdaptiveIncrementConfig - Valores Optimizados', () {
    late Exercise multiJointBarbell;
    late Exercise isolationDumbbell;

    setUp(() {
      multiJointBarbell = Exercise(
        id: '1',
        name: 'Squat',
        description: 'Back squat exercise',
        imageUrl: '',
        muscleGroups: const [],
        tips: const [],
        commonMistakes: const [],
        category: ExerciseCategory.quadriceps,
        difficulty: ExerciseDifficulty.intermediate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        exerciseType: ExerciseType.multiJoint,
        loadType: LoadType.barbell,
      );

      isolationDumbbell = Exercise(
        id: '2',
        name: 'Bicep Curl',
        description: 'Bicep curl exercise',
        imageUrl: '',
        muscleGroups: const [],
        tips: const [],
        commonMistakes: const [],
        category: ExerciseCategory.biceps,
        difficulty: ExerciseDifficulty.beginner,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        exerciseType: ExerciseType.isolation,
        loadType: LoadType.dumbbell,
      );
    });

    group('Rangos de Repeticiones Optimizados', () {
      test('debería devolver rangos correctos para FUERZA', () {
        // Multi-joint
        final (minReps, maxReps) = AdaptiveIncrementConfig.getRepetitionsRange(
          multiJointBarbell,
          objective: TrainingObjective.strength,
        );
        expect(minReps, 3);
        expect(maxReps, 6);

        // Isolation
        final (minRepsIso, maxRepsIso) = AdaptiveIncrementConfig.getRepetitionsRange(
          isolationDumbbell,
          objective: TrainingObjective.strength,
        );
        expect(minRepsIso, 5);
        expect(maxRepsIso, 8);
      });

      test('debería devolver rangos correctos para HIPERTROFIA', () {
        // Multi-joint
        final (minReps, maxReps) = AdaptiveIncrementConfig.getRepetitionsRange(
          multiJointBarbell,
          objective: TrainingObjective.hypertrophy,
        );
        expect(minReps, 6);
        expect(maxReps, 12);

        // Isolation
        final (minRepsIso, maxRepsIso) = AdaptiveIncrementConfig.getRepetitionsRange(
          isolationDumbbell,
          objective: TrainingObjective.hypertrophy,
        );
        expect(minRepsIso, 8);
        expect(maxRepsIso, 15);
      });

      test('debería devolver rangos correctos para RESISTENCIA', () {
        // Multi-joint
        final (minReps, maxReps) = AdaptiveIncrementConfig.getRepetitionsRange(
          multiJointBarbell,
          objective: TrainingObjective.endurance,
        );
        expect(minReps, 15);
        expect(maxReps, 25);

        // Isolation
        final (minRepsIso, maxRepsIso) = AdaptiveIncrementConfig.getRepetitionsRange(
          isolationDumbbell,
          objective: TrainingObjective.endurance,
        );
        expect(minRepsIso, 20);
        expect(maxRepsIso, 30);
      });

      test('debería devolver rangos correctos para POTENCIA', () {
        // Multi-joint
        final (minReps, maxReps) = AdaptiveIncrementConfig.getRepetitionsRange(
          multiJointBarbell,
          objective: TrainingObjective.power,
        );
        expect(minReps, 1);
        expect(maxReps, 5);

        // Isolation
        final (minRepsIso, maxRepsIso) = AdaptiveIncrementConfig.getRepetitionsRange(
          isolationDumbbell,
          objective: TrainingObjective.power,
        );
        expect(minRepsIso, 3);
        expect(maxRepsIso, 8);
      });
    });

    group('Tiempos de Descanso Optimizados', () {
      test('debería devolver tiempos correctos para FUERZA', () {
        final restTime = AdaptiveIncrementConfig.getRestTimeSeconds(
          multiJointBarbell,
          objective: TrainingObjective.strength,
        );
        expect(restTime, 240); // 4 minutos

        final restTimeIso = AdaptiveIncrementConfig.getRestTimeSeconds(
          isolationDumbbell,
          objective: TrainingObjective.strength,
        );
        expect(restTimeIso, 180); // 3 minutos
      });

      test('debería devolver tiempos correctos para HIPERTROFIA', () {
        final restTime = AdaptiveIncrementConfig.getRestTimeSeconds(
          multiJointBarbell,
          objective: TrainingObjective.hypertrophy,
        );
        expect(restTime, 120); // 2 minutos

        final restTimeIso = AdaptiveIncrementConfig.getRestTimeSeconds(
          isolationDumbbell,
          objective: TrainingObjective.hypertrophy,
        );
        expect(restTimeIso, 90); // 1.5 minutos
      });

      test('debería devolver tiempos correctos para RESISTENCIA', () {
        final restTime = AdaptiveIncrementConfig.getRestTimeSeconds(
          multiJointBarbell,
          objective: TrainingObjective.endurance,
        );
        expect(restTime, 60); // 1 minuto

        final restTimeIso = AdaptiveIncrementConfig.getRestTimeSeconds(
          isolationDumbbell,
          objective: TrainingObjective.endurance,
        );
        expect(restTimeIso, 45); // 45 segundos
      });

      test('debería devolver tiempos correctos para POTENCIA', () {
        final restTime = AdaptiveIncrementConfig.getRestTimeSeconds(
          multiJointBarbell,
          objective: TrainingObjective.power,
        );
        expect(restTime, 300); // 5 minutos

        final restTimeIso = AdaptiveIncrementConfig.getRestTimeSeconds(
          isolationDumbbell,
          objective: TrainingObjective.power,
        );
        expect(restTimeIso, 180); // 3 minutos
      });
    });

    group('Series Base Optimizadas', () {
      test('debería devolver series correctas para FUERZA', () {
        final seriesRange = AdaptiveIncrementConfig.getSeriesIncrementRangeByObjective(
          multiJointBarbell,
          objective: TrainingObjective.strength,
        );
        expect(seriesRange?.min, 1);
        expect(seriesRange?.max, 2);
        expect(seriesRange?.defaultValue, 1);

        final seriesRangeIso = AdaptiveIncrementConfig.getSeriesIncrementRangeByObjective(
          isolationDumbbell,
          objective: TrainingObjective.strength,
        );
        expect(seriesRangeIso?.min, 1);
        expect(seriesRangeIso?.max, 2);
        expect(seriesRangeIso?.defaultValue, 1);
      });

      test('debería devolver series correctas para HIPERTROFIA', () {
        final seriesRange = AdaptiveIncrementConfig.getSeriesIncrementRangeByObjective(
          multiJointBarbell,
          objective: TrainingObjective.hypertrophy,
        );
        expect(seriesRange?.min, 1);
        expect(seriesRange?.max, 2);
        expect(seriesRange?.defaultValue, 1);

        final seriesRangeIso = AdaptiveIncrementConfig.getSeriesIncrementRangeByObjective(
          isolationDumbbell,
          objective: TrainingObjective.hypertrophy,
        );
        expect(seriesRangeIso?.min, 1);
        expect(seriesRangeIso?.max, 2);
        expect(seriesRangeIso?.defaultValue, 1);
      });

      test('debería devolver series correctas para RESISTENCIA', () {
        final seriesRange = AdaptiveIncrementConfig.getSeriesIncrementRangeByObjective(
          multiJointBarbell,
          objective: TrainingObjective.endurance,
        );
        expect(seriesRange?.min, 1);
        expect(seriesRange?.max, 3);
        expect(seriesRange?.defaultValue, 2);

        final seriesRangeIso = AdaptiveIncrementConfig.getSeriesIncrementRangeByObjective(
          isolationDumbbell,
          objective: TrainingObjective.endurance,
        );
        expect(seriesRangeIso?.min, 1);
        expect(seriesRangeIso?.max, 2);
        expect(seriesRangeIso?.defaultValue, 1);
      });

      test('debería devolver series correctas para POTENCIA', () {
        final seriesRange = AdaptiveIncrementConfig.getSeriesIncrementRangeByObjective(
          multiJointBarbell,
          objective: TrainingObjective.power,
        );
        expect(seriesRange?.min, 1);
        expect(seriesRange?.max, 2);
        expect(seriesRange?.defaultValue, 1);

        final seriesRangeIso = AdaptiveIncrementConfig.getSeriesIncrementRangeByObjective(
          isolationDumbbell,
          objective: TrainingObjective.power,
        );
        expect(seriesRangeIso?.min, 1);
        expect(seriesRangeIso?.max, 2);
        expect(seriesRangeIso?.defaultValue, 1);
      });
    });

    group('Incrementos de Peso Optimizados', () {
      test('debería devolver incrementos correctos para FUERZA', () {
        final increment = AdaptiveIncrementConfig.getRecommendedIncrementByObjective(
          multiJointBarbell,
          ExperienceLevel.intermediate,
          objective: TrainingObjective.strength,
        );
        expect(increment, 6.25); // Valor optimizado para fuerza

        final incrementIso = AdaptiveIncrementConfig.getRecommendedIncrementByObjective(
          isolationDumbbell,
          ExperienceLevel.intermediate,
          objective: TrainingObjective.strength,
        );
        expect(incrementIso, 1.875); // Valor conservador para aislamiento
      });

      test('debería devolver incrementos correctos para HIPERTROFIA', () {
        final increment = AdaptiveIncrementConfig.getRecommendedIncrementByObjective(
          multiJointBarbell,
          ExperienceLevel.intermediate,
          objective: TrainingObjective.hypertrophy,
        );
        expect(increment, 3.75); // Valor optimizado para hipertrofia

        final incrementIso = AdaptiveIncrementConfig.getRecommendedIncrementByObjective(
          isolationDumbbell,
          ExperienceLevel.intermediate,
          objective: TrainingObjective.hypertrophy,
        );
        expect(incrementIso, 1.625); // Valor moderado para aislamiento
      });

      test('debería devolver incrementos correctos para RESISTENCIA', () {
        final increment = AdaptiveIncrementConfig.getRecommendedIncrementByObjective(
          multiJointBarbell,
          ExperienceLevel.intermediate,
          objective: TrainingObjective.endurance,
        );
        expect(increment, 1.875); // Valor pequeño para resistencia

        final incrementIso = AdaptiveIncrementConfig.getRecommendedIncrementByObjective(
          isolationDumbbell,
          ExperienceLevel.intermediate,
          objective: TrainingObjective.endurance,
        );
        expect(incrementIso, 1.25); // Valor muy pequeño para aislamiento
      });

      test('debería devolver incrementos correctos para POTENCIA', () {
        final increment = AdaptiveIncrementConfig.getRecommendedIncrementByObjective(
          multiJointBarbell,
          ExperienceLevel.intermediate,
          objective: TrainingObjective.power,
        );
        expect(increment, 7.5); // Valor agresivo para potencia

        final incrementIso = AdaptiveIncrementConfig.getRecommendedIncrementByObjective(
          isolationDumbbell,
          ExperienceLevel.intermediate,
          objective: TrainingObjective.power,
        );
        expect(incrementIso, 1.875); // Valor moderado-agresivo para aislamiento
      });
    });

    group('Derivación de Nivel de Experiencia', () {
      test('debería derivar nivel correcto por dificultad del ejercicio', () {
        final beginnerExercise = Exercise(
          id: '3',
          name: 'Wall Push-up',
          description: 'Beginner exercise',
          imageUrl: '',
          muscleGroups: const [],
          tips: const [],
          commonMistakes: const [],
          category: ExerciseCategory.chest,
          difficulty: ExerciseDifficulty.beginner,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          exerciseType: ExerciseType.multiJoint,
          loadType: LoadType.bodyweight,
        );

        final advancedExercise = Exercise(
          id: '4',
          name: 'Muscle-up',
          description: 'Advanced exercise',
          imageUrl: '',
          muscleGroups: const [],
          tips: const [],
          commonMistakes: const [],
          category: ExerciseCategory.chest,
          difficulty: ExerciseDifficulty.advanced,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          exerciseType: ExerciseType.multiJoint,
          loadType: LoadType.bodyweight,
        );

        // Beginner -> Initiated
        final incrementBeginner = AdaptiveIncrementConfig.getRecommendedIncrementByObjective(
          beginnerExercise,
          ExperienceLevel.initiated,
          objective: TrainingObjective.hypertrophy,
        );
        expect(incrementBeginner, 0.0); // Valor mínimo

        // Advanced -> Advanced
        final incrementAdvanced = AdaptiveIncrementConfig.getRecommendedIncrementByObjective(
          advancedExercise,
          ExperienceLevel.advanced,
          objective: TrainingObjective.hypertrophy,
        );
        expect(incrementAdvanced, 0.0); // Valor máximo
      });
    });

    group('Compatibilidad con Fallbacks', () {
      test('debería usar valores por defecto cuando no se especifica objetivo', () {
        final (minReps, maxReps) = AdaptiveIncrementConfig.getRepetitionsRange(multiJointBarbell);
        expect(minReps, 6); // Fallback a hipertrofia
        expect(maxReps, 12);

        final increment = AdaptiveIncrementConfig.getDefaultIncrement(multiJointBarbell);
        expect(increment, 2.5); // Fallback a hipertrofia
      });

      test('debería manejar ejercicios con tipos de carga especiales', () {
        final bodyweightExercise = Exercise(
          id: '5',
          name: 'Push-up',
          description: 'Bodyweight exercise',
          imageUrl: '',
          muscleGroups: const [],
          tips: const [],
          commonMistakes: const [],
          category: ExerciseCategory.chest,
          difficulty: ExerciseDifficulty.intermediate,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          exerciseType: ExerciseType.multiJoint,
          loadType: LoadType.bodyweight,
        );

        final increment = AdaptiveIncrementConfig.getRecommendedIncrementByObjective(
          bodyweightExercise,
          ExperienceLevel.intermediate,
          objective: TrainingObjective.hypertrophy,
        );
        expect(increment, 0.0); // Sin incremento de peso para peso corporal
      });
    });
  });
}
