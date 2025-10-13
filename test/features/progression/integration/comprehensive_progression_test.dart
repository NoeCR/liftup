import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/muscle_group_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/configs/preset_progression_configs.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/stepped_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/double_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/undulating_progression_strategy.dart';

/// Tests comprehensivos para validar estrategias de progresión en ciclos largos
/// Estos tests simulan 6 meses de entrenamiento para validar:
/// - Incrementos de peso correctos según AdaptiveIncrementConfig
/// - Lógica de deload funcionando correctamente
/// - Progresión consistente a largo plazo
void main() {
  group('Comprehensive Progression Tests (6 months)', () {
    late List<Exercise> testExercises;
    late Map<String, dynamic> strategies;

    setUpAll(() {
      testExercises = _createTestExercises();
      strategies = {
        'linear': LinearProgressionStrategy(),
        'stepped': SteppedProgressionStrategy(),
        'double': DoubleProgressionStrategy(),
        'undulating': UndulatingProgressionStrategy(),
      };
    });

    group('Linear Progression Strategy', () {
      test('6-month simulation with barbell multi-joint', () {
        final exercise = testExercises.firstWhere(
          (e) => e.exerciseType == ExerciseType.multiJoint && e.loadType == LoadType.barbell,
        );
        final preset = PresetProgressionConfigs.createLinearHypertrophyPreset();
        final strategy = strategies['linear']!;

        final result = _simulateLongTermProgression(strategy: strategy, preset: preset, exercise: exercise, months: 6);

        // Validar que la progresión fue exitosa
        expect(result.success, isTrue);
        expect(result.totalSessions, greaterThan(0));
        expect(result.finalWeight, greaterThan(result.initialWeight));
        expect(result.deloadCount, greaterThan(0));

        // Validar incrementos consistentes
        expect(result.averageWeightIncrement, closeTo(6.0, 0.1)); // 6kg promedio por sesión de incremento

        // Validar que se aplicaron deloads
        expect(result.deloadCount, greaterThan(0));

        print('\n📊 Linear Progression - 6 months:');
        print('  Initial Weight: ${result.initialWeight}kg');
        print('  Final Weight: ${result.finalWeight}kg');
        print('  Total Gain: ${(result.finalWeight - result.initialWeight).toStringAsFixed(1)}kg');
        print('  Total Sessions: ${result.totalSessions}');
        print('  Deloads Applied: ${result.deloadCount}');
        print('  Average Increment: ${result.averageWeightIncrement.toStringAsFixed(1)}kg');
      });

      test('6-month simulation with dumbbell isolation', () {
        final exercise = testExercises.firstWhere(
          (e) => e.exerciseType == ExerciseType.isolation && e.loadType == LoadType.dumbbell,
        );
        final preset = PresetProgressionConfigs.createLinearHypertrophyPreset();
        final strategy = strategies['linear']!;

        final result = _simulateLongTermProgression(strategy: strategy, preset: preset, exercise: exercise, months: 6);

        // Validar que la progresión fue exitosa
        expect(result.success, isTrue);
        expect(result.finalWeight, greaterThan(result.initialWeight));

        // Validar incrementos más pequeños para isolation
        expect(result.averageWeightIncrement, closeTo(1.875, 0.1)); // 1.875kg promedio

        print('\n📊 Linear Progression (Dumbbell Isolation) - 6 months:');
        print('  Initial Weight: ${result.initialWeight}kg');
        print('  Final Weight: ${result.finalWeight}kg');
        print('  Total Gain: ${(result.finalWeight - result.initialWeight).toStringAsFixed(1)}kg');
        print('  Average Increment: ${result.averageWeightIncrement.toStringAsFixed(1)}kg');
      });

      test('Bodyweight exercises should not increment weight over 6 months', () {
        final exercise = testExercises.firstWhere(
          (e) => e.exerciseType == ExerciseType.multiJoint && e.loadType == LoadType.bodyweight,
        );
        final preset = PresetProgressionConfigs.createLinearHypertrophyPreset();
        final strategy = strategies['linear']!;

        final result = _simulateLongTermProgression(strategy: strategy, preset: preset, exercise: exercise, months: 6);

        // Validar que no hay incremento de peso
        expect(result.success, isTrue);
        expect(result.finalWeight, equals(result.initialWeight));
        expect(result.averageWeightIncrement, equals(0.0));

        print('\n📊 Linear Progression (Bodyweight) - 6 months:');
        print('  Weight: ${result.finalWeight}kg (no change)');
        print('  Total Sessions: ${result.totalSessions}');
      });
    });

    group('Stepped Progression Strategy', () {
      test('6-month simulation with barbell multi-joint', () {
        final exercise = testExercises.firstWhere(
          (e) => e.exerciseType == ExerciseType.multiJoint && e.loadType == LoadType.barbell,
        );
        final preset = PresetProgressionConfigs.createSteppedHypertrophyPreset();
        final strategy = strategies['stepped']!;

        final result = _simulateLongTermProgression(strategy: strategy, preset: preset, exercise: exercise, months: 6);

        // Validar que la progresión fue exitosa
        expect(result.success, isTrue);
        expect(result.finalWeight, greaterThan(result.initialWeight));

        // Stepped progression should have larger total gains due to accumulation
        final totalGain = result.finalWeight - result.initialWeight;
        expect(totalGain, greaterThan(50.0)); // Should gain more than linear over 6 months

        print('\n📊 Stepped Progression - 6 months:');
        print('  Initial Weight: ${result.initialWeight}kg');
        print('  Final Weight: ${result.finalWeight}kg');
        print('  Total Gain: ${(result.finalWeight - result.initialWeight).toStringAsFixed(1)}kg');
        print('  Average Increment: ${result.averageWeightIncrement.toStringAsFixed(1)}kg');
      });
    });

    group('Double Progression Strategy', () {
      test('6-month simulation with barbell multi-joint', () {
        final exercise = testExercises.firstWhere(
          (e) => e.exerciseType == ExerciseType.multiJoint && e.loadType == LoadType.barbell,
        );
        final preset = PresetProgressionConfigs.createDoubleHypertrophyPreset();
        final strategy = strategies['double']!;

        final result = _simulateLongTermProgression(strategy: strategy, preset: preset, exercise: exercise, months: 6);

        // Validar que la progresión fue exitosa
        expect(result.success, isTrue);
        expect(result.finalWeight, greaterThan(result.initialWeight));

        print('\n📊 Double Progression - 6 months:');
        print('  Initial Weight: ${result.initialWeight}kg');
        print('  Final Weight: ${result.finalWeight}kg');
        print('  Total Gain: ${(result.finalWeight - result.initialWeight).toStringAsFixed(1)}kg');
        print('  Average Increment: ${result.averageWeightIncrement.toStringAsFixed(1)}kg');
      });
    });

    group('Undulating Progression Strategy', () {
      test('6-month simulation with barbell multi-joint', () {
        final exercise = testExercises.firstWhere(
          (e) => e.exerciseType == ExerciseType.multiJoint && e.loadType == LoadType.barbell,
        );
        final preset = PresetProgressionConfigs.createUndulatingHypertrophyPreset();
        final strategy = strategies['undulating']!;

        final result = _simulateLongTermProgression(strategy: strategy, preset: preset, exercise: exercise, months: 6);

        // Validar que la progresión fue exitosa
        expect(result.success, isTrue);
        expect(result.finalWeight, greaterThan(result.initialWeight));

        // Undulating should show more variability
        expect(result.weightVariance, greaterThan(0));

        print('\n📊 Undulating Progression - 6 months:');
        print('  Initial Weight: ${result.initialWeight}kg');
        print('  Final Weight: ${result.finalWeight}kg');
        print('  Total Gain: ${(result.finalWeight - result.initialWeight).toStringAsFixed(1)}kg');
        print('  Weight Variance: ${result.weightVariance.toStringAsFixed(2)}');
      });
    });

    group('Cross-Strategy Comparison', () {
      test('Compare all strategies over 3 months', () {
        final exercise = testExercises.firstWhere(
          (e) => e.exerciseType == ExerciseType.multiJoint && e.loadType == LoadType.barbell,
        );

        final results = <String, LongTermResult>{};

        for (final entry in strategies.entries) {
          final strategyName = entry.key;
          final strategy = entry.value;

          ProgressionConfig preset;
          switch (strategyName) {
            case 'linear':
              preset = PresetProgressionConfigs.createLinearHypertrophyPreset();
              break;
            case 'stepped':
              preset = PresetProgressionConfigs.createSteppedHypertrophyPreset();
              break;
            case 'double':
              preset = PresetProgressionConfigs.createDoubleHypertrophyPreset();
              break;
            case 'undulating':
              preset = PresetProgressionConfigs.createUndulatingHypertrophyPreset();
              break;
            default:
              continue;
          }

          final result = _simulateLongTermProgression(
            strategy: strategy,
            preset: preset,
            exercise: exercise,
            months: 3,
          );

          results[strategyName] = result;
        }

        // Validar que todas las estrategias funcionaron
        for (final entry in results.entries) {
          expect(entry.value.success, isTrue, reason: '${entry.key} strategy failed');
          expect(
            entry.value.finalWeight,
            greaterThan(entry.value.initialWeight),
            reason: '${entry.key} strategy did not increase weight',
          );
        }

        print('\n📊 Cross-Strategy Comparison (3 months):');
        for (final entry in results.entries) {
          final result = entry.value;
          final gain = result.finalWeight - result.initialWeight;
          print('  ${entry.key.toUpperCase()}: ${gain.toStringAsFixed(1)}kg gain, ${result.deloadCount} deloads');
        }
      });
    });
  });
}

/// Helper function para crear ejercicios de prueba
List<Exercise> _createTestExercises() {
  final now = DateTime.now();
  final exercises = <Exercise>[];

  // Crear ejercicios representativos
  final combinations = [
    {'type': ExerciseType.multiJoint, 'load': LoadType.barbell},
    {'type': ExerciseType.isolation, 'load': LoadType.dumbbell},
    {'type': ExerciseType.multiJoint, 'load': LoadType.machine},
    {'type': ExerciseType.isolation, 'load': LoadType.cable},
    {'type': ExerciseType.multiJoint, 'load': LoadType.bodyweight},
    {'type': ExerciseType.isolation, 'load': LoadType.resistanceBand},
  ];

  for (final combo in combinations) {
    final exerciseType = combo['type'] as ExerciseType;
    final loadType = combo['load'] as LoadType;

    exercises.add(
      Exercise(
        id: 'test-${exerciseType.name}-${loadType.name}',
        name: 'Test ${exerciseType.name} ${loadType.name}',
        description: 'Test exercise for ${exerciseType.name} ${loadType.name}',
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
      ),
    );
  }

  return exercises;
}

/// Helper function para simular progresión a largo plazo
LongTermResult _simulateLongTermProgression({
  required dynamic strategy,
  required ProgressionConfig preset,
  required Exercise exercise,
  required int months,
}) {
  try {
    // Calcular número de sesiones (asumiendo 3 sesiones por semana)
    final sessionsPerWeek = (preset.customParameters['sessions_per_week'] ?? 3) as int;
    final totalSessions = months * 4 * sessionsPerWeek; // 4 semanas por mes

    // Estado inicial
    var currentState = ProgressionState(
      id: 'test-state',
      progressionConfigId: 'test-config',
      exerciseId: exercise.id,
      routineId: 'test',
      currentCycle: 1,
      currentWeek: 1,
      currentSession: 1,
      currentWeight: 100.0,
      currentReps: preset.minReps,
      currentSets: preset.baseSets,
      baseWeight: 100.0,
      baseReps: preset.minReps,
      baseSets: preset.baseSets,
      sessionHistory: {},
      lastUpdated: DateTime.now(),
      isDeloadWeek: false,
      customData: {},
    );

    // Variables para tracking
    final progressionHistory = <SessionData>[];
    var totalWeightIncrements = 0.0;
    var deloadCount = 0;
    var incrementSessionCount = 0;

    // Simular todas las sesiones
    for (int session = 1; session <= totalSessions; session++) {
      final result = strategy.calculate(
        config: preset,
        state: currentState,
        routineId: 'test',
        currentWeight: currentState.currentWeight,
        currentReps: currentState.currentReps,
        currentSets: currentState.currentSets,
        exercise: exercise,
      );

      // Trackear progresión antes de actualizar el estado
      final weightChange = result.newWeight - currentState.currentWeight;
      if (result.incrementApplied && weightChange > 0) {
        totalWeightIncrements += weightChange;
        incrementSessionCount++;
      }

      // Actualizar estado
      currentState = currentState.copyWith(
        currentWeight: result.newWeight,
        currentReps: result.newReps,
        currentSets: result.newSets,
        currentSession: session,
        lastUpdated: DateTime.now(),
      );

      if (result.isDeload) {
        deloadCount++;
      }

      // Guardar datos de la sesión
      progressionHistory.add(
        SessionData(
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

    // Calcular estadísticas
    final averageWeightIncrement = incrementSessionCount > 0 ? totalWeightIncrements / incrementSessionCount : 0.0;

    final weightVariance = _calculateWeightVariance(progressionHistory);

    return LongTermResult(
      success: true,
      initialWeight: 100.0,
      finalWeight: currentState.currentWeight,
      totalSessions: totalSessions,
      deloadCount: deloadCount,
      averageWeightIncrement: averageWeightIncrement,
      weightVariance: weightVariance,
      progressionHistory: progressionHistory,
    );
  } catch (e) {
    return LongTermResult(
      success: false,
      initialWeight: 100.0,
      finalWeight: 100.0,
      totalSessions: 0,
      deloadCount: 0,
      averageWeightIncrement: 0.0,
      weightVariance: 0.0,
      progressionHistory: [],
      error: e.toString(),
    );
  }
}

/// Helper function para calcular la varianza de peso
double _calculateWeightVariance(List<SessionData> history) {
  if (history.length < 2) return 0.0;

  final weights = history.map((s) => s.weight).toList();
  final mean = weights.reduce((a, b) => a + b) / weights.length;
  final variance = weights.map((w) => (w - mean) * (w - mean)).reduce((a, b) => a + b) / weights.length;

  return variance;
}

/// Clases de datos para los resultados
class LongTermResult {
  final bool success;
  final double initialWeight;
  final double finalWeight;
  final int totalSessions;
  final int deloadCount;
  final double averageWeightIncrement;
  final double weightVariance;
  final List<SessionData> progressionHistory;
  final String? error;

  const LongTermResult({
    required this.success,
    required this.initialWeight,
    required this.finalWeight,
    required this.totalSessions,
    required this.deloadCount,
    required this.averageWeightIncrement,
    required this.weightVariance,
    required this.progressionHistory,
    this.error,
  });
}

class SessionData {
  final int session;
  final double weight;
  final int reps;
  final int sets;
  final bool incrementApplied;
  final bool isDeload;
  final String reason;

  const SessionData({
    required this.session,
    required this.weight,
    required this.reps,
    required this.sets,
    required this.incrementApplied,
    required this.isDeload,
    required this.reason,
  });
}
