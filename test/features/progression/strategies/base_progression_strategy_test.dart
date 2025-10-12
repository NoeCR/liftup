import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/muscle_group_enum.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/base_progression_strategy.dart';

/// Test para validar la funcionalidad común de BaseProgressionStrategy
void main() {
  group('BaseProgressionStrategy', () {
    late TestProgressionStrategy strategy;
    late ProgressionConfig config;
    late ProgressionState state;

    setUp(() {
      strategy = TestProgressionStrategy();
      config = ProgressionConfig(
        id: 'test-config',
        isGlobal: true,
        type: ProgressionType.linear,
        unit: ProgressionUnit.session,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 4,
        minReps: 8,
        maxReps: 12,
        baseSets: 3,
        deloadWeek: 3,
        deloadPercentage: 0.8,
        customParameters: const {},
        startDate: DateTime.now(),
        endDate: null,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
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
        currentReps: 10,
        currentSets: 3,
        baseWeight: 100.0,
        baseReps: 10,
        baseSets: 3,
        sessionHistory: const {},
        lastUpdated: DateTime.now(),
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );
    });

    group('getCurrentInCycle', () {
      test('calcula correctamente la posición en el ciclo por sesión', () {
        // Sesión 1 en ciclo de 4
        state = state.copyWith(currentSession: 1);
        expect(strategy.getCurrentInCycle(config, state), equals(1));

        // Sesión 2 en ciclo de 4
        state = state.copyWith(currentSession: 2);
        expect(strategy.getCurrentInCycle(config, state), equals(2));

        // Sesión 4 en ciclo de 4
        state = state.copyWith(currentSession: 4);
        expect(strategy.getCurrentInCycle(config, state), equals(4));

        // Sesión 5 reinicia el ciclo (sesión 1 del siguiente ciclo)
        state = state.copyWith(currentSession: 5);
        expect(strategy.getCurrentInCycle(config, state), equals(1));
      });

      test('calcula correctamente la posición en el ciclo por semana', () {
        config = config.copyWith(unit: ProgressionUnit.week);

        // Semana 1 en ciclo de 4
        state = state.copyWith(currentWeek: 1);
        expect(strategy.getCurrentInCycle(config, state), equals(1));

        // Semana 2 en ciclo de 4
        state = state.copyWith(currentWeek: 2);
        expect(strategy.getCurrentInCycle(config, state), equals(2));

        // Semana 4 en ciclo de 4
        state = state.copyWith(currentWeek: 4);
        expect(strategy.getCurrentInCycle(config, state), equals(4));

        // Semana 5 reinicia el ciclo (semana 1 del siguiente ciclo)
        state = state.copyWith(currentWeek: 5);
        expect(strategy.getCurrentInCycle(config, state), equals(1));
      });
    });

    group('isDeloadPeriod', () {
      test('identifica correctamente períodos de deload', () {
        config = config.copyWith(deloadWeek: 3);

        // Semana 1: no es deload
        expect(strategy.isDeloadPeriod(config, 1), isFalse);

        // Semana 2: no es deload
        expect(strategy.isDeloadPeriod(config, 2), isFalse);

        // Semana 3: es deload
        expect(strategy.isDeloadPeriod(config, 3), isTrue);

        // Semana 4: no es deload
        expect(strategy.isDeloadPeriod(config, 4), isFalse);
      });

      test('maneja correctamente cuando no hay deload (deloadWeek = 0)', () {
        config = config.copyWith(deloadWeek: 0);

        // Ninguna semana debe ser deload
        for (int week = 1; week <= 10; week++) {
          expect(strategy.isDeloadPeriod(config, week), isFalse);
        }
      });
    });

    group('getIncrementValue', () {
      test('usa valor base cuando no hay parámetros personalizados', () {
        final increment = strategy.getIncrementValue(config);
        expect(increment, equals(2.5)); // incrementValue del config
      });

      test('usa incremento específico por tipo de ejercicio multi-joint', () {
        // Crear un config con incrementValue 0 para usar AdaptiveIncrementConfig
        final testConfig = config.copyWith(incrementValue: 0);

        // Crear un ejercicio multi-joint para probar AdaptiveIncrementConfig
        final exercise = Exercise(
          id: 'test',
          name: 'Test Exercise',
          description: 'Test description',
          imageUrl: '',
          muscleGroups: [MuscleGroup.pectoralMajor],
          tips: [],
          commonMistakes: [],
          category: ExerciseCategory.chest,
          difficulty: ExerciseDifficulty.intermediate,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          exerciseType: ExerciseType.multiJoint,
          loadType: LoadType.barbell,
        );

        final increment = strategy.getIncrementValue(testConfig, exercise: exercise);
        // AdaptiveIncrementConfig para barbell multi-joint con ExperienceLevel.intermediate
        // debería ser (5.0 + 7.0) / 2 = 6.0
        expect(increment, equals(6.0));
      });

      test('usa incremento específico por tipo de ejercicio isolation', () {
        // Crear un config con incrementValue 0 para usar AdaptiveIncrementConfig
        final testConfig = config.copyWith(incrementValue: 0);

        // Crear un ejercicio isolation para probar AdaptiveIncrementConfig
        final exercise = Exercise(
          id: 'test',
          name: 'Test Exercise',
          description: 'Test description',
          imageUrl: '',
          muscleGroups: [MuscleGroup.bicepsLongHead],
          tips: [],
          commonMistakes: [],
          category: ExerciseCategory.biceps,
          difficulty: ExerciseDifficulty.intermediate,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          exerciseType: ExerciseType.isolation,
          loadType: LoadType.dumbbell,
        );

        final increment = strategy.getIncrementValue(testConfig, exercise: exercise);
        // AdaptiveIncrementConfig para dumbbell isolation con ExperienceLevel.intermediate
        // debería ser (1.25 + 2.5) / 2 = 1.875
        expect(increment, equals(1.875));
      });

      test('usa incremento global como fallback', () {
        config = config.copyWith(customParameters: {'increment_value': 3.0});

        final increment = strategy.getIncrementValue(config);
        expect(increment, equals(3.0));
      });

      test('usa incremento por ejercicio específico con prioridad', () {
        config = config.copyWith(
          customParameters: {
            'increment_value': 3.0,
            'multi_increment_min': 5.0,
            'per_exercise': {
              'test-exercise': {'increment_value': 4.0, 'multi_increment_min': 6.0},
            },
          },
        );

        final increment = strategy.getIncrementValue(config, exerciseType: ExerciseType.multiJoint);
        expect(increment, equals(6.0)); // per_exercise > multi_increment_min
      });

      test('maneja errores en parámetros personalizados graciosamente', () {
        config = config.copyWith(
          customParameters: {
            'per_exercise': 'invalid_data', // Datos inválidos
            'increment_value': 3.0,
          },
        );

        final increment = strategy.getIncrementValue(config);
        expect(increment, equals(3.0)); // Debe usar fallback global
      });
    });

    group('getMaxReps', () {
      test('usa valor por defecto cuando no hay parámetros personalizados', () {
        final maxReps = strategy.getMaxReps(config);
        expect(maxReps, equals(12)); // Valor por defecto
      });

      test('usa max_reps específico por tipo de ejercicio multi-joint', () {
        config = config.copyWith(customParameters: {'multi_reps_max': 8, 'iso_reps_max': 15});

        final maxReps = strategy.getMaxReps(config, exerciseType: ExerciseType.multiJoint);
        expect(maxReps, equals(8));
      });

      test('usa max_reps específico por tipo de ejercicio isolation', () {
        config = config.copyWith(customParameters: {'multi_reps_max': 8, 'iso_reps_max': 15});

        final maxReps = strategy.getMaxReps(config, exerciseType: ExerciseType.isolation);
        expect(maxReps, equals(15));
      });

      test('usa max_reps global como fallback', () {
        config = config.copyWith(customParameters: {'max_reps': 10});

        final maxReps = strategy.getMaxReps(config);
        expect(maxReps, equals(10));
      });
    });

    group('getMinReps', () {
      test('usa valor por defecto cuando no hay parámetros personalizados', () {
        final minReps = strategy.getMinReps(config);
        expect(minReps, equals(8)); // Valor por defecto del config
      });

      test('usa min_reps específico por tipo de ejercicio multi-joint', () {
        config = config.copyWith(customParameters: {'multi_reps_min': 3, 'iso_reps_min': 8});

        final minReps = strategy.getMinReps(config, exerciseType: ExerciseType.multiJoint);
        expect(minReps, equals(3));
      });

      test('usa min_reps específico por tipo de ejercicio isolation', () {
        config = config.copyWith(customParameters: {'multi_reps_min': 3, 'iso_reps_min': 8});

        final minReps = strategy.getMinReps(config, exerciseType: ExerciseType.isolation);
        expect(minReps, equals(8));
      });

      test('usa min_reps global como fallback', () {
        config = config.copyWith(customParameters: {'min_reps': 6});

        final minReps = strategy.getMinReps(config);
        expect(minReps, equals(6));
      });
    });

    group('Fallbacks por tipo de ejercicio', () {
      test('usa fallbacks por defecto para multi-joint cuando no hay parámetros', () {
        final increment = strategy.getIncrementValue(config, exerciseType: ExerciseType.multiJoint);
        final maxReps = strategy.getMaxReps(config, exerciseType: ExerciseType.multiJoint);
        final minReps = strategy.getMinReps(config, exerciseType: ExerciseType.multiJoint);

        expect(increment, equals(2.5)); // Default para multi-joint
        expect(maxReps, equals(8)); // Default para multi-joint
        expect(minReps, equals(5)); // Default para multi-joint
      });

      test('usa fallbacks por defecto para isolation cuando no hay parámetros', () {
        final increment = strategy.getIncrementValue(config, exerciseType: ExerciseType.isolation);
        final maxReps = strategy.getMaxReps(config, exerciseType: ExerciseType.isolation);
        final minReps = strategy.getMinReps(config, exerciseType: ExerciseType.isolation);

        expect(increment, equals(1.25)); // Default para isolation
        expect(maxReps, equals(15)); // Default para isolation
        expect(minReps, equals(8)); // Default para isolation
      });
    });
  });
}

/// Clase de prueba que extiende BaseProgressionStrategy para testing
class TestProgressionStrategy extends BaseProgressionStrategy {
  // Exponer métodos protegidos para testing
}
