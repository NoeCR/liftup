import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/muscle_group_enum.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/wave_progression_strategy.dart';

void main() {
  group('Cycle Calculation Tests', () {
    // Matriz de ejercicios para cubrir ExerciseType + LoadType
    List<Exercise> getTestExercises() {
      final now = DateTime.now();
      return [
        Exercise(
          id: 'ex-barbell-multi',
          name: 'Barbell Squat',
          description: 'Test',
          imageUrl: '',
          muscleGroups: const [MuscleGroup.rectusFemoris],
          tips: const [],
          commonMistakes: const [],
          category: ExerciseCategory.quadriceps,
          difficulty: ExerciseDifficulty.intermediate,
          createdAt: now,
          updatedAt: now,
          exerciseType: ExerciseType.multiJoint,
          loadType: LoadType.barbell,
        ),
        Exercise(
          id: 'ex-dumbbell-iso',
          name: 'Dumbbell Curl',
          description: 'Test',
          imageUrl: '',
          muscleGroups: const [MuscleGroup.bicepsLongHead],
          tips: const [],
          commonMistakes: const [],
          category: ExerciseCategory.biceps,
          difficulty: ExerciseDifficulty.beginner,
          createdAt: now,
          updatedAt: now,
          exerciseType: ExerciseType.isolation,
          loadType: LoadType.dumbbell,
        ),
        Exercise(
          id: 'ex-machine-multi',
          name: 'Leg Press',
          description: 'Test',
          imageUrl: '',
          muscleGroups: const [MuscleGroup.rectusFemoris],
          tips: const [],
          commonMistakes: const [],
          category: ExerciseCategory.quadriceps,
          difficulty: ExerciseDifficulty.beginner,
          createdAt: now,
          updatedAt: now,
          exerciseType: ExerciseType.multiJoint,
          loadType: LoadType.machine,
        ),
        Exercise(
          id: 'ex-bodyweight-multi',
          name: 'Pull Up',
          description: 'Test',
          imageUrl: '',
          muscleGroups: const [MuscleGroup.latissimusDorsi],
          tips: const [],
          commonMistakes: const [],
          category: ExerciseCategory.back,
          difficulty: ExerciseDifficulty.intermediate,
          createdAt: now,
          updatedAt: now,
          exerciseType: ExerciseType.multiJoint,
          loadType: LoadType.bodyweight,
        ),
        Exercise(
          id: 'ex-band-iso',
          name: 'Band Fly',
          description: 'Test',
          imageUrl: '',
          muscleGroups: const [MuscleGroup.pectoralMajor],
          tips: const [],
          commonMistakes: const [],
          category: ExerciseCategory.chest,
          difficulty: ExerciseDifficulty.beginner,
          createdAt: now,
          updatedAt: now,
          exerciseType: ExerciseType.isolation,
          loadType: LoadType.resistanceBand,
        ),
      ];
    }

    Exercise getIncrementalExercise() {
      final now = DateTime.now();
      return Exercise(
        id: 'ex-inc',
        name: 'Bench Press',
        description: 'Incremental',
        imageUrl: '',
        muscleGroups: const [MuscleGroup.pectoralMajor],
        tips: const [],
        commonMistakes: const [],
        category: ExerciseCategory.chest,
        difficulty: ExerciseDifficulty.intermediate,
        createdAt: now,
        updatedAt: now,
        exerciseType: ExerciseType.multiJoint,
        loadType: LoadType.barbell,
      );
    }

    bool isIncremental(LoadType loadType) {
      switch (loadType) {
        case LoadType.bodyweight:
        case LoadType.resistanceBand:
          return false;
        default:
          return true;
      }
    }

    // Helper para crear configuraciones
    ProgressionConfig createConfig({required ProgressionUnit unit, int cycleLength = 4, int deloadWeek = 0}) {
      final now = DateTime.now();
      return ProgressionConfig(
        id: 'cycle_test_config',
        isGlobal: true,
        type: ProgressionType.linear,
        unit: unit,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: cycleLength,
        minReps: 8,
        maxReps: 12,
        baseSets: 3,
        deloadWeek: deloadWeek,
        deloadPercentage: 0.9,
        customParameters: const {},
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
    }

    // Helper para crear estados
    ProgressionState createState({int currentSession = 1, int currentWeek = 1}) {
      final now = DateTime.now();
      return ProgressionState(
        id: 'cycle_test_state',
        progressionConfigId: 'cycle_test_config',
        exerciseId: 'test_exercise',
        routineId: 'test-routine-1',
        currentCycle: 1,
        currentWeek: currentWeek,
        currentSession: currentSession,
        currentWeight: 100.0,
        currentReps: 10,
        currentSets: 4,
        baseWeight: 100.0,
        baseReps: 10,
        baseSets: 4,
        sessionHistory: const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );
    }

    group('Session-based Cycle Calculation', () {
      final strategy = LinearProgressionStrategy();

      test('sesión 1 en ciclo de 4 sesiones', () {
        final config = createConfig(unit: ProgressionUnit.session, cycleLength: 4);
        for (final ex in getTestExercises()) {
          final state = createState(currentSession: 1);
          final result = strategy.calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: 100.0,
            currentReps: 10,
            currentSets: 4,
            exercise: ex,
          );
          expect(result.reason, contains('week 1 of 4'));
        }
      });

      test('sesión 2 en ciclo de 4 sesiones', () {
        final config = createConfig(unit: ProgressionUnit.session, cycleLength: 4);
        for (final ex in getTestExercises()) {
          final state = createState(currentSession: 2);
          final result = strategy.calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: 100.0,
            currentReps: 10,
            currentSets: 4,
            exercise: ex,
          );
          expect(result.reason, contains('week 2 of 4'));
        }
      });

      test('sesión 4 en ciclo de 4 sesiones', () {
        final config = createConfig(unit: ProgressionUnit.session, cycleLength: 4);
        for (final ex in getTestExercises()) {
          final state = createState(currentSession: 4);
          final result = strategy.calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: 100.0,
            currentReps: 10,
            currentSets: 4,
            exercise: ex,
          );
          expect(result.reason, contains('week 4 of 4'));
        }
      });

      test('sesión 5 reinicia ciclo (sesión 1 del siguiente ciclo)', () {
        final config = createConfig(unit: ProgressionUnit.session, cycleLength: 4);
        for (final ex in getTestExercises()) {
          final state = createState(currentSession: 5);
          final result = strategy.calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: 100.0,
            currentReps: 10,
            currentSets: 4,
            exercise: ex,
          );
          expect(result.reason, contains('week 1 of 4')); // Reinicia
        }
      });

      test('sesión 8 en ciclo de 4 sesiones (sesión 4 del segundo ciclo)', () {
        final config = createConfig(unit: ProgressionUnit.session, cycleLength: 4);
        for (final ex in getTestExercises()) {
          final state = createState(currentSession: 8);
          final result = strategy.calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: 100.0,
            currentReps: 10,
            currentSets: 4,
            exercise: ex,
          );
          expect(result.reason, contains('week 4 of 4'));
        }
      });

      test('deload en sesión 3 de ciclo de 4', () {
        final config = createConfig(unit: ProgressionUnit.session, cycleLength: 4, deloadWeek: 3);
        for (final ex in getTestExercises()) {
          final state = createState(currentSession: 3);
          final result = strategy.calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: 120.0,
            currentReps: 10,
            currentSets: 4,
            exercise: ex,
          );
          expect(result.reason, contains('week 3 of 4'));
        }
      });
    });

    group('Week-based Cycle Calculation', () {
      final strategy = LinearProgressionStrategy();

      test('semana 1 en ciclo de 4 semanas', () {
        final config = createConfig(unit: ProgressionUnit.week, cycleLength: 4);
        for (final ex in getTestExercises()) {
          final state = createState(currentWeek: 1);
          final result = strategy.calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: 100.0,
            currentReps: 10,
            currentSets: 4,
            exercise: ex,
          );
          expect(result.reason, contains('week 1 of 4'));
        }
      });

      test('semana 4 en ciclo de 4 semanas', () {
        final config = createConfig(unit: ProgressionUnit.week, cycleLength: 4);
        for (final ex in getTestExercises()) {
          final state = createState(currentWeek: 4);
          final result = strategy.calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: 100.0,
            currentReps: 10,
            currentSets: 4,
            exercise: ex,
          );
          expect(result.reason, contains('week 4 of 4'));
        }
      });

      test('semana 5 reinicia ciclo (semana 1 del siguiente ciclo)', () {
        final config = createConfig(unit: ProgressionUnit.week, cycleLength: 4);
        for (final ex in getTestExercises()) {
          final state = createState(currentWeek: 5);
          final result = strategy.calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: 100.0,
            currentReps: 10,
            currentSets: 4,
            exercise: ex,
          );
          expect(result.reason, contains('week 1 of 4')); // Reinicia
        }
      });

      test('deload en semana 3 de ciclo de 4', () {
        final config = createConfig(unit: ProgressionUnit.week, cycleLength: 4, deloadWeek: 3);
        for (final ex in getTestExercises()) {
          final state = createState(currentWeek: 3);
          final result = strategy.calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: 120.0,
            currentReps: 10,
            currentSets: 4,
            exercise: ex,
          );
          expect(result.reason, contains('week 3 of 4'));
        }
      });
    });

    group('WaveProgressionStrategy Cycle Logic', () {
      final strategy = WaveProgressionStrategy();

      test('semana 1: alta intensidad', () {
        final config = createConfig(unit: ProgressionUnit.week, cycleLength: 3);
        for (final ex in getTestExercises()) {
          final state = createState(currentWeek: 1);
          final result = strategy.calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: 100.0,
            currentReps: 10,
            currentSets: 4,
            exercise: ex,
          );
          expect(result.reason, contains('high intensity'));
          if (isIncremental(ex.loadType)) {
            final inc = strategy.getIncrementValueSync(config, ex);
            expect(result.newWeight, closeTo(100.0 + inc, 0.001));
            expect(result.newReps, 9);
          } else {
            expect(result.newWeight, 100.0);
          }
        }
      });

      test('semana 2: alto volumen', () {
        final config = createConfig(unit: ProgressionUnit.week, cycleLength: 3);
        for (final ex in getTestExercises()) {
          final state = createState(currentWeek: 2);
          final result = strategy.calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: 100.0,
            currentReps: 10,
            currentSets: 4,
            exercise: ex,
          );
          expect(result.reason, contains('high volume'));
          if (isIncremental(ex.loadType)) {
            final inc = strategy.getIncrementValueSync(config, ex);
            expect(result.newWeight, closeTo(100.0 - inc * 0.3, 0.001));
            expect(result.newReps, 12);
            expect(result.newSets, 5);
          } else {
            expect(result.newWeight, 100.0);
          }
        }
      });

      test('semana 3: deload', () {
        final config = createConfig(unit: ProgressionUnit.week, cycleLength: 3, deloadWeek: 3);
        for (final ex in getTestExercises()) {
          final state = createState(currentWeek: 3);
          final result = strategy.calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: 120.0,
            currentReps: 10,
            currentSets: 4,
            exercise: ex,
          );
          expect(result.reason, contains('Deload'));
          if (isIncremental(ex.loadType)) {
            final base = 100.0; // baseWeight en createState
            final increaseOverBase = 120.0 - base;
            final expectedDeload = base + increaseOverBase * 0.9;
            expect(result.newWeight, closeTo(expectedDeload, 0.001));
            expect(result.newSets, 2);
          }
        }
      });

      test('semana 4 reinicia ciclo (semana 1 del siguiente ciclo)', () {
        final config = createConfig(unit: ProgressionUnit.week, cycleLength: 3);
        for (final ex in getTestExercises()) {
          final state = createState(currentWeek: 4);
          final result = strategy.calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: 100.0,
            currentReps: 10,
            currentSets: 4,
            exercise: ex,
          );
          expect(result.reason, contains('high intensity')); // Reinicia
        }
      });
    });

    group('Cycle Edge Cases', () {
      final strategy = LinearProgressionStrategy();

      test('ciclo de 1 sesión', () {
        final config = createConfig(unit: ProgressionUnit.session, cycleLength: 1);
        final state = createState(currentSession: 1);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: getIncrementalExercise(),
        );

        expect(result.incrementApplied, true);
        expect(result.reason, contains('week 1 of 1'));
      });

      test('ciclo de 1 sesión - sesión 2 reinicia', () {
        final config = createConfig(unit: ProgressionUnit.session, cycleLength: 1);
        final state = createState(currentSession: 2);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: getIncrementalExercise(),
        );

        expect(result.incrementApplied, true);
        expect(result.reason, contains('week 1 of 1')); // Reinicia
      });

      test('ciclo largo (10 sesiones)', () {
        final config = createConfig(unit: ProgressionUnit.session, cycleLength: 10);
        final state = createState(currentSession: 7);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: getIncrementalExercise(),
        );

        expect(result.incrementApplied, true);
        expect(result.reason, contains('week 7 of 10'));
      });

      test('deload en sesión 0 (sin deload)', () {
        final config = createConfig(
          unit: ProgressionUnit.session,
          cycleLength: 4,
          deloadWeek: 0, // Sin deload
        );
        final state = createState(currentSession: 1);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: getIncrementalExercise(),
        );

        expect(result.incrementApplied, true);
        expect(result.reason, isNot(contains('deload')));
      });

      test('deload en sesión mayor al ciclo', () {
        final config = createConfig(
          unit: ProgressionUnit.session,
          cycleLength: 4,
          deloadWeek: 5, // Deload fuera del ciclo
        );
        final state = createState(currentSession: 1);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: getIncrementalExercise(),
        );

        expect(result.incrementApplied, true);
        expect(result.reason, isNot(contains('Deload')));
      });
    });

    group('Frequency and Cycle Interaction', () {
      final strategy = LinearProgressionStrategy();

      test('frecuencia 2 en ciclo de 4 sesiones', () {
        final config = createConfig(unit: ProgressionUnit.session, cycleLength: 4);
        // Modificar frecuencia después de crear
        final modifiedConfig = ProgressionConfig(
          id: config.id,
          isGlobal: config.isGlobal,
          type: config.type,
          unit: config.unit,
          primaryTarget: config.primaryTarget,
          secondaryTarget: config.secondaryTarget,
          incrementValue: config.incrementValue,
          incrementFrequency: 2, // Frecuencia 2
          cycleLength: config.cycleLength,
          minReps: config.minReps,
          maxReps: config.maxReps,
          baseSets: config.baseSets,
          deloadWeek: config.deloadWeek,
          deloadPercentage: config.deloadPercentage,
          customParameters: config.customParameters,
          startDate: config.startDate,
          endDate: config.endDate,
          isActive: config.isActive,
          createdAt: config.createdAt,
          updatedAt: config.updatedAt,
        );

        // Sesión 1: no incrementa (1 % 2 != 0)
        final state1 = createState(currentSession: 1);
        final result1 = strategy.calculate(
          config: modifiedConfig,
          state: state1,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: getIncrementalExercise(),
        );
        expect(result1.incrementApplied, false);

        // Sesión 2: incrementa (2 % 2 == 0)
        final state2 = createState(currentSession: 2);
        final result2 = strategy.calculate(
          config: modifiedConfig,
          state: state2,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: getIncrementalExercise(),
        );
        expect(result2.incrementApplied, true);
        expect(result2.reason, contains('week 2 of 4'));

        // Sesión 4: incrementa (4 % 2 == 0)
        final state4 = createState(currentSession: 4);
        final result4 = strategy.calculate(
          config: modifiedConfig,
          state: state4,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: getIncrementalExercise(),
        );
        expect(result4.incrementApplied, true);
        expect(result4.reason, contains('week 4 of 4'));
      });

      test('frecuencia 3 en ciclo de 4 sesiones', () {
        final config = createConfig(unit: ProgressionUnit.session, cycleLength: 4);
        final modifiedConfig = ProgressionConfig(
          id: config.id,
          isGlobal: config.isGlobal,
          type: config.type,
          unit: config.unit,
          primaryTarget: config.primaryTarget,
          secondaryTarget: config.secondaryTarget,
          incrementValue: config.incrementValue,
          incrementFrequency: 3, // Frecuencia 3
          cycleLength: config.cycleLength,
          minReps: config.minReps,
          maxReps: config.maxReps,
          baseSets: config.baseSets,
          deloadWeek: config.deloadWeek,
          deloadPercentage: config.deloadPercentage,
          customParameters: config.customParameters,
          startDate: config.startDate,
          endDate: config.endDate,
          isActive: config.isActive,
          createdAt: config.createdAt,
          updatedAt: config.updatedAt,
        );

        // Solo sesión 3 incrementa (3 % 3 == 0)
        final state3 = createState(currentSession: 3);
        final result3 = strategy.calculate(
          config: modifiedConfig,
          state: state3,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: getIncrementalExercise(),
        );
        expect(result3.incrementApplied, true);
        expect(result3.reason, contains('week 3 of 4'));
      });
    });
  });
}
