import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/double_factor_progression_strategy.dart';

void main() {
  group('DoubleFactorProgressionStrategy (Doble Progresión)', () {
    late DoubleFactorProgressionStrategy strategy;
    late DateTime now;
    late ProgressionConfig config;
    late ProgressionState state;

    setUp(() {
      strategy = DoubleFactorProgressionStrategy();
      now = DateTime.now();
      config = ProgressionConfig(
        id: 'cfg',
        isGlobal: true,
        type: ProgressionType.doubleFactor,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 0,
        deloadPercentage: 0.9,
        customParameters: const {'min_reps': 6, 'max_reps': 10, 'increment_value': 2.5},
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
        routineId: 'test-routine-1',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 70.0,
        currentReps: 6,
        currentSets: 3,
        baseWeight: 70.0,
        baseReps: 6,
        baseSets: 3,
        sessionHistory: const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );
    });

    test('incrementa repeticiones cuando currentReps < maxReps', () {
      // Configuración: min_reps=6, max_reps=10, currentReps=6
      final result = strategy.calculate(
        config: config,
        state: state,
        routineId: 'test-routine',
        currentWeight: 70.0,
        currentReps: 6,
        currentSets: 3,
      );

      expect(result.incrementApplied, true);
      expect(result.newWeight, 70.0); // Peso se mantiene
      expect(result.newReps, 7); // Reps incrementan en 1
      expect(result.newSets, 3); // Sets se mantienen
      expect(result.reason, contains('increasing reps'));
    });

    test('incrementa peso y resetea reps cuando currentReps >= maxReps', () {
      // Configuración: min_reps=6, max_reps=10, currentReps=10
      final result = strategy.calculate(
        config: config,
        state: state,
        routineId: 'test-routine',
        currentWeight: 70.0,
        currentReps: 10,
        currentSets: 3,
      );

      expect(result.incrementApplied, true);
      expect(result.newWeight, 72.5); // Peso incrementa en 2.5kg
      expect(result.newReps, 6); // Reps se resetean a min_reps
      expect(result.newSets, 3); // Sets se mantienen
      expect(result.reason, contains('increasing weight'));
      expect(result.reason, contains('resetting reps to 6'));
    });

    test('usa parámetros por ejercicio cuando están disponibles', () {
      final configWithPerExercise = ProgressionConfig(
        id: 'cfg',
        isGlobal: true,
        type: ProgressionType.doubleFactor,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 0,
        deloadPercentage: 0.9,
        customParameters: const {
          'min_reps': 5, // Global
          'max_reps': 12, // Global
          'increment_value': 2.5, // Global
          'per_exercise': {
            'ex': {
              'min_reps': 8, // Específico del ejercicio
              'max_reps': 15, // Específico del ejercicio
              'increment_value': 1.25, // Específico del ejercicio
            },
          },
        },
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      // Test con reps en el máximo específico del ejercicio
      final result = strategy.calculate(
        config: configWithPerExercise,
        state: state,
        routineId: 'test-routine',
        currentWeight: 70.0,
        currentReps: 15, // max_reps específico del ejercicio
        currentSets: 3,
      );

      expect(result.newWeight, 71.25); // increment_value específico (1.25kg)
      expect(result.newReps, 8); // min_reps específico del ejercicio
    });

    test('aplica deload correctamente', () {
      final configWithDeload = ProgressionConfig(
        id: 'cfg',
        isGlobal: true,
        type: ProgressionType.doubleFactor,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 4, // Deload en semana 4
        deloadPercentage: 0.8,
        customParameters: const {'min_reps': 6, 'max_reps': 10},
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final stateInDeloadWeek = ProgressionState(
        id: 'st',
        progressionConfigId: 'cfg',
        exerciseId: 'ex',
        routineId: 'test-routine-1',
        currentCycle: 1,
        currentWeek: 4, // Semana de deload
        currentSession: 1,
        currentWeight: 75.0, // Peso progresado
        currentReps: 8,
        currentSets: 3,
        baseWeight: 70.0,
        baseReps: 6,
        baseSets: 3,
        sessionHistory: const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );

      final result = strategy.calculate(
        config: configWithDeload,
        state: stateInDeloadWeek,
        routineId: 'test-routine',
        currentWeight: 75.0,
        currentReps: 8,
        currentSets: 3,
      );

      expect(result.incrementApplied, true);
      expect(result.newWeight, 74.0); // 70 + (5 * 0.8) = 74.0
      expect(result.newReps, 8); // Reps se mantienen en deload (no se incrementan primero)
      expect(result.newSets, 2); // Sets reducidos al 70% (3 * 0.7 = 2.1 ≈ 2)
      expect(result.reason, contains('deload'));
    });

    test('restaura sets a base tras deload cuando incrementa reps', () {
      // No deload, simulamos venir de deload con sets reducidos
      final configNoDeload = config.copyWith(deloadWeek: 0);
      final st = state.copyWith(currentReps: 6, currentSets: 2, baseSets: 3);
      final result = strategy.calculate(
        config: configNoDeload,
        state: st,
        routineId: 'test-routine',
        currentWeight: 70.0,
        currentReps: 6, // < max -> incrementa reps
        currentSets: 2, // heredado de deload
      );
      expect(result.incrementApplied, true);
      expect(result.newSets, 3); // debe restaurar a baseSets
    });

    test('restaura sets a base tras deload cuando incrementa peso y resetea reps', () {
      // No deload, simulamos venir de deload con sets reducidos
      final configNoDeload = config.copyWith(deloadWeek: 0);
      final st = state.copyWith(currentReps: 10, currentSets: 2, baseSets: 3);
      final result = strategy.calculate(
        config: configNoDeload,
        state: st,
        routineId: 'test-routine',
        currentWeight: 70.0,
        currentReps: 10, // == max -> incrementa peso y resetea reps
        currentSets: 2, // heredado de deload
      );
      expect(result.incrementApplied, true);
      expect(result.newSets, 3); // debe restaurar a baseSets
    });

    test('usa valores por defecto cuando no hay parámetros personalizados', () {
      final configMinimal = ProgressionConfig(
        id: 'cfg',
        isGlobal: true,
        type: ProgressionType.doubleFactor,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 0,
        deloadPercentage: 0.9,
        customParameters: const {}, // Sin parámetros personalizados
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      // Test con reps en el máximo por defecto (12)
      final result = strategy.calculate(
        config: configMinimal,
        state: state,
        routineId: 'test-routine',
        currentWeight: 70.0,
        currentReps: 12, // max_reps por defecto
        currentSets: 3,
      );

      expect(result.newWeight, 72.5); // incrementValue del config (2.5kg)
      expect(result.newReps, 5); // min_reps por defecto
    });

    test('simula 3 ciclos completos con deload cada 6 semanas para validar progresión a largo plazo', () {
      // Configuración para simulación a largo plazo con deloads cada 6 semanas
      final configLongTerm = ProgressionConfig(
        id: 'cfg',
        isGlobal: true,
        type: ProgressionType.doubleFactor,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 6, // Ciclo de 6 semanas
        deloadWeek: 6, // Deload en semana 6
        deloadPercentage: 0.8, // Reducción del 20%
        customParameters: const {'min_reps': 6, 'max_reps': 10, 'increment_value': 2.5},
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      // Estado inicial
      var currentWeight = 70.0;
      var currentReps = 6;
      var currentSets = 3;
      var currentWeek = 1;
      var currentCycle = 1;

      // Registro de progresión para validación
      final progressionHistory = <Map<String, dynamic>>[];

      // Simular 3 ciclos completos (18 semanas)
      for (var week = 1; week <= 18; week++) {
        // Calcular semana actual en el ciclo
        currentWeek = ((week - 1) % configLongTerm.cycleLength) + 1;
        currentCycle = ((week - 1) ~/ configLongTerm.cycleLength) + 1;

        final state = ProgressionState(
          id: 'st',
          progressionConfigId: 'cfg',
          exerciseId: 'ex',
          routineId: 'test-routine-1',
          currentCycle: currentCycle,
          currentWeek: currentWeek,
          currentSession: 1,
          currentWeight: currentWeight,
          currentReps: currentReps,
          currentSets: currentSets,
          baseWeight: 70.0,
          baseReps: 6,
          baseSets: 3,
          sessionHistory: const {},
          lastUpdated: now,
          isDeloadWeek: false,
          oneRepMax: null,
          customData: const {},
        );

        final result = strategy.calculate(
          config: configLongTerm,
          state: state,
          routineId: 'test-routine',
          currentWeight: currentWeight,
          currentReps: currentReps,
          currentSets: currentSets,
        );

        // Registrar progresión
        progressionHistory.add({
          'week': week,
          'cycle': currentCycle,
          'weekInCycle': currentWeek,
          'oldWeight': currentWeight,
          'oldReps': currentReps,
          'oldSets': currentSets,
          'newWeight': result.newWeight,
          'newReps': result.newReps,
          'newSets': result.newSets,
          'isDeload': currentWeek == configLongTerm.deloadWeek,
          'reason': result.reason,
        });

        // Actualizar valores para la siguiente iteración
        currentWeight = result.newWeight;
        currentReps = result.newReps;
        currentSets = result.newSets;
      }

      // Validaciones de progresión a largo plazo

      // Debug: Imprimir progresión para análisis
      print('\n=== PROGRESIÓN A LARGO PLAZO ===');
      for (var entry in progressionHistory) {
        print(
          'Semana ${entry['week']}: Ciclo ${entry['cycle']}, Semana ${entry['weekInCycle']} - '
          'Peso: ${entry['oldWeight']} -> ${entry['newWeight']}, '
          'Reps: ${entry['oldReps']} -> ${entry['newReps']}, '
          'Sets: ${entry['oldSets']} -> ${entry['newSets']} '
          '${entry['isDeload'] ? '[DELOAD]' : ''}',
        );
      }
      print('================================\n');

      // 1. Verificar que el peso ha progresado significativamente
      final finalWeight = progressionHistory.last['newWeight'] as double;
      final initialWeight = progressionHistory.first['oldWeight'] as double;
      print('Peso inicial: $initialWeight, Peso final: $finalWeight, Diferencia: ${finalWeight - initialWeight}');
      expect(finalWeight, greaterThan(initialWeight + 4.0)); // Al menos 4kg de progresión (realista con deloads)

      // 2. Verificar que los deloads se aplicaron correctamente
      final deloadWeeks = progressionHistory.where((entry) => entry['isDeload'] as bool).toList();
      expect(deloadWeeks.length, 3); // 3 deloads en 3 ciclos

      // Verificar que cada deload redujo el peso apropiadamente
      for (var deloadEntry in deloadWeeks) {
        final oldWeight = deloadEntry['oldWeight'] as double;
        final newWeight = deloadEntry['newWeight'] as double;

        // El peso después del deload debe ser menor o igual que antes
        expect(newWeight, lessThanOrEqualTo(oldWeight));

        // El peso después del deload debe ser mayor o igual que el peso base (70kg)
        expect(newWeight, greaterThanOrEqualTo(70.0));
      }

      // 3. Verificar progresión de reps dentro de cada ciclo
      for (var cycle = 1; cycle <= 3; cycle++) {
        final cycleWeeks =
            progressionHistory.where((entry) => entry['cycle'] == cycle && !(entry['isDeload'] as bool)).toList();

        if (cycleWeeks.isNotEmpty) {
          // En semanas no-deload, las reps deben incrementar progresivamente
          // EXCEPTO cuando se incrementa el peso (reps se resetean a min_reps)
          for (var i = 1; i < cycleWeeks.length; i++) {
            final prevReps = cycleWeeks[i - 1]['newReps'] as int;
            final currentReps = cycleWeeks[i]['newReps'] as int;
            final prevWeight = cycleWeeks[i - 1]['newWeight'] as double;
            final currentWeight = cycleWeeks[i]['newWeight'] as double;

            // Si el peso incrementó, las reps pueden resetearse (decrementar)
            if (currentWeight > prevWeight) {
              // Peso incrementó, reps pueden resetearse
              expect(currentReps, equals(6)); // Debe resetearse a min_reps
            } else {
              // Peso no incrementó, reps deben incrementar o mantenerse
              expect(currentReps, greaterThanOrEqualTo(prevReps));
            }
          }
        }
      }

      // 4. Verificar que después de cada deload, las reps se mantienen apropiadas
      for (var deloadEntry in deloadWeeks) {
        final deloadReps = deloadEntry['newReps'] as int;
        // Las reps durante deload deben estar en un rango razonable
        expect(deloadReps, inInclusiveRange(6, 10));
      }

      // 5. Verificar que la progresión de peso es consistente
      var totalWeightIncreases = 0.0;
      for (var i = 1; i < progressionHistory.length; i++) {
        final prevWeight = progressionHistory[i - 1]['newWeight'] as double;
        final currentWeight = progressionHistory[i]['newWeight'] as double;

        if (currentWeight > prevWeight) {
          totalWeightIncreases += (currentWeight - prevWeight);
        }
      }

      // Debe haber habido incrementos de peso significativos
      expect(totalWeightIncreases, greaterThan(7.0)); // Al menos 7kg de incrementos totales

      // 6. Verificar que las reps se mantienen dentro del rango configurado
      for (var entry in progressionHistory) {
        final reps = entry['newReps'] as int;
        expect(reps, inInclusiveRange(6, 10)); // min_reps a max_reps
      }

      // 7. Verificar que los sets se mantienen apropiados
      for (var entry in progressionHistory) {
        final sets = entry['newSets'] as int;
        if (entry['isDeload'] as bool) {
          expect(sets, lessThanOrEqualTo(3)); // Sets reducidos durante deload
        } else {
          // Durante progresión normal, los sets pueden ser 3 o menos (si vienen de un deload)
          expect(sets, lessThanOrEqualTo(3));
        }
      }

      // 8. Verificar progresión específica del primer ciclo como ejemplo
      final firstCycle = progressionHistory.take(6).toList();
      expect(firstCycle[0]['newReps'], 7); // Semana 1: 6 -> 7 reps
      expect(firstCycle[1]['newReps'], 8); // Semana 2: 7 -> 8 reps
      expect(firstCycle[2]['newReps'], 9); // Semana 3: 8 -> 9 reps
      expect(firstCycle[3]['newReps'], 10); // Semana 4: 9 -> 10 reps
      expect(firstCycle[4]['newReps'], 6); // Semana 5: 10 -> 6 reps (incrementa peso y resetea)
      expect(firstCycle[5]['newReps'], 6); // Semana 6: deload, reps se mantienen (no se incrementan primero)

      // 9. Verificar que el peso progresa después del primer ciclo completo
      final startOfSecondCycle =
          progressionHistory[6]['newWeight'] as double; // Semana 7: segundo ciclo (72.0 después del deload)
      // El peso después del deload puede ser menor, pero debe ser mayor que el peso base
      expect(startOfSecondCycle, greaterThan(70.0)); // Peso debe ser mayor que el peso base

      // 10. Verificar consistencia en la razón de progresión
      final progressionReasons = progressionHistory.map((e) => e['reason'] as String).toList();
      final increasingRepsReasons = progressionReasons.where((r) => r.contains('increasing reps')).length;
      final increasingWeightReasons = progressionReasons.where((r) => r.contains('increasing weight')).length;
      final deloadReasons = progressionReasons.where((r) => r.contains('deload')).length;

      expect(increasingRepsReasons, greaterThan(8)); // Debe haber muchas semanas incrementando reps
      expect(increasingWeightReasons, greaterThanOrEqualTo(3)); // Debe haber al menos 3 semanas incrementando peso
      expect(deloadReasons, equals(3)); // Exactamente 3 deloads
    });

    test('blocks progression when exercise is locked', () {
      final res = strategy.calculate(
        config: config,
        state: state,
        routineId: 'test-routine',
        currentWeight: 70.0,
        currentReps: 6,
        currentSets: 3,
        isExerciseLocked: true,
      );
      expect(res.incrementApplied, false);
      expect(res.newWeight, 70.0);
      expect(res.newReps, 6);
      expect(res.newSets, 3);
      expect(res.reason, contains('blocked'));
    });
  });
}
