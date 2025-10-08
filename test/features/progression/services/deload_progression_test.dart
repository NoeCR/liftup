import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/progression/services/progression_service.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import '../helpers/progression_service_test_helper.dart';

void main() {
  group('Deload Progression Tests', () {
    late ProgressionService progressionService;
    late ProgressionConfig testConfig;
    late ProgressionState testState;

    setUp(() async {
      // Crear servicio con mock de base de datos
      progressionService = ProgressionServiceTestHelper.createWithMockDatabase();
      testConfig = ProgressionConfig(
        id: 'test-config',
        isGlobal: true,
        customParameters: {'sessions_per_week': 3, 'max_weeks': 8, 'reset_percentage': 0.85},
        type: ProgressionType.linear,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 4,
        deloadPercentage: 0.8,
        isActive: true,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      testState = ProgressionState(
        id: 'test-state',
        progressionConfigId: 'test-config',
        exerciseId: 'test-exercise',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 100.0,
        currentReps: 10,
        currentSets: 3,
        baseWeight: 100.0,
        baseReps: 10,
        baseSets: 3,
        lastUpdated: DateTime.now(),
        sessionHistory: {},
        customData: {},
        isDeloadWeek: false,
      );

      // Guardar la configuración y estado en la base de datos mock
      await progressionService.saveProgressionConfig(testConfig);
      await progressionService.saveProgressionState(testState);
    });

    // No need for tearDown with mock database - it's automatically cleaned up

    group('Linear Progression Deload Tests', () {
      test('should apply deload on week 4 and continue progression after', () async {
        // Configurar progresión lineal con ciclo de 4 semanas
        final config = testConfig.copyWith(
          type: ProgressionType.linear,
          cycleLength: 4,
          deloadWeek: 4,
          deloadPercentage: 0.8,
        );
        await progressionService.saveProgressionConfig(config);

        // Semana 1: Progresión normal
        var state = testState.copyWith(currentWeek: 1);
        var result = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );
        expect(result.newWeight, equals(102.5)); // 100 + 2.5
        expect(result.incrementApplied, isTrue);

        // Semana 2: Progresión normal
        state = state.copyWith(currentWeek: 2, currentWeight: 102.5);
        await progressionService.saveProgressionState(state);
        result = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );
        expect(result.newWeight, equals(105.0)); // 102.5 + 2.5
        expect(result.incrementApplied, isTrue);

        // Semana 3: Progresión normal
        state = state.copyWith(currentWeek: 3, currentWeight: 105.0);
        await progressionService.saveProgressionState(state);
        result = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );
        expect(result.newWeight, equals(107.5)); // 105 + 2.5
        expect(result.incrementApplied, isTrue);

        // Semana 4: DELOAD
        state = state.copyWith(currentWeek: 4, currentWeight: 107.5);
        await progressionService.saveProgressionState(state);
        result = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );
        expect(result.newWeight, equals(106.0)); // Deload: 100 + ((107.5 - 100) * 0.8) = 100 + (7.5 * 0.8) = 106.0
        expect(result.newSets, equals(2)); // 3 * 0.7 (reduced sets)
        expect(result.incrementApplied, isTrue);
        expect(result.reason, contains('deload'));

        // Semana 5: Continuación de progresión (nuevo ciclo)
        state = state.copyWith(currentWeek: 5, currentWeight: 106.0);
        await progressionService.saveProgressionState(state);
        result = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );
        expect(result.newWeight, equals(108.5)); // 106 + 2.5
        expect(result.incrementApplied, isTrue);
        expect(result.reason, contains('week 1 of 4')); // Nuevo ciclo
      });

      test('should handle multiple deload cycles correctly', () async {
        final config = testConfig.copyWith(
          type: ProgressionType.linear,
          cycleLength: 3,
          deloadWeek: 3,
          deloadPercentage: 0.75,
        );
        await progressionService.saveProgressionConfig(config);

        // Primer ciclo completo
        var state = testState.copyWith(currentWeek: 1);

        // Semana 1
        var result = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );
        expect(result.newWeight, equals(102.5));

        // Semana 2
        state = state.copyWith(currentWeek: 2, currentWeight: 102.5);
        await progressionService.saveProgressionState(state);
        result = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );
        expect(result.newWeight, equals(105.0));

        // Semana 3: DELOAD
        state = state.copyWith(currentWeek: 3, currentWeight: 105.0);
        await progressionService.saveProgressionState(state);
        result = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );
        expect(
          result.newWeight,
          closeTo(103.75, 0.001),
        ); // Deload: 100 + ((105.0 - 100) * 0.75) = 100 + (5.0 * 0.75) = 103.75

        // Segundo ciclo
        // Semana 4 (nuevo ciclo, semana 1)
        state = state.copyWith(currentWeek: 4, currentWeight: 105.625);
        await progressionService.saveProgressionState(state);
        result = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );
        expect(result.newWeight, closeTo(108.125, 0.001)); // 105.625 + 2.5
        expect(result.reason, contains('week 1 of 3'));

        // Semana 5 (nuevo ciclo, semana 2)
        state = state.copyWith(currentWeek: 5, currentWeight: 108.125);
        await progressionService.saveProgressionState(state);
        result = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );
        expect(result.newWeight, closeTo(110.625, 0.001)); // 108.125 + 2.5
        expect(result.reason, contains('week 2 of 3'));

        // Semana 6: DELOAD (segundo ciclo)
        state = state.copyWith(currentWeek: 6, currentWeight: 110.625);
        await progressionService.saveProgressionState(state);
        result = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );
        expect(
          result.newWeight,
          closeTo(107.96875, 0.001),
        ); // Deload: 100 + ((110.625 - 100) * 0.75) = 100 + (10.625 * 0.75) = 107.96875
        expect(result.reason, contains('deload'));
      });
    });

    group('Stepped Progression Deload Tests', () {
      test('should apply deload correctly in stepped progression', () async {
        final config = testConfig.copyWith(
          id: 'stepped-config',
          type: ProgressionType.stepped,
          cycleLength: 4,
          deloadWeek: 4,
          deloadPercentage: 0.8,
          customParameters: {'sessions_per_week': 3, 'accumulation_weeks': 3, 'deload_volume_reduction': 0.7},
        );

        // Guardar la configuración específica
        await progressionService.saveProgressionConfig(config);

        // Semanas 1-3: Acumulación
        for (int week = 1; week <= 3; week++) {
          final state = testState.copyWith(progressionConfigId: config.id, currentWeek: week);
          await progressionService.saveProgressionState(state);
          final result = await progressionService.calculateProgression(
            config.id,
            'test-exercise',
            state.currentWeight,
            state.currentReps,
            state.currentSets,
          );
          expect(result.newWeight, equals(100.0 + (week * 2.5)));
          expect(result.incrementApplied, isTrue);
          expect(result.reason, contains('accumulation phase'));
        }

        // Semana 4: DELOAD
        final deloadState = testState.copyWith(progressionConfigId: config.id, currentWeek: 4);
        await progressionService.saveProgressionState(deloadState);
        final deloadResult = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          deloadState.currentWeight,
          deloadState.currentReps,
          deloadState.currentSets,
        );
        expect(deloadResult.newWeight, equals(100.0)); // Mantiene peso base
        expect(deloadResult.newSets, equals(2)); // 3 * 0.7
        expect(deloadResult.incrementApplied, isTrue);
        expect(deloadResult.reason, contains('deload'));
      });
    });

    group('Wave Progression Deload Tests', () {
      test('should apply deload on week 3 of wave progression', () async {
        final config = testConfig.copyWith(
          type: ProgressionType.wave,
          cycleLength: 3,
          deloadWeek: 3,
          deloadPercentage: 0.7,
        );
        await progressionService.saveProgressionConfig(config);

        // Semana 1: Alta intensidad
        var state = testState.copyWith(progressionConfigId: config.id, currentWeek: 1);
        await progressionService.saveProgressionState(state);
        var result = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );
        expect(result.newWeight, equals(102.5)); // 100 + 2.5
        expect(result.newReps, equals(9)); // 10 * 0.9
        expect(result.reason, contains('high intensity'));

        // Semana 2: Alto volumen
        state = state.copyWith(currentWeek: 2, currentWeight: 102.5, currentReps: 8);
        await progressionService.saveProgressionState(state);
        result = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );
        expect(result.newWeight, equals(101.75)); // 102.5 - (2.5 * 0.3)
        expect(result.newReps, equals(10)); // 8 * 1.3
        expect(result.newSets, equals(4)); // 3 + 1
        expect(result.reason, contains('high volume'));

        // Semana 3: DELOAD
        state = state.copyWith(currentWeek: 3, currentWeight: 102.0, currentReps: 10, currentSets: 4);
        await progressionService.saveProgressionState(state);
        result = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );
        expect(result.newWeight, equals(70.0)); // 100 * 0.7
        expect(result.newSets, equals(3)); // 4 * 0.7
        expect(result.reason, contains('deload week'));

        // Semana 4: Nuevo ciclo (alta intensidad)
        state = state.copyWith(currentWeek: 4, currentWeight: 70.0, currentSets: 3);
        await progressionService.saveProgressionState(state);
        result = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );
        expect(result.newWeight, equals(72.5)); // 70 + 2.5
        expect(result.reason, contains('week 1 of 3'));
      });
    });

    group('Double Progression Deload Tests', () {
      test('should apply deload correctly in double progression', () async {
        final config = testConfig.copyWith(
          type: ProgressionType.double,
          cycleLength: 6,
          deloadWeek: 6,
          deloadPercentage: 0.9,
          customParameters: {'min_reps': 5, 'max_reps': 12},
        );
        await progressionService.saveProgressionConfig(config);

        // Semanas 1-5: Progresión normal (aumentar reps)
        var state = testState.copyWith(progressionConfigId: config.id, currentWeek: 1, currentReps: 5);

        for (int week = 1; week <= 5; week++) {
          state = state.copyWith(progressionConfigId: config.id, currentWeek: week);
          await progressionService.saveProgressionState(state);
          final result = await progressionService.calculateProgression(
            config.id,
            'test-exercise',
            state.currentWeight,
            state.currentReps,
            state.currentSets,
          );

          if (state.currentReps < 12) {
            expect(result.newReps, equals(state.currentReps + 1));
            expect(result.newWeight, equals(state.currentWeight));
            expect(result.reason, contains('increasing reps'));
          } else {
            expect(result.newWeight, equals(state.currentWeight + 2.5));
            expect(result.newReps, equals(5));
            expect(result.reason, contains('increasing weight'));
          }
        }

        // Semana 6: DELOAD
        state = state.copyWith(progressionConfigId: config.id, currentWeek: 6);
        await progressionService.saveProgressionState(state);
        final deloadResult = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );
        expect(deloadResult.newWeight, equals(100.0)); // Mantiene peso base
        expect(deloadResult.newSets, equals(2)); // 3 * 0.7
        expect(deloadResult.reason, contains('deload week'));
      });
    });

    group('Undulating Progression Deload Tests', () {
      test('should apply deload correctly in undulating progression', () async {
        final config = testConfig.copyWith(
          type: ProgressionType.undulating,
          cycleLength: 4,
          deloadWeek: 4,
          deloadPercentage: 0.85,
        );
        await progressionService.saveProgressionConfig(config);

        // Semanas 1-3: Progresión ondulante normal
        for (int week = 1; week <= 3; week++) {
          final state = testState.copyWith(progressionConfigId: config.id, currentWeek: week);
          await progressionService.saveProgressionState(state);
          final result = await progressionService.calculateProgression(
            config.id,
            'test-exercise',
            state.currentWeight,
            state.currentReps,
            state.currentSets,
          );

          if (week % 2 == 1) {
            // Día pesado
            expect(result.newWeight, greaterThan(state.currentWeight));
            expect(result.newReps, lessThan(state.currentReps));
            expect(result.reason, contains('heavy day'));
          } else {
            // Día ligero
            expect(result.newWeight, lessThan(state.currentWeight));
            expect(result.newReps, greaterThan(state.currentReps));
            expect(result.reason, contains('light day'));
          }
        }

        // Semana 4: DELOAD
        final deloadState = testState.copyWith(progressionConfigId: config.id, currentWeek: 4);
        await progressionService.saveProgressionState(deloadState);
        final deloadResult = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          deloadState.currentWeight,
          deloadState.currentReps,
          deloadState.currentSets,
        );
        expect(deloadResult.newWeight, equals(100.0)); // Mantiene peso base
        expect(deloadResult.newSets, equals(2)); // 3 * 0.7
        expect(deloadResult.reason, contains('deload week'));
      });
    });

    group('Autoregulated Progression Deload Tests', () {
      test('should apply deload correctly in autoregulated progression', () async {
        final config = testConfig.copyWith(
          type: ProgressionType.autoregulated,
          cycleLength: 8,
          deloadWeek: 8,
          deloadPercentage: 0.8,
          customParameters: {'target_rpe': 8.0, 'rpe_threshold': 0.5, 'target_reps': 10, 'max_reps': 12, 'min_reps': 5},
        );
        await progressionService.saveProgressionConfig(config);

        // Semanas 1-7: Progresión autoregulada normal
        for (int week = 1; week <= 7; week++) {
          final state = testState.copyWith(currentWeek: week);
          await progressionService.saveProgressionState(state);
          final result = await progressionService.calculateProgression(
            config.id,
            'test-exercise',
            state.currentWeight,
            state.currentReps,
            state.currentSets,
          );

          // La progresión autoregulada puede aumentar peso o reps
          expect(result.incrementApplied, isTrue);
          expect(result.reason, contains('Autoregulated progression'));
        }

        // Semana 8: DELOAD
        final deloadState = testState.copyWith(currentWeek: 8);
        await progressionService.saveProgressionState(deloadState);
        final deloadResult = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          deloadState.currentWeight,
          deloadState.currentReps,
          deloadState.currentSets,
        );
        expect(deloadResult.newWeight, equals(100.0)); // Mantiene peso base
        expect(deloadResult.newSets, equals(2)); // 3 * 0.7
        expect(deloadResult.reason, contains('deload week'));
      });
    });

    group('Double Factor Progression Deload Tests', () {
      test('should apply deload correctly in double factor progression', () async {
        final config = testConfig.copyWith(
          type: ProgressionType.doubleFactor,
          cycleLength: 8,
          deloadWeek: 4,
          deloadPercentage: 0.8,
          customParameters: {'fitness_gain': 0.1, 'fatigue_decay': 0.05},
        );
        await progressionService.saveProgressionConfig(config);

        // Semanas 1-3: Progresión doble factor normal
        for (int week = 1; week <= 3; week++) {
          final state = testState.copyWith(currentWeek: week);
          await progressionService.saveProgressionState(state);
          final result = await progressionService.calculateProgression(
            config.id,
            'test-exercise',
            state.currentWeight,
            state.currentReps,
            state.currentSets,
          );

          expect(result.incrementApplied, isTrue);
          expect(result.reason, contains('Double factor progression'));
        }

        // Semana 4: DELOAD
        final deloadState = testState.copyWith(progressionConfigId: config.id, currentWeek: 4);
        await progressionService.saveProgressionState(deloadState);
        final deloadResult = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          deloadState.currentWeight,
          deloadState.currentReps,
          deloadState.currentSets,
        );
        expect(deloadResult.newWeight, equals(100.0)); // Mantiene peso base
        expect(deloadResult.newSets, equals(2)); // 3 * 0.7
        expect(deloadResult.reason, contains('deload week'));
      });
    });

    group('Overload Progression Deload Tests', () {
      test('should apply deload correctly in overload progression', () async {
        final config = testConfig.copyWith(
          type: ProgressionType.overload,
          cycleLength: 6,
          deloadWeek: 6,
          deloadPercentage: 0.75,
          customParameters: {'overload_type': 'volume', 'overload_rate': 0.1},
        );
        await progressionService.saveProgressionConfig(config);

        // Semanas 1-5: Progresión de sobrecarga normal
        for (int week = 1; week <= 5; week++) {
          final state = testState.copyWith(progressionConfigId: config.id, currentWeek: week);
          await progressionService.saveProgressionState(state);
          final result = await progressionService.calculateProgression(
            config.id,
            'test-exercise',
            state.currentWeight,
            state.currentReps,
            state.currentSets,
          );

          expect(result.incrementApplied, isTrue);
          expect(result.reason, contains('Overload progression'));
        }

        // Semana 6: DELOAD
        final deloadState = testState.copyWith(progressionConfigId: config.id, currentWeek: 6);
        await progressionService.saveProgressionState(deloadState);
        final deloadResult = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          deloadState.currentWeight,
          deloadState.currentReps,
          deloadState.currentSets,
        );
        expect(deloadResult.newWeight, equals(100.0)); // Mantiene peso base
        expect(deloadResult.newSets, equals(2)); // 3 * 0.7
        expect(deloadResult.reason, contains('deload week'));
      });
    });

    group('Edge Cases', () {
      test('should handle deload week 0 (no deload)', () async {
        final config = testConfig.copyWith(
          type: ProgressionType.linear,
          deloadWeek: 0, // Sin deload
          cycleLength: 4,
        );
        await progressionService.saveProgressionConfig(config);

        // Todas las semanas deberían aplicar progresión normal
        var currentWeight = 100.0;
        for (int week = 1; week <= 8; week++) {
          final state = testState.copyWith(
            progressionConfigId: config.id,
            currentWeek: week,
            currentWeight: currentWeight,
          );
          await progressionService.saveProgressionState(state);
          final result = await progressionService.calculateProgression(
            config.id,
            'test-exercise',
            state.currentWeight,
            state.currentReps,
            state.currentSets,
          );

          expect(result.newWeight, equals(100.0 + (week * 2.5)));
          expect(result.reason, isNot(contains('deload')));
          currentWeight = result.newWeight; // Actualizar para la siguiente semana
        }
      });

      test('should handle deload week equal to cycle length', () async {
        final config = testConfig.copyWith(
          type: ProgressionType.linear,
          cycleLength: 4,
          deloadWeek: 4, // Deload en la última semana del ciclo
        );

        // Semana 4: DELOAD
        final deloadState = testState.copyWith(currentWeek: 4);
        await progressionService.saveProgressionState(deloadState);
        final deloadResult = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          deloadState.currentWeight,
          deloadState.currentReps,
          deloadState.currentSets,
        );
        expect(deloadResult.reason, contains('deload'));
        expect(deloadResult.newWeight, equals(100.0)); // Deload: 100 + ((100 - 100) * 0.8) = 100 + (0 * 0.8) = 100.0
      });

      test('should handle very long cycles correctly', () async {
        final config = testConfig.copyWith(
          type: ProgressionType.linear,
          cycleLength: 12,
          deloadWeek: 12,
          deloadPercentage: 0.7,
        );
        await progressionService.saveProgressionConfig(config);

        // Semana 12: DELOAD
        final deloadState = testState.copyWith(progressionConfigId: config.id, currentWeek: 12);
        await progressionService.saveProgressionState(deloadState);
        final deloadResult = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          deloadState.currentWeight,
          deloadState.currentReps,
          deloadState.currentSets,
        );
        expect(deloadResult.reason, contains('deload'));
        expect(deloadResult.newWeight, equals(100.0)); // Deload: 100 + ((100 - 100) * 0.7) = 100 + (0 * 0.7) = 100.0

        // Semana 13: Nuevo ciclo
        final newCycleState = testState.copyWith(currentWeek: 13, currentWeight: 70.0);
        final newCycleResult = await progressionService.calculateProgression(
          config.id,
          'test-exercise',
          newCycleState.currentWeight,
          newCycleState.currentReps,
          newCycleState.currentSets,
        );
        expect(newCycleResult.reason, contains('week 1 of 12'));
        expect(newCycleResult.newWeight, equals(72.5)); // 70 + 2.5
      });
    });
  });
}
