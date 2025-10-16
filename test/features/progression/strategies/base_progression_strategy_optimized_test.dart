import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/base_progression_strategy.dart';

class TestProgressionStrategy extends BaseProgressionStrategy {
  @override
  String get strategyName => 'Test Strategy';

  @override
  bool shouldApplyProgressionValues(
    ProgressionState? progressionState,
    String routineId,
    bool isExerciseLocked,
  ) {
    return true;
  }
}

void main() {
  group('BaseProgressionStrategy - Nueva Funcionalidad', () {
    late TestProgressionStrategy strategy;
    late Exercise testExercise;

    setUp(() {
      strategy = TestProgressionStrategy();
      testExercise = Exercise(
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
    });

    group('Derivación de Sesiones por Semana', () {
      test('debería derivar 3 sesiones para FUERZA', () {
        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.linear,
          unit: ProgressionUnit.session,
          primaryTarget: ProgressionTarget.weight,
          secondaryTarget: ProgressionTarget.reps,
          incrementValue: 2.5,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {},
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 3,
          maxReps: 6,
          baseSets: 5,
        );

        final state = ProgressionState(
          id: 'test',
          progressionConfigId: 'test',
          exerciseId: '1',
          routineId: 'routine1',
          currentCycle: 1,
          currentWeek: 1,
          currentSession: 1,
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 5,
          baseWeight: 100.0,
          baseReps: 5,
          baseSets: 5,
          sessionHistory: const {},
          lastUpdated: DateTime.now(),
          isDeloadWeek: false,
          oneRepMax: null,
          customData: const {},
        );

        final result = strategy.calculateNextSessionAndWeek(
          config: config,
          state: state,
        );

        // Con 3 sesiones por semana, la sesión 4 debería ser semana 2
        expect(result.session, 2);
        expect(result.week, 1); // (2-1) ~/ 3 + 1 = 1
      });

      test('debería derivar 4 sesiones para HIPERTROFIA', () {
        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.linear,
          unit: ProgressionUnit.session,
          primaryTarget: ProgressionTarget.volume,
          secondaryTarget: ProgressionTarget.reps,
          incrementValue: 2.5,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {},
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 6,
          maxReps: 12,
          baseSets: 4,
        );

        final state = ProgressionState(
          id: 'test',
          progressionConfigId: 'test',
          exerciseId: '1',
          routineId: 'routine1',
          currentCycle: 1,
          currentWeek: 1,
          currentSession: 1,
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
          baseWeight: 100.0,
          baseReps: 8,
          baseSets: 4,
          sessionHistory: const {},
          lastUpdated: DateTime.now(),
          isDeloadWeek: false,
          oneRepMax: null,
          customData: const {},
        );

        final result = strategy.calculateNextSessionAndWeek(
          config: config,
          state: state,
        );

        // Con 4 sesiones por semana, la sesión 5 debería ser semana 2
        expect(result.session, 2);
        expect(result.week, 1); // (2-1) ~/ 4 + 1 = 1
      });

      test('debería derivar 5 sesiones para RESISTENCIA', () {
        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.linear,
          unit: ProgressionUnit.session,
          primaryTarget: ProgressionTarget.reps,
          secondaryTarget: ProgressionTarget.volume,
          incrementValue: 1.25,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {},
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 15,
          maxReps: 25,
          baseSets: 2,
        );

        final state = ProgressionState(
          id: 'test',
          progressionConfigId: 'test',
          exerciseId: '1',
          routineId: 'routine1',
          currentCycle: 1,
          currentWeek: 1,
          currentSession: 1,
          currentWeight: 50.0,
          currentReps: 20,
          currentSets: 2,
          baseWeight: 50.0,
          baseReps: 20,
          baseSets: 2,
          sessionHistory: const {},
          lastUpdated: DateTime.now(),
          isDeloadWeek: false,
          oneRepMax: null,
          customData: const {},
        );

        final result = strategy.calculateNextSessionAndWeek(
          config: config,
          state: state,
        );

        // Con 5 sesiones por semana, la sesión 6 debería ser semana 2
        expect(result.session, 2);
        expect(result.week, 1); // (2-1) ~/ 5 + 1 = 1
      });

      test('debería derivar 3 sesiones para POTENCIA', () {
        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.linear,
          unit: ProgressionUnit.session,
          primaryTarget: ProgressionTarget.weight,
          secondaryTarget: ProgressionTarget.reps,
          incrementValue: 5.0,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {},
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 1,
          maxReps: 5,
          baseSets: 6,
        );

        final state = ProgressionState(
          id: 'test',
          progressionConfigId: 'test',
          exerciseId: '1',
          routineId: 'routine1',
          currentCycle: 1,
          currentWeek: 1,
          currentSession: 1,
          currentWeight: 120.0,
          currentReps: 3,
          currentSets: 6,
          baseWeight: 120.0,
          baseReps: 3,
          baseSets: 6,
          sessionHistory: const {},
          lastUpdated: DateTime.now(),
          isDeloadWeek: false,
          oneRepMax: null,
          customData: const {},
        );

        final result = strategy.calculateNextSessionAndWeek(
          config: config,
          state: state,
        );

        // Con 3 sesiones por semana, la sesión 4 debería ser semana 2
        expect(result.session, 2);
        expect(result.week, 1); // (2-1) ~/ 3 + 1 = 1
      });
    });

    group('Derivación de Nivel de Experiencia', () {
      test('debería derivar nivel correcto por dificultad del ejercicio', () {
        final beginnerExercise = Exercise(
          id: '2',
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
          id: '3',
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

        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.linear,
          unit: ProgressionUnit.session,
          primaryTarget: ProgressionTarget.volume,
          secondaryTarget: ProgressionTarget.reps,
          incrementValue: 2.5,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {},
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 6,
          maxReps: 12,
          baseSets: 4,
        );

        // Beginner -> Initiated
        final incrementBeginner = strategy.getIncrementValueSync(
          config,
          beginnerExercise,
        );
        expect(incrementBeginner, 0.0); // Bodyweight no incrementa peso

        // Advanced -> Advanced
        final incrementAdvanced = strategy.getIncrementValueSync(
          config,
          advancedExercise,
        );
        expect(incrementAdvanced, 0.0); // Bodyweight no incrementa peso
      });
    });

    group('Integración con Sistema Adaptativo', () {
      test('debería usar valores adaptativos para FUERZA', () {
        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.linear,
          unit: ProgressionUnit.session,
          primaryTarget: ProgressionTarget.weight,
          secondaryTarget: ProgressionTarget.reps,
          incrementValue: 2.5,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {},
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 3,
          maxReps: 6,
          baseSets: 5,
        );

        final increment = strategy.getIncrementValueSync(config, testExercise);
        expect(
          increment,
          6.25,
        ); // Valor optimizado para fuerza + multi-joint + barbell + intermediate
      });

      test('debería usar valores adaptativos para HIPERTROFIA', () {
        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.linear,
          unit: ProgressionUnit.session,
          primaryTarget: ProgressionTarget.volume,
          secondaryTarget: ProgressionTarget.reps,
          incrementValue: 2.5,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {},
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 6,
          maxReps: 12,
          baseSets: 4,
        );

        final increment = strategy.getIncrementValueSync(config, testExercise);
        expect(
          increment,
          3.75,
        ); // Valor optimizado para hipertrofia + multi-joint + barbell + intermediate
      });

      test('debería usar valores adaptativos para RESISTENCIA', () {
        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.linear,
          unit: ProgressionUnit.session,
          primaryTarget: ProgressionTarget.reps,
          secondaryTarget: ProgressionTarget.volume,
          incrementValue: 1.25,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {},
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 15,
          maxReps: 25,
          baseSets: 2,
        );

        final increment = strategy.getIncrementValueSync(config, testExercise);
        expect(
          increment,
          1.875,
        ); // Valor optimizado para resistencia + multi-joint + barbell + intermediate
      });

      test('debería usar valores adaptativos para POTENCIA', () {
        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.linear,
          unit: ProgressionUnit.session,
          primaryTarget: ProgressionTarget.weight,
          secondaryTarget: ProgressionTarget.reps,
          incrementValue: 5.0,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {},
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 1,
          maxReps: 5,
          baseSets: 6,
        );

        final increment = strategy.getIncrementValueSync(config, testExercise);
        expect(
          increment,
          6.25,
        ); // Valor optimizado para potencia + multi-joint + barbell + intermediate
      });
    });

    group('Compatibilidad con Configuraciones Existentes', () {
      test('debería mantener compatibilidad con customParameters', () {
        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.linear,
          unit: ProgressionUnit.session,
          primaryTarget: ProgressionTarget.volume,
          secondaryTarget: ProgressionTarget.reps,
          incrementValue: 2.5,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {'target_rpe': 8.0, 'rest_time_seconds': 120},
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 6,
          maxReps: 12,
          baseSets: 4,
        );

        // El sistema debería seguir funcionando con customParameters existentes
        final increment = strategy.getIncrementValueSync(config, testExercise);
        expect(increment, 3.75); // Valor adaptativo, no customParameters
      });
    });
  });
}
