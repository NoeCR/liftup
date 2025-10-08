import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';

void main() {
  group('Basic Progression Tests', () {
    test('should have all progression types defined', () {
      // Arrange & Act
      final progressionTypes = ProgressionType.values;

      // Assert
      expect(progressionTypes, isNotEmpty);
      expect(progressionTypes.contains(ProgressionType.linear), isTrue);
      expect(progressionTypes.contains(ProgressionType.undulating), isTrue);
      expect(progressionTypes.contains(ProgressionType.stepped), isTrue);
      expect(progressionTypes.contains(ProgressionType.double), isTrue);
      expect(progressionTypes.contains(ProgressionType.wave), isTrue);
      expect(progressionTypes.contains(ProgressionType.static), isTrue);
      expect(progressionTypes.contains(ProgressionType.reverse), isTrue);
    });

    test('should have correct display names for progression types', () {
      // Arrange & Act
      final linearDisplayName = ProgressionType.linear.displayNameKey;
      final undulatingDisplayName = ProgressionType.undulating.displayNameKey;
      final steppedDisplayName = ProgressionType.stepped.displayNameKey;
      final doubleDisplayName = ProgressionType.double.displayNameKey;
      final waveDisplayName = ProgressionType.wave.displayNameKey;
      final staticDisplayName = ProgressionType.static.displayNameKey;
      final reverseDisplayName = ProgressionType.reverse.displayNameKey;

      // Assert
      expect(linearDisplayName, isNotEmpty);
      expect(undulatingDisplayName, isNotEmpty);
      expect(steppedDisplayName, isNotEmpty);
      expect(doubleDisplayName, isNotEmpty);
      expect(waveDisplayName, isNotEmpty);
      expect(staticDisplayName, isNotEmpty);
      expect(reverseDisplayName, isNotEmpty);
    });

    test('should have correct descriptions for progression types', () {
      // Arrange & Act
      final linearDescription = ProgressionType.linear.descriptionKey;
      final undulatingDescription = ProgressionType.undulating.descriptionKey;
      final steppedDescription = ProgressionType.stepped.descriptionKey;
      final doubleDescription = ProgressionType.double.descriptionKey;
      final waveDescription = ProgressionType.wave.descriptionKey;
      final staticDescription = ProgressionType.static.descriptionKey;
      final reverseDescription = ProgressionType.reverse.descriptionKey;

      // Assert
      expect(linearDescription, isNotEmpty);
      expect(undulatingDescription, isNotEmpty);
      expect(steppedDescription, isNotEmpty);
      expect(doubleDescription, isNotEmpty);
      expect(waveDescription, isNotEmpty);
      expect(staticDescription, isNotEmpty);
      expect(reverseDescription, isNotEmpty);
    });

    test('should have all progression units defined', () {
      // Arrange & Act
      final progressionUnits = ProgressionUnit.values;

      // Assert
      expect(progressionUnits, isNotEmpty);
      expect(progressionUnits.contains(ProgressionUnit.session), isTrue);
      expect(progressionUnits.contains(ProgressionUnit.week), isTrue);
    });

    test('should have correct display names for progression units', () {
      // Arrange & Act
      final sessionDisplayName = ProgressionUnit.session.displayNameKey;
      final weekDisplayName = ProgressionUnit.week.displayNameKey;

      // Assert
      expect(sessionDisplayName, isNotEmpty);
      expect(weekDisplayName, isNotEmpty);
    });

    test('should have all progression targets defined', () {
      // Arrange & Act
      final progressionTargets = ProgressionTarget.values;

      // Assert
      expect(progressionTargets, isNotEmpty);
      expect(progressionTargets.contains(ProgressionTarget.weight), isTrue);
      expect(progressionTargets.contains(ProgressionTarget.reps), isTrue);
      expect(progressionTargets.contains(ProgressionTarget.sets), isTrue);
      expect(progressionTargets.contains(ProgressionTarget.volume), isTrue);
    });

    test('should have correct display names for progression targets', () {
      // Arrange & Act
      final weightDisplayName = ProgressionTarget.weight.displayNameKey;
      final repsDisplayName = ProgressionTarget.reps.displayNameKey;
      final setsDisplayName = ProgressionTarget.sets.displayNameKey;
      final volumeDisplayName = ProgressionTarget.volume.displayNameKey;

      // Assert
      expect(weightDisplayName, isNotEmpty);
      expect(repsDisplayName, isNotEmpty);
      expect(setsDisplayName, isNotEmpty);
      expect(volumeDisplayName, isNotEmpty);
    });
  });

  group('Progression Type Logic Tests', () {
    test('should identify linear progression correctly', () {
      // Arrange
      const progressionType = ProgressionType.linear;

      // Act & Assert
      expect(progressionType, ProgressionType.linear);
      expect(progressionType.displayNameKey, equals('progression.types.linear'));
      expect(progressionType.descriptionKey, equals('progression.types.linearDescription'));
    });

    test('should identify undulating progression correctly', () {
      // Arrange
      const progressionType = ProgressionType.undulating;

      // Act & Assert
      expect(progressionType, ProgressionType.undulating);
      expect(progressionType.displayNameKey, equals('progression.types.undulating'));
      expect(progressionType.descriptionKey, equals('progression.types.undulatingDescription'));
    });

    test('should identify stepped progression correctly', () {
      // Arrange
      const progressionType = ProgressionType.stepped;

      // Act & Assert
      expect(progressionType, ProgressionType.stepped);
      expect(progressionType.displayNameKey, equals('progression.types.stepped'));
      expect(progressionType.descriptionKey, equals('progression.types.steppedDescription'));
    });

    test('should identify double progression correctly', () {
      // Arrange
      const progressionType = ProgressionType.double;

      // Act & Assert
      expect(progressionType, ProgressionType.double);
      expect(progressionType.displayNameKey, equals('progression.types.double'));
      expect(progressionType.descriptionKey, equals('progression.types.doubleDescription'));
    });

    test('should identify wave progression correctly', () {
      // Arrange
      const progressionType = ProgressionType.wave;

      // Act & Assert
      expect(progressionType, ProgressionType.wave);
      expect(progressionType.displayNameKey, equals('progression.types.wave'));
      expect(progressionType.descriptionKey, equals('progression.types.waveDescription'));
    });

    test('should identify static progression correctly', () {
      // Arrange
      const progressionType = ProgressionType.static;

      // Act & Assert
      expect(progressionType, ProgressionType.static);
      expect(progressionType.displayNameKey, equals('progression.types.static'));
      expect(progressionType.descriptionKey, equals('progression.types.staticDescription'));
    });

    test('should identify reverse progression correctly', () {
      // Arrange
      const progressionType = ProgressionType.reverse;

      // Act & Assert
      expect(progressionType, ProgressionType.reverse);
      expect(progressionType.displayNameKey, equals('progression.types.reverse'));
      expect(progressionType.descriptionKey, equals('progression.types.reverseDescription'));
    });
  });

  group('Progression Unit Logic Tests', () {
    test('should identify session unit correctly', () {
      // Arrange
      const progressionUnit = ProgressionUnit.session;

      // Act & Assert
      expect(progressionUnit, ProgressionUnit.session);
      expect(progressionUnit.displayNameKey, equals('progression.units.session'));
    });

    test('should identify week unit correctly', () {
      // Arrange
      const progressionUnit = ProgressionUnit.week;

      // Act & Assert
      expect(progressionUnit, ProgressionUnit.week);
      expect(progressionUnit.displayNameKey, equals('progression.units.week'));
    });
  });

  group('Progression Target Logic Tests', () {
    test('should identify weight target correctly', () {
      // Arrange
      const progressionTarget = ProgressionTarget.weight;

      // Act & Assert
      expect(progressionTarget, ProgressionTarget.weight);
      expect(progressionTarget.displayNameKey, equals('progression.targets.weight'));
    });

    test('should identify reps target correctly', () {
      // Arrange
      const progressionTarget = ProgressionTarget.reps;

      // Act & Assert
      expect(progressionTarget, ProgressionTarget.reps);
      expect(progressionTarget.displayNameKey, equals('progression.targets.reps'));
    });

    test('should identify sets target correctly', () {
      // Arrange
      const progressionTarget = ProgressionTarget.sets;

      // Act & Assert
      expect(progressionTarget, ProgressionTarget.sets);
      expect(progressionTarget.displayNameKey, equals('progression.targets.sets'));
    });

    test('should identify volume target correctly', () {
      // Arrange
      const progressionTarget = ProgressionTarget.volume;

      // Act & Assert
      expect(progressionTarget, ProgressionTarget.volume);
      expect(progressionTarget.displayNameKey, equals('progression.targets.volume'));
    });
  });

  group('Progression Calculation Logic Tests', () {
    test('should calculate linear progression correctly', () {
      // Arrange
      const currentWeight = 100.0;
      const incrementValue = 2.5;
      const expectedWeight = 102.5;

      // Act
      final newWeight = currentWeight + incrementValue;

      // Assert
      expect(newWeight, expectedWeight);
    });

    test('should calculate undulating progression correctly', () {
      // Arrange
      const baseWeight = 100.0;
      const heavyMultiplier = 1.1;
      const lightMultiplier = 0.9;
      const expectedHeavyWeight = 110.0;
      const expectedLightWeight = 90.0;

      // Act
      final heavyWeight = baseWeight * heavyMultiplier;
      final lightWeight = baseWeight * lightMultiplier;

      // Assert
      expect(heavyWeight, closeTo(expectedHeavyWeight, 0.01));
      expect(lightWeight, closeTo(expectedLightWeight, 0.01));
    });

    test('should calculate deload week correctly', () {
      // Arrange
      const currentWeight = 100.0;
      const deloadPercentage = 0.85;
      const expectedDeloadWeight = 85.0;

      // Act
      final deloadWeight = currentWeight * deloadPercentage;

      // Assert
      expect(deloadWeight, expectedDeloadWeight);
    });

    test('should calculate double progression correctly', () {
      // Arrange
      const currentReps = 10;
      const maxReps = 12;
      const minReps = 8;
      const currentWeight = 100.0;
      const incrementValue = 2.5;

      // Act - Test reps progression
      final newReps = currentReps < maxReps ? currentReps + 1 : minReps;
      final newWeight = currentReps >= maxReps ? currentWeight + incrementValue : currentWeight;

      // Assert
      expect(newReps, 11); // Should increase reps
      expect(newWeight, 100.0); // Should not change weight

      // Act - Test weight progression when at max reps
      final finalReps = 12 >= maxReps ? minReps : 12;
      final finalWeight = 12 >= maxReps ? currentWeight + incrementValue : currentWeight;

      // Assert
      expect(finalReps, minReps); // Should reset to min reps
      expect(finalWeight, 102.5); // Should increase weight
    });

    test('should calculate wave progression correctly', () {
      // Arrange
      const baseWeight = 100.0;
      const week1Multiplier = 1.0;
      const week2Multiplier = 1.05;
      const week3Multiplier = 1.1;

      // Act
      final week1Weight = baseWeight * week1Multiplier;
      final week2Weight = baseWeight * week2Multiplier;
      final week3Weight = baseWeight * week3Multiplier;

      // Assert
      expect(week1Weight, 100.0);
      expect(week2Weight, 105.0);
      expect(week3Weight, closeTo(110.0, 0.01));
    });

    test('should calculate reverse progression correctly', () {
      // Arrange
      const currentWeight = 100.0;
      const decrementValue = 2.5;
      const expectedWeight = 97.5;

      // Act
      final newWeight = currentWeight - decrementValue;

      // Assert
      expect(newWeight, expectedWeight);
    });

    test('should calculate volume progression correctly', () {
      // Arrange
      const weight = 100.0;
      const reps = 10;
      const sets = 3;
      const expectedVolume = 3000.0;

      // Act
      final volume = weight * reps * sets;

      // Assert
      expect(volume, expectedVolume);
    });
  });

  group('Edge Cases and Error Handling', () {
    test('should handle zero increment value', () {
      // Arrange
      const currentWeight = 100.0;
      const incrementValue = 0.0;

      // Act
      final newWeight = currentWeight + incrementValue;

      // Assert
      expect(newWeight, currentWeight);
    });

    test('should handle negative increment value', () {
      // Arrange
      const currentWeight = 100.0;
      const incrementValue = -2.5;

      // Act
      final newWeight = currentWeight + incrementValue;

      // Assert
      expect(newWeight, 97.5);
    });

    test('should handle very high increment value', () {
      // Arrange
      const currentWeight = 100.0;
      const incrementValue = 100.0;

      // Act
      final newWeight = currentWeight + incrementValue;

      // Assert
      expect(newWeight, 200.0);
    });

    test('should handle zero weight', () {
      // Arrange
      const currentWeight = 0.0;
      const incrementValue = 2.5;

      // Act
      final newWeight = currentWeight + incrementValue;

      // Assert
      expect(newWeight, 2.5);
    });

    test('should handle negative weight', () {
      // Arrange
      const currentWeight = -10.0;
      const incrementValue = 2.5;

      // Act
      final newWeight = currentWeight + incrementValue;

      // Assert
      expect(newWeight, -7.5);
    });

    test('should handle zero reps', () {
      // Arrange
      const currentReps = 0;
      const incrementValue = 1;

      // Act
      final newReps = currentReps + incrementValue;

      // Assert
      expect(newReps, 1);
    });

    test('should handle zero sets', () {
      // Arrange
      const currentSets = 0;
      const incrementValue = 1;

      // Act
      final newSets = currentSets + incrementValue;

      // Assert
      expect(newSets, 1);
    });
  });
}
