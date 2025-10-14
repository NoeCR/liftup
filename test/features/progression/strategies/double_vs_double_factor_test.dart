import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/muscle_group_enum.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/double_factor_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/double_progression_strategy.dart';

void main() {
  group('Double vs Double Factor Progression Tests', () {
    late ProgressionConfig config;
    late ProgressionState state;
    late Exercise testExercise;

    setUp(() {
      final now = DateTime.now();
      config = ProgressionConfig(
        id: 'cfg',
        isGlobal: true,
        type: ProgressionType.double,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: ProgressionTarget.reps,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 4,
        minReps: 8,
        maxReps: 12,
        baseSets: 3,
        deloadWeek: 0,
        deloadPercentage: 0.8,
        customParameters: const {'min_reps': 6, 'max_reps': 10},
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      state = ProgressionState(
        id: 'st',
        progressionConfigId: 'cfg',
        exerciseId: 'ex',
        routineId: 'test-routine',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 80.0,
        currentReps: 6,
        currentSets: 3,
        baseWeight: 80.0,
        baseReps: 6,
        baseSets: 3,
        sessionHistory: const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );

      // Crear ejercicio de prueba
      testExercise = Exercise(
        id: 'test-exercise',
        name: 'Test Exercise',
        description: 'Test exercise for progression',
        imageUrl: '',
        muscleGroups: [MuscleGroup.pectoralMajor],
        tips: [],
        commonMistakes: [],
        category: ExerciseCategory.chest,
        difficulty: ExerciseDifficulty.intermediate,
        createdAt: now,
        updatedAt: now,
        exerciseType: ExerciseType.multiJoint,
        loadType: LoadType.barbell,
      );
    });

    test(
      'Double Progression: incrementa reps primero, luego peso (secuencial)',
      () {
        final strategy = DoubleProgressionStrategy();

        // Semana 1: Incrementar reps (6 -> 7)
        var result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 80.0,
          currentReps: 6,
          currentSets: 3,
          exercise: testExercise,
        );
        expect(result.newWeight, 80.0);
        expect(result.newReps, 7);
        expect(result.reason, contains('increasing reps'));

        // Semana 2: Incrementar reps (7 -> 8)
        result = strategy.calculate(
          config: config,
          state: state.copyWith(currentWeek: 2),
          routineId: 'test-routine',
          currentWeight: 80.0,
          currentReps: 7,
          currentSets: 3,
          exercise: testExercise,
        );
        expect(result.newWeight, 80.0);
        expect(result.newReps, 8);
        expect(result.reason, contains('increasing reps'));

        // Semana 3: Incrementar reps (8 -> 9)
        result = strategy.calculate(
          config: config,
          state: state.copyWith(currentWeek: 3),
          routineId: 'test-routine',
          currentWeight: 80.0,
          currentReps: 8,
          currentSets: 3,
          exercise: testExercise,
        );
        expect(result.newWeight, 80.0);
        expect(result.newReps, 9);
        expect(result.reason, contains('increasing reps'));

        // Semana 4: Incrementar reps (9 -> 10)
        result = strategy.calculate(
          config: config,
          state: state.copyWith(currentWeek: 4),
          routineId: 'test-routine',
          currentWeight: 80.0,
          currentReps: 9,
          currentSets: 3,
          exercise: testExercise,
        );
        expect(result.newWeight, 80.0);
        expect(result.newReps, 10);
        expect(result.reason, contains('increasing reps'));

        // Semana 5: Alcanzó max reps, incrementar peso y resetear reps
        result = strategy.calculate(
          config: config,
          state: state.copyWith(currentWeek: 5),
          routineId: 'test-routine',
          currentWeight: 80.0,
          currentReps: 10,
          currentSets: 3,
          exercise: testExercise,
        );
        expect(result.newWeight, 86.0); // 80 + 6.0 (incremento adaptativo)
        expect(result.newReps, 6); // Reset a min reps
        expect(result.reason, contains('increasing weight'));
      },
    );

    test('Double Factor Progression: alterna peso y reps (simultáneo)', () {
      final strategy = DoubleFactorProgressionStrategy();

      // Semana 1 (impar): Incrementar peso, mantener reps
      var result = strategy.calculate(
        config: config,
        state: state,
        routineId: 'test-routine',
        currentWeight: 80.0,
        currentReps: 6,
        currentSets: 3,
        exercise: testExercise,
      );
      expect(result.newWeight, 86.0); // 80 + 6.0 (incremento adaptativo)
      expect(result.newReps, 6); // Mantiene reps
      expect(result.reason, contains('increasing weight'));

      // Semana 2 (par): Incrementar reps, mantener peso
      result = strategy.calculate(
        config: config,
        state: state.copyWith(currentWeek: 2),
        routineId: 'test-routine',
        currentWeight: 82.5,
        currentReps: 6,
        currentSets: 3,
        exercise: testExercise,
      );
      expect(result.newWeight, 82.5); // Mantiene peso
      expect(result.newReps, 7); // Incrementa reps
      expect(result.reason, contains('increasing reps'));

      // Semana 3 (impar): Incrementar peso, mantener reps
      result = strategy.calculate(
        config: config,
        state: state.copyWith(currentWeek: 3),
        routineId: 'test-routine',
        currentWeight: 82.5,
        currentReps: 7,
        currentSets: 3,
        exercise: testExercise,
      );
      expect(result.newWeight, 88.5); // 82.5 + 6.0 (incremento adaptativo)
      expect(result.newReps, 7); // Mantiene reps
      expect(result.reason, contains('increasing weight'));

      // Semana 4 (par): Incrementar reps, mantener peso
      result = strategy.calculate(
        config: config,
        state: state.copyWith(currentWeek: 4),
        routineId: 'test-routine',
        currentWeight: 85.0,
        currentReps: 7,
        currentSets: 3,
        exercise: testExercise,
      );
      expect(result.newWeight, 85.0); // Mantiene peso
      expect(result.newReps, 8); // Incrementa reps
      expect(result.reason, contains('increasing reps'));
    });

    test('Double Factor Progression: respeta límites de reps', () {
      final strategy = DoubleFactorProgressionStrategy();

      // Semana par con reps en el máximo: no debe incrementar más
      var result = strategy.calculate(
        config: config,
        state: state.copyWith(currentWeek: 2),
        routineId: 'test-routine',
        currentWeight: 80.0,
        currentReps: 10, // Max reps
        currentSets: 3,
        exercise: testExercise,
      );
      expect(result.newWeight, 80.0);
      expect(result.newReps, 10); // Se mantiene en max
      expect(result.reason, contains('increasing reps to 10'));
    });

    test('Ambas estrategias son diferentes en el mismo escenario', () {
      final doubleStrategy = DoubleProgressionStrategy();
      final doubleFactorStrategy = DoubleFactorProgressionStrategy();

      // Misma configuración inicial
      final testState = state.copyWith(currentWeek: 1);

      final doubleResult = doubleStrategy.calculate(
        config: config,
        state: testState,
        routineId: 'test-routine',
        currentWeight: 80.0,
        currentReps: 6,
        currentSets: 3,
        exercise: testExercise,
      );

      final doubleFactorResult = doubleFactorStrategy.calculate(
        config: config,
        state: testState,
        routineId: 'test-routine',
        currentWeight: 80.0,
        currentReps: 6,
        currentSets: 3,
        exercise: testExercise,
      );

      // Double Progression: incrementa reps
      expect(doubleResult.newWeight, 80.0);
      expect(doubleResult.newReps, 7);

      // Double Factor: incrementa peso
      expect(doubleFactorResult.newWeight, 86.0);
      expect(doubleFactorResult.newReps, 6);

      // Los resultados deben ser diferentes
      expect(
        doubleResult.newWeight,
        isNot(equals(doubleFactorResult.newWeight)),
      );
      expect(doubleResult.newReps, isNot(equals(doubleFactorResult.newReps)));
    });

    test('Simulación de 6 semanas: Double Progression vs Double Factor', () {
      final doubleStrategy = DoubleProgressionStrategy();
      final doubleFactorStrategy = DoubleFactorProgressionStrategy();

      // Configuración para 6 semanas
      final sixWeekConfig = config.copyWith(cycleLength: 6);

      print('\n=== COMPARACIÓN 6 SEMANAS ===');
      print('Double Progression (secuencial):');

      var weight = 80.0;
      var reps = 6;

      for (int week = 1; week <= 6; week++) {
        final result = doubleStrategy.calculate(
          config: sixWeekConfig,
          state: state.copyWith(currentWeek: week),
          routineId: 'test-routine',
          currentWeight: weight,
          currentReps: reps,
          currentSets: 3,
        );

        weight = result.newWeight;
        reps = result.newReps;

        print('Semana $week: ${weight}kg x $reps reps - ${result.reason}');
      }

      print('\nDouble Factor (alternado):');

      weight = 80.0;
      reps = 6;

      for (int week = 1; week <= 6; week++) {
        final result = doubleFactorStrategy.calculate(
          config: sixWeekConfig,
          state: state.copyWith(currentWeek: week),
          routineId: 'test-routine',
          currentWeight: weight,
          currentReps: reps,
          currentSets: 3,
        );

        weight = result.newWeight;
        reps = result.newReps;

        print('Semana $week: ${weight}kg x $reps reps - ${result.reason}');
      }
    });
  });
}
