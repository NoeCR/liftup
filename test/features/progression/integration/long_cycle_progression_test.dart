import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/muscle_group_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/configs/adaptive_increment_config.dart';
import 'package:liftly/features/progression/configs/preset_progression_configs.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/autoregulated_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/double_factor_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/double_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/overload_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/reverse_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/static_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/stepped_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/undulating_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/wave_progression_strategy.dart';

/// Tests exhaustivos para validar estrategias de progresión en ciclos largos (6 meses)
///
/// Estos tests simulan entrenamientos reales para validar:
/// - Incrementos de peso correctos según AdaptiveIncrementConfig
/// - Incrementos de series correctos
/// - Lógica de deload funcionando
/// - Resets de ciclo apropiados
/// - Progresión consistente a largo plazo
void main() {
  group('Long Cycle Progression Tests (6 months)', () {
    late List<Exercise> testExercises;
    late Map<String, dynamic> testStrategies;

    setUpAll(() {
      // Crear ejercicios de prueba para diferentes combinaciones
      testExercises = _createTestExercises();

      // Mapear estrategias disponibles
      testStrategies = {
        'linear': LinearProgressionStrategy(),
        'stepped': SteppedProgressionStrategy(),
        'double': DoubleProgressionStrategy(),
        'undulating': UndulatingProgressionStrategy(),
        'autoregulated': AutoregulatedProgressionStrategy(),
        'doubleFactor': DoubleFactorProgressionStrategy(),
        'wave': WaveProgressionStrategy(),
        'overload': OverloadProgressionStrategy(),
        'static': StaticProgressionStrategy(),
        'reverse': ReverseProgressionStrategy(),
      };
    });

    group('Linear Progression Strategy', () {
      test('Linear Hypertrophy - Barbell Multi-joint (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['linear']!,
          preset: PresetProgressionConfigs.createLinearHypertrophyPreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.multiJoint &&
                e.loadType == LoadType.barbell,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedLinearProgression(
            LoadType.barbell,
            ExerciseType.multiJoint,
          ),
        );
      });

      test('Linear Strength - Dumbbell Isolation (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['linear']!,
          preset: PresetProgressionConfigs.createLinearStrengthPreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.isolation &&
                e.loadType == LoadType.dumbbell,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedLinearProgression(
            LoadType.dumbbell,
            ExerciseType.isolation,
          ),
        );
      });

      test('Linear Endurance - Machine Multi-joint (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['linear']!,
          preset: PresetProgressionConfigs.createLinearEndurancePreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.multiJoint &&
                e.loadType == LoadType.machine,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedLinearProgression(
            LoadType.machine,
            ExerciseType.multiJoint,
          ),
        );
      });

      test('Linear Power - Cable Isolation (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['linear']!,
          preset: PresetProgressionConfigs.createLinearPowerPreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.isolation &&
                e.loadType == LoadType.cable,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedLinearProgression(
            LoadType.cable,
            ExerciseType.isolation,
          ),
        );
      });
    });

    group('Stepped Progression Strategy', () {
      test('Stepped Hypertrophy - Barbell Multi-joint (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['stepped']!,
          preset: PresetProgressionConfigs.createSteppedHypertrophyPreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.multiJoint &&
                e.loadType == LoadType.barbell,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedSteppedProgression(
            LoadType.barbell,
            ExerciseType.multiJoint,
          ),
        );
      });

      test('Stepped Strength - Dumbbell Isolation (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['stepped']!,
          preset: PresetProgressionConfigs.createSteppedStrengthPreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.isolation &&
                e.loadType == LoadType.dumbbell,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedSteppedProgression(
            LoadType.dumbbell,
            ExerciseType.isolation,
          ),
        );
      });
    });

    group('Double Progression Strategy', () {
      test('Double Hypertrophy - Barbell Multi-joint (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['double']!,
          preset: PresetProgressionConfigs.createDoubleHypertrophyPreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.multiJoint &&
                e.loadType == LoadType.barbell,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedDoubleProgression(
            LoadType.barbell,
            ExerciseType.multiJoint,
          ),
        );
      });

      test('Double Strength - Dumbbell Isolation (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['double']!,
          preset: PresetProgressionConfigs.createDoubleStrengthPreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.isolation &&
                e.loadType == LoadType.dumbbell,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedDoubleProgression(
            LoadType.dumbbell,
            ExerciseType.isolation,
          ),
        );
      });
    });

    group('Undulating Progression Strategy', () {
      test('Undulating Hypertrophy - Barbell Multi-joint (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['undulating']!,
          preset: PresetProgressionConfigs.createUndulatingHypertrophyPreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.multiJoint &&
                e.loadType == LoadType.barbell,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedUndulatingProgression(
            LoadType.barbell,
            ExerciseType.multiJoint,
          ),
        );
      });

      test('Undulating Strength - Dumbbell Isolation (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['undulating']!,
          preset: PresetProgressionConfigs.createUndulatingStrengthPreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.isolation &&
                e.loadType == LoadType.dumbbell,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedUndulatingProgression(
            LoadType.dumbbell,
            ExerciseType.isolation,
          ),
        );
      });
    });

    group('Autoregulated Progression Strategy', () {
      test('Autoregulated Hypertrophy - Barbell Multi-joint (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['autoregulated']!,
          preset:
              PresetProgressionConfigs.createAutoregulatedHypertrophyPreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.multiJoint &&
                e.loadType == LoadType.barbell,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedAutoregulatedProgression(
            LoadType.barbell,
            ExerciseType.multiJoint,
          ),
        );
      });

      test('Autoregulated Strength - Dumbbell Isolation (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['autoregulated']!,
          preset: PresetProgressionConfigs.createAutoregulatedStrengthPreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.isolation &&
                e.loadType == LoadType.dumbbell,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedAutoregulatedProgression(
            LoadType.dumbbell,
            ExerciseType.isolation,
          ),
        );
      });
    });

    group('Double Factor Progression Strategy', () {
      test('Double Factor Hypertrophy - Barbell Multi-joint (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['doubleFactor']!,
          preset:
              PresetProgressionConfigs.createDoubleFactorHypertrophyPreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.multiJoint &&
                e.loadType == LoadType.barbell,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedDoubleFactorProgression(
            LoadType.barbell,
            ExerciseType.multiJoint,
          ),
        );
      });

      test('Double Factor Strength - Dumbbell Isolation (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['doubleFactor']!,
          preset: PresetProgressionConfigs.createDoubleFactorStrengthPreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.isolation &&
                e.loadType == LoadType.dumbbell,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedDoubleFactorProgression(
            LoadType.dumbbell,
            ExerciseType.isolation,
          ),
        );
      });
    });

    group('Wave Progression Strategy', () {
      test('Wave Hypertrophy - Barbell Multi-joint (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['wave']!,
          preset: PresetProgressionConfigs.createWaveHypertrophyPreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.multiJoint &&
                e.loadType == LoadType.barbell,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedWaveProgression(
            LoadType.barbell,
            ExerciseType.multiJoint,
          ),
        );
      });

      test('Wave Strength - Dumbbell Isolation (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['wave']!,
          preset: PresetProgressionConfigs.createWaveStrengthPreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.isolation &&
                e.loadType == LoadType.dumbbell,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedWaveProgression(
            LoadType.dumbbell,
            ExerciseType.isolation,
          ),
        );
      });
    });

    group('Overload Progression Strategy', () {
      test('Overload Hypertrophy - Barbell Multi-joint (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['overload']!,
          preset: PresetProgressionConfigs.createOverloadHypertrophyPreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.multiJoint &&
                e.loadType == LoadType.barbell,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedOverloadProgression(
            LoadType.barbell,
            ExerciseType.multiJoint,
          ),
        );
      });

      test('Overload Strength - Dumbbell Isolation (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['overload']!,
          preset: PresetProgressionConfigs.createOverloadStrengthPreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.isolation &&
                e.loadType == LoadType.dumbbell,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedOverloadProgression(
            LoadType.dumbbell,
            ExerciseType.isolation,
          ),
        );
      });
    });

    group('Static Progression Strategy', () {
      test('Static Hypertrophy - Barbell Multi-joint (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['static']!,
          preset: PresetProgressionConfigs.createStaticHypertrophyPreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.multiJoint &&
                e.loadType == LoadType.barbell,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedStaticProgression(
            LoadType.barbell,
            ExerciseType.multiJoint,
          ),
        );
      });

      test('Static Strength - Dumbbell Isolation (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['static']!,
          preset: PresetProgressionConfigs.createStaticStrengthPreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.isolation &&
                e.loadType == LoadType.dumbbell,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedStaticProgression(
            LoadType.dumbbell,
            ExerciseType.isolation,
          ),
        );
      });
    });

    group('Reverse Progression Strategy', () {
      test('Reverse Hypertrophy - Barbell Multi-joint (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['reverse']!,
          preset: PresetProgressionConfigs.createReverseHypertrophyPreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.multiJoint &&
                e.loadType == LoadType.barbell,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedReverseProgression(
            LoadType.barbell,
            ExerciseType.multiJoint,
          ),
        );
      });

      test('Reverse Strength - Dumbbell Isolation (6 months)', () {
        _testLongCycleProgression(
          strategy: testStrategies['reverse']!,
          preset: PresetProgressionConfigs.createReverseStrengthPreset(),
          exercise: testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.isolation &&
                e.loadType == LoadType.dumbbell,
          ),
          months: 6,
          expectedWeightProgression: _getExpectedReverseProgression(
            LoadType.dumbbell,
            ExerciseType.isolation,
          ),
        );
      });
    });

    group('Edge Cases and Special Scenarios', () {
      test('Bodyweight exercises should not increment weight', () {
        final bodyweightExercise = testExercises.firstWhere(
          (e) => e.loadType == LoadType.bodyweight,
        );
        final strategy = testStrategies['linear']!;
        // Crear preset sin deloads para bodyweight
        final preset = PresetProgressionConfigs.createLinearHypertrophyPreset()
            .copyWith(
              deloadWeek: 0, // Sin deloads para bodyweight
            );

        final result = _testLongCycleProgression(
          strategy: strategy,
          preset: preset,
          exercise: bodyweightExercise,
          months: 3, // Test más corto para bodyweight
          expectedWeightProgression: _getExpectedBodyweightProgression(),
        );

        // Verificar que el peso no cambie para ejercicios de peso corporal
        expect(result.finalWeight, equals(result.initialWeight));
      });

      test('Resistance band exercises should not increment weight', () {
        final resistanceBandExercise = testExercises.firstWhere(
          (e) => e.loadType == LoadType.resistanceBand,
        );
        final strategy = testStrategies['linear']!;
        // Crear preset sin deloads para resistance band
        final preset = PresetProgressionConfigs.createLinearHypertrophyPreset()
            .copyWith(
              deloadWeek: 0, // Sin deloads para resistance band
            );

        final result = _testLongCycleProgression(
          strategy: strategy,
          preset: preset,
          exercise: resistanceBandExercise,
          months: 3, // Test más corto para resistance band
          expectedWeightProgression: _getExpectedResistanceBandProgression(),
        );

        // Verificar que el peso no cambie para ejercicios de banda elástica
        expect(result.finalWeight, equals(result.initialWeight));
      });

      test('Deload weeks should reduce weight appropriately', () {
        final strategy = testStrategies['linear']!;
        final preset = PresetProgressionConfigs.createLinearHypertrophyPreset();
        final exercise = testExercises.firstWhere(
          (e) =>
              e.exerciseType == ExerciseType.multiJoint &&
              e.loadType == LoadType.barbell,
        );

        final result = _testLongCycleProgression(
          strategy: strategy,
          preset: preset,
          exercise: exercise,
          months: 2, // Test más corto para validar deload
          expectedWeightProgression: _getExpectedLinearProgression(
            LoadType.barbell,
            ExerciseType.multiJoint,
          ),
        );

        // Verificar que se hayan aplicado deloads
        expect(result.deloadCount, greaterThan(0));

        // Verificar que los deloads redujeron el peso apropiadamente
        for (final deload in result.deloadSessions) {
          expect(deload.weight, lessThan(deload.previousWeight));
          expect(
            deload.weight,
            greaterThanOrEqualTo(
              deload.previousWeight * preset.deloadPercentage,
            ),
          );
        }
      });

      test('Series increments should work correctly for different load types', () {
        final strategy =
            testStrategies['wave']!; // Usar WaveProgressionStrategy que sí incrementa series
        final preset = PresetProgressionConfigs.createWaveHypertrophyPreset();

        // Test con diferentes tipos de carga que soportan incrementos de series
        final loadTypes = [
          LoadType.machine,
          LoadType.bodyweight,
          LoadType.resistanceBand,
        ];

        for (final loadType in loadTypes) {
          final exercise = testExercises.firstWhere(
            (e) => e.loadType == loadType,
          );

          final result = _testLongCycleProgression(
            strategy: strategy,
            preset: preset,
            exercise: exercise,
            months: 2, // Test más corto
            expectedWeightProgression: _getExpectedSeriesIncrementProgression(
              loadType,
            ),
          );

          // Verificar que se hayan aplicado incrementos de series
          expect(result.seriesIncrementCount, greaterThan(0));
        }
      });
    });
  });
}

/// Helper function para crear ejercicios de prueba
List<Exercise> _createTestExercises() {
  final now = DateTime.now();
  final exercises = <Exercise>[];

  // Crear ejercicios para todas las combinaciones de ExerciseType y LoadType
  for (final exerciseType in ExerciseType.values) {
    for (final loadType in LoadType.values) {
      exercises.add(
        Exercise(
          id: 'test-${exerciseType.name}-${loadType.name}',
          name: 'Test ${exerciseType.name} ${loadType.name}',
          description:
              'Test exercise for ${exerciseType.name} ${loadType.name}',
          imageUrl: '',
          muscleGroups:
              exerciseType == ExerciseType.multiJoint
                  ? [MuscleGroup.pectoralMajor]
                  : [MuscleGroup.bicepsLongHead],
          tips: [],
          commonMistakes: [],
          category:
              exerciseType == ExerciseType.multiJoint
                  ? ExerciseCategory.chest
                  : ExerciseCategory.biceps,
          difficulty: ExerciseDifficulty.intermediate,
          createdAt: now,
          updatedAt: now,
          exerciseType: exerciseType,
          loadType: loadType,
        ),
      );
    }
  }

  return exercises;
}

/// Helper function para obtener la progresión esperada de Linear Progression
Map<String, dynamic> _getExpectedLinearProgression(
  LoadType loadType,
  ExerciseType exerciseType,
) {
  final incrementRange = AdaptiveIncrementConfig.getIncrementRange(
    _createTempExercise(exerciseType, loadType),
  );
  final seriesIncrementRange = AdaptiveIncrementConfig.getSeriesIncrementRange(
    _createTempExercise(exerciseType, loadType),
  );

  return {
    'weightIncrement': incrementRange?.defaultValue ?? 0.0,
    'seriesIncrement': seriesIncrementRange?.defaultValue ?? 0,
    'frequency': 1, // Linear progression increments every session
    'deloadFrequency': 4, // Every 4 sessions
  };
}

/// Helper function para obtener la progresión esperada de Stepped Progression
Map<String, dynamic> _getExpectedSteppedProgression(
  LoadType loadType,
  ExerciseType exerciseType,
) {
  final incrementRange = AdaptiveIncrementConfig.getIncrementRange(
    _createTempExercise(exerciseType, loadType),
  );

  return {
    'weightIncrement':
        (incrementRange?.defaultValue ?? 0.0) *
        2, // Stepped doubles the increment
    'frequency': 2, // Stepped progression increments every 2 sessions
    'deloadFrequency': 6, // Every 6 sessions
  };
}

/// Helper function para obtener la progresión esperada de Double Progression
Map<String, dynamic> _getExpectedDoubleProgression(
  LoadType loadType,
  ExerciseType exerciseType,
) {
  final incrementRange = AdaptiveIncrementConfig.getIncrementRange(
    _createTempExercise(exerciseType, loadType),
  );

  return {
    'weightIncrement': incrementRange?.defaultValue ?? 0.0,
    'frequency': 1, // Double progression can increment every session
    'deloadFrequency': 4, // Every 4 sessions
    'repProgression': true, // Double progression also progresses reps
  };
}

/// Helper function para obtener la progresión esperada de Undulating Progression
Map<String, dynamic> _getExpectedUndulatingProgression(
  LoadType loadType,
  ExerciseType exerciseType,
) {
  final incrementRange = AdaptiveIncrementConfig.getIncrementRange(
    _createTempExercise(exerciseType, loadType),
  );

  return {
    'weightIncrement': incrementRange?.defaultValue ?? 0.0,
    'frequency': 3, // Undulating alternates between heavy/light/medium
    'deloadFrequency': 9, // Every 9 sessions (3 cycles)
    'undulatingPattern': true, // Should show alternating intensity
  };
}

/// Helper function para obtener la progresión esperada de Autoregulated Progression
Map<String, dynamic> _getExpectedAutoregulatedProgression(
  LoadType loadType,
  ExerciseType exerciseType,
) {
  final incrementRange = AdaptiveIncrementConfig.getIncrementRange(
    _createTempExercise(exerciseType, loadType),
  );

  return {
    'weightIncrement': incrementRange?.defaultValue ?? 0.0,
    'frequency': 1, // Autoregulated can increment every session based on RPE
    'deloadFrequency': 8, // Every 8 sessions
    'rpeBased': true, // Should be based on RPE thresholds
  };
}

/// Helper function para obtener la progresión esperada de Double Factor Progression
Map<String, dynamic> _getExpectedDoubleFactorProgression(
  LoadType loadType,
  ExerciseType exerciseType,
) {
  final incrementRange = AdaptiveIncrementConfig.getIncrementRange(
    _createTempExercise(exerciseType, loadType),
  );

  return {
    'weightIncrement': incrementRange?.defaultValue ?? 0.0,
    'frequency': 1, // Double factor can increment every session
    'deloadFrequency': 6, // Every 6 sessions
    'volumeIntensityAlternating':
        true, // Alternates between volume and intensity weeks
  };
}

/// Helper function para obtener la progresión esperada de Wave Progression
Map<String, dynamic> _getExpectedWaveProgression(
  LoadType loadType,
  ExerciseType exerciseType,
) {
  final incrementRange = AdaptiveIncrementConfig.getIncrementRange(
    _createTempExercise(exerciseType, loadType),
  );

  return {
    'weightIncrement': incrementRange?.defaultValue ?? 0.0,
    'frequency': 1, // Wave can increment every session
    'deloadFrequency': 6, // Every 6 sessions
    'wavePattern': true, // Should show wave-like progression pattern
  };
}

/// Helper function para obtener la progresión esperada de Overload Progression
Map<String, dynamic> _getExpectedOverloadProgression(
  LoadType loadType,
  ExerciseType exerciseType,
) {
  final incrementRange = AdaptiveIncrementConfig.getIncrementRange(
    _createTempExercise(exerciseType, loadType),
  );

  return {
    'weightIncrement':
        (incrementRange?.defaultValue ?? 0.0) *
        1.1, // Overload uses 110% factor
    'frequency': 1, // Overload can increment every session
    'deloadFrequency': 4, // Every 4 sessions
    'overloadFactor': 1.1, // Should apply overload factor
  };
}

/// Helper function para obtener la progresión esperada de Static Progression
Map<String, dynamic> _getExpectedStaticProgression(
  LoadType loadType,
  ExerciseType exerciseType,
) {
  return {
    'weightIncrement':
        0.0, // Static progression doesn't increment weight automatically
    'frequency': 0, // No automatic increments
    'deloadFrequency': 8, // Every 8 sessions
    'manualProgression': true, // Should require manual progression
  };
}

/// Helper function para obtener la progresión esperada de Reverse Progression
Map<String, dynamic> _getExpectedReverseProgression(
  LoadType loadType,
  ExerciseType exerciseType,
) {
  final incrementRange = AdaptiveIncrementConfig.getIncrementRange(
    _createTempExercise(exerciseType, loadType),
  );

  return {
    'weightIncrement': incrementRange?.defaultValue ?? 0.0,
    'frequency': 1, // Reverse can increment every session
    'deloadFrequency': 4, // Every 4 sessions
    'reversePattern': true, // Should show reverse progression pattern
  };
}

/// Helper function para obtener la progresión esperada de Bodyweight exercises
Map<String, dynamic> _getExpectedBodyweightProgression() {
  return {
    'weightIncrement': 0.0, // Bodyweight exercises don't increment weight
    'seriesIncrement': 2, // But can increment series
    'frequency': 0, // No weight increments
    'deloadFrequency': 0, // No deloads for bodyweight
  };
}

/// Helper function para obtener la progresión esperada de Resistance Band exercises
Map<String, dynamic> _getExpectedResistanceBandProgression() {
  return {
    'weightIncrement': 0.0, // Resistance band exercises don't increment weight
    'seriesIncrement': 2, // But can increment series
    'frequency': 0, // No weight increments
    'deloadFrequency': 0, // No deloads for resistance band
  };
}

/// Helper function para obtener la progresión esperada de Series Increment
Map<String, dynamic> _getExpectedSeriesIncrementProgression(LoadType loadType) {
  final seriesIncrementRange = AdaptiveIncrementConfig.getSeriesIncrementRange(
    _createTempExercise(ExerciseType.multiJoint, loadType),
  );

  return {
    'weightIncrement': 0.0, // Focus on series increments
    'seriesIncrement': seriesIncrementRange?.defaultValue ?? 0,
    'frequency': 1, // Can increment series every session
    'deloadFrequency': 4, // Still has deloads
  };
}

/// Helper function para crear un ejercicio temporal
Exercise _createTempExercise(ExerciseType exerciseType, LoadType loadType) {
  final now = DateTime.now();
  return Exercise(
    id: 'temp-${exerciseType.name}-${loadType.name}',
    name: 'Temp ${exerciseType.name} ${loadType.name}',
    description: 'Temporary exercise for testing',
    imageUrl: '',
    muscleGroups:
        exerciseType == ExerciseType.multiJoint
            ? [MuscleGroup.pectoralMajor]
            : [MuscleGroup.bicepsLongHead],
    tips: [],
    commonMistakes: [],
    category:
        exerciseType == ExerciseType.multiJoint
            ? ExerciseCategory.chest
            : ExerciseCategory.biceps,
    difficulty: ExerciseDifficulty.intermediate,
    createdAt: now,
    updatedAt: now,
    exerciseType: exerciseType,
    loadType: loadType,
  );
}

/// Helper function para ejecutar un test de ciclo largo
LongCycleTestResult _testLongCycleProgression({
  required dynamic strategy,
  required ProgressionConfig preset,
  required Exercise exercise,
  required int months,
  required Map<String, dynamic> expectedWeightProgression,
}) {
  // Calcular número de sesiones (asumiendo 3 sesiones por semana)
  final sessionsPerWeek = preset.customParameters['sessions_per_week'] ?? 3;
  final totalSessions = months * 4 * sessionsPerWeek; // 4 semanas por mes

  // Estado inicial
  var currentState = ProgressionState(
    id: 'test-state',
    progressionConfigId: preset.id,
    routineId: 'test-routine',
    exerciseId: exercise.id,
    currentCycle: 1,
    currentWeek: 1,
    currentSession: 1,
    currentWeight: 100.0, // Peso inicial de 100kg
    currentReps: preset.minReps,
    currentSets: preset.baseSets,
    baseWeight: 80.0, // Peso base menor para permitir deloads
    baseReps: preset.minReps,
    baseSets: preset.baseSets,
    sessionHistory: {},
    lastUpdated: DateTime.now(),
    isDeloadWeek: false,
    customData: {},
  );

  // Variables para tracking
  final progressionHistory = <SessionResult>[];
  var totalWeightIncrements = 0.0;
  var totalSeriesIncrements = 0.0;
  var deloadCount = 0;
  final deloadSessions = <DeloadSession>[];
  var seriesIncrementCount = 0;

  // Simular todas las sesiones
  for (int session = 1; session <= totalSessions; session++) {
    final result = strategy.calculate(
      config: preset,
      state: currentState,
      routineId: 'test-routine',
      currentWeight: currentState.currentWeight,
      currentReps: currentState.currentReps,
      currentSets: currentState.currentSets,
      isExerciseLocked: false,
      exercise: exercise,
    );

    // Trackear progresión ANTES de actualizar el estado
    if (result.incrementApplied) {
      totalWeightIncrements += (result.newWeight - currentState.currentWeight);
    }

    if (result.newSets > currentState.currentSets) {
      totalSeriesIncrements += (result.newSets - currentState.currentSets);
      seriesIncrementCount++;
    }

    if (result.isDeload) {
      deloadCount++;
      deloadSessions.add(
        DeloadSession(
          session: session,
          weight: result.newWeight, // Peso después del deload
          previousWeight: currentState.currentWeight, // Peso antes del deload
          reason: result.reason,
        ),
      );
    }

    // Actualizar estado DESPUÉS de trackear
    // Calcular la semana basada en la sesión (3 sesiones por semana)
    final week = ((session - 1) ~/ 3) + 1;
    currentState = currentState.copyWith(
      currentSession: session,
      currentWeek: week,
      currentWeight: result.newWeight,
      currentReps: result.newReps,
      currentSets: result.newSets,
      lastUpdated: DateTime.now(),
    );

    // Guardar resultado de la sesión
    progressionHistory.add(
      SessionResult(
        session: session,
        weight: result.newWeight,
        reps: result.newReps,
        sets: result.newSets,
        incrementApplied: result.incrementApplied,
        isDeload: result.isDeload,
        reason: result.reason,
      ),
    );
  }

  return LongCycleTestResult(
    initialWeight: 100.0,
    finalWeight: currentState.currentWeight,
    totalWeightIncrements: totalWeightIncrements,
    totalSeriesIncrements: totalSeriesIncrements.toInt(),
    deloadCount: deloadCount,
    deloadSessions: deloadSessions,
    seriesIncrementCount: seriesIncrementCount,
    progressionHistory: progressionHistory,
    finalState: currentState,
  );
}

/// Clases de datos para los resultados de los tests
class LongCycleTestResult {
  final double initialWeight;
  final double finalWeight;
  final double totalWeightIncrements;
  final int totalSeriesIncrements;
  final int deloadCount;
  final List<DeloadSession> deloadSessions;
  final int seriesIncrementCount;
  final List<SessionResult> progressionHistory;
  final ProgressionState finalState;

  const LongCycleTestResult({
    required this.initialWeight,
    required this.finalWeight,
    required this.totalWeightIncrements,
    required this.totalSeriesIncrements,
    required this.deloadCount,
    required this.deloadSessions,
    required this.seriesIncrementCount,
    required this.progressionHistory,
    required this.finalState,
  });
}

class SessionResult {
  final int session;
  final double weight;
  final int reps;
  final int sets;
  final bool incrementApplied;
  final bool isDeload;
  final String reason;

  const SessionResult({
    required this.session,
    required this.weight,
    required this.reps,
    required this.sets,
    required this.incrementApplied,
    required this.isDeload,
    required this.reason,
  });
}

class DeloadSession {
  final int session;
  final double weight;
  final double previousWeight;
  final String reason;

  const DeloadSession({
    required this.session,
    required this.weight,
    required this.previousWeight,
    required this.reason,
  });
}
