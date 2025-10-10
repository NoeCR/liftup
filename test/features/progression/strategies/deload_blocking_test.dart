import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/double_factor_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';

void main() {
  group('Deload Blocking Tests', () {
    test('linear progression: blocking during deload preserves baseSets', () {
      final strategy = LinearProgressionStrategy();
      final now = DateTime.now();

      final config = ProgressionConfig(
        id: 'cfg',
        isGlobal: true,
        type: ProgressionType.linear,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 4, // Deload en semana 4
        deloadPercentage: 0.8,
        customParameters: const {},
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final state = ProgressionState(
        id: 'st',
        progressionConfigId: 'cfg',
        exerciseId: 'ex',
        routineId: 'test-routine-1',
        currentCycle: 1,
        currentWeek: 4, // Semana de deload
        currentSession: 1,
        currentWeight: 100.0,
        currentReps: 10,
        currentSets: 3, // Sets reducidos por deload anterior
        baseWeight: 100.0,
        baseReps: 10,
        baseSets: 4, // Sets base originales
        sessionHistory: const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );

      // Bloquear progresión durante deload
      final result = strategy.calculate(
        config: config,
        state: state,
        routineId: 'test-routine',
        currentWeight: 100.0,
        currentReps: 10,
        currentSets: 3, // Sets reducidos por deload
        isExerciseLocked: true,
      );

      // Verificar que se usan los baseSets, no los currentSets reducidos
      expect(result.newSets, 4); // Debe usar baseSets, no currentSets (3)
      expect(result.incrementApplied, false);
      expect(result.reason, contains('blocked'));
    });

    test(
      'double factor progression: blocking during deload preserves baseSets',
      () {
        final strategy = DoubleFactorProgressionStrategy();
        final now = DateTime.now();

        final config = ProgressionConfig(
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

        final state = ProgressionState(
          id: 'st',
          progressionConfigId: 'cfg',
          exerciseId: 'ex',
          routineId: 'test-routine-1',
          currentCycle: 1,
          currentWeek: 4, // Semana de deload
          currentSession: 1,
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 2, // Sets reducidos por deload anterior
          baseWeight: 100.0,
          baseReps: 6,
          baseSets: 4, // Sets base originales
          sessionHistory: const {},
          lastUpdated: now,
          isDeloadWeek: false,
          oneRepMax: null,
          customData: const {},
        );

        // Bloquear progresión durante deload
        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 2, // Sets reducidos por deload
          isExerciseLocked: true,
        );

        // Verificar que se usan los baseSets, no los currentSets reducidos
        expect(result.newSets, 4); // Debe usar baseSets, no currentSets (2)
        expect(result.incrementApplied, false);
        expect(result.reason, contains('blocked'));
      },
    );

    test('normal progression after deload blocking restores to baseSets', () {
      final strategy = LinearProgressionStrategy();
      final now = DateTime.now();

      final config = ProgressionConfig(
        id: 'cfg',
        isGlobal: true,
        type: ProgressionType.linear,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 0, // Sin deload
        deloadPercentage: 0.8,
        customParameters: const {},
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final state = ProgressionState(
        id: 'st',
        progressionConfigId: 'cfg',
        exerciseId: 'ex',
        routineId: 'test-routine-1',
        currentCycle: 1,
        currentWeek: 1, // Semana normal
        currentSession: 1,
        currentWeight: 100.0,
        currentReps: 10,
        currentSets:
            3, // Sets que podrían haber sido reducidos por deload anterior
        baseWeight: 100.0,
        baseReps: 10,
        baseSets: 4, // Sets base originales
        sessionHistory: const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );

      // Progresión normal (no bloqueada)
      final result = strategy.calculate(
        config: config,
        state: state,
        routineId: 'test-routine',
        currentWeight: 100.0,
        currentReps: 10,
        currentSets: 3, // Sets reducidos
        isExerciseLocked: false,
      );

      // Verificar que se restauran los baseSets
      expect(result.newSets, 4); // Debe restaurar a baseSets
      expect(result.incrementApplied, true);
      expect(result.reason, contains('Linear progression'));
    });
  });
}
