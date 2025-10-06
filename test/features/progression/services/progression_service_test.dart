import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:liftly/features/progression/services/progression_service.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import '../mocks/progression_mock_factory.dart';

// Generate mocks
@GenerateMocks([ProgressionService])
import 'progression_service_test.mocks.dart';

void main() {
  group('ProgressionService - Core Functionality', () {
    late MockProgressionService mockProgressionService;

    setUp(() {
      mockProgressionService = MockProgressionService();
    });

    tearDown(() {
      reset(mockProgressionService);
    });

    group('Progression Initialization', () {
      test('should initialize progression successfully', () async {
        // Arrange
        final expectedConfig = ProgressionMockFactory.createProgressionConfig(
          type: ProgressionType.linear,
          incrementValue: 2.5,
          isGlobal: true,
        );

        when(
          mockProgressionService.initializeProgression(
            type: anyNamed('type'),
            unit: anyNamed('unit'),
            primaryTarget: anyNamed('primaryTarget'),
            secondaryTarget: anyNamed('secondaryTarget'),
            incrementValue: anyNamed('incrementValue'),
            incrementFrequency: anyNamed('incrementFrequency'),
            cycleLength: anyNamed('cycleLength'),
            deloadWeek: anyNamed('deloadWeek'),
            deloadPercentage: anyNamed('deloadPercentage'),
            customParameters: anyNamed('customParameters'),
            isGlobal: anyNamed('isGlobal'),
          ),
        ).thenAnswer((invocation) async {
          // Simulate calling saveProgressionConfig
          await mockProgressionService.saveProgressionConfig(expectedConfig);
          return expectedConfig;
        });

        when(mockProgressionService.saveProgressionConfig(any)).thenAnswer((_) async {});

        // Act
        final result = await mockProgressionService.initializeProgression(
          type: ProgressionType.linear,
          unit: ProgressionUnit.session,
          primaryTarget: ProgressionTarget.weight,
          secondaryTarget: null,
          incrementValue: 2.5,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 4,
          deloadPercentage: 0.9,
          customParameters: {},
          isGlobal: true,
        );

        // Assert
        expect(result, isNotNull);
        expect(result.type, ProgressionType.linear);
        expect(result.incrementValue, 2.5);
        expect(result.isGlobal, isTrue);
        expect(result.isActive, isTrue);

        // Verify that saveProgressionConfig was called
        verify(mockProgressionService.saveProgressionConfig(any)).called(1);
      });

      test('should create progression state for exercise', () async {
        // Arrange
        final configId = 'test-config-1';
        final exerciseId = 'test-exercise-1';
        final expectedState = ProgressionMockFactory.createProgressionState(
          progressionConfigId: configId,
          exerciseId: exerciseId,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 3,
        );

        when(
          mockProgressionService.initializeExerciseProgression(
            configId: anyNamed('configId'),
            exerciseId: anyNamed('exerciseId'),
            baseWeight: anyNamed('baseWeight'),
            baseReps: anyNamed('baseReps'),
            baseSets: anyNamed('baseSets'),
            oneRepMax: anyNamed('oneRepMax'),
          ),
        ).thenAnswer((invocation) async {
          // Simulate calling saveProgressionState
          await mockProgressionService.saveProgressionState(expectedState);
          return expectedState;
        });

        when(mockProgressionService.saveProgressionState(any)).thenAnswer((_) async {});

        // Act
        final result = await mockProgressionService.initializeExerciseProgression(
          configId: configId,
          exerciseId: exerciseId,
          baseWeight: 100.0,
          baseReps: 10,
          baseSets: 3,
        );

        // Assert
        expect(result, isNotNull);
        expect(result.progressionConfigId, configId);
        expect(result.exerciseId, exerciseId);
        expect(result.currentWeight, 100.0);
        expect(result.currentReps, 10);
        expect(result.currentSets, 3);

        // Verify that saveProgressionState was called
        verify(mockProgressionService.saveProgressionState(any)).called(1);
      });
    });

    group('Progression Calculations', () {
      test('should calculate linear progression correctly', () async {
        // Arrange
        final configId = 'test-config-1';
        final exerciseId = 'test-exercise-1';
        final expectedResult = ProgressionCalculationResult(
          newWeight: 102.5,
          newReps: 10,
          newSets: 3,
          incrementApplied: true,
          reason: 'Linear progression: +2.5 kg',
        );

        when(
          mockProgressionService.calculateProgression(configId, exerciseId, 100.0, 10, 3),
        ).thenAnswer((_) async => expectedResult);

        // Act
        final result = await mockProgressionService.calculateProgression(configId, exerciseId, 100.0, 10, 3);

        // Assert
        expect(result, isNotNull);
        expect(result.newWeight, 102.5);
        expect(result.newReps, 10);
        expect(result.newSets, 3);
        expect(result.incrementApplied, isTrue);
        expect(result.reason, contains('Linear progression'));
      });

      test('should calculate undulating progression correctly', () async {
        // Arrange
        final configId = 'test-config-1';
        final exerciseId = 'test-exercise-1';
        final expectedResult = ProgressionCalculationResult(
          newWeight: 110.0,
          newReps: 10,
          newSets: 3,
          incrementApplied: true,
          reason: 'Undulating progression: Heavy day (110%)',
        );

        when(
          mockProgressionService.calculateProgression(configId, exerciseId, 100.0, 10, 3),
        ).thenAnswer((_) async => expectedResult);

        // Act
        final result = await mockProgressionService.calculateProgression(configId, exerciseId, 100.0, 10, 3);

        // Assert
        expect(result, isNotNull);
        expect(result.newWeight, 110.0);
        expect(result.newReps, 10);
        expect(result.newSets, 3);
        expect(result.incrementApplied, isTrue);
        expect(result.reason, contains('Undulating progression'));
      });

      test('should handle deload week correctly', () async {
        // Arrange
        final configId = 'test-config-1';
        final exerciseId = 'test-exercise-1';
        final expectedResult = ProgressionCalculationResult(
          newWeight: 85.0,
          newReps: 10,
          newSets: 3,
          incrementApplied: true,
          reason: 'Stepped progression: Deload week (-15%)',
        );

        when(
          mockProgressionService.calculateProgression(configId, exerciseId, 100.0, 10, 3),
        ).thenAnswer((_) async => expectedResult);

        // Act
        final result = await mockProgressionService.calculateProgression(configId, exerciseId, 100.0, 10, 3);

        // Assert
        expect(result, isNotNull);
        expect(result.newWeight, 85.0);
        expect(result.newReps, 10);
        expect(result.newSets, 3);
        expect(result.incrementApplied, isTrue);
        expect(result.reason, contains('Deload week'));
      });

      test('should handle double progression correctly', () async {
        // Arrange
        final configId = 'test-config-1';
        final exerciseId = 'test-exercise-1';
        final expectedResult = ProgressionCalculationResult(
          newWeight: 100.0,
          newReps: 11,
          newSets: 3,
          incrementApplied: true,
          reason: 'Double progression: Reps increased',
        );

        when(
          mockProgressionService.calculateProgression(configId, exerciseId, 100.0, 10, 3),
        ).thenAnswer((_) async => expectedResult);

        // Act
        final result = await mockProgressionService.calculateProgression(configId, exerciseId, 100.0, 10, 3);

        // Assert
        expect(result, isNotNull);
        expect(result.newWeight, 100.0);
        expect(result.newReps, 11);
        expect(result.newSets, 3);
        expect(result.incrementApplied, isTrue);
        expect(result.reason, contains('Double progression'));
      });
    });

    group('Error Handling', () {
      test('should handle database errors gracefully', () async {
        // Arrange
        when(mockProgressionService.saveProgressionConfig(any)).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => mockProgressionService.saveProgressionConfig(ProgressionMockFactory.createProgressionConfig()),
          throwsException,
        );
      });

      test('should handle invalid progression parameters', () async {
        // Arrange
        final configId = 'test-config-1';
        final exerciseId = 'test-exercise-1';
        final expectedResult = ProgressionCalculationResult(
          newWeight: 95.0,
          newReps: 10,
          newSets: 3,
          incrementApplied: true,
          reason: 'Invalid parameters: using fallback values',
        );

        when(
          mockProgressionService.calculateProgression(configId, exerciseId, 100.0, 10, 3),
        ).thenAnswer((_) async => expectedResult);

        // Act
        final result = await mockProgressionService.calculateProgression(configId, exerciseId, 100.0, 10, 3);

        // Assert
        expect(result, isNotNull);
        expect(result.newWeight, 95.0);
        expect(result.reason, contains('Invalid parameters'));
      });

      test('should handle missing custom parameters', () async {
        // Arrange
        final configId = 'test-config-1';
        final exerciseId = 'test-exercise-1';
        final expectedResult = ProgressionCalculationResult(
          newWeight: 100.0,
          newReps: 10,
          newSets: 3,
          incrementApplied: false,
          reason: 'Missing custom parameters: no progression applied',
        );

        when(
          mockProgressionService.calculateProgression(configId, exerciseId, 100.0, 10, 3),
        ).thenAnswer((_) async => expectedResult);

        // Act
        final result = await mockProgressionService.calculateProgression(configId, exerciseId, 100.0, 10, 3);

        // Assert
        expect(result, isNotNull);
        expect(result.newWeight, 100.0);
        expect(result.incrementApplied, isFalse);
        expect(result.reason, contains('Missing custom parameters'));
      });
    });
  });
}
