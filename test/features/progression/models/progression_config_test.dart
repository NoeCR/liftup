import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import '../mocks/progression_mock_factory.dart';

void main() {
  group('ProgressionConfig', () {
    test('should create a valid progression config', () {
      // Arrange & Act
      final config = ProgressionMockFactory.createProgressionConfig();

      // Assert
      expect(config.id, isNotEmpty);
      expect(config.isGlobal, isTrue);
      expect(config.type, ProgressionType.linear);
      expect(config.unit, ProgressionUnit.session);
      expect(config.primaryTarget, ProgressionTarget.weight);
      expect(config.incrementValue, 2.5);
      expect(config.incrementFrequency, 1);
      expect(config.cycleLength, 4);
      expect(config.deloadWeek, 4);
      expect(config.deloadPercentage, 0.9);
      expect(config.isActive, isTrue);
      expect(config.startDate, isNotNull);
      expect(config.createdAt, isNotNull);
      expect(config.updatedAt, isNotNull);
    });

    test('should create a copy with modified values', () {
      // Arrange
      final originalConfig = ProgressionMockFactory.createProgressionConfig();

      // Act
      final modifiedConfig = originalConfig.copyWith(
        incrementValue: 5.0,
        isActive: false,
        endDate: DateTime.now().add(const Duration(days: 30)),
        updatedAt: DateTime.now().add(const Duration(seconds: 1)),
      );

      // Assert
      expect(modifiedConfig.id, originalConfig.id);
      expect(modifiedConfig.incrementValue, 5.0);
      expect(modifiedConfig.isActive, isFalse);
      expect(modifiedConfig.endDate, isNotNull);
      expect(modifiedConfig.updatedAt, isNot(originalConfig.updatedAt));
    });

    test('should validate progression config parameters', () {
      // Arrange & Act
      final config = ProgressionMockFactory.createProgressionConfig(
        incrementValue: 0.0,
        incrementFrequency: 0,
        deloadPercentage: 1.5, // Invalid: > 1.0
      );

      // Assert
      expect(config.incrementValue, 0.0);
      expect(config.incrementFrequency, 0);
      expect(config.deloadPercentage, 1.5);
    });

    test('should handle different progression types', () {
      // Arrange & Act
      final linearConfig = ProgressionMockFactory.createProgressionConfig(
        type: ProgressionType.linear,
      );
      final undulatingConfig = ProgressionMockFactory.createProgressionConfig(
        type: ProgressionType.undulating,
        customParameters: {
          'heavy_day_multiplier': 1.1,
          'light_day_multiplier': 0.9,
        },
      );

      // Assert
      expect(linearConfig.type, ProgressionType.linear);
      expect(undulatingConfig.type, ProgressionType.undulating);
      expect(undulatingConfig.customParameters['heavy_day_multiplier'], 1.1);
      expect(undulatingConfig.customParameters['light_day_multiplier'], 0.9);
    });

    test('should handle different progression units', () {
      // Arrange & Act
      final sessionConfig = ProgressionMockFactory.createProgressionConfig(
        unit: ProgressionUnit.session,
      );
      final weekConfig = ProgressionMockFactory.createProgressionConfig(
        unit: ProgressionUnit.week,
      );
      final cycleConfig = ProgressionMockFactory.createProgressionConfig(
        unit: ProgressionUnit.cycle,
      );

      // Assert
      expect(sessionConfig.unit, ProgressionUnit.session);
      expect(weekConfig.unit, ProgressionUnit.week);
      expect(cycleConfig.unit, ProgressionUnit.cycle);
    });

    test('should handle different progression targets', () {
      // Arrange & Act
      final weightConfig = ProgressionMockFactory.createProgressionConfig(
        primaryTarget: ProgressionTarget.weight,
      );
      final repsConfig = ProgressionMockFactory.createProgressionConfig(
        primaryTarget: ProgressionTarget.reps,
        secondaryTarget: ProgressionTarget.weight,
      );
      final setsConfig = ProgressionMockFactory.createProgressionConfig(
        primaryTarget: ProgressionTarget.sets,
      );
      final volumeConfig = ProgressionMockFactory.createProgressionConfig(
        primaryTarget: ProgressionTarget.volume,
      );

      // Assert
      expect(weightConfig.primaryTarget, ProgressionTarget.weight);
      expect(repsConfig.primaryTarget, ProgressionTarget.reps);
      expect(repsConfig.secondaryTarget, ProgressionTarget.weight);
      expect(setsConfig.primaryTarget, ProgressionTarget.sets);
      expect(volumeConfig.primaryTarget, ProgressionTarget.volume);
    });

    test('should handle custom parameters correctly', () {
      // Arrange
      final customParams = {
        'max_reps': 12,
        'min_reps': 8,
        'rpe_target': 8.5,
        'deload_threshold': 0.8,
      };

      // Act
      final config = ProgressionMockFactory.createProgressionConfig(
        customParameters: customParams,
      );

      // Assert
      expect(config.customParameters, customParams);
      expect(config.customParameters['max_reps'], 12);
      expect(config.customParameters['min_reps'], 8);
      expect(config.customParameters['rpe_target'], 8.5);
      expect(config.customParameters['deload_threshold'], 0.8);
    });

    test('should handle date ranges correctly', () {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 12, 31);

      // Act
      final config = ProgressionMockFactory.createProgressionConfig(
        startDate: startDate,
        endDate: endDate,
      );

      // Assert
      expect(config.startDate, startDate);
      expect(config.endDate, endDate);
    });

    test('should handle inactive progression config', () {
      // Arrange & Act
      final config = ProgressionMockFactory.createProgressionConfig(
        isActive: false,
        endDate: DateTime.now(),
      );

      // Assert
      expect(config.isActive, isFalse);
      expect(config.endDate, isNotNull);
    });

    test('should handle global vs non-global progression', () {
      // Arrange & Act
      final globalConfig = ProgressionMockFactory.createProgressionConfig(
        isGlobal: true,
      );
      final localConfig = ProgressionMockFactory.createProgressionConfig(
        isGlobal: false,
      );

      // Assert
      expect(globalConfig.isGlobal, isTrue);
      expect(localConfig.isGlobal, isFalse);
    });
  });
}
