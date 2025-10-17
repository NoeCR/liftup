import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/configs/adaptive_increment_config.dart';
import 'package:liftly/features/progression/configs/preset_progression_configs.dart';
import 'package:liftly/features/progression/enums/training_objective.dart';
import 'package:liftly/features/progression/models/progression_config.dart';

void main() {
  group('Derivación de Valores en UI', () {
    late Exercise testExercise;

    setUp(() {
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

    group('Derivación de RPE por Objetivo', () {
      test('debería derivar RPE correcto para FUERZA', () {
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

        final objective = AdaptiveIncrementConfig.parseObjective(config.getTrainingObjective());

        int targetRPE;
        switch (objective) {
          case TrainingObjective.strength:
            targetRPE = 8; // RPE alto para fuerza máxima
            break;
          case TrainingObjective.hypertrophy:
            targetRPE = 7; // RPE moderado-alto para hipertrofia
            break;
          case TrainingObjective.endurance:
            targetRPE = 6; // RPE moderado para resistencia
            break;
          case TrainingObjective.power:
            targetRPE = 8; // RPE alto para potencia máxima
            break;
        }

        expect(targetRPE, 8); // Fuerza debería ser 8
      });

      test('debería derivar RPE correcto para HIPERTROFIA', () {
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

        final objective = AdaptiveIncrementConfig.parseObjective(config.getTrainingObjective());

        int targetRPE;
        switch (objective) {
          case TrainingObjective.strength:
            targetRPE = 8;
            break;
          case TrainingObjective.hypertrophy:
            targetRPE = 7;
            break;
          case TrainingObjective.endurance:
            targetRPE = 6;
            break;
          case TrainingObjective.power:
            targetRPE = 8;
            break;
        }

        expect(targetRPE, 7); // Hipertrofia debería ser 7
      });

      test('debería derivar RPE correcto para RESISTENCIA', () {
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

        final objective = AdaptiveIncrementConfig.parseObjective(config.getTrainingObjective());

        int targetRPE;
        switch (objective) {
          case TrainingObjective.strength:
            targetRPE = 8;
            break;
          case TrainingObjective.hypertrophy:
            targetRPE = 7;
            break;
          case TrainingObjective.endurance:
            targetRPE = 6;
            break;
          case TrainingObjective.power:
            targetRPE = 8;
            break;
        }

        expect(targetRPE, 6); // Resistencia debería ser 6
      });

      test('debería derivar RPE correcto para POTENCIA', () {
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

        final objective = AdaptiveIncrementConfig.parseObjective(config.getTrainingObjective());

        int targetRPE;
        switch (objective) {
          case TrainingObjective.strength:
            targetRPE = 8;
            break;
          case TrainingObjective.hypertrophy:
            targetRPE = 7;
            break;
          case TrainingObjective.endurance:
            targetRPE = 6;
            break;
          case TrainingObjective.power:
            targetRPE = 8;
            break;
        }

        expect(targetRPE, 8); // Potencia debería ser 8
      });
    });

    group('Derivación de Rango de RPE por Objetivo', () {
      test('debería derivar rango correcto para FUERZA', () {
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

        final objective = AdaptiveIncrementConfig.parseObjective(config.getTrainingObjective());

        int rpeRange;
        switch (objective) {
          case TrainingObjective.strength:
            rpeRange = 1; // Rango estrecho para fuerza
            break;
          case TrainingObjective.hypertrophy:
            rpeRange = 2; // Rango moderado para hipertrofia
            break;
          case TrainingObjective.endurance:
            rpeRange = 3; // Rango amplio para resistencia
            break;
          case TrainingObjective.power:
            rpeRange = 1; // Rango estrecho para potencia
            break;
        }

        expect(rpeRange, 1); // Fuerza debería ser 1
      });

      test('debería derivar rango correcto para HIPERTROFIA', () {
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

        final objective = AdaptiveIncrementConfig.parseObjective(config.getTrainingObjective());

        int rpeRange;
        switch (objective) {
          case TrainingObjective.strength:
            rpeRange = 1;
            break;
          case TrainingObjective.hypertrophy:
            rpeRange = 2;
            break;
          case TrainingObjective.endurance:
            rpeRange = 3;
            break;
          case TrainingObjective.power:
            rpeRange = 1;
            break;
        }

        expect(rpeRange, 2); // Hipertrofia debería ser 2
      });

      test('debería derivar rango correcto para RESISTENCIA', () {
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

        final objective = AdaptiveIncrementConfig.parseObjective(config.getTrainingObjective());

        int rpeRange;
        switch (objective) {
          case TrainingObjective.strength:
            rpeRange = 1;
            break;
          case TrainingObjective.hypertrophy:
            rpeRange = 2;
            break;
          case TrainingObjective.endurance:
            rpeRange = 3;
            break;
          case TrainingObjective.power:
            rpeRange = 1;
            break;
        }

        expect(rpeRange, 3); // Resistencia debería ser 3
      });

      test('debería derivar rango correcto para POTENCIA', () {
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

        final objective = AdaptiveIncrementConfig.parseObjective(config.getTrainingObjective());

        int rpeRange;
        switch (objective) {
          case TrainingObjective.strength:
            rpeRange = 1;
            break;
          case TrainingObjective.hypertrophy:
            rpeRange = 2;
            break;
          case TrainingObjective.endurance:
            rpeRange = 3;
            break;
          case TrainingObjective.power:
            rpeRange = 1;
            break;
        }

        expect(rpeRange, 1); // Potencia debería ser 1
      });
    });

    group('Derivación de Tiempo de Descanso por Objetivo', () {
      test('debería derivar tiempo correcto para FUERZA', () {
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

        final objective = AdaptiveIncrementConfig.parseObjective(config.getTrainingObjective());

        final restTime = AdaptiveIncrementConfig.getRestTimeSeconds(testExercise, objective: objective);

        expect(restTime, 240); // Fuerza multi-joint debería ser 240s (4 min)
      });

      test('debería derivar tiempo correcto para HIPERTROFIA', () {
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

        final objective = AdaptiveIncrementConfig.parseObjective(config.getTrainingObjective());

        final restTime = AdaptiveIncrementConfig.getRestTimeSeconds(testExercise, objective: objective);

        expect(restTime, 120); // Hipertrofia multi-joint debería ser 120s (2 min)
      });

      test('debería derivar tiempo correcto para RESISTENCIA', () {
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

        final objective = AdaptiveIncrementConfig.parseObjective(config.getTrainingObjective());

        final restTime = AdaptiveIncrementConfig.getRestTimeSeconds(testExercise, objective: objective);

        expect(restTime, 60); // Resistencia multi-joint debería ser 60s (1 min)
      });

      test('debería derivar tiempo correcto para POTENCIA', () {
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

        final objective = AdaptiveIncrementConfig.parseObjective(config.getTrainingObjective());

        final restTime = AdaptiveIncrementConfig.getRestTimeSeconds(testExercise, objective: objective);

        expect(restTime, 240); // Potencia multi-joint debería ser 240s (4 min)
      });
    });

    group('Integración con Presets', () {
      test('debería derivar valores correctos para preset de FUERZA', () {
        final presets = PresetProgressionConfigs.getPresetsForType(ProgressionType.linear);
        final strengthPreset = presets.firstWhere((preset) => preset.primaryTarget == ProgressionTarget.weight);

        final objective = AdaptiveIncrementConfig.parseObjective(strengthPreset.getTrainingObjective());

        expect(objective, TrainingObjective.strength);

        final (minReps, maxReps) = AdaptiveIncrementConfig.getRepetitionsRange(testExercise, objective: objective);

        expect(minReps, 3);
        expect(maxReps, 6);
      });

      test('debería derivar valores correctos para preset de HIPERTROFIA', () {
        final presets = PresetProgressionConfigs.getPresetsForType(ProgressionType.linear);
        final hypertrophyPreset = presets.firstWhere((preset) => preset.primaryTarget == ProgressionTarget.volume);

        final objective = AdaptiveIncrementConfig.parseObjective(hypertrophyPreset.getTrainingObjective());

        expect(objective, TrainingObjective.hypertrophy);

        final (minReps, maxReps) = AdaptiveIncrementConfig.getRepetitionsRange(testExercise, objective: objective);

        expect(minReps, 6);
        expect(maxReps, 12);
      });

      test('debería derivar valores correctos para preset de RESISTENCIA', () {
        final presets = PresetProgressionConfigs.getPresetsForType(ProgressionType.linear);
        final endurancePreset = presets.firstWhere((preset) => preset.primaryTarget == ProgressionTarget.reps);

        final objective = AdaptiveIncrementConfig.parseObjective(endurancePreset.getTrainingObjective());

        expect(objective, TrainingObjective.endurance);

        final (minReps, maxReps) = AdaptiveIncrementConfig.getRepetitionsRange(testExercise, objective: objective);

        expect(minReps, 15);
        expect(maxReps, 25);
      });
    });
  });
}
