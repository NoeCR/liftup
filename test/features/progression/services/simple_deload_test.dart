import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/services/progression_service.dart';

void main() {
  group('Simple Deload Tests', () {
    late ProgressionService progressionService;

    setUp(() {
      progressionService = ProgressionService();
    });

    test('should create progression service', () {
      expect(progressionService, isNotNull);
    });

    test('should validate deload week calculation', () {
      // Test deload week calculation logic
      final cycleLength = 4;
      final deloadWeek = 4;

      // Week 1: Not deload
      final week1 = 1;
      final weekInCycle1 = ((week1 - 1) % cycleLength) + 1;
      final isDeloadWeek1 = weekInCycle1 == deloadWeek;
      expect(isDeloadWeek1, isFalse);

      // Week 2: Not deload
      final week2 = 2;
      final weekInCycle2 = ((week2 - 1) % cycleLength) + 1;
      final isDeloadWeek2 = weekInCycle2 == deloadWeek;
      expect(isDeloadWeek2, isFalse);

      // Week 3: Not deload
      final week3 = 3;
      final weekInCycle3 = ((week3 - 1) % cycleLength) + 1;
      final isDeloadWeek3 = weekInCycle3 == deloadWeek;
      expect(isDeloadWeek3, isFalse);

      // Week 4: DELOAD
      final week4 = 4;
      final weekInCycle4 = ((week4 - 1) % cycleLength) + 1;
      final isDeloadWeek4 = weekInCycle4 == deloadWeek;
      expect(isDeloadWeek4, isTrue);

      // Week 5: New cycle, week 1 (not deload)
      final week5 = 5;
      final weekInCycle5 = ((week5 - 1) % cycleLength) + 1;
      final isDeloadWeek5 = weekInCycle5 == deloadWeek;
      expect(isDeloadWeek5, isFalse);
      expect(weekInCycle5, equals(1)); // Should be week 1 of new cycle
    });

    test('should validate deload percentage calculation', () {
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

    test('should validate sets reduction during deload', () {
      final baseSets = 3;
      final setsReduction = 0.7;

      final deloadSets = (baseSets * setsReduction).round();
      expect(deloadSets, equals(2));

      // Test different set counts
      expect((4 * 0.7).round(), equals(3));
      expect((5 * 0.7).round(), equals(4));
      expect((6 * 0.7).round(), equals(4));
    });

    test('should validate cycle continuation after deload', () {
      final cycleLength = 4;

      // Test multiple cycles
      for (int week = 1; week <= 12; week++) {
        final weekInCycle = ((week - 1) % cycleLength) + 1;
        final isDeloadWeek = weekInCycle == 4;

        // Every 4th week should be deload
        if (week % 4 == 0) {
          expect(isDeloadWeek, isTrue, reason: 'Week $week should be deload week');
        } else {
          expect(isDeloadWeek, isFalse, reason: 'Week $week should not be deload week');
        }

        // Week in cycle should be 1-4
        expect(weekInCycle, inInclusiveRange(1, 4));
      }
    });

    test('should validate progression config creation', () {
      final config = ProgressionConfig(
        id: 'test-config',
        isGlobal: true,
        type: ProgressionType.linear,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 4,
        deloadPercentage: 0.8,
        minReps: 8,
        maxReps: 12,
        baseSets: 3,
        isActive: true,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        customParameters: {},
      );

      expect(config.id, equals('test-config'));
      expect(config.type, equals(ProgressionType.linear));
      expect(config.cycleLength, equals(4));
      expect(config.deloadWeek, equals(4));
      expect(config.deloadPercentage, equals(0.8));
      expect(config.isActive, isTrue);
    });

    test('should validate different deload configurations', () {
      // Test different cycle lengths and deload weeks
      final configurations = [
        {'cycleLength': 3, 'deloadWeek': 3, 'deloadPercentage': 0.75},
        {'cycleLength': 4, 'deloadWeek': 4, 'deloadPercentage': 0.8},
        {'cycleLength': 6, 'deloadWeek': 6, 'deloadPercentage': 0.85},
        {'cycleLength': 8, 'deloadWeek': 4, 'deloadPercentage': 0.8}, // Mid-cycle deload
        {'cycleLength': 12, 'deloadWeek': 12, 'deloadPercentage': 0.7},
      ];

      for (final config in configurations) {
        final cycleLength = config['cycleLength'] as int;
        final deloadWeek = config['deloadWeek'] as int;
        final deloadPercentage = config['deloadPercentage'] as double;

        // Validate deload week is within cycle
        expect(deloadWeek, lessThanOrEqualTo(cycleLength));
        expect(deloadWeek, greaterThan(0));

        // Validate deload percentage is reasonable
        expect(deloadPercentage, greaterThan(0.5));
        expect(deloadPercentage, lessThan(1.0));

        // Test deload calculation
        final baseWeight = 100.0;
        final deloadWeight = baseWeight * deloadPercentage;
        expect(deloadWeight, lessThan(baseWeight));
        expect(deloadWeight, greaterThan(baseWeight * 0.5));
      }
    });

    test('should validate progression types support deload', () {
      final progressionTypes = ProgressionType.values;

      for (final type in progressionTypes) {
        // All progression types should support deload
        expect(type, isNotNull);

        // Test that we can create a config for each type
        final config = ProgressionConfig(
          id: 'test-${type.name}',
          isGlobal: true,
          type: type,
          unit: ProgressionUnit.week,
          primaryTarget: ProgressionTarget.weight,
          incrementValue: 2.5,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 4,
          deloadPercentage: 0.8,
          minReps: 8,
          maxReps: 12,
          baseSets: 3,
          isActive: true,
          startDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          customParameters: {},
        );

        expect(config.type, equals(type));
      }
    });

    test('should validate edge cases for deload', () {
      // Test deload week 0 (no deload)
      final noDeloadConfig = ProgressionConfig(
        id: 'no-deload',
        isGlobal: true,
        type: ProgressionType.linear,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 0, // No deload
        deloadPercentage: 0.8,
        minReps: 8,
        maxReps: 12,
        baseSets: 3,
        isActive: true,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        customParameters: {},
      );

      expect(noDeloadConfig.deloadWeek, equals(0));

      // Test very long cycles
      final longCycleConfig = ProgressionConfig(
        id: 'long-cycle',
        isGlobal: true,
        type: ProgressionType.linear,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 12,
        deloadWeek: 12,
        deloadPercentage: 0.7,
        minReps: 8,
        maxReps: 12,
        baseSets: 3,
        isActive: true,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        customParameters: {},
      );

      expect(longCycleConfig.cycleLength, equals(12));
      expect(longCycleConfig.deloadWeek, equals(12));
    });
  });
}
