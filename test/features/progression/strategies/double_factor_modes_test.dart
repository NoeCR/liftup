import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/enums/double_factor_mode.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/double_factor_progression_strategy.dart';

import '../helpers/exercise_mock_factory.dart';

void main() {
  group('DoubleFactorProgressionStrategy - Modos de Progresión', () {
    late DoubleFactorProgressionStrategy strategy;
    late Exercise exercise;

    setUp(() {
      strategy = DoubleFactorProgressionStrategy();
      exercise = ExerciseMockFactory.createExercise();
    });

    /// Helper para crear configuración con modo específico
    ProgressionConfig createConfigWithMode(String mode) {
      return ProgressionConfig(
        id: 'test-config',
        isGlobal: true,
        type: ProgressionType.doubleFactor,
        unit: ProgressionUnit.week, // Cambiar a week para que use currentWeek
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: ProgressionTarget.reps,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 6,
        deloadWeek: 6,
        deloadPercentage: 0.8,
        customParameters: {'double_factor_mode': mode, 'min_reps': 6, 'max_reps': 10},
        startDate: DateTime.now(),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        minReps: 6,
        maxReps: 10,
        baseSets: 3,
      );
    }

    /// Helper para crear estado de progresión
    ProgressionState createState({required int currentInCycle, required double baseWeight, required int baseReps}) {
      return ProgressionState(
        id: 'test-state',
        progressionConfigId: 'test-config',
        exerciseId: exercise.id,
        routineId: 'test-routine',
        currentCycle: 1,
        currentWeek: currentInCycle,
        currentSession: 1,
        currentWeight: baseWeight,
        currentReps: baseReps,
        currentSets: 3,
        baseWeight: baseWeight,
        baseReps: baseReps,
        baseSets: 3,
        sessionHistory: {},
        lastUpdated: DateTime.now(),
        isDeloadWeek: false,
        customData: {},
      );
    }

    group('Modo Alternado (alternate)', () {
      test('semana impar incrementa peso, mantiene reps', () {
        final config = createConfigWithMode('alternate');
        final state = createState(
          currentInCycle: 1, // Semana impar
          baseWeight: 80.0,
          baseReps: 6,
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 80.0,
          currentReps: 6,
          currentSets: 3,
          exercise: exercise,
        );

        expect(
          result.newWeight,
          85.0,
        ); // 80.0 + 5.0 (incremento adaptativo para strength + multiJoint + barbell + initiated)
        expect(result.newReps, 6); // Mantiene reps
        expect(result.incrementApplied, true);
        expect(result.reason, contains('Double factor (alternate): increasing weight'));
        expect(result.reason, contains('week 1'));
      });

      test('semana par incrementa reps, mantiene peso', () {
        final config = createConfigWithMode('alternate');
        final state = createState(
          currentInCycle: 2, // Semana par
          baseWeight: 80.0,
          baseReps: 6,
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 85.0,
          currentReps: 6,
          currentSets: 3,
          exercise: exercise,
        );

        expect(result.newWeight, 85.0); // Mantiene peso
        expect(result.newReps, 7); // 6 + 1
        expect(result.incrementApplied, true);
        expect(result.reason, contains('Double factor (alternate): increasing reps'));
        expect(result.reason, contains('week 2'));
      });

      test('respeta límites de reps en modo alternado', () {
        final config = createConfigWithMode('alternate');
        final state = createState(
          currentInCycle: 2, // Semana par
          baseWeight: 80.0,
          baseReps: 6,
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 85.0,
          currentReps: 10, // Ya en el máximo
          currentSets: 3,
          exercise: exercise,
        );

        expect(result.newWeight, 85.0); // Mantiene peso
        expect(result.newReps, 10); // Se mantiene en el máximo
        expect(result.incrementApplied, true);
        expect(result.reason, contains('Double factor (alternate): increasing reps'));
      });
    });

    group('Modo Simultáneo (both)', () {
      test('incrementa peso y reps simultáneamente', () {
        final config = createConfigWithMode('both');
        final state = createState(currentInCycle: 1, baseWeight: 80.0, baseReps: 6);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 80.0,
          currentReps: 6,
          currentSets: 3,
          exercise: exercise,
        );

        expect(
          result.newWeight,
          85.0,
        ); // 80.0 + 5.0 (incremento adaptativo para strength + multiJoint + barbell + initiated)
        expect(result.newReps, 7); // 6 + 1
        expect(result.incrementApplied, true);
        expect(result.reason, contains('Double factor (both): increasing weight'));
        expect(result.reason, contains('and reps'));
      });

      test('respeta límites de reps en modo simultáneo', () {
        final config = createConfigWithMode('both');
        final state = createState(currentInCycle: 1, baseWeight: 80.0, baseReps: 6);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 80.0,
          currentReps: 10, // Ya en el máximo
          currentSets: 3,
          exercise: exercise,
        );

        expect(result.newWeight, 85.0); // Incrementa peso (80.0 + 5.0)
        expect(result.newReps, 10); // Se mantiene en el máximo
        expect(result.incrementApplied, true);
        expect(result.reason, contains('Double factor (both): increasing weight'));
      });
    });

    group('Modo Compuesto (composite)', () {
      test('incrementa peso y reps con prioridad en peso', () {
        final config = createConfigWithMode('composite');
        final state = createState(currentInCycle: 1, baseWeight: 80.0, baseReps: 6);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 80.0,
          currentReps: 6,
          currentSets: 3,
          exercise: exercise,
        );

        expect(
          result.newWeight,
          85.0,
        ); // 80.0 + 5.0 (incremento adaptativo para strength + multiJoint + barbell + initiated)
        expect(result.newReps, 8); // 6 + 2 (5.0 * 0.3 = 1.5, redondeado a 2)
        expect(result.incrementApplied, true);
        expect(result.reason, contains('Double factor (composite): increasing weight'));
        expect(result.reason, contains('and reps +2'));
      });

      test('calcula incremento de reps como 30% del incremento de peso', () {
        final config = createConfigWithMode('composite');
        // Configurar incremento de peso más grande para probar el cálculo
        final configWithBigIncrement = config.copyWith(
          incrementValue: 5.0, // Incremento más grande
        );
        final state = createState(currentInCycle: 1, baseWeight: 80.0, baseReps: 6);

        final result = strategy.calculate(
          config: configWithBigIncrement,
          state: state,
          routineId: 'test-routine',
          currentWeight: 80.0,
          currentReps: 6,
          currentSets: 3,
          exercise: exercise,
        );

        expect(result.newWeight, 85.0); // 80.0 + 5.0
        expect(result.newReps, 8); // 6 + 2 (5.0 * 0.3 = 1.5, redondeado a 2)
        expect(result.incrementApplied, true);
        expect(result.reason, contains('and reps +2'));
      });

      test('respeta límites de reps en modo compuesto', () {
        final config = createConfigWithMode('composite');
        final state = createState(currentInCycle: 1, baseWeight: 80.0, baseReps: 6);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 80.0,
          currentReps: 9, // Cerca del máximo
          currentSets: 3,
          exercise: exercise,
        );

        expect(result.newWeight, 85.0); // Incrementa peso (80.0 + 5.0)
        expect(result.newReps, 10); // Se mantiene en el máximo (9 + 1 = 10, pero se clampa a 10)
        expect(result.incrementApplied, true);
      });
    });

    group('Modo por defecto', () {
      test('usa modo alternado cuando no se especifica modo', () {
        final config = createConfigWithMode(''); // Sin modo especificado
        final state = createState(
          currentInCycle: 1, // Semana impar
          baseWeight: 80.0,
          baseReps: 6,
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 80.0,
          currentReps: 6,
          currentSets: 3,
          exercise: exercise,
        );

        expect(result.newWeight, 85.0); // Incrementa peso (80.0 + 5.0) (modo alternado, semana impar)
        expect(result.newReps, 6); // Mantiene reps
        expect(result.reason, contains('Double factor (alternate)'));
      });

      test('usa modo alternado cuando se especifica modo inválido', () {
        final config = createConfigWithMode('invalid_mode');
        final state = createState(
          currentInCycle: 1, // Semana impar
          baseWeight: 80.0,
          baseReps: 6,
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 80.0,
          currentReps: 6,
          currentSets: 3,
          exercise: exercise,
        );

        expect(result.newWeight, 85.0); // Incrementa peso (80.0 + 5.0) (modo alternado por defecto)
        expect(result.newReps, 6); // Mantiene reps
        expect(result.reason, contains('Double factor (alternate)'));
      });
    });

    group('Deload con diferentes modos', () {
      test('deload funciona igual para todos los modos', () {
        final modes = ['alternate', 'both', 'composite'];

        for (final mode in modes) {
          final config = createConfigWithMode(mode);
          final state = createState(
            currentInCycle: 6, // Semana de deload
            baseWeight: 80.0,
            baseReps: 6,
          );

          final result = strategy.calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: 90.0, // Peso actual mayor que base
            currentReps: 8, // Reps actuales mayores que base
            currentSets: 3,
            exercise: exercise,
          );

          expect(result.isDeload, true);
          expect(result.shouldResetCycle, true);
          expect(result.reason, contains('Deload session'));
          expect(result.reason, contains('week 6'));
        }
      });
    });
  });

  group('DoubleFactorMode Extension', () {
    test('displayName devuelve nombres correctos', () {
      expect(DoubleFactorMode.alternate.displayName, 'Alternado');
      expect(DoubleFactorMode.both.displayName, 'Simultáneo');
      expect(DoubleFactorMode.composite.displayName, 'Compuesto');
    });

    test('description devuelve descripciones correctas', () {
      expect(DoubleFactorMode.alternate.description, contains('Alterna entre incrementar peso'));
      expect(DoubleFactorMode.both.description, contains('Incrementa peso y reps simultáneamente'));
      expect(DoubleFactorMode.composite.description, contains('Usa un índice compuesto'));
    });

    test('recommendedObjectives devuelve objetivos correctos', () {
      expect(DoubleFactorMode.alternate.recommendedObjectives, containsAll(['strength', 'endurance', 'general']));
      expect(DoubleFactorMode.both.recommendedObjectives, containsAll(['hypertrophy']));
      expect(DoubleFactorMode.composite.recommendedObjectives, containsAll(['power']));
    });

    test('recommendedExperienceLevel devuelve niveles correctos', () {
      expect(DoubleFactorMode.alternate.recommendedExperienceLevel, 'beginner-intermediate');
      expect(DoubleFactorMode.both.recommendedExperienceLevel, 'intermediate-advanced');
      expect(DoubleFactorMode.composite.recommendedExperienceLevel, 'intermediate-advanced');
    });
  });
}
