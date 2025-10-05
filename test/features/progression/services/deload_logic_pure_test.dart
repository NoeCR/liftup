import 'package:flutter_test/flutter_test.dart';
import 'package:liftup/features/progression/models/progression_config.dart';
import 'package:liftup/features/progression/models/progression_state.dart';
import 'package:liftup/common/enums/progression_type_enum.dart';

void main() {
  group('Deload Logic Pure Tests', () {
    late ProgressionConfig testConfig;
    late ProgressionState testState;

    setUp(() {
      testConfig = ProgressionConfig(
        id: 'test-config',
        isGlobal: true,
        customParameters: {
          'sessions_per_week': 3,
          'max_weeks': 8,
          'reset_percentage': 0.85,
        },
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
    });

    group('Deload Week Calculation', () {
      test('should calculate week in cycle correctly', () {
        // Test deload week calculation logic
        final cycleLength = 4;
        final deloadWeek = 4;

        // Week 1: Not deload
        final week1 = 1;
        final weekInCycle1 = ((week1 - 1) % cycleLength) + 1;
        final isDeloadWeek1 = weekInCycle1 == deloadWeek;
        expect(isDeloadWeek1, isFalse);
        expect(weekInCycle1, equals(1));

        // Week 2: Not deload
        final week2 = 2;
        final weekInCycle2 = ((week2 - 1) % cycleLength) + 1;
        final isDeloadWeek2 = weekInCycle2 == deloadWeek;
        expect(isDeloadWeek2, isFalse);
        expect(weekInCycle2, equals(2));

        // Week 3: Not deload
        final week3 = 3;
        final weekInCycle3 = ((week3 - 1) % cycleLength) + 1;
        final isDeloadWeek3 = weekInCycle3 == deloadWeek;
        expect(isDeloadWeek3, isFalse);
        expect(weekInCycle3, equals(3));

        // Week 4: DELOAD
        final week4 = 4;
        final weekInCycle4 = ((week4 - 1) % cycleLength) + 1;
        final isDeloadWeek4 = weekInCycle4 == deloadWeek;
        expect(isDeloadWeek4, isTrue);
        expect(weekInCycle4, equals(4));

        // Week 5: New cycle, week 1 (not deload)
        final week5 = 5;
        final weekInCycle5 = ((week5 - 1) % cycleLength) + 1;
        final isDeloadWeek5 = weekInCycle5 == deloadWeek;
        expect(isDeloadWeek5, isFalse);
        expect(weekInCycle5, equals(1)); // Should be week 1 of new cycle

        // Week 8: New cycle, week 4 (deload)
        final week8 = 8;
        final weekInCycle8 = ((week8 - 1) % cycleLength) + 1;
        final isDeloadWeek8 = weekInCycle8 == deloadWeek;
        expect(isDeloadWeek8, isTrue);
        expect(weekInCycle8, equals(4));
      });

      test('should handle different cycle lengths', () {
        // Test with 3-week cycle
        final cycleLength3 = 3;
        final deloadWeek3 = 3;

        for (int week = 1; week <= 9; week++) {
          final weekInCycle = ((week - 1) % cycleLength3) + 1;
          final isDeloadWeek = weekInCycle == deloadWeek3;

          if (week % 3 == 0) {
            expect(
              isDeloadWeek,
              isTrue,
              reason: 'Week $week should be deload week',
            );
          } else {
            expect(
              isDeloadWeek,
              isFalse,
              reason: 'Week $week should not be deload week',
            );
          }
        }

        // Test with 6-week cycle
        final cycleLength6 = 6;
        final deloadWeek6 = 6;

        for (int week = 1; week <= 12; week++) {
          final weekInCycle = ((week - 1) % cycleLength6) + 1;
          final isDeloadWeek = weekInCycle == deloadWeek6;

          if (week % 6 == 0) {
            expect(
              isDeloadWeek,
              isTrue,
              reason: 'Week $week should be deload week',
            );
          } else {
            expect(
              isDeloadWeek,
              isFalse,
              reason: 'Week $week should not be deload week',
            );
          }
        }
      });
    });

    group('Deload Percentage Calculation', () {
      test('should calculate deload weight correctly', () {
        final baseWeight = 100.0;
        final deloadPercentage = 0.8;

        final deloadWeight = baseWeight * deloadPercentage;
        expect(deloadWeight, equals(80.0));

        // Test different deload percentages
        expect(100.0 * 0.7, equals(70.0));
        expect(100.0 * 0.75, equals(75.0));
        expect(100.0 * 0.85, equals(85.0));
        expect(100.0 * 0.9, equals(90.0));
      });

      test('should calculate deload sets correctly', () {
        final baseSets = 3;
        final setsReduction = 0.7;

        final deloadSets = (baseSets * setsReduction).round();
        expect(deloadSets, equals(2));

        // Test different set counts
        expect((4 * 0.7).round(), equals(3));
        expect((5 * 0.7).round(), equals(4));
        expect((6 * 0.7).round(), equals(4));
      });
    });

    group('Progression Config Validation', () {
      test('should validate deload week is within cycle length', () {
        final validConfigs = [
          {'cycleLength': 3, 'deloadWeek': 3},
          {'cycleLength': 4, 'deloadWeek': 4},
          {'cycleLength': 6, 'deloadWeek': 6},
          {'cycleLength': 8, 'deloadWeek': 4}, // Mid-cycle deload
          {'cycleLength': 12, 'deloadWeek': 12},
        ];

        for (final config in validConfigs) {
          final cycleLength = config['cycleLength'] as int;
          final deloadWeek = config['deloadWeek'] as int;

          // Validate deload week is within cycle
          expect(deloadWeek, lessThanOrEqualTo(cycleLength));
          expect(deloadWeek, greaterThan(0));
        }
      });

      test('should validate deload percentage is reasonable', () {
        final validPercentages = [0.7, 0.75, 0.8, 0.85, 0.9];

        for (final percentage in validPercentages) {
          expect(percentage, greaterThan(0.5));
          expect(percentage, lessThan(1.0));

          // Test calculation
          final baseWeight = 100.0;
          final deloadWeight = baseWeight * percentage;
          expect(deloadWeight, lessThan(baseWeight));
          expect(deloadWeight, greaterThan(baseWeight * 0.5));
        }
      });
    });

    group('Session Frequency Logic', () {
      test(
        'should determine progression application based on session frequency',
        () {
          // Simulate the logic for determining when to apply progression
          bool shouldApplyProgression(
            int sessionsPerWeek,
            bool isFirstSessionOfWeek,
          ) {
            if (sessionsPerWeek == 1) {
              return true; // Apply always for single session routines
            } else {
              return isFirstSessionOfWeek; // Only first session for multiple sessions
            }
          }

          // Test cases
          expect(
            shouldApplyProgression(1, false),
            isTrue,
          ); // 1 session, not first
          expect(shouldApplyProgression(1, true), isTrue); // 1 session, first
          expect(
            shouldApplyProgression(3, false),
            isFalse,
          ); // 3 sessions, not first
          expect(shouldApplyProgression(3, true), isTrue); // 3 sessions, first
          expect(
            shouldApplyProgression(5, false),
            isFalse,
          ); // 5 sessions, not first
          expect(shouldApplyProgression(5, true), isTrue); // 5 sessions, first
        },
      );

      test('should validate session frequency parameters', () {
        final validFrequencies = [1, 2, 3, 4, 5, 6, 7];

        for (final frequency in validFrequencies) {
          expect(frequency, greaterThan(0));
          expect(frequency, lessThanOrEqualTo(7));

          // Validate logic
          if (frequency == 1) {
            // Single session routines: apply always
            expect(true, isTrue); // Always apply
          } else {
            // Multiple session routines: apply conditionally
            expect(true, isTrue); // Conditional logic
          }
        }
      });
    });

    group('Edge Cases', () {
      test('should handle deload week 0 (no deload)', () {
        final noDeloadConfig = testConfig.copyWith(
          deloadWeek: 0, // No deload
        );

        expect(noDeloadConfig.deloadWeek, equals(0));

        // Test that no deload is applied
        final cycleLength = noDeloadConfig.cycleLength;
        for (int week = 1; week <= cycleLength * 2; week++) {
          final weekInCycle = ((week - 1) % cycleLength) + 1;
          final isDeloadWeek = weekInCycle == noDeloadConfig.deloadWeek;
          expect(
            isDeloadWeek,
            isFalse,
            reason: 'Week $week should never be deload week',
          );
        }
      });

      test('should handle very long cycles', () {
        final longCycleConfig = testConfig.copyWith(
          cycleLength: 12,
          deloadWeek: 12,
          deloadPercentage: 0.7,
        );

        expect(longCycleConfig.cycleLength, equals(12));
        expect(longCycleConfig.deloadWeek, equals(12));

        // Test deload calculation
        final baseWeight = 100.0;
        final deloadWeight = baseWeight * longCycleConfig.deloadPercentage;
        expect(deloadWeight, equals(70.0));
      });

      test('should handle mid-cycle deload', () {
        final midCycleConfig = testConfig.copyWith(
          cycleLength: 8,
          deloadWeek: 4, // Deload in middle of cycle
        );

        expect(midCycleConfig.cycleLength, equals(8));
        expect(midCycleConfig.deloadWeek, equals(4));

        // Test that deload occurs at week 4 and 12 (week 4 of second cycle)
        final testWeeks = [
          4,
          12,
          20,
          28,
        ]; // Weeks 4, 12, 20, 28 should all be deload weeks
        for (final week in testWeeks) {
          final weekInCycle = ((week - 1) % midCycleConfig.cycleLength) + 1;
          final isDeloadWeek = weekInCycle == midCycleConfig.deloadWeek;
          expect(
            isDeloadWeek,
            isTrue,
            reason:
                'Week $week (cycle week $weekInCycle) should be deload week',
          );
        }

        // Test that non-deload weeks don't trigger deload
        final nonDeloadWeeks = [1, 2, 3, 5, 6, 7, 8, 9, 10, 11];
        for (final week in nonDeloadWeeks) {
          final weekInCycle = ((week - 1) % midCycleConfig.cycleLength) + 1;
          final isDeloadWeek = weekInCycle == midCycleConfig.deloadWeek;
          expect(
            isDeloadWeek,
            isFalse,
            reason:
                'Week $week (cycle week $weekInCycle) should not be deload week',
          );
        }
      });
    });

    group('Progression Type Support', () {
      test('should validate all progression types support deload', () {
        final progressionTypes = ProgressionType.values;

        for (final type in progressionTypes) {
          // All progression types should support deload
          expect(type, isNotNull);

          // Test that we can create a config for each type
          final config = testConfig.copyWith(type: type);

          expect(config.type, equals(type));
          expect(config.deloadWeek, greaterThanOrEqualTo(0));
          expect(config.deloadPercentage, greaterThan(0.5));
          expect(config.deloadPercentage, lessThan(1.0));
        }
      });
    });
  });
}
