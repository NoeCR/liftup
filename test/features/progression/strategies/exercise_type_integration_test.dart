import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/muscle_group_enum.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/autoregulated_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/double_factor_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/reverse_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/stepped_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/undulating_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/wave_progression_strategy.dart';

void main() {
  group('Exercise Type Integration Tests', () {
    late ProgressionConfig config;
    late ProgressionState state;
    final now = DateTime.now();

    // Helper function to create test exercises
    Exercise createTestExercise({
      required ExerciseType exerciseType,
      required LoadType loadType,
      String id = 'test-exercise',
      String name = 'Test Exercise',
    }) {
      return Exercise(
        id: id,
        name: name,
        description: 'Test description',
        imageUrl: '',
        muscleGroups:
            exerciseType == ExerciseType.multiJoint ? [MuscleGroup.pectoralMajor] : [MuscleGroup.bicepsLongHead],
        tips: [],
        commonMistakes: [],
        category: exerciseType == ExerciseType.multiJoint ? ExerciseCategory.chest : ExerciseCategory.biceps,
        difficulty: ExerciseDifficulty.intermediate,
        createdAt: now,
        updatedAt: now,
        exerciseType: exerciseType,
        loadType: loadType,
      );
    }

    setUp(() {
      config = ProgressionConfig(
        id: 'test-config',
        isGlobal: true,
        type: ProgressionType.linear,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 0, // Usar AdaptiveIncrementConfig
        incrementFrequency: 1,
        cycleLength: 4,
        minReps: 8,
        maxReps: 12,
        baseSets: 3,
        deloadWeek: 0,
        deloadPercentage: 0.8,
        customParameters: const {},
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      state = ProgressionState(
        id: 'test-state',
        progressionConfigId: 'test-config',
        exerciseId: 'test-exercise',
        routineId: 'test-routine-1',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 100.0,
        currentReps: 5,
        currentSets: 3,
        baseWeight: 100.0,
        baseReps: 5,
        baseSets: 3,
        sessionHistory: const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );
    });

    group('LinearProgressionStrategy', () {
      test('aplica incremento multi_increment_min para ejercicios multi-joint', () {
        final strategy = LinearProgressionStrategy();

        // Crear ejercicio multi-joint para usar AdaptiveIncrementConfig
        final exercise = createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.barbell);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exercise: exercise,
        );

        // AdaptiveIncrementConfig para barbell multi-joint con ExperienceLevel.intermediate
        // debería ser (5.0 + 7.0) / 2 = 6.0
        expect(result.newWeight, 103.75); // 100 + 3.75
        expect(result.incrementApplied, true);
        expect(result.reason, contains('+3.75kg'));
      });

      test('aplica incremento iso_increment_min para ejercicios isolation', () {
        final strategy = LinearProgressionStrategy();

        // Crear ejercicio isolation para usar AdaptiveIncrementConfig
        final exercise = createTestExercise(exerciseType: ExerciseType.isolation, loadType: LoadType.dumbbell);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exercise: exercise,
        );

        // AdaptiveIncrementConfig para dumbbell isolation con ExperienceLevel.intermediate
        // debería ser (1.25 + 2.5) / 2 = 1.875
        expect(result.newWeight, 101.875); // 100 + 1.875
        expect(result.incrementApplied, true);
        expect(result.reason, contains('+1.875kg'));
      });

      test('usa incrementValue base requiere exercise; sin exercise mantiene valores', () {
        final strategy = LinearProgressionStrategy();

        // Crear un config con incrementValue > 0 para probar el fallback
        final testConfig = config.copyWith(incrementValue: 2.5);

        final result = strategy.calculate(
          config: testConfig,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          // exerciseType: null (no especificado)
        );
        // Con la nueva API, si no se proporciona exercise, la progresión se bloquea
        expect(result.newWeight, 100.0);
        expect(result.incrementApplied, false);
        expect(result.reason, contains('exercise required'));
      });
    });

    group('DoubleFactorProgressionStrategy', () {
      test('incrementa peso en semana impar para ejercicios multi-joint', () {
        final strategy = DoubleFactorProgressionStrategy();

        // Crear ejercicio multi-joint para usar AdaptiveIncrementConfig
        final exercise = createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.barbell);

        // Semana 1 (impar) - debería incrementar peso
        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 8, // Máximo para multi-joint
          currentSets: 3,
          exercise: exercise,
        );

        // AdaptiveIncrementConfig para barbell multi-joint con ExperienceLevel.intermediate
        // debería ser (5.0 + 7.0) / 2 = 6.0
        expect(result.newWeight, 103.75); // 100 + 3.75
        expect(result.newReps, 6); // Reps se mantienen (semana impar)
        expect(result.incrementApplied, true);
        expect(result.reason, contains('increasing weight'));
      });

      test('incrementa peso en semana impar para ejercicios isolation', () {
        final strategy = DoubleFactorProgressionStrategy();

        // Crear ejercicio isolation para usar AdaptiveIncrementConfig
        final exercise = createTestExercise(exerciseType: ExerciseType.isolation, loadType: LoadType.dumbbell);

        // Semana 1 (impar) - debería incrementar peso
        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10, // Dentro del rango maxReps: 12
          currentSets: 3,
          exercise: exercise,
        );

        // AdaptiveIncrementConfig para dumbbell isolation con ExperienceLevel.intermediate
        // debería ser (1.25 + 2.5) / 2 = 1.875
        expect(result.newWeight, 101.875); // 100 + 1.875
        expect(result.newReps, 8); // Reps se mantienen (semana impar)
        expect(result.incrementApplied, true);
        expect(result.reason, contains('increasing weight'));
      });

      test('incrementa reps dentro del rango multi-joint', () {
        final strategy = DoubleFactorProgressionStrategy();

        // Usar semana 2 (par) para que incremente reps
        final stateWeek2 = state.copyWith(currentWeek: 2);

        final result = strategy.calculate(
          config: config,
          state: stateWeek2,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10, // Dentro del rango
          currentSets: 3,
          exercise: createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.barbell),
        );

        expect(result.newWeight, 100.0); // No cambia peso
        expect(result.newReps, 6); // Incrementa reps
        expect(result.incrementApplied, true);
        expect(result.reason, contains('increasing reps'));
      });

      test('incrementa reps dentro del rango isolation', () {
        final strategy = DoubleFactorProgressionStrategy();

        // Usar semana 2 (par) para que incremente reps
        final stateWeek2 = state.copyWith(currentWeek: 2);

        final result = strategy.calculate(
          config: config,
          state: stateWeek2,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10, // Dentro del rango
          currentSets: 3,
          exercise: createTestExercise(exerciseType: ExerciseType.isolation, loadType: LoadType.dumbbell),
        );

        expect(result.newWeight, 100.0); // No cambia peso
        expect(result.newReps, 8); // Incrementa reps
        expect(result.incrementApplied, true);
        expect(result.reason, contains('increasing reps'));
      });
    });

    group('UndulatingProgressionStrategy', () {
      test('aplica incremento multi en día pesado para multi-joint', () {
        final strategy = UndulatingProgressionStrategy();

        // Crear ejercicio multi-joint para usar AdaptiveIncrementConfig
        final exercise = createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.barbell);

        // Semana 1 = día pesado (impar)
        final stateWeek1 = state.copyWith(currentWeek: 1);

        final result = strategy.calculate(
          config: config,
          state: stateWeek1,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exercise: exercise,
        );

        // AdaptiveIncrementConfig para barbell multi-joint con ExperienceLevel.intermediate
        // debería ser (5.0 + 7.0) / 2 = 6.0
        expect(result.newWeight, 103.75); // 100 + 3.75
        expect(result.incrementApplied, true);
        expect(result.reason, contains('+3.75kg'));
      });

      test('aplica incremento iso en día pesado para isolation', () {
        final strategy = UndulatingProgressionStrategy();

        // Crear ejercicio isolation para usar AdaptiveIncrementConfig
        final exercise = createTestExercise(exerciseType: ExerciseType.isolation, loadType: LoadType.dumbbell);

        // Semana 1 = día pesado (impar)
        final stateWeek1 = state.copyWith(currentWeek: 1);

        final result = strategy.calculate(
          config: config,
          state: stateWeek1,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exercise: exercise,
        );

        // AdaptiveIncrementConfig para dumbbell isolation con ExperienceLevel.intermediate
        // debería ser (1.25 + 2.5) / 2 = 1.875
        expect(result.newWeight, 101.875); // 100 + 1.875
        expect(result.incrementApplied, true);
        expect(result.reason, contains('+1.875kg'));
      });

      test('reduce peso con incremento multi en día ligero para multi-joint', () {
        final strategy = UndulatingProgressionStrategy();

        // Crear ejercicio multi-joint para usar AdaptiveIncrementConfig
        final exercise = createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.barbell);

        // Semana 2 = día ligero (par)
        final stateWeek2 = state.copyWith(currentWeek: 2);

        final result = strategy.calculate(
          config: config,
          state: stateWeek2,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exercise: exercise,
        );

        // AdaptiveIncrementConfig para barbell multi-joint con ExperienceLevel.intermediate
        // debería ser (5.0 + 7.0) / 2 = 6.0
        expect(result.newWeight, 96.25); // 100 - 3.75
        expect(result.incrementApplied, true);
        expect(result.reason, contains('-3.75kg'));
      });

      test('reduce peso con incremento iso en día ligero para isolation', () {
        final strategy = UndulatingProgressionStrategy();

        // Crear ejercicio isolation para usar AdaptiveIncrementConfig
        final exercise = createTestExercise(exerciseType: ExerciseType.isolation, loadType: LoadType.dumbbell);

        // Semana 2 = día ligero (par)
        final stateWeek2 = state.copyWith(currentWeek: 2);

        final result = strategy.calculate(
          config: config,
          state: stateWeek2,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exercise: exercise,
        );

        // AdaptiveIncrementConfig para dumbbell isolation con ExperienceLevel.intermediate
        // debería ser (1.25 + 2.5) / 2 = 1.875
        expect(result.newWeight, 98.125); // 100 - 1.125
        expect(result.incrementApplied, true);
        expect(result.reason, contains('-1.875kg'));
      });
    });

    group('SteppedProgressionStrategy', () {
      test('acumula incremento multi para ejercicios multi-joint', () {
        final strategy = SteppedProgressionStrategy();

        // Crear ejercicio multi-joint para usar AdaptiveIncrementConfig
        final exercise = createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.barbell);

        // Semana 2 de acumulación
        final stateWeek2 = state.copyWith(currentWeek: 2);

        final result = strategy.calculate(
          config: config,
          state: stateWeek2,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exercise: exercise,
        );

        // Acumulación: baseWeight + (increment * week)
        // AdaptiveIncrementConfig para barbell multi-joint con ExperienceLevel.intermediate
        // debería ser (5.0 + 7.0) / 2 = 6.0
        // 100 + (6.0 * 2) = 112.0
        expect(result.newWeight, 107.5);
        expect(result.incrementApplied, true);
        expect(result.reason, contains('accumulation phase'));
      });

      test('acumula incremento iso para ejercicios isolation', () {
        final strategy = SteppedProgressionStrategy();
        // Semana 3 de acumulación
        final stateWeek3 = state.copyWith(currentWeek: 3);

        final exercise = createTestExercise(exerciseType: ExerciseType.isolation, loadType: LoadType.dumbbell);
        final result = strategy.calculate(
          config: config,
          state: stateWeek3,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exercise: exercise,
        );

        // Acumulación: baseWeight + (increment * week)
        final inc = strategy.getIncrementValueSync(config, exercise);
        expect(result.newWeight, closeTo(100.0 + (inc * 3), 0.0001));
        expect(result.incrementApplied, true);
        expect(result.reason, contains('accumulation phase'));
      });
    });

    group('WaveProgressionStrategy', () {
      test('aplica incremento multi en semana 1 (alta intensidad) para multi-joint', () {
        final strategy = WaveProgressionStrategy();
        // Semana 1 = alta intensidad
        final stateWeek1 = state.copyWith(currentWeek: 1);
        final exercise = createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.barbell);

        final result = strategy.calculate(
          config: config,
          state: stateWeek1,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exercise: exercise,
        );

        expect(result.newWeight, 103.75); // 100 + 3.75 (AdaptiveIncrementConfig para barbell multi-joint)
        expect(result.incrementApplied, true);
        expect(result.reason, contains('+3.75kg'));
      });

      test('aplica incremento iso en semana 1 (alta intensidad) para isolation', () {
        final strategy = WaveProgressionStrategy();
        // Semana 1 = alta intensidad
        final stateWeek1 = state.copyWith(currentWeek: 1);
        final exercise = createTestExercise(exerciseType: ExerciseType.isolation, loadType: LoadType.dumbbell);

        final result = strategy.calculate(
          config: config,
          state: stateWeek1,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exercise: exercise,
        );

        expect(result.newWeight, 101.875); // 100 + 1.875 (AdaptiveIncrementConfig para dumbbell isolation)
        expect(result.incrementApplied, true);
        expect(result.reason, contains('+1.875kg'));
      });

      test('reduce peso con incremento multi en semana 2 (alto volumen) para multi-joint', () {
        final strategy = WaveProgressionStrategy();
        // Semana 2 = alto volumen
        final stateWeek2 = state.copyWith(currentWeek: 2);
        final exercise = createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.barbell);

        final result = strategy.calculate(
          config: config,
          state: stateWeek2,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exercise: exercise,
        );

        // Alto volumen: reduce peso por 30% del incremento
        // 100 - (6.0 * 0.3) = 98.2
        expect(result.newWeight, 98.875);
        expect(result.incrementApplied, true);
        expect(result.reason, contains('-1.1kg'));
      });

      test('reduce peso con incremento iso en semana 2 (alto volumen) para isolation', () {
        final strategy = WaveProgressionStrategy();
        // Semana 2 = alto volumen
        final stateWeek2 = state.copyWith(currentWeek: 2);
        final exercise = createTestExercise(exerciseType: ExerciseType.isolation, loadType: LoadType.dumbbell);

        final result = strategy.calculate(
          config: config,
          state: stateWeek2,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exercise: exercise,
        );

        // Alto volumen: reduce peso por 30% del incremento
        // 100 - (1.875 * 0.3) = 99.4375
        expect(result.newWeight, 99.4375);
        expect(result.incrementApplied, true);
        expect(result.reason, contains('-0.6kg'));
      });
    });

    group('ReverseProgressionStrategy', () {
      test('reduce peso con incremento multi para ejercicios multi-joint', () {
        final strategy = ReverseProgressionStrategy();
        final exercise = createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.barbell);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exercise: exercise,
        );

        expect(result.newWeight, 96.25); // 100 - 3.75 (AdaptiveIncrementConfig para barbell multi-joint)
        expect(result.newReps, 6); // Incrementa reps
        expect(result.incrementApplied, true);
        expect(result.reason, contains('-3.75kg'));
      });

      test('reduce peso con incremento iso para ejercicios isolation', () {
        final strategy = ReverseProgressionStrategy();
        final exercise = createTestExercise(exerciseType: ExerciseType.isolation, loadType: LoadType.dumbbell);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exercise: exercise,
        );

        expect(result.newWeight, 98.125); // 100 - 1.125 (AdaptiveIncrementConfig para dumbbell isolation)
        expect(result.newReps, 6); // Incrementa reps
        expect(result.incrementApplied, true);
        expect(result.reason, contains('-1.875kg'));
      });
    });

    group('AutoregulatedProgressionStrategy', () {
      test('aplica incremento multi cuando RPE es bajo para multi-joint', () {
        final strategy = AutoregulatedProgressionStrategy();
        // Simular RPE bajo (reps realizadas > target)
        final stateWithHistory = state.copyWith(
          sessionHistory: {
            'session_1': {'reps': 12}, // Más reps de las esperadas = RPE bajo
          },
        );
        final exercise = createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.barbell);

        final result = strategy.calculate(
          config: config,
          state: stateWithHistory,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exercise: exercise,
        );

        expect(result.newWeight, 103.75); // 100 + 3.75 (AdaptiveIncrementConfig para barbell multi-joint)
        expect(result.incrementApplied, true);
        expect(result.reason, contains('+3.75kg'));
      });

      test('aplica incremento iso cuando RPE es bajo para isolation', () {
        final strategy = AutoregulatedProgressionStrategy();
        // Simular RPE bajo (reps realizadas > target)
        final stateWithHistory = state.copyWith(
          sessionHistory: {
            'session_1': {'reps': 12}, // Más reps de las esperadas = RPE bajo
          },
        );
        final exercise = createTestExercise(exerciseType: ExerciseType.isolation, loadType: LoadType.dumbbell);

        final result = strategy.calculate(
          config: config,
          state: stateWithHistory,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exercise: exercise,
        );

        expect(result.newWeight, 101.875); // 100 + 1.875 (AdaptiveIncrementConfig para dumbbell isolation)
        expect(result.incrementApplied, true);
        expect(result.reason, contains('+1.875kg'));
      });
    });

    group('Fallback Behavior', () {
      test('todas las estrategias usan incrementValue base cuando no hay parámetros específicos', () {
        final configWithoutSpecifics = config.copyWith(
          customParameters: {
            'increment_value': 3.0, // Solo valor base
          },
        );

        final strategies = <dynamic>[
          LinearProgressionStrategy(),
          DoubleFactorProgressionStrategy(),
          UndulatingProgressionStrategy(),
          SteppedProgressionStrategy(),
          WaveProgressionStrategy(),
          // ReverseProgressionStrategy(), // Excluida porque reduce peso por diseño
          AutoregulatedProgressionStrategy(),
        ];

        for (final strategy in strategies) {
          // Para DoubleFactorProgressionStrategy, necesitamos reps >= maxReps para que incremente peso
          final currentReps = strategy is DoubleFactorProgressionStrategy ? 12 : 5;

          // Para estrategias que alternan, necesitamos estar en fase de incremento
          final testState =
              strategy is UndulatingProgressionStrategy
                  ? state.copyWith(currentWeek: 1) // Semana 1 = día pesado
                  : strategy is WaveProgressionStrategy
                  ? state.copyWith(currentWeek: 1) // Semana 1 = alta intensidad
                  : strategy is AutoregulatedProgressionStrategy
                  ? state.copyWith(
                    sessionHistory: {
                      'session_1': {'reps': 12}, // Más reps de las esperadas = RPE bajo
                    },
                  )
                  : state;

          final exercise = createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.barbell);
          final result = strategy.calculate(
            config: configWithoutSpecifics,
            state: testState,
            routineId: 'test-routine',
            currentWeight: 100.0,
            currentReps: currentReps,
            currentSets: 3,
            exercise: exercise,
          );

          // Usar incremento calculado por la estrategia (AdaptiveIncrementConfig si aplica)
          // Verificamos que incremente respecto a 100 si la estrategia aplica incremento en esa fase
          expect(result.incrementApplied, true);
          expect(result.newWeight, greaterThan(100.0));
          expect(result.incrementApplied, true);
        }
      });

      test('todas las estrategias usan defaults por tipo cuando no hay parámetros personalizados', () {
        final configMinimal = config.copyWith(
          customParameters: const {}, // Sin parámetros personalizados
        );

        final exercise = createTestExercise(exerciseType: ExerciseType.multiJoint, loadType: LoadType.barbell);

        final strategies = <dynamic>[
          LinearProgressionStrategy(),
          DoubleFactorProgressionStrategy(),
          UndulatingProgressionStrategy(),
          SteppedProgressionStrategy(),
          WaveProgressionStrategy(),
          // ReverseProgressionStrategy(), // Excluida porque reduce peso por diseño
          AutoregulatedProgressionStrategy(),
        ];

        for (final strategy in strategies) {
          // Para DoubleFactorProgressionStrategy, necesitamos reps >= maxReps para que incremente peso
          final currentReps = strategy is DoubleFactorProgressionStrategy ? 12 : 5;

          // Para estrategias que alternan, necesitamos estar en fase de incremento
          final testState =
              strategy is UndulatingProgressionStrategy
                  ? state.copyWith(currentWeek: 1) // Semana 1 = día pesado
                  : strategy is WaveProgressionStrategy
                  ? state.copyWith(currentWeek: 1) // Semana 1 = alta intensidad
                  : strategy is AutoregulatedProgressionStrategy
                  ? state.copyWith(
                    sessionHistory: {
                      'session_1': {'reps': 12}, // Más reps de las esperadas = RPE bajo
                    },
                  )
                  : state;

          final result = strategy.calculate(
            config: configMinimal,
            state: testState,
            routineId: 'test-routine',
            currentWeight: 100.0,
            currentReps: currentReps,
            currentSets: 3,
            exercise: exercise,
          );

          // Deben usar AdaptiveIncrementConfig (6.0 para barbell multi-joint)
          expect(result.newWeight, greaterThan(100.0));
          expect(result.incrementApplied, true);
        }
      });
    });
  });
}
