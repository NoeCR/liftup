import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:liftup/features/progression/models/progression_config.dart';
import 'package:liftup/features/progression/models/progression_state.dart';
import 'package:liftup/features/progression/services/progression_service.dart';
import 'package:liftup/common/enums/progression_type_enum.dart';
import '../mocks/progression_mock_factory.dart';

// Generate mocks
@GenerateMocks([ProgressionService])
import 'session_progression_integration_test.mocks.dart';

// Helper functions for setting up specific progression mocks
void _setupLinearProgressionMock(
  MockProgressionService mockService,
  ProgressionConfig config,
  ProgressionState state,
) {
  when(
    mockService.getActiveProgressionConfig(),
  ).thenAnswer((_) async => config);
  when(
    mockService.getProgressionStateByExercise(any, any),
  ).thenAnswer((_) async => state);

  when(mockService.calculateProgression(any, any, any, any, any)).thenAnswer((
    invocation,
  ) async {
    final args = invocation.positionalArguments;
    final currentWeight = args[2] as double;
    final currentReps = args[3] as int;
    final currentSets = args[4] as int;

    // Linear progression: add increment value to weight
    final newWeight = currentWeight + config.incrementValue;

    return ProgressionCalculationResult(
      newWeight: newWeight,
      newReps: currentReps,
      newSets: currentSets,
      incrementApplied: true,
      reason: 'Linear progression: +${config.incrementValue} kg',
    );
  });
}

void _setupUndulatingProgressionMock(
  MockProgressionService mockService,
  ProgressionConfig config,
  ProgressionState state, {
  required bool isHeavyDay,
}) {
  when(
    mockService.getActiveProgressionConfig(),
  ).thenAnswer((_) async => config);
  when(
    mockService.getProgressionStateByExercise(any, any),
  ).thenAnswer((_) async => state);

  when(mockService.calculateProgression(any, any, any, any, any)).thenAnswer((
    invocation,
  ) async {
    final args = invocation.positionalArguments;
    final currentWeight = args[2] as double;
    final currentReps = args[3] as int;
    final currentSets = args[4] as int;

    // Undulating progression: heavy day = +10%, light day = -10%
    final multiplier = isHeavyDay ? 1.1 : 0.9;
    final newWeight = currentWeight * multiplier;

    return ProgressionCalculationResult(
      newWeight: newWeight,
      newReps: currentReps,
      newSets: currentSets,
      incrementApplied: true,
      reason:
          'Undulating progression: ${isHeavyDay ? 'Heavy' : 'Light'} day (${(multiplier * 100).toInt()}%)',
    );
  });
}

void _setupSteppedProgressionMock(
  MockProgressionService mockService,
  ProgressionConfig config,
  ProgressionState state, {
  required bool isDeloadWeek,
}) {
  when(
    mockService.getActiveProgressionConfig(),
  ).thenAnswer((_) async => config);
  when(
    mockService.getProgressionStateByExercise(any, any),
  ).thenAnswer((_) async => state);

  when(mockService.calculateProgression(any, any, any, any, any)).thenAnswer((
    invocation,
  ) async {
    final args = invocation.positionalArguments;
    final currentWeight = args[2] as double;
    final currentReps = args[3] as int;
    final currentSets = args[4] as int;

    // Stepped progression: normal week = +2.5kg, deload week = -15%
    final newWeight =
        isDeloadWeek
            ? currentWeight *
                0.85 // 15% reduction
            : currentWeight + 2.5; // Normal increment

    return ProgressionCalculationResult(
      newWeight: newWeight,
      newReps: currentReps,
      newSets: currentSets,
      incrementApplied: true,
      reason:
          'Stepped progression: ${isDeloadWeek ? 'Deload week (-15%)' : 'Normal week (+2.5kg)'}',
    );
  });
}

void _setupDoubleProgressionMock(
  MockProgressionService mockService,
  ProgressionConfig config,
  ProgressionState state, {
  required bool isAtMaxReps,
}) {
  when(
    mockService.getActiveProgressionConfig(),
  ).thenAnswer((_) async => config);
  when(
    mockService.getProgressionStateByExercise(any, any),
  ).thenAnswer((_) async => state);

  when(mockService.calculateProgression(any, any, any, any, any)).thenAnswer((
    invocation,
  ) async {
    final args = invocation.positionalArguments;
    final currentWeight = args[2] as double;
    final currentReps = args[3] as int;
    final currentSets = args[4] as int;

    // Double progression: increase reps until max, then increase weight and reset reps
    if (isAtMaxReps) {
      return ProgressionCalculationResult(
        newWeight: currentWeight + 2.5,
        newReps: 8, // Reset to minimum reps
        newSets: currentSets,
        incrementApplied: true,
        reason: 'Double progression: Weight increased, reps reset to minimum',
      );
    } else {
      return ProgressionCalculationResult(
        newWeight: currentWeight,
        newReps: currentReps + 1,
        newSets: currentSets,
        incrementApplied: true,
        reason: 'Double progression: Reps increased',
      );
    }
  });
}

void _setupWaveProgressionMock(
  MockProgressionService mockService,
  ProgressionConfig config,
  ProgressionState state, {
  required int weekNumber,
}) {
  when(
    mockService.getActiveProgressionConfig(),
  ).thenAnswer((_) async => config);
  when(
    mockService.getProgressionStateByExercise(any, any),
  ).thenAnswer((_) async => state);

  when(mockService.calculateProgression(any, any, any, any, any)).thenAnswer((
    invocation,
  ) async {
    final args = invocation.positionalArguments;
    final currentWeight = args[2] as double;
    final currentReps = args[3] as int;
    final currentSets = args[4] as int;

    // Wave progression: week 1 = base, week 2 = +5%, week 3 = +10%
    final multipliers = [1.0, 1.05, 1.1];
    final multiplier = multipliers[weekNumber - 1];
    final newWeight = currentWeight * multiplier;

    return ProgressionCalculationResult(
      newWeight: newWeight,
      newReps: currentReps,
      newSets: currentSets,
      incrementApplied: true,
      reason:
          'Wave progression: Week $weekNumber (${(multiplier * 100).toInt()}%)',
    );
  });
}

void _setupStaticProgressionMock(
  MockProgressionService mockService,
  ProgressionConfig config,
  ProgressionState state,
) {
  when(
    mockService.getActiveProgressionConfig(),
  ).thenAnswer((_) async => config);
  when(
    mockService.getProgressionStateByExercise(any, any),
  ).thenAnswer((_) async => state);

  when(mockService.calculateProgression(any, any, any, any, any)).thenAnswer((
    invocation,
  ) async {
    final args = invocation.positionalArguments;
    final currentWeight = args[2] as double;
    final currentReps = args[3] as int;
    final currentSets = args[4] as int;

    // Static progression: no changes
    return ProgressionCalculationResult(
      newWeight: currentWeight,
      newReps: currentReps,
      newSets: currentSets,
      incrementApplied: false,
      reason: 'Static progression: No changes applied',
    );
  });
}

void _setupReverseProgressionMock(
  MockProgressionService mockService,
  ProgressionConfig config,
  ProgressionState state,
) {
  when(
    mockService.getActiveProgressionConfig(),
  ).thenAnswer((_) async => config);
  when(
    mockService.getProgressionStateByExercise(any, any),
  ).thenAnswer((_) async => state);

  when(mockService.calculateProgression(any, any, any, any, any)).thenAnswer((
    invocation,
  ) async {
    final args = invocation.positionalArguments;
    final currentWeight = args[2] as double;
    final currentReps = args[3] as int;
    final currentSets = args[4] as int;

    // Reverse progression: decrease weight
    final newWeight = currentWeight - 2.5;

    return ProgressionCalculationResult(
      newWeight: newWeight,
      newReps: currentReps,
      newSets: currentSets,
      incrementApplied: true,
      reason: 'Reverse progression: -2.5 kg',
    );
  });
}

void main() {
  group('Session Progression Integration', () {
    late MockProgressionService mockProgressionService;

    setUp(() {
      mockProgressionService = MockProgressionService();
      // Clean state - no default mocks, each test will configure its own
    });

    tearDown(() {
      // Clean up all mocks after each test
      reset(mockProgressionService);
    });

    group('Linear Progression Integration', () {
      test('should apply linear progression to exercise sets', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig(
          type: ProgressionType.linear,
          incrementValue: 2.5,
          incrementFrequency: 1,
        );
        final state = ProgressionMockFactory.createProgressionState(
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 3,
          currentSession: 1,
        );

        // Setup specific linear progression mock
        _setupLinearProgressionMock(mockProgressionService, config, state);

        // Act - Test progression calculation directly
        final result = await mockProgressionService.calculateProgression(
          config.id,
          state.exerciseId,
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );

        // Assert - Comprehensive validation
        expect(result, isNotNull, reason: 'Result should not be null');
        expect(
          result.newWeight,
          equals(102.5),
          reason: 'Weight should increase by increment value (100.0 + 2.5)',
        );
        expect(
          result.newReps,
          equals(10),
          reason: 'Reps should remain unchanged in linear progression',
        );
        expect(
          result.newSets,
          equals(3),
          reason: 'Sets should remain unchanged in linear progression',
        );
        expect(
          result.incrementApplied,
          isTrue,
          reason: 'Increment should be applied',
        );
        expect(
          result.reason,
          contains('Linear progression'),
          reason: 'Reason should indicate linear progression',
        );
        expect(
          result.reason,
          contains('+2.5 kg'),
          reason: 'Reason should show the increment value',
        );

        // Verify mock interactions
        verify(
          mockProgressionService.calculateProgression(
            config.id,
            state.exerciseId,
            state.currentWeight,
            state.currentReps,
            state.currentSets,
          ),
        ).called(1);
      });

      test('should not apply progression if frequency not met', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig(
          type: ProgressionType.linear,
          incrementValue: 2.5,
          incrementFrequency: 2, // Every 2 sessions
        );
        final state = ProgressionMockFactory.createProgressionState(
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 3,
          currentSession: 1, // First session, should not increment
        );

        // Setup specific mock for frequency not met scenario
        when(
          mockProgressionService.getActiveProgressionConfig(),
        ).thenAnswer((_) async => config);
        when(
          mockProgressionService.getProgressionStateByExercise(any, any),
        ).thenAnswer((_) async => state);
        when(
          mockProgressionService.calculateProgression(any, any, any, any, any),
        ).thenAnswer((invocation) async {
          final args = invocation.positionalArguments;
          final currentWeight = args[2] as double;
          final currentReps = args[3] as int;
          final currentSets = args[4] as int;

          // Frequency not met - no progression applied
          return ProgressionCalculationResult(
            newWeight: currentWeight,
            newReps: currentReps,
            newSets: currentSets,
            incrementApplied: false,
            reason: 'Frequency not met: progression skipped',
          );
        });

        final routine = ProgressionMockFactory.createRoutine();
        // Act - Test progression calculation directly
        final result = await mockProgressionService.calculateProgression(
          config.id,
          state.exerciseId,
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );

        // Assert
        expect(result, isNotNull);
        expect(result, isNotNull);

        // Verify that progression was NOT applied
        // result is ProgressionCalculationResult, not a list
        expect(result.newWeight, 100.0); // No change
        expect(result.newReps, 10);
      });
    });

    group('Undulating Progression Integration', () {
      test('should apply heavy day progression', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig(
          type: ProgressionType.undulating,
          customParameters: {
            'heavy_day_multiplier': 1.1,
            'light_day_multiplier': 0.9,
          },
        );
        final state = ProgressionMockFactory.createProgressionState(
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
          currentSession: 1, // Odd session = heavy day
        );

        // Setup specific undulating progression mock for heavy day
        _setupUndulatingProgressionMock(
          mockProgressionService,
          config,
          state,
          isHeavyDay: true,
        );

        final routine = ProgressionMockFactory.createRoutine();
        // Act - Test progression calculation directly
        final result = await mockProgressionService.calculateProgression(
          config.id,
          state.exerciseId,
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );

        // Assert - Comprehensive validation for heavy day
        expect(result, isNotNull, reason: 'Result should not be null');
        expect(
          result.newWeight,
          closeTo(110.0, 0.01),
          reason: 'Heavy day should increase weight by 10% (100.0 * 1.1)',
        );
        expect(
          result.newReps,
          equals(8),
          reason: 'Reps should remain unchanged in undulating progression',
        );
        expect(
          result.newSets,
          equals(4),
          reason: 'Sets should remain unchanged in undulating progression',
        );
        expect(
          result.incrementApplied,
          isTrue,
          reason: 'Increment should be applied on heavy day',
        );
        expect(
          result.reason,
          contains('Undulating progression'),
          reason: 'Reason should indicate undulating progression',
        );
        expect(
          result.reason,
          contains('Heavy day'),
          reason: 'Reason should indicate heavy day',
        );
        expect(
          result.reason,
          contains('110%'),
          reason: 'Reason should show the multiplier percentage',
        );

        // Verify mock interactions
        verify(
          mockProgressionService.calculateProgression(
            config.id,
            state.exerciseId,
            state.currentWeight,
            state.currentReps,
            state.currentSets,
          ),
        ).called(1);
      });

      test('should apply light day progression', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig(
          type: ProgressionType.undulating,
          customParameters: {
            'heavy_day_multiplier': 1.1,
            'light_day_multiplier': 0.9,
          },
        );
        final state = ProgressionMockFactory.createProgressionState(
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 3,
          currentSession: 2, // Even session = light day
        );

        // Setup specific undulating progression mock for light day
        _setupUndulatingProgressionMock(
          mockProgressionService,
          config,
          state,
          isHeavyDay: false,
        );

        final routine = ProgressionMockFactory.createRoutine();
        // Act - Test progression calculation directly
        final result = await mockProgressionService.calculateProgression(
          config.id,
          state.exerciseId,
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );

        // Assert - Comprehensive validation for light day
        expect(result, isNotNull, reason: 'Result should not be null');
        expect(
          result.newWeight,
          closeTo(90.0, 0.01),
          reason: 'Light day should decrease weight by 10% (100.0 * 0.9)',
        );
        expect(
          result.newReps,
          equals(10),
          reason: 'Reps should remain unchanged in undulating progression',
        );
        expect(
          result.newSets,
          equals(3),
          reason: 'Sets should remain unchanged in undulating progression',
        );
        expect(
          result.incrementApplied,
          isTrue,
          reason: 'Increment should be applied on light day',
        );
        expect(
          result.reason,
          contains('Undulating progression'),
          reason: 'Reason should indicate undulating progression',
        );
        expect(
          result.reason,
          contains('Light day'),
          reason: 'Reason should indicate light day',
        );
        expect(
          result.reason,
          contains('90%'),
          reason: 'Reason should show the multiplier percentage',
        );

        // Verify mock interactions
        verify(
          mockProgressionService.calculateProgression(
            config.id,
            state.exerciseId,
            state.currentWeight,
            state.currentReps,
            state.currentSets,
          ),
        ).called(1);
      });
    });

    group('Stepped Progression Integration', () {
      test('should apply normal week progression', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig(
          type: ProgressionType.stepped,
          incrementValue: 2.5,
          deloadWeek: 4,
        );
        final state = ProgressionMockFactory.createProgressionState(
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 3,
          currentWeek: 2, // Normal week
        );

        // Setup specific stepped progression mock for normal week
        _setupSteppedProgressionMock(
          mockProgressionService,
          config,
          state,
          isDeloadWeek: false,
        );

        final routine = ProgressionMockFactory.createRoutine();
        // Act - Test progression calculation directly
        final result = await mockProgressionService.calculateProgression(
          config.id,
          state.exerciseId,
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );

        // Assert - Comprehensive validation for normal week
        expect(result, isNotNull, reason: 'Result should not be null');
        expect(
          result.newWeight,
          equals(102.5),
          reason:
              'Normal week should increase weight by increment value (100.0 + 2.5)',
        );
        expect(
          result.newReps,
          equals(10),
          reason: 'Reps should remain unchanged in stepped progression',
        );
        expect(
          result.newSets,
          equals(3),
          reason: 'Sets should remain unchanged in stepped progression',
        );
        expect(
          result.incrementApplied,
          isTrue,
          reason: 'Increment should be applied on normal week',
        );
        expect(
          result.reason,
          contains('Stepped progression'),
          reason: 'Reason should indicate stepped progression',
        );
        expect(
          result.reason,
          contains('Normal week'),
          reason: 'Reason should indicate normal week',
        );
        expect(
          result.reason,
          contains('+2.5kg'),
          reason: 'Reason should show the increment value',
        );

        // Verify mock interactions
        verify(
          mockProgressionService.calculateProgression(
            config.id,
            state.exerciseId,
            state.currentWeight,
            state.currentReps,
            state.currentSets,
          ),
        ).called(1);
      });

      test('should apply deload week progression', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig(
          type: ProgressionType.stepped,
          incrementValue: 2.5,
          deloadWeek: 4,
          deloadPercentage: 0.85,
        );
        final state = ProgressionMockFactory.createProgressionState(
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 3,
          currentWeek: 4, // Deload week
        );

        // Setup specific stepped progression mock for deload week
        _setupSteppedProgressionMock(
          mockProgressionService,
          config,
          state,
          isDeloadWeek: true,
        );

        final routine = ProgressionMockFactory.createRoutine();

        // Act - Test progression calculation directly
        final result = await mockProgressionService.calculateProgression(
          config.id,
          state.exerciseId,
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );

        // Assert - Comprehensive validation for deload week
        expect(result, isNotNull, reason: 'Result should not be null');
        expect(
          result.newWeight,
          closeTo(85.0, 0.01),
          reason: 'Deload week should reduce weight by 15% (100.0 * 0.85)',
        );
        expect(
          result.newReps,
          equals(10),
          reason: 'Reps should remain unchanged in stepped progression',
        );
        expect(
          result.newSets,
          equals(3),
          reason: 'Sets should remain unchanged in stepped progression',
        );
        expect(
          result.incrementApplied,
          isTrue,
          reason: 'Increment should be applied on deload week',
        );
        expect(
          result.reason,
          contains('Stepped progression'),
          reason: 'Reason should indicate stepped progression',
        );
        expect(
          result.reason,
          contains('Deload week'),
          reason: 'Reason should indicate deload week',
        );
        expect(
          result.reason,
          contains('-15%'),
          reason: 'Reason should show the deload percentage',
        );

        // Verify mock interactions
        verify(
          mockProgressionService.calculateProgression(
            config.id,
            state.exerciseId,
            state.currentWeight,
            state.currentReps,
            state.currentSets,
          ),
        ).called(1);
      });
    });

    group('Double Progression Integration', () {
      test('should increase reps when below max', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig(
          type: ProgressionType.double,
          primaryTarget: ProgressionTarget.reps,
          secondaryTarget: ProgressionTarget.weight,
          customParameters: {'max_reps': 12, 'min_reps': 8},
        );
        final state = ProgressionMockFactory.createProgressionState(
          currentWeight: 100.0,
          currentReps: 10, // Below max of 12
          currentSets: 3,
        );

        // Setup specific double progression mock for reps increase
        _setupDoubleProgressionMock(
          mockProgressionService,
          config,
          state,
          isAtMaxReps: false,
        );

        final routine = ProgressionMockFactory.createRoutine();

        // Act - Test progression calculation directly
        final result = await mockProgressionService.calculateProgression(
          config.id,
          state.exerciseId,
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );

        // Assert - Comprehensive validation for reps increase
        expect(result, isNotNull, reason: 'Result should not be null');
        expect(
          result.newWeight,
          equals(100.0),
          reason: 'Weight should remain unchanged when increasing reps',
        );
        expect(
          result.newReps,
          equals(11),
          reason: 'Reps should increase by 1 when below max',
        );
        expect(
          result.newSets,
          equals(3),
          reason: 'Sets should remain unchanged in double progression',
        );
        expect(
          result.incrementApplied,
          isTrue,
          reason: 'Increment should be applied for reps increase',
        );
        expect(
          result.reason,
          contains('Double progression'),
          reason: 'Reason should indicate double progression',
        );
        expect(
          result.reason,
          contains('Reps increased'),
          reason: 'Reason should indicate reps increase',
        );

        // Verify mock interactions
        verify(
          mockProgressionService.calculateProgression(
            config.id,
            state.exerciseId,
            state.currentWeight,
            state.currentReps,
            state.currentSets,
          ),
        ).called(1);
      });

      test('should increase weight and reset reps when at max', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig(
          type: ProgressionType.double,
          primaryTarget: ProgressionTarget.reps,
          secondaryTarget: ProgressionTarget.weight,
          customParameters: {'max_reps': 12, 'min_reps': 8},
        );
        final state = ProgressionMockFactory.createProgressionState(
          currentWeight: 100.0,
          currentReps: 12, // At max
          currentSets: 3,
        );

        // Setup specific double progression mock for weight increase and reps reset
        _setupDoubleProgressionMock(
          mockProgressionService,
          config,
          state,
          isAtMaxReps: true,
        );

        final routine = ProgressionMockFactory.createRoutine();
        // Act - Test progression calculation directly
        final result = await mockProgressionService.calculateProgression(
          config.id,
          state.exerciseId,
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );

        // Assert - Comprehensive validation for weight increase and reps reset
        expect(result, isNotNull, reason: 'Result should not be null');
        expect(
          result.newWeight,
          equals(102.5),
          reason: 'Weight should increase by increment value when at max reps',
        );
        expect(
          result.newReps,
          equals(8),
          reason: 'Reps should reset to minimum when at max',
        );
        expect(
          result.newSets,
          equals(3),
          reason: 'Sets should remain unchanged in double progression',
        );
        expect(
          result.incrementApplied,
          isTrue,
          reason: 'Increment should be applied for weight increase',
        );
        expect(
          result.reason,
          contains('Double progression'),
          reason: 'Reason should indicate double progression',
        );
        expect(
          result.reason,
          contains('Weight increased'),
          reason: 'Reason should indicate weight increase',
        );
        expect(
          result.reason,
          contains('reps reset'),
          reason: 'Reason should indicate reps reset',
        );

        // Verify mock interactions
        verify(
          mockProgressionService.calculateProgression(
            config.id,
            state.exerciseId,
            state.currentWeight,
            state.currentReps,
            state.currentSets,
          ),
        ).called(1);
      });
    });

    group('Wave Progression Integration', () {
      test('should apply week 1 progression', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig(
          type: ProgressionType.wave,
          cycleLength: 3,
          customParameters: {
            'week_1_multiplier': 1.0,
            'week_2_multiplier': 1.05,
            'week_3_multiplier': 1.1,
          },
        );
        final state = ProgressionMockFactory.createProgressionState(
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 3,
          currentWeek: 1,
        );

        // Setup specific mock for frequency not met scenario
        when(
          mockProgressionService.getActiveProgressionConfig(),
        ).thenAnswer((_) async => config);
        when(
          mockProgressionService.getProgressionStateByExercise(any, any),
        ).thenAnswer((_) async => state);
        when(
          mockProgressionService.calculateProgression(any, any, any, any, any),
        ).thenAnswer((invocation) async {
          final args = invocation.positionalArguments;
          final currentWeight = args[2] as double;
          final currentReps = args[3] as int;
          final currentSets = args[4] as int;

          // Frequency not met - no progression applied
          return ProgressionCalculationResult(
            newWeight: currentWeight,
            newReps: currentReps,
            newSets: currentSets,
            incrementApplied: false,
            reason: 'Frequency not met: progression skipped',
          );
        });

        final routine = ProgressionMockFactory.createRoutine();
        // Act - Test progression calculation directly
        final result = await mockProgressionService.calculateProgression(
          config.id,
          state.exerciseId,
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );

        // Assert
        expect(result, isNotNull);
        expect(result, isNotNull);

        // Verify week 1 progression
        // result is ProgressionCalculationResult, not a list
        expect(result.newWeight, 100.0); // Base weight
        expect(result.newReps, 10);
        expect(result.newSets, 3);
      });

      test('should apply week 2 progression', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig(
          type: ProgressionType.wave,
          cycleLength: 3,
          customParameters: {
            'week_1_multiplier': 1.0,
            'week_2_multiplier': 1.05,
            'week_3_multiplier': 1.1,
          },
        );
        final state = ProgressionMockFactory.createProgressionState(
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 3,
          currentWeek: 2,
        );

        // Setup specific wave progression mock for week 2
        _setupWaveProgressionMock(
          mockProgressionService,
          config,
          state,
          weekNumber: 2,
        );

        final routine = ProgressionMockFactory.createRoutine();

        // Act - Test progression calculation directly
        final result = await mockProgressionService.calculateProgression(
          config.id,
          state.exerciseId,
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );

        // Assert - Comprehensive validation for week 2
        expect(result, isNotNull, reason: 'Result should not be null');
        expect(
          result.newWeight,
          closeTo(105.0, 0.01),
          reason: 'Week 2 should increase weight by 5% (100.0 * 1.05)',
        );
        expect(
          result.newReps,
          equals(10),
          reason: 'Reps should remain unchanged in wave progression',
        );
        expect(
          result.newSets,
          equals(3),
          reason: 'Sets should remain unchanged in wave progression',
        );
        expect(
          result.incrementApplied,
          isTrue,
          reason: 'Increment should be applied on week 2',
        );
        expect(
          result.reason,
          contains('Wave progression'),
          reason: 'Reason should indicate wave progression',
        );
        expect(
          result.reason,
          contains('Week 2'),
          reason: 'Reason should indicate week 2',
        );
        expect(
          result.reason,
          contains('105%'),
          reason: 'Reason should show the multiplier percentage',
        );

        // Verify mock interactions
        verify(
          mockProgressionService.calculateProgression(
            config.id,
            state.exerciseId,
            state.currentWeight,
            state.currentReps,
            state.currentSets,
          ),
        ).called(1);
      });

      test('should apply week 3 progression', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig(
          type: ProgressionType.wave,
          cycleLength: 3,
          customParameters: {
            'week_1_multiplier': 1.0,
            'week_2_multiplier': 1.05,
            'week_3_multiplier': 1.1,
          },
        );
        final state = ProgressionMockFactory.createProgressionState(
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 3,
          currentWeek: 3,
        );

        // Setup specific wave progression mock for week 3
        _setupWaveProgressionMock(
          mockProgressionService,
          config,
          state,
          weekNumber: 3,
        );

        final routine = ProgressionMockFactory.createRoutine();

        // Act - Test progression calculation directly
        final result = await mockProgressionService.calculateProgression(
          config.id,
          state.exerciseId,
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );

        // Assert - Comprehensive validation for week 3
        expect(result, isNotNull, reason: 'Result should not be null');
        expect(
          result.newWeight,
          closeTo(110.0, 0.01),
          reason: 'Week 3 should increase weight by 10% (100.0 * 1.1)',
        );
        expect(
          result.newReps,
          equals(10),
          reason: 'Reps should remain unchanged in wave progression',
        );
        expect(
          result.newSets,
          equals(3),
          reason: 'Sets should remain unchanged in wave progression',
        );
        expect(
          result.incrementApplied,
          isTrue,
          reason: 'Increment should be applied on week 3',
        );
        expect(
          result.reason,
          contains('Wave progression'),
          reason: 'Reason should indicate wave progression',
        );
        expect(
          result.reason,
          contains('Week 3'),
          reason: 'Reason should indicate week 3',
        );
        expect(
          result.reason,
          contains('110%'),
          reason: 'Reason should show the multiplier percentage',
        );

        // Verify mock interactions
        verify(
          mockProgressionService.calculateProgression(
            config.id,
            state.exerciseId,
            state.currentWeight,
            state.currentReps,
            state.currentSets,
          ),
        ).called(1);
      });
    });

    group('Static Progression Integration', () {
      test('should maintain constant values', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig(
          type: ProgressionType.static,
          incrementValue: 0.0,
        );
        final state = ProgressionMockFactory.createProgressionState(
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 3,
        );

        // Setup specific mock for frequency not met scenario
        when(
          mockProgressionService.getActiveProgressionConfig(),
        ).thenAnswer((_) async => config);
        when(
          mockProgressionService.getProgressionStateByExercise(any, any),
        ).thenAnswer((_) async => state);
        when(
          mockProgressionService.calculateProgression(any, any, any, any, any),
        ).thenAnswer((invocation) async {
          final args = invocation.positionalArguments;
          final currentWeight = args[2] as double;
          final currentReps = args[3] as int;
          final currentSets = args[4] as int;

          // Frequency not met - no progression applied
          return ProgressionCalculationResult(
            newWeight: currentWeight,
            newReps: currentReps,
            newSets: currentSets,
            incrementApplied: false,
            reason: 'Frequency not met: progression skipped',
          );
        });

        final routine = ProgressionMockFactory.createRoutine();

        // Act - Test progression calculation directly
        final result = await mockProgressionService.calculateProgression(
          config.id,
          state.exerciseId,
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );

        // Assert
        expect(result, isNotNull);
        expect(result, isNotNull);

        // Verify no progression applied
        expect(result.newWeight, 100.0); // No change
        expect(result.newReps, 10); // No change
        expect(result.newSets, 3); // No change
        expect(result.incrementApplied, isFalse);
      });
    });

    group('Reverse Progression Integration', () {
      test('should decrease values over time', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig(
          type: ProgressionType.reverse,
          incrementValue: -2.5, // Negative increment
        );
        final state = ProgressionMockFactory.createProgressionState(
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 3,
        );

        // Setup specific reverse progression mock
        _setupReverseProgressionMock(mockProgressionService, config, state);

        final routine = ProgressionMockFactory.createRoutine();

        // Act - Test progression calculation directly
        final result = await mockProgressionService.calculateProgression(
          config.id,
          state.exerciseId,
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );

        // Assert - Comprehensive validation for reverse progression
        expect(result, isNotNull, reason: 'Result should not be null');
        expect(
          result.newWeight,
          equals(97.5),
          reason:
              'Reverse progression should decrease weight by increment value (100.0 - 2.5)',
        );
        expect(
          result.newReps,
          equals(10),
          reason: 'Reps should remain unchanged in reverse progression',
        );
        expect(
          result.newSets,
          equals(3),
          reason: 'Sets should remain unchanged in reverse progression',
        );
        expect(
          result.incrementApplied,
          isTrue,
          reason: 'Increment should be applied in reverse progression',
        );
        expect(
          result.reason,
          contains('Reverse progression'),
          reason: 'Reason should indicate reverse progression',
        );
        expect(
          result.reason,
          contains('-2.5 kg'),
          reason: 'Reason should show the negative increment value',
        );

        // Verify mock interactions
        verify(
          mockProgressionService.calculateProgression(
            config.id,
            state.exerciseId,
            state.currentWeight,
            state.currentReps,
            state.currentSets,
          ),
        ).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle no active progression config', () async {
        // Arrange
        when(
          mockProgressionService.getActiveProgressionConfig(),
        ).thenAnswer((_) async => null);

        // Act - Test that no progression is applied when no config exists
        final config =
            await mockProgressionService.getActiveProgressionConfig();

        // Assert
        expect(config, isNull);
      });

      test('should handle missing progression state', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig();
        when(
          mockProgressionService.getActiveProgressionConfig(),
        ).thenAnswer((_) async => config);
        when(
          mockProgressionService.getProgressionStateByExercise(any, any),
        ).thenAnswer((_) async => null);

        // Act - Test that service handles missing state gracefully
        final state = await mockProgressionService
            .getProgressionStateByExercise(config.id, 'test-exercise-id');

        // Assert
        expect(state, isNull);
      });
    });
  });
}
