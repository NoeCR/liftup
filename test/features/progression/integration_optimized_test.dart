import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/configs/adaptive_increment_config.dart';
import 'package:liftly/features/progression/configs/preset_progression_configs.dart';
import 'package:liftly/features/progression/enums/training_objective.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/autoregulated_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/overload_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/stepped_progression_strategy.dart';

void main() {
  group('Integración del Sistema Optimizado', () {
    late Exercise multiJointBarbell;

    ProgressionState createTestState({int session = 1, Map<String, dynamic>? history}) {
      final now = DateTime.now();
      return ProgressionState(
        id: 'test-state',
        progressionConfigId: 'test-config',
        exerciseId: 'test-exercise',
        routineId: 'test-routine',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: session,
        currentWeight: 100.0,
        currentReps: 10,
        currentSets: 3,
        baseWeight: 100.0,
        baseReps: 10,
        baseSets: 3,
        sessionHistory: history ?? const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );
    }

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

    group('Flujo Completo de Configuración por Objetivo', () {
      test('debería configurar correctamente un entrenamiento de FUERZA', () {
        // 1. Crear configuración de fuerza
        final strengthConfig = ProgressionConfig(
          id: 'strength_test',
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

        // 2. Verificar derivación de objetivo
        final objective = AdaptiveIncrementConfig.parseObjective(strengthConfig.getTrainingObjective());
        expect(objective, TrainingObjective.strength);

        // 3. Verificar valores adaptativos
        final (minReps, maxReps) = AdaptiveIncrementConfig.getRepetitionsRange(multiJointBarbell, objective: objective);
        expect(minReps, 3);
        expect(maxReps, 6);

        final increment = AdaptiveIncrementConfig.getRecommendedIncrementByObjective(
          multiJointBarbell,
          ExperienceLevel.intermediate,
          objective: objective,
        );
        expect(increment, 6.25);

        final restTime = AdaptiveIncrementConfig.getRestTimeSeconds(multiJointBarbell, objective: objective);
        expect(restTime, 240);

        final seriesRange = AdaptiveIncrementConfig.getSeriesIncrementRangeByObjective(
          multiJointBarbell,
          objective: objective,
        );
        expect(seriesRange?.defaultValue, 1);

        // 4. Verificar funcionamiento de estrategia
        final strategy = LinearProgressionStrategy();
        final result = strategy.calculate(
          config: strengthConfig,
          exercise: multiJointBarbell,
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 5,
          state: createTestState(),
          routineId: 'routine1',
          isExerciseLocked: false,
        );

        expect(result.newWeight, 106.25); // 100 + 6.25 increment
        expect(result.newReps, 5);
        expect(result.newSets, 5);
        expect(result.reason, contains('Linear progression'));
      });

      test('debería configurar correctamente un entrenamiento de HIPERTROFIA', () {
        // 1. Crear configuración de hipertrofia
        final hypertrophyConfig = ProgressionConfig(
          id: 'hypertrophy_test',
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

        // 2. Verificar derivación de objetivo
        final objective = AdaptiveIncrementConfig.parseObjective(hypertrophyConfig.getTrainingObjective());
        expect(objective, TrainingObjective.hypertrophy);

        // 3. Verificar valores adaptativos
        final (minReps, maxReps) = AdaptiveIncrementConfig.getRepetitionsRange(multiJointBarbell, objective: objective);
        expect(minReps, 6);
        expect(maxReps, 12);

        final increment = AdaptiveIncrementConfig.getRecommendedIncrementByObjective(
          multiJointBarbell,
          ExperienceLevel.intermediate,
          objective: objective,
        );
        expect(increment, 3.75);

        final restTime = AdaptiveIncrementConfig.getRestTimeSeconds(multiJointBarbell, objective: objective);
        expect(restTime, 120);

        final seriesRange = AdaptiveIncrementConfig.getSeriesIncrementRangeByObjective(
          multiJointBarbell,
          objective: objective,
        );
        expect(seriesRange?.defaultValue, 1);

        // 4. Verificar funcionamiento de estrategia
        final strategy = LinearProgressionStrategy();
        final result = strategy.calculate(
          config: hypertrophyConfig,
          exercise: multiJointBarbell,
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
          state: createTestState(),
          routineId: 'routine1',
          isExerciseLocked: false,
        );

        expect(result.newWeight, 103.75); // 100 + 3.75 increment
        expect(result.newReps, 8);
        expect(result.newSets, 4);
        expect(result.reason, contains('Linear progression'));
      });

      test('debería configurar correctamente un entrenamiento de RESISTENCIA', () {
        // 1. Crear configuración de resistencia
        final enduranceConfig = ProgressionConfig(
          id: 'endurance_test',
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

        // 2. Verificar derivación de objetivo
        final objective = AdaptiveIncrementConfig.parseObjective(enduranceConfig.getTrainingObjective());
        expect(objective, TrainingObjective.endurance);

        // 3. Verificar valores adaptativos
        final (minReps, maxReps) = AdaptiveIncrementConfig.getRepetitionsRange(multiJointBarbell, objective: objective);
        expect(minReps, 15);
        expect(maxReps, 25);

        final increment = AdaptiveIncrementConfig.getRecommendedIncrementByObjective(
          multiJointBarbell,
          ExperienceLevel.intermediate,
          objective: objective,
        );
        expect(increment, 1.875);

        final restTime = AdaptiveIncrementConfig.getRestTimeSeconds(multiJointBarbell, objective: objective);
        expect(restTime, 60);

        final seriesRange = AdaptiveIncrementConfig.getSeriesIncrementRangeByObjective(
          multiJointBarbell,
          objective: objective,
        );
        expect(seriesRange?.defaultValue, 2);

        // 4. Verificar funcionamiento de estrategia
        final strategy = LinearProgressionStrategy();
        final result = strategy.calculate(
          config: enduranceConfig,
          exercise: multiJointBarbell,
          currentWeight: 50.0,
          currentReps: 20,
          currentSets: 2,
          state: createTestState(),
          routineId: 'routine1',
          isExerciseLocked: false,
        );

        expect(result.newWeight, 51.875); // 50 + 1.875 increment
        expect(result.newReps, 20);
        expect(result.newSets, 2);
        expect(result.reason, contains('Linear progression'));
      });

      test('debería configurar correctamente un entrenamiento de POTENCIA', () {
        // 1. Crear configuración de potencia
        final powerConfig = ProgressionConfig(
          id: 'power_test',
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

        // 2. Verificar derivación de objetivo
        final objective = AdaptiveIncrementConfig.parseObjective(powerConfig.getTrainingObjective());
        expect(objective, TrainingObjective.strength);

        // 3. Verificar valores adaptativos
        final (minReps, maxReps) = AdaptiveIncrementConfig.getRepetitionsRange(multiJointBarbell, objective: objective);
        expect(minReps, 3);
        expect(maxReps, 6);

        final increment = AdaptiveIncrementConfig.getRecommendedIncrementByObjective(
          multiJointBarbell,
          ExperienceLevel.intermediate,
          objective: objective,
        );
        expect(increment, 6.25);

        final restTime = AdaptiveIncrementConfig.getRestTimeSeconds(multiJointBarbell, objective: objective);
        expect(restTime, 240);

        final seriesRange = AdaptiveIncrementConfig.getSeriesIncrementRangeByObjective(
          multiJointBarbell,
          objective: objective,
        );
        expect(seriesRange?.defaultValue, 1);

        // 4. Verificar funcionamiento de estrategia
        final strategy = LinearProgressionStrategy();
        final result = strategy.calculate(
          config: powerConfig,
          exercise: multiJointBarbell,
          currentWeight: 120.0,
          currentReps: 3,
          currentSets: 6,
          state: createTestState(),
          routineId: 'routine1',
          isExerciseLocked: false,
        );

        expect(result.newWeight, 126.25); // 120 + 6.25 increment
        expect(result.newReps, 3);
        expect(result.newSets, 5);
        expect(result.reason, contains('Linear progression'));
      });
    });

    group('Integración con Estrategias Especializadas', () {
      test('debería funcionar correctamente con AutoregulatedProgressionStrategy', () {
        final config = ProgressionConfig(
          id: 'autoregulated_test',
          isGlobal: true,
          type: ProgressionType.autoregulated,
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

        final strategy = AutoregulatedProgressionStrategy();
        final result = strategy.calculate(
          config: config,
          exercise: multiJointBarbell,
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
          state: createTestState(),
          routineId: 'routine1',
          isExerciseLocked: false,
        );

        expect(result.newWeight, 98.125);
        expect(result.newReps, 8);
        expect(result.newSets, 3);
        expect(result.reason, contains('RPE'));
      });

      test('debería funcionar correctamente con SteppedProgressionStrategy', () {
        final config = ProgressionConfig(
          id: 'stepped_test',
          isGlobal: true,
          type: ProgressionType.stepped,
          unit: ProgressionUnit.week,
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

        final strategy = SteppedProgressionStrategy();
        final result = strategy.calculate(
          config: config,
          exercise: multiJointBarbell,
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
          state: createTestState(),
          routineId: 'routine1',
          isExerciseLocked: false,
        );

        expect(result.newWeight, 103.75);
        expect(result.newReps, 8);
        expect(result.newSets, 4);
        expect(result.reason, contains('Stepped progression'));
      });

      test('debería funcionar correctamente con OverloadProgressionStrategy', () {
        final config = ProgressionConfig(
          id: 'overload_test',
          isGlobal: true,
          type: ProgressionType.overload,
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

        final strategy = OverloadProgressionStrategy();
        final result = strategy.calculate(
          config: config,
          exercise: multiJointBarbell,
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
          state: createTestState(),
          routineId: 'routine1',
          isExerciseLocked: false,
        );

        expect(result.newWeight, 100.0);
        expect(result.newReps, 8);
        expect(result.newSets, 3);
        expect(result.reason, contains('Overload progression'));
      });
    });

    group('Compatibilidad con Presets Existentes', () {
      test('debería mantener compatibilidad con presets de FUERZA', () {
        final presets = PresetProgressionConfigs.getPresetsForType(ProgressionType.linear);
        final strengthPreset = presets.firstWhere((preset) => preset.primaryTarget == ProgressionTarget.weight);

        final objective = AdaptiveIncrementConfig.parseObjective(strengthPreset.getTrainingObjective());
        expect(objective, TrainingObjective.strength);

        final (minReps, maxReps) = AdaptiveIncrementConfig.getRepetitionsRange(multiJointBarbell, objective: objective);
        expect(minReps, 3);
        expect(maxReps, 6);

        final increment = AdaptiveIncrementConfig.getRecommendedIncrementByObjective(
          multiJointBarbell,
          ExperienceLevel.intermediate,
          objective: objective,
        );
        expect(increment, 6.25);
      });

      test('debería mantener compatibilidad con presets de HIPERTROFIA', () {
        final presets = PresetProgressionConfigs.getPresetsForType(ProgressionType.linear);
        final hypertrophyPreset = presets.firstWhere((preset) => preset.primaryTarget == ProgressionTarget.volume);

        final objective = AdaptiveIncrementConfig.parseObjective(hypertrophyPreset.getTrainingObjective());
        expect(objective, TrainingObjective.hypertrophy);

        final (minReps, maxReps) = AdaptiveIncrementConfig.getRepetitionsRange(multiJointBarbell, objective: objective);
        expect(minReps, 6);
        expect(maxReps, 12);

        final increment = AdaptiveIncrementConfig.getRecommendedIncrementByObjective(
          multiJointBarbell,
          ExperienceLevel.intermediate,
          objective: objective,
        );
        expect(increment, 3.75);
      });

      test('debería mantener compatibilidad con presets de RESISTENCIA', () {
        final presets = PresetProgressionConfigs.getPresetsForType(ProgressionType.linear);
        final endurancePreset = presets.firstWhere((preset) => preset.primaryTarget == ProgressionTarget.reps);

        final objective = AdaptiveIncrementConfig.parseObjective(endurancePreset.getTrainingObjective());
        expect(objective, TrainingObjective.endurance);

        final (minReps, maxReps) = AdaptiveIncrementConfig.getRepetitionsRange(multiJointBarbell, objective: objective);
        expect(minReps, 15);
        expect(maxReps, 25);

        final increment = AdaptiveIncrementConfig.getRecommendedIncrementByObjective(
          multiJointBarbell,
          ExperienceLevel.intermediate,
          objective: objective,
        );
        expect(increment, 1.875);
      });
    });

    group('Diferenciación por Tipo de Ejercicio', () {
      test('debería aplicar valores diferentes para multi-joint vs isolation', () {
        final config = ProgressionConfig(
          id: 'comparison_test',
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

        final objective = AdaptiveIncrementConfig.parseObjective(config.getTrainingObjective());

        // Multi-joint
        final (minRepsMulti, maxRepsMulti) = AdaptiveIncrementConfig.getRepetitionsRange(
          multiJointBarbell,
          objective: objective,
        );
        final incrementMulti = AdaptiveIncrementConfig.getRecommendedIncrementByObjective(
          multiJointBarbell,
          ExperienceLevel.intermediate,
          objective: objective,
        );

        // Isolation
        final (minRepsIso, maxRepsIso) = AdaptiveIncrementConfig.getRepetitionsRange(
          isolationDumbbell,
          objective: objective,
        );
        final incrementIso = AdaptiveIncrementConfig.getRecommendedIncrementByObjective(
          isolationDumbbell,
          ExperienceLevel.initiated, // Beginner -> Initiated
          objective: objective,
        );

        // Verificar diferencias
        expect(minRepsMulti, 6);
        expect(maxRepsMulti, 12);
        expect(minRepsIso, 8);
        expect(maxRepsIso, 15);

        expect(incrementMulti, 3.75);
        expect(incrementIso, 1.25); // Menor incremento para isolation + initiated
      });
    });
  });
}
