import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/muscle_group_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
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

import '../helpers/progression_test_reporter.dart' as reporter;

/// Test runner que ejecuta todos los tests de progresión y genera reportes detallados
void main() {
  group('Complete Progression Test Suite', () {
    late Map<String, dynamic> testStrategies;
    late List<ProgressionConfig> allPresets;
    late List<TestSummary> allSummaries;

    setUpAll(() {
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

      // Obtener todos los presets
      allPresets = PresetProgressionConfigs.getAllPresets();

      // Inicializar lista de resúmenes
      allSummaries = [];
    });

    test('Execute Complete Test Suite - 6 Months Simulation', () {
      print('\n📊 EJECUTANDO TESTS COMPLETOS - SIMULACIÓN DE 6 MESES');
      print('-' * 60);

      final startTime = DateTime.now();
      var testCount = 0;
      var successCount = 0;
      var failureCount = 0;

      // Ejecutar tests para cada combinación de estrategia + preset + ejercicio
      for (final strategyEntry in testStrategies.entries) {
        final strategyName = strategyEntry.key;
        final strategy = strategyEntry.value;

        print('\n🔄 Probando estrategia: $strategyName');

        // Obtener presets para esta estrategia
        final strategyPresets =
            allPresets.where((preset) => preset.type.name.toLowerCase() == strategyName.toLowerCase()).toList();

        if (strategyPresets.isEmpty) {
          print('  ⚠️  No se encontraron presets para $strategyName');
          continue;
        }

        for (final preset in strategyPresets) {
          final presetName = _getPresetName(preset);
          print('  📋 Preset: $presetName');

          // Probar con diferentes tipos de ejercicios
          final testExercises = _getTestExercisesForStrategy(strategyName);

          for (final exercise in testExercises) {
            testCount++;

            try {
              print('    🏋️  ${exercise.exerciseType.name} + ${exercise.loadType.name}');

              final result = _executeLongCycleTest(
                strategy: strategy,
                strategyName: strategyName,
                preset: preset,
                presetName: presetName,
                exercise: exercise,
                months: 6,
              );

              if (result.success) {
                successCount++;
                allSummaries.add(result.summary);

                // Generar reporte detallado para casos exitosos
                if (testCount % 10 == 0) {
                  // Cada 10 tests
                  reporter.ProgressionTestReporter.generateDetailedReport(
                    strategyName: strategyName,
                    presetName: presetName,
                    exercise: exercise,
                    months: 6,
                    progressionHistory:
                        result.progressionHistory
                            .map(
                              (s) => reporter.SessionResult(
                                session: s.session,
                                weight: s.weight,
                                reps: s.reps,
                                sets: s.sets,
                                incrementApplied: s.incrementApplied,
                                isDeload: s.isDeload,
                                reason: s.reason,
                              ),
                            )
                            .toList(),
                    deloadCount: result.deloadCount,
                    totalWeightIncrements: result.totalWeightIncrements,
                    totalSeriesIncrements: result.totalSeriesIncrements.toInt(),
                    seriesIncrementCount: result.seriesIncrementCount,
                  );
                }
              } else {
                failureCount++;
                print('    ❌ FALLÓ: ${result.errorMessage}');
              }
            } catch (e) {
              failureCount++;
              print('    ❌ ERROR: $e');
            }
          }
        }
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      print('\n📊 RESUMEN DE EJECUCIÓN:');
      print('  • Total de tests: $testCount');
      print('  • Exitosos: $successCount');
      print('  • Fallidos: $failureCount');
      print('  • Duración: ${duration.inMinutes} minutos ${duration.inSeconds % 60} segundos');
      print('  • Tasa de éxito: ${(successCount / testCount * 100).toStringAsFixed(1)}%');

      // Generar resumen ejecutivo
      if (allSummaries.isNotEmpty) {
        reporter.ProgressionTestReporter.generateExecutiveSummary(
          summaries:
              allSummaries
                  .map(
                    (s) => reporter.TestSummary(
                      strategy: s.strategy,
                      preset: s.preset,
                      exerciseType: s.exerciseType,
                      loadType: s.loadType,
                      initialWeight: s.initialWeight,
                      finalWeight: s.finalWeight,
                      deloadCount: s.deloadCount,
                      weightVariance: s.weightVariance,
                      totalSessions: s.totalSessions,
                    ),
                  )
                  .toList(),
        );
      }

      // Generar reportes CSV
      _generateCSVReports(allSummaries);

      // Verificar que todos los tests pasaron
      expect(failureCount, equals(0), reason: 'Algunos tests fallaron. Revisar los logs para más detalles.');
    });

    test('Quick Validation Test - 1 Month Simulation', () {
      print('\n⚡ EJECUTANDO VALIDACIÓN RÁPIDA - SIMULACIÓN DE 1 MES');
      print('-' * 60);

      // Test rápido con solo algunas combinaciones
      final quickTests = [
        {'strategy': 'linear', 'preset': 'hypertrophy', 'exercise': 'barbell-multijoint'},
        {'strategy': 'stepped', 'preset': 'strength', 'exercise': 'dumbbell-isolation'},
        {'strategy': 'undulating', 'preset': 'hypertrophy', 'exercise': 'machine-multijoint'},
        {'strategy': 'autoregulated', 'preset': 'strength', 'exercise': 'cable-isolation'},
      ];

      for (final testConfig in quickTests) {
        final strategyName = testConfig['strategy']!;
        final presetName = testConfig['preset']!;
        final exerciseType = testConfig['exercise']!;

        print('🔄 $strategyName + $presetName + $exerciseType');

        final strategy = testStrategies[strategyName];
        final preset = _getPresetByName(strategyName, presetName);
        final exercise = _getExerciseByType(exerciseType);

        if (strategy != null && preset != null && exercise != null) {
          final result = _executeLongCycleTest(
            strategy: strategy,
            strategyName: strategyName,
            preset: preset,
            presetName: presetName,
            exercise: exercise,
            months: 1,
          );

          expect(
            result.success,
            isTrue,
            reason: 'Quick test failed for $strategyName + $presetName + $exerciseType: ${result.errorMessage}',
          );

          print('  ✅ Éxito: ${result.summary.finalWeight - result.summary.initialWeight}kg ganados');
        }
      }
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
  }

  return exercises;
}

/// Helper function para obtener ejercicios de prueba para una estrategia específica
List<Exercise> _getTestExercisesForStrategy(String strategyName) {
  // Para tests completos, usar una muestra representativa
  final representativeExercises = [
    'barbell-multijoint',
    'dumbbell-isolation',
    'machine-multijoint',
    'cable-isolation',
    'bodyweight-multijoint',
    'resistanceband-isolation',
  ];

  return representativeExercises
      .map((type) => _getExerciseByType(type))
      .where((e) => e != null)
      .cast<Exercise>()
      .toList();
}

/// Helper function para obtener un ejercicio por tipo
Exercise? _getExerciseByType(String exerciseType) {
  final parts = exerciseType.split('-');
  if (parts.length != 2) return null;

  final loadTypeStr = parts[0];
  final exerciseTypeStr = parts[1];

  final loadType = LoadType.values.firstWhere(
    (lt) => lt.name.toLowerCase() == loadTypeStr.toLowerCase(),
    orElse: () => LoadType.barbell,
  );

  final exType = ExerciseType.values.firstWhere(
    (et) => et.name.toLowerCase() == exerciseTypeStr.toLowerCase(),
    orElse: () => ExerciseType.multiJoint,
  );

  return _createTestExercises().firstWhere(
    (e) => e.exerciseType == exType && e.loadType == loadType,
    orElse: () => _createTestExercises().first,
  );
}

/// Helper function para obtener un preset por nombre
ProgressionConfig? _getPresetByName(String strategyName, String presetName) {
  final allPresets = PresetProgressionConfigs.getAllPresets();

  return allPresets.firstWhere(
    (preset) =>
        preset.type.name.toLowerCase() == strategyName.toLowerCase() &&
        preset.getTrainingObjective().toLowerCase() == presetName.toLowerCase(),
    orElse: () => allPresets.first,
  );
}

/// Helper function para obtener el nombre de un preset
String _getPresetName(ProgressionConfig preset) {
  return '${preset.type.name} ${preset.getTrainingObjective()}';
}

/// Helper function para ejecutar un test de ciclo largo
TestExecutionResult _executeLongCycleTest({
  required dynamic strategy,
  required String strategyName,
  required ProgressionConfig preset,
  required String presetName,
  required Exercise exercise,
  required int months,
}) {
  try {
    // Calcular número de sesiones
    final sessionsPerWeek = (preset.customParameters['sessions_per_week'] ?? 3) as int;
    final totalSessions = months * 4 * sessionsPerWeek;

    // Estado inicial
    var currentState = ProgressionState(
      id: 'test-state',
      progressionConfigId: preset.id,
      routineId: 'test-routine',
      exerciseId: exercise.id,
      currentCycle: 1,
      currentWeek: 1,
      currentSession: 1,
      currentWeight: 100.0,
      currentReps: preset.minReps,
      currentSets: preset.baseSets,
      baseWeight: 100.0,
      baseReps: preset.minReps,
      baseSets: preset.baseSets,
      sessionHistory: const {},
      lastUpdated: DateTime.now(),
      isDeloadWeek: false,
      customData: const {},
    );

    // Variables para tracking
    final progressionHistory = <SessionResult>[];
    var totalWeightIncrements = 0.0;
    var totalSeriesIncrements = 0.0;
    var deloadCount = 0;
    var seriesIncrementCount = 0;

    // Simular todas las sesiones
    for (int session = 1; session <= totalSessions; session++) {
      final previousWeight = currentState.currentWeight;
      final previousSets = currentState.currentSets;

      final result = strategy.calculate(
        config: preset,
        state: currentState,
        routineId: 'test-routine',
        currentWeight: currentState.currentWeight,
        currentReps: currentState.currentReps,
        currentSets: currentState.currentSets,
        exercise: exercise,
      );

      // Actualizar estado
      currentState = currentState.copyWith(
        currentWeight: result.newWeight,
        currentReps: result.newReps,
        currentSets: result.newSets,
        lastUpdated: DateTime.now(),
        currentSession: session,
        currentWeek: ((session - 1) ~/ sessionsPerWeek) + 1,
        isDeloadWeek: result.isDeload,
      );

      // Trackear progresión
      if (result.incrementApplied) {
        final delta = result.newWeight - previousWeight;
        if (delta > 0) totalWeightIncrements += delta;
      }

      if (result.newSets > previousSets) {
        totalSeriesIncrements = totalSeriesIncrements + (result.newSets - previousSets);
        seriesIncrementCount++;
      }

      if (result.isDeload) {
        deloadCount++;
      }

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

    // Crear resumen
    final summary = TestSummary(
      strategy: strategyName,
      preset: presetName,
      exerciseType: exercise.exerciseType.name,
      loadType: exercise.loadType.name,
      initialWeight: 100.0,
      finalWeight: currentState.currentWeight,
      deloadCount: deloadCount,
      weightVariance: _calculateWeightVariance(progressionHistory),
      totalSessions: totalSessions,
    );

    return TestExecutionResult(
      success: true,
      summary: summary,
      progressionHistory: progressionHistory,
      deloadCount: deloadCount,
      totalWeightIncrements: totalWeightIncrements,
      totalSeriesIncrements: totalSeriesIncrements,
      seriesIncrementCount: seriesIncrementCount,
      errorMessage: '',
    );
  } catch (e) {
    return TestExecutionResult(
      success: false,
      summary: TestSummary(
        strategy: strategyName,
        preset: presetName,
        exerciseType: exercise.exerciseType.name,
        loadType: exercise.loadType.name,
        initialWeight: 100.0,
        finalWeight: 100.0,
        deloadCount: 0,
        weightVariance: 0.0,
        totalSessions: 0,
      ),
      progressionHistory: [],
      deloadCount: 0,
      totalWeightIncrements: 0.0,
      totalSeriesIncrements: 0,
      seriesIncrementCount: 0,
      errorMessage: e.toString(),
    );
  }
}

/// Helper function para calcular la varianza de peso
double _calculateWeightVariance(List<SessionResult> history) {
  if (history.length < 2) return 0.0;

  final weights = history.map((s) => s.weight).toList();
  final mean = weights.reduce((a, b) => a + b) / weights.length;
  final variance = weights.map((w) => (w - mean) * (w - mean)).reduce((a, b) => a + b) / weights.length;

  return variance;
}

/// Helper function para generar reportes CSV
void _generateCSVReports(List<TestSummary> summaries) {
  print('\n📄 GENERANDO REPORTES CSV...');

  // Crear directorio de reportes
  final reportsDir = Directory('test_reports');
  if (!reportsDir.existsSync()) {
    reportsDir.createSync(recursive: true);
  }

  // Generar reporte de resúmenes
  final summaryFile = File('test_reports/test_summaries.csv');
  final summaryBuffer = StringBuffer();

  summaryBuffer.writeln(
    'Strategy,Preset,ExerciseType,LoadType,InitialWeight,FinalWeight,WeightGain,DeloadCount,WeightVariance,TotalSessions',
  );

  for (final summary in summaries) {
    final weightGain = summary.finalWeight - summary.initialWeight;
    summaryBuffer.writeln(
      '${summary.strategy},${summary.preset},${summary.exerciseType},${summary.loadType},${summary.initialWeight},${summary.finalWeight},$weightGain,${summary.deloadCount},${summary.weightVariance},${summary.totalSessions}',
    );
  }

  summaryFile.writeAsStringSync(summaryBuffer.toString());
  print('  ✅ Reporte de resúmenes: test_reports/test_summaries.csv');

  // Generar reporte de análisis
  final analysisFile = File('test_reports/analysis_report.txt');
  final analysisBuffer = StringBuffer();

  analysisBuffer.writeln('ANÁLISIS DE TESTS DE PROGRESIÓN');
  analysisBuffer.writeln('=' * 50);
  analysisBuffer.writeln('Fecha: ${DateTime.now()}');
  analysisBuffer.writeln('Total de tests: ${summaries.length}');
  analysisBuffer.writeln('');

  // Análisis por estrategia
  final strategies = summaries.map((s) => s.strategy).toSet();
  for (final strategy in strategies) {
    final strategySummaries = summaries.where((s) => s.strategy == strategy).toList();
    final avgWeightGain =
        strategySummaries.map((s) => s.finalWeight - s.initialWeight).reduce((a, b) => a + b) /
        strategySummaries.length;
    final avgDeloads = strategySummaries.map((s) => s.deloadCount).reduce((a, b) => a + b) / strategySummaries.length;

    analysisBuffer.writeln('$strategy:');
    analysisBuffer.writeln('  - Tests: ${strategySummaries.length}');
    analysisBuffer.writeln('  - Ganancia promedio: ${avgWeightGain.toStringAsFixed(1)}kg');
    analysisBuffer.writeln('  - Deloads promedio: ${avgDeloads.toStringAsFixed(1)}');
    analysisBuffer.writeln('');
  }

  analysisFile.writeAsStringSync(analysisBuffer.toString());
  print('  ✅ Reporte de análisis: test_reports/analysis_report.txt');
}

/// Clases de datos para los resultados
class TestExecutionResult {
  final bool success;
  final TestSummary summary;
  final List<SessionResult> progressionHistory;
  final int deloadCount;
  final double totalWeightIncrements;
  final double totalSeriesIncrements;
  final int seriesIncrementCount;
  final String errorMessage;

  const TestExecutionResult({
    required this.success,
    required this.summary,
    required this.progressionHistory,
    required this.deloadCount,
    required this.totalWeightIncrements,
    required this.totalSeriesIncrements,
    required this.seriesIncrementCount,
    required this.errorMessage,
  });
}

class TestSummary {
  final String strategy;
  final String preset;
  final String exerciseType;
  final String loadType;
  final double initialWeight;
  final double finalWeight;
  final int deloadCount;
  final double weightVariance;
  final int totalSessions;

  const TestSummary({
    required this.strategy,
    required this.preset,
    required this.exerciseType,
    required this.loadType,
    required this.initialWeight,
    required this.finalWeight,
    required this.deloadCount,
    required this.weightVariance,
    required this.totalSessions,
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
