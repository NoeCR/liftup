import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/double_factor_progression_strategy.dart';

void main() {
  group('Double Factor Deload Tests', () {
    late ProgressionConfig config;
    late ProgressionState state;

    setUp(() {
      final now = DateTime.now();
      config = ProgressionConfig(
        id: 'cfg',
        isGlobal: true,
        type: ProgressionType.doubleFactor,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: ProgressionTarget.reps,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 4, // Deload en semana 4 (par)
        deloadPercentage: 0.8, // Reducción del 20%
        customParameters: const {'min_reps': 6, 'max_reps': 10},
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
        routineId: 'test-routine',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 80.0,
        currentReps: 6,
        currentSets: 3,
        baseWeight: 80.0,
        baseReps: 6,
        baseSets: 3,
        sessionHistory: const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );
    });

    test('deload se aplica solo en semanas pares', () {
      final strategy = DoubleFactorProgressionStrategy();

      // Semana 3 (impar) - NO debe aplicar deload aunque sea deloadWeek
      final configOddDeload = config.copyWith(deloadWeek: 3);
      var result = strategy.calculate(
        config: configOddDeload,
        state: state.copyWith(currentWeek: 3),
        routineId: 'test-routine',
        currentWeight: 85.0,
        currentReps: 7,
        currentSets: 3,
      );

      // No debe ser deload, debe continuar con progresión normal
      expect(result.isDeload, false);
      expect(result.reason, contains('increasing weight')); // Semana impar

      // Semana 4 (par) - SÍ debe aplicar deload
      result = strategy.calculate(
        config: config,
        state: state.copyWith(currentWeek: 4),
        routineId: 'test-routine',
        currentWeight: 85.0,
        currentReps: 8,
        currentSets: 3,
      );

      expect(result.isDeload, true);
      expect(result.reason, contains('deload'));
    });

    test('deload reduce peso y reps proporcionalmente al progreso', () {
      final strategy = DoubleFactorProgressionStrategy();

      // Simular progresión hasta semana 4 con incrementos
      // Peso base: 80kg, progresado a 87.5kg (+7.5kg)
      // Reps base: 6, progresado a 8 (+2 reps)
      final result = strategy.calculate(
        config: config,
        state: state.copyWith(currentWeek: 4),
        routineId: 'test-routine',
        currentWeight: 87.5, // 80 + 7.5 (3 incrementos de 2.5kg)
        currentReps: 8, // 6 + 2 (2 incrementos de reps)
        currentSets: 3,
      );

      // Deload debe reducir proporcionalmente:
      // Peso: 80 + (7.5 * 0.8) = 80 + 6 = 86kg
      // Reps: 6 + (2 * 0.8) = 6 + 1.6 = 7.6 ≈ 8 reps
      expect(result.isDeload, true);
      expect(result.newWeight, 86.0); // 80 + (7.5 * 0.8)
      expect(result.newReps, 8); // 6 + (2 * 0.8) = 7.6 ≈ 8
      expect(result.newSets, 2); // 3 * 0.7 = 2.1 ≈ 2
      expect(result.reason, contains('weight: 86.0kg, reps: 8'));
    });

    test('deload con progreso mínimo mantiene valores base', () {
      final strategy = DoubleFactorProgressionStrategy();

      // Simular progresión mínima
      final result = strategy.calculate(
        config: config,
        state: state.copyWith(currentWeek: 4),
        routineId: 'test-routine',
        currentWeight: 80.0, // Sin progreso en peso
        currentReps: 6, // Sin progreso en reps
        currentSets: 3,
      );

      // Deload debe mantener valores base
      expect(result.isDeload, true);
      expect(result.newWeight, 80.0); // Sin incremento, mantiene base
      expect(result.newReps, 6); // Sin incremento, mantiene base
      expect(result.newSets, 2); // Solo reduce sets
    });

    test('deload con progreso máximo reduce significativamente', () {
      final strategy = DoubleFactorProgressionStrategy();

      // Simular progresión máxima
      final result = strategy.calculate(
        config: config,
        state: state.copyWith(currentWeek: 4),
        routineId: 'test-routine',
        currentWeight: 100.0, // 80 + 20kg de progreso
        currentReps: 10, // 6 + 4 reps de progreso
        currentSets: 3,
      );

      // Deload debe reducir significativamente:
      // Peso: 80 + (20 * 0.8) = 80 + 16 = 96kg
      // Reps: 6 + (4 * 0.8) = 6 + 3.2 = 9.2 ≈ 9 reps
      expect(result.isDeload, true);
      expect(result.newWeight, 96.0); // 80 + (20 * 0.8)
      expect(result.newReps, 9); // 6 + (4 * 0.8) = 9.2 ≈ 9
      expect(result.newSets, 2); // 3 * 0.7 = 2.1 ≈ 2
    });

    test('simulación completa: 6 semanas con deload en semana 4', () {
      final strategy = DoubleFactorProgressionStrategy();
      final config6Weeks = config.copyWith(cycleLength: 6, deloadWeek: 4);

      print('\n=== SIMULACIÓN DOUBLE FACTOR CON DELOAD ===');

      var weight = 80.0;
      var reps = 6;
      var sets = 3;

      for (int week = 1; week <= 6; week++) {
        final result = strategy.calculate(
          config: config6Weeks,
          state: state.copyWith(currentWeek: week),
          routineId: 'test-routine',
          currentWeight: weight,
          currentReps: reps,
          currentSets: sets,
        );

        weight = result.newWeight;
        reps = result.newReps;
        sets = result.newSets;

        final isDeload = result.isDeload;
        final deloadMark = isDeload ? ' [DELOAD]' : '';

        print(
          'Semana $week: ${weight}kg x $reps reps x $sets sets$deloadMark - ${result.reason}',
        );
      }

      // Verificar que el deload se aplicó correctamente
      expect(weight, lessThan(100.0)); // Debe haber reducción significativa
      // Los sets se restauran después del deload, no se mantienen reducidos
    });

    test('deload no se aplica si la semana deload es impar', () {
      final strategy = DoubleFactorProgressionStrategy();
      final configOddDeload = config.copyWith(deloadWeek: 3); // Semana impar

      // Semana 3 (impar) - NO debe aplicar deload
      final result = strategy.calculate(
        config: configOddDeload,
        state: state.copyWith(currentWeek: 3),
        routineId: 'test-routine',
        currentWeight: 85.0,
        currentReps: 7,
        currentSets: 3,
      );

      expect(result.isDeload, false);
      expect(
        result.reason,
        contains('increasing weight'),
      ); // Continúa progresión normal
    });

    test('deload se aplica correctamente en semana 6 (par)', () {
      final strategy = DoubleFactorProgressionStrategy();
      final config6Weeks = config.copyWith(
        cycleLength: 6,
        deloadWeek: 6,
      ); // Semana par

      // Semana 6 (par) - SÍ debe aplicar deload
      final result = strategy.calculate(
        config: config6Weeks,
        state: state.copyWith(currentWeek: 6),
        routineId: 'test-routine',
        currentWeight: 90.0,
        currentReps: 8,
        currentSets: 3,
      );

      expect(result.isDeload, true);
      expect(result.reason, contains('deload'));
      expect(result.newWeight, lessThan(90.0)); // Debe reducir peso
      expect(result.newSets, equals(2)); // Debe reducir sets
      // Las reps se reducen proporcionalmente al progreso sobre la base
    });
  });
}
