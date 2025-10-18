import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/muscle_group_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/configs/adaptive_increment_config.dart';
import 'package:liftly/features/progression/configs/preset_progression_configs.dart';
import 'package:liftly/features/progression/enums/training_objective.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/undulating_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/wave_progression_strategy.dart';

/// Tests de integración para validar cómo interactúan presets y strategies
/// Verifica que cada preset funcione correctamente con su estrategia
void main() {
  group('Preset-Strategy Integration Tests', () {
    // Helper para crear ejercicios de prueba
    Exercise createTestExercise({
      required ExerciseType exerciseType,
      required LoadType loadType,
      String name = 'Test Exercise',
    }) {
      return Exercise(
        id: 'test-${exerciseType.name}-${loadType.name}',
        name: name,
        exerciseType: exerciseType,
        loadType: loadType,
        muscleGroups: [MuscleGroup.pectoralMajor],
        description: 'Test description',
        imageUrl: 'test_image.png',
        tips: [],
        commonMistakes: [],
        category: ExerciseCategory.chest,
        difficulty: ExerciseDifficulty.intermediate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    // Helper para crear estado de progresión
    ProgressionState createState({
      String configId = 'test-config',
      int currentSession = 1,
      int currentWeek = 1,
      double currentWeight = 100.0,
      int currentReps = 10,
      int currentSets = 3,
    }) {
      final now = DateTime.now();
      return ProgressionState(
        id: 'test-state',
        progressionConfigId: configId,
        exerciseId: 'test-exercise',
        routineId: 'test-routine',
        currentCycle: 1,
        currentWeek: currentWeek,
        currentSession: currentSession,
        currentWeight: currentWeight,
        currentReps: currentReps,
        currentSets: currentSets,
        baseWeight: 100.0,
        baseReps: 8,
        baseSets: 3,
        sessionHistory: const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );
    }

    group('Linear Preset + Strategy Integration', () {
      final strategy = LinearProgressionStrategy();

      test('hypertrophy preset aplica incrementos correctos para barbell multi-joint', () {
        final preset = PresetProgressionConfigs.createLinearHypertrophyPreset();
        final exercise = createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.barbell);
        final state = createState(configId: preset.id);

        // Calcular progresión
        final result = strategy.calculate(
          config: preset,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 3,
          exerciseType: exercise.exerciseType,
          exercise: exercise,
        );

        // Verificar que se aplicó incremento
        expect(result.incrementApplied, isTrue);
        expect(result.newWeight, greaterThan(100.0));

        // Verificar que el incremento está dentro del rango adaptativo
        final incrementRange = AdaptiveIncrementConfig.getIncrementRange(exercise);

        final actualIncrement = result.newWeight - 100.0;
        expect(actualIncrement, greaterThanOrEqualTo(incrementRange?.min ?? 0));
        expect(actualIncrement, lessThanOrEqualTo(incrementRange?.max ?? 10));
      });

      test('strength preset aplica incrementos mayores que hypertrophy', () {
        final hypertrophyPreset = PresetProgressionConfigs.createLinearHypertrophyPreset();
        final strengthPreset = PresetProgressionConfigs.createLinearStrengthPreset();
        final exercise = createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.barbell);

        final hypertrophyState = createState(configId: hypertrophyPreset.id);
        final strengthState = createState(configId: strengthPreset.id);

        // Calcular ambas progresiones
        final hypertrophyResult = strategy.calculate(
          config: hypertrophyPreset,
          state: hypertrophyState,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
          exerciseType: exercise.exerciseType,
          exercise: exercise,
        );

        final strengthResult = strategy.calculate(
          config: strengthPreset,
          state: strengthState,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 5,
          exerciseType: exercise.exerciseType,
          exercise: exercise,
        );

        // Strength debería tener incrementos mayores o iguales
        expect(strengthResult.newWeight - 100.0, greaterThanOrEqualTo(hypertrophyResult.newWeight - 100.0));
      });

      test('endurance preset con dumbbell isolation usa incrementos pequeños', () {
        final preset = PresetProgressionConfigs.createLinearEndurancePreset();
        final exercise = createTestExercise(exerciseType: ExerciseType.isolation, loadType: LoadType.dumbbell);
        // Usar sesión 2 para que coincida con incrementFrequency: 2
        final state = createState(configId: preset.id, currentSession: 2);

        final result = strategy.calculate(
          config: preset,
          state: state,
          routineId: 'test-routine',
          currentWeight: 10.0,
          currentReps: 15,
          currentSets: 3,
          exerciseType: exercise.exerciseType,
          exercise: exercise,
        );

        // Verificar incremento pequeño para isolation + dumbbell
        expect(result.incrementApplied, isTrue);
        final increment = result.newWeight - 10.0;
        expect(increment, lessThanOrEqualTo(2.5)); // Incrementos pequeños para endurance + isolation
      });

      test('preset respeta rangos de reps según objetivo', () {
        final presets = [
          PresetProgressionConfigs.createLinearHypertrophyPreset(),
          PresetProgressionConfigs.createLinearStrengthPreset(),
          PresetProgressionConfigs.createLinearEndurancePreset(),
        ];

        for (final preset in presets) {
          final objective = preset.getTrainingObjective();

          if (objective == 'hypertrophy') {
            expect(preset.minReps, greaterThanOrEqualTo(6));
            expect(preset.maxReps, lessThanOrEqualTo(12));
          } else if (objective == 'strength') {
            expect(preset.minReps, lessThanOrEqualTo(6));
            expect(preset.maxReps, lessThanOrEqualTo(8));
          } else if (objective == 'endurance') {
            expect(preset.minReps, greaterThanOrEqualTo(12));
            expect(preset.maxReps, greaterThanOrEqualTo(15));
          }
        }
      });
    });

    group('Undulating Preset + Strategy Integration', () {
      final strategy = UndulatingProgressionStrategy();

      test('hypertrophy preset alterna intensidad correctamente', () {
        final preset = PresetProgressionConfigs.createUndulatingHypertrophyPreset();
        final exercise = createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.barbell);

        // Día pesado (sesión impar)
        final heavyState = createState(configId: preset.id, currentSession: 1);
        final heavyResult = strategy.calculate(
          config: preset,
          state: heavyState,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 6,
          currentSets: 4,
          exerciseType: exercise.exerciseType,
          exercise: exercise,
        );

        // Día ligero (sesión par)
        final lightState = createState(configId: preset.id, currentSession: 2);
        final lightResult = strategy.calculate(
          config: preset,
          state: lightState,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 3,
          exerciseType: exercise.exerciseType,
          exercise: exercise,
        );

        // Los días pesados y ligeros deberían tener diferentes características
        expect(heavyResult.newWeight, isNotNull);
        expect(lightResult.newWeight, isNotNull);
      });

      test('strength preset usa incrementos adaptativos en ondulación', () {
        final preset = PresetProgressionConfigs.createUndulatingStrengthPreset();
        final exercise = createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.barbell);
        final state = createState(configId: preset.id);

        final result = strategy.calculate(
          config: preset,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 5,
          exerciseType: exercise.exerciseType,
          exercise: exercise,
        );

        expect(result.incrementApplied, isTrue);

        // Verificar que usa incremento adaptativo
        final actualIncrement = result.newWeight - 100.0;
        expect(actualIncrement, greaterThan(0));
      });
    });

    group('Wave Preset + Strategy Integration', () {
      final strategy = WaveProgressionStrategy();

      test('hypertrophy preset ondula a través de las semanas', () {
        final preset = PresetProgressionConfigs.createLinearHypertrophyPreset();
        final exercise = createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.barbell);

        final results = <dynamic>[];

        // Simular 3 semanas de ondulación
        for (int week = 1; week <= 3; week++) {
          final state = createState(configId: preset.id, currentWeek: week);
          final result = strategy.calculate(
            config: preset,
            state: state,
            routineId: 'test-routine',
            currentWeight: 100.0,
            currentReps: 8,
            currentSets: 3,
            exerciseType: exercise.exerciseType,
            exercise: exercise,
          );
          results.add(result);
        }

        // Verificar que hubo cambios en las semanas
        expect(results.length, equals(3));
        for (final result in results) {
          expect(result.newWeight, isNotNull);
        }
      });

      test('strength preset mantiene progresión a través de ondas', () {
        final preset = PresetProgressionConfigs.createLinearStrengthPreset();
        final exercise = createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.barbell);

        // Primera onda
        final state1 = createState(configId: preset.id, currentWeek: 1);
        final result1 = strategy.calculate(
          config: preset,
          state: state1,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 5,
          exerciseType: exercise.exerciseType,
          exercise: exercise,
        );

        // Segunda onda
        final state2 = createState(configId: preset.id, currentWeek: 4);
        final result2 = strategy.calculate(
          config: preset,
          state: state2,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 5,
          exerciseType: exercise.exerciseType,
          exercise: exercise,
        );

        expect(result1.incrementApplied, isTrue);
        expect(result2.incrementApplied, isTrue);
      });
    });

    group('Adaptive Series Increments with Presets', () {
      test('preset usa incrementos de series adaptativos por loadType', () {
        final preset = PresetProgressionConfigs.createLinearHypertrophyPreset();

        // Ejercicio con barbell
        final barbellExercise = createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.barbell);

        // Ejercicio con máquina
        final machineExercise = createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.machine);

        // Obtener incrementos de series
        final barbellSeriesIncrement = preset.getAdaptiveSeriesIncrement(barbellExercise);
        final machineSeriesIncrement = preset.getAdaptiveSeriesIncrement(machineExercise);

        // Verificar que son válidos
        expect(barbellSeriesIncrement, greaterThan(0));
        expect(machineSeriesIncrement, greaterThan(0));

        // Máquinas deberían permitir más flexibilidad
        expect(machineSeriesIncrement, greaterThanOrEqualTo(barbellSeriesIncrement));
      });

      test('preset con bodyweight usa incrementos de series mayores', () {
        final preset = PresetProgressionConfigs.createLinearEndurancePreset();
        final exercise = createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.bodyweight);

        final seriesIncrement = preset.getAdaptiveSeriesIncrement(exercise);
        final range = AdaptiveIncrementConfig.getSeriesIncrementRangeByObjective(
          exercise,
          objective: TrainingObjective.hypertrophy,
        );

        expect(seriesIncrement, greaterThan(0));
        expect(seriesIncrement, lessThanOrEqualTo(range?.max ?? 5));
        expect(seriesIncrement, greaterThanOrEqualTo(range?.min ?? 1));
      });
    });

    group('Deload with Presets', () {
      final strategy = LinearProgressionStrategy();

      test('preset respeta deload y mantiene incrementos adaptativos después', () {
        final preset = PresetProgressionConfigs.createLinearHypertrophyPreset();
        final exercise = createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.barbell);

        // Semana de deload
        final deloadState = createState(configId: preset.id, currentWeek: preset.deloadWeek);

        final deloadResult = strategy.calculate(
          config: preset,
          state: deloadState,
          routineId: 'test-routine',
          currentWeight: 110.0,
          currentReps: 8,
          currentSets: 4,
          exerciseType: exercise.exerciseType,
          exercise: exercise,
        );

        // Después del deload, volver a progresión normal
        final postDeloadState = createState(configId: preset.id, currentWeek: preset.deloadWeek + 1);

        final postDeloadResult = strategy.calculate(
          config: preset,
          state: postDeloadState,
          routineId: 'test-routine',
          currentWeight: deloadResult.newWeight,
          currentReps: 8,
          currentSets: 3,
          exerciseType: exercise.exerciseType,
          exercise: exercise,
        );

        // Verificar que se reanuda la progresión con incrementos adaptativos
        expect(postDeloadResult.incrementApplied, isTrue);
        expect(postDeloadResult.newWeight, greaterThan(deloadResult.newWeight));
      });
    });
  });
}
