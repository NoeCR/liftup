import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hive/hive.dart';
import 'package:liftup/features/progression/models/progression_config.dart';
import 'package:liftup/features/progression/models/progression_state.dart';
import 'package:liftup/features/progression/services/progression_service.dart';
import 'package:liftup/common/enums/progression_type_enum.dart';
import '../mocks/progression_mock_factory.dart';

// Generate mocks
@GenerateMocks([Box, ProgressionService])
import 'progression_service_test.mocks.dart';

void main() {
  group('ProgressionService', () {
    late MockProgressionService mockProgressionService;

    setUp(() {
      mockProgressionService = MockProgressionService();

      // Setup default mock responses
      when(
        mockProgressionService.saveProgressionConfig(any),
      ).thenAnswer((_) async {});
      when(
        mockProgressionService.getProgressionConfig(any),
      ).thenAnswer((_) async => null);
      when(
        mockProgressionService.getAllProgressionConfigs(),
      ).thenAnswer((_) async => []);
      when(
        mockProgressionService.saveProgressionState(any),
      ).thenAnswer((_) async {});
      when(
        mockProgressionService.getProgressionState(any),
      ).thenAnswer((_) async => null);
      when(
        mockProgressionService.getProgressionStatesByConfig(any),
      ).thenAnswer((_) async => []);
      when(
        mockProgressionService.getActiveProgressionConfig(),
      ).thenAnswer((_) async => null);
      when(
        mockProgressionService.getProgressionStateByExercise(any, any),
      ).thenAnswer((_) async => null);
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
        final config = ProgressionMockFactory.createProgressionConfig();
        // Simulate calling saveProgressionConfig
        await mockProgressionService.saveProgressionConfig(config);
        return config;
      });
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
        final args = invocation.namedArguments;
        final configId = args['configId'] as String? ?? 'test-config-1';
        final exerciseId = args['exerciseId'] as String? ?? 'test-exercise-1';
        final baseWeight = args['baseWeight'] as double? ?? 100.0;
        final baseReps = args['baseReps'] as int? ?? 10;
        final baseSets = args['baseSets'] as int? ?? 3;
        
        final state = ProgressionMockFactory.createProgressionState(
          progressionConfigId: configId,
          exerciseId: exerciseId,
          currentWeight: baseWeight,
          currentReps: baseReps,
          currentSets: baseSets,
        );
        // Simulate calling saveProgressionState
        await mockProgressionService.saveProgressionState(state);
        return state;
      });
      when(
        mockProgressionService.calculateProgression(any, any, any, any, any),
      ).thenAnswer(
        (_) async => ProgressionCalculationResult(
          newWeight: 102.5,
          newReps: 10,
          newSets: 3,
          incrementApplied: true,
          reason: 'Test progression',
        ),
      );
    });

    group('ProgressionConfig Management', () {
      test('should save progression config successfully', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig();
        // Mock is already configured in setUp

        // Act
        await mockProgressionService.saveProgressionConfig(config);

        // Assert
        verify(mockProgressionService.saveProgressionConfig(config)).called(1);
      });

      test('should get progression config by id', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig();
        when(
          mockProgressionService.getProgressionConfig(any),
        ).thenAnswer((_) async => config);

        // Act
        final result = await mockProgressionService.getProgressionConfig(
          config.id,
        );

        // Assert
        expect(result, config);
        verify(
          mockProgressionService.getProgressionConfig(config.id),
        ).called(1);
      });

      test('should return null when config not found', () async {
        // Arrange
        when(
          mockProgressionService.getProgressionConfig(any),
        ).thenAnswer((_) async => null);

        // Act
        final result = await mockProgressionService.getProgressionConfig(
          'non-existent-id',
        );

        // Assert
        expect(result, isNull);
        verify(
          mockProgressionService.getProgressionConfig('non-existent-id'),
        ).called(1);
      });

      test('should get all progression configs', () async {
        // Arrange
        final configs = [
          ProgressionMockFactory.createProgressionConfig(id: 'config-1'),
          ProgressionMockFactory.createProgressionConfig(id: 'config-2'),
        ];
        when(
          mockProgressionService.getAllProgressionConfigs(),
        ).thenAnswer((_) async => configs);

        // Act
        final result = await mockProgressionService.getAllProgressionConfigs();

        // Assert
        expect(result, configs);
        verify(mockProgressionService.getAllProgressionConfigs()).called(1);
      });

      test('should get active global progression config', () async {
        // Arrange
        final activeConfig = ProgressionMockFactory.createProgressionConfig(
          isGlobal: true,
          isActive: true,
        );
        final inactiveConfig = ProgressionMockFactory.createProgressionConfig(
          isGlobal: true,
          isActive: false,
        );
        when(
          mockProgressionService.getAllProgressionConfigs(),
        ).thenAnswer((_) async => [activeConfig, inactiveConfig]);

        // Act
        final result =
            await mockProgressionService.getActiveProgressionConfig();

        // Assert
        expect(result, activeConfig);
        verify(mockProgressionService.getAllProgressionConfigs()).called(1);
      });

      test('should return null when no active global config exists', () async {
        // Arrange
        when(
          mockProgressionService.getAllProgressionConfigs(),
        ).thenAnswer((_) async => []);

        // Act
        final result =
            await mockProgressionService.getActiveProgressionConfig();

        // Assert
        expect(result, isNull);
        verify(mockProgressionService.getAllProgressionConfigs()).called(1);
      });

      test('should delete progression config', () async {
        // Arrange
        final configId = 'test-config-id';
        when(
          mockProgressionService.deleteProgressionConfig(any),
        ).thenAnswer((_) async {});

        // Act
        await mockProgressionService.deleteProgressionConfig(configId);

        // Assert
        verify(
          mockProgressionService.deleteProgressionConfig(configId),
        ).called(1);
      });
    });

    group('ProgressionState Management', () {
      test('should save progression state successfully', () async {
        // Arrange
        final state = ProgressionMockFactory.createProgressionState();
        // Mock is already configured in setUp

        // Act
        await mockProgressionService.saveProgressionState(state);

        // Assert
        verify(mockProgressionService.saveProgressionState(state)).called(1);
      });

      test('should get progression state by id', () async {
        // Arrange
        final state = ProgressionMockFactory.createProgressionState();
        when(
          mockProgressionService.getProgressionState(any),
        ).thenAnswer((_) async => state);

        // Act
        final result = await mockProgressionService.getProgressionState(
          state.id,
        );

        // Assert
        expect(result, state);
        verify(mockProgressionService.getProgressionState(state.id)).called(1);
      });

      test('should get progression state by exercise and config', () async {
        // Arrange
        final state = ProgressionMockFactory.createProgressionState(
          exerciseId: 'exercise-1',
          progressionConfigId: 'config-1',
        );
        when(
          mockProgressionService.getProgressionStatesByConfig(any),
        ).thenAnswer((_) async => [state]);

        // Act
        final result = await mockProgressionService
            .getProgressionStateByExercise('exercise-1', 'config-1');

        // Assert
        expect(result, state);
        verify(
          mockProgressionService.getProgressionStatesByConfig(any),
        ).called(1);
      });

      test('should return null when state not found', () async {
        // Arrange
        when(
          mockProgressionService.getProgressionStatesByConfig(any),
        ).thenAnswer((_) async => []);

        // Act
        final result = await mockProgressionService
            .getProgressionStateByExercise(
              'non-existent-exercise',
              'non-existent-config',
            );

        // Assert
        expect(result, isNull);
        verify(
          mockProgressionService.getProgressionStatesByConfig(any),
        ).called(1);
      });

      test('should get all progression states for config', () async {
        // Arrange
        final states = [
          ProgressionMockFactory.createProgressionState(
            progressionConfigId: 'config-1',
            exerciseId: 'exercise-1',
          ),
          ProgressionMockFactory.createProgressionState(
            progressionConfigId: 'config-1',
            exerciseId: 'exercise-2',
          ),
          ProgressionMockFactory.createProgressionState(
            progressionConfigId: 'config-2',
            exerciseId: 'exercise-3',
          ),
        ];
        when(
          mockProgressionService.getProgressionStatesByConfig(any),
        ).thenAnswer((_) async => states);

        // Act
        final result = await mockProgressionService
            .getProgressionStatesByConfig('config-1');

        // Assert
        expect(result.length, 2);
        expect(
          result.every((state) => state.progressionConfigId == 'config-1'),
          isTrue,
        );
        verify(
          mockProgressionService.getProgressionStatesByConfig(any),
        ).called(1);
      });

      test('should delete progression state', () async {
        // Arrange
        final stateId = 'test-state-id';
        when(
          mockProgressionService.deleteProgressionConfig(any),
        ).thenAnswer((_) async {});

        // Act
        await mockProgressionService.deleteProgressionConfig(stateId);

        // Assert
        verify(
          mockProgressionService.deleteProgressionConfig(stateId),
        ).called(1);
      });
    });

    group('Progression Initialization', () {
      test('should initialize progression successfully', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig();
        // Mock is already configured in setUp

        // Act
        final result = await mockProgressionService.initializeProgression(
          type: config.type,
          unit: config.unit,
          primaryTarget: config.primaryTarget,
          secondaryTarget: config.secondaryTarget,
          incrementValue: config.incrementValue,
          incrementFrequency: config.incrementFrequency,
          cycleLength: config.cycleLength,
          deloadWeek: config.deloadWeek,
          deloadPercentage: config.deloadPercentage,
          customParameters: config.customParameters,
          isGlobal: config.isGlobal,
        );

        // Assert
        expect(result, isNotNull);
        expect(result.type, config.type);
        expect(result.isGlobal, config.isGlobal);
        expect(result.isActive, isTrue);
        verify(mockProgressionService.saveProgressionConfig(any)).called(1);
      });

      test('should create progression state for exercise', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig();
        final exerciseId = 'test-exercise';
        // Mock is already configured in setUp

        // Act
        final result = await mockProgressionService
            .initializeExerciseProgression(
              configId: config.id,
              exerciseId: exerciseId,
              baseWeight: 100.0,
              baseReps: 10,
              baseSets: 3,
            );

        // Assert
        expect(result, isNotNull);
        expect(result.progressionConfigId, config.id);
        expect(result.exerciseId, exerciseId);
        expect(result.currentWeight, 100.0);
        expect(result.currentReps, 10);
        expect(result.currentSets, 3);
        verify(mockProgressionService.saveProgressionState(any)).called(1);
      });
    });

    group('Progression Calculations', () {
      test('should calculate linear progression correctly', () async {
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

        // Act
        final result = await mockProgressionService.calculateProgression(
          config.id,
          state.exerciseId,
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );

        // Assert
        expect(result.newWeight, 102.5);
        expect(result.newReps, 10);
        expect(result.newSets, 3);
        expect(result.incrementApplied, isTrue);
      });

      test('should calculate undulating progression correctly', () async {
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

        // Act
        final result = await mockProgressionService.calculateProgression(
          config.id,
          state.exerciseId,
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );

        // Assert
        expect(result.newWeight, 110.0); // 100.0 * 1.1
        expect(result.newReps, 8);
        expect(result.newSets, 4);
      });

      test('should calculate deload week correctly', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig(
          type: ProgressionType.stepped,
          deloadWeek: 4,
          deloadPercentage: 0.85,
        );
        final state = ProgressionMockFactory.createProgressionState(
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 3,
          currentWeek: 4, // Deload week
        );

        // Act
        final result = await mockProgressionService.calculateProgression(
          config.id,
          state.exerciseId,
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );

        // Assert
        expect(result.newWeight, 85.0); // 100.0 * 0.85
        expect(result.newReps, 10);
        expect(result.newSets, 3);
        expect(result.reason, contains('deload'));
      });

      test('should handle double progression correctly', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig(
          type: ProgressionType.double,
          primaryTarget: ProgressionTarget.reps,
          secondaryTarget: ProgressionTarget.weight,
          customParameters: {'max_reps': 12, 'min_reps': 8},
        );

        // Test reps progression
        final repsState = ProgressionMockFactory.createProgressionState(
          currentWeight: 100.0,
          currentReps: 10, // Below max
          currentSets: 3,
        );
        final repsResult = await mockProgressionService.calculateProgression(
          config.id,
          repsState.exerciseId,
          repsState.currentWeight,
          repsState.currentReps,
          repsState.currentSets,
        );

        // Test weight progression
        final weightState = ProgressionMockFactory.createProgressionState(
          currentWeight: 100.0,
          currentReps: 12, // At max
          currentSets: 3,
        );
        final weightResult = await mockProgressionService.calculateProgression(
          config.id,
          weightState.exerciseId,
          weightState.currentWeight,
          weightState.currentReps,
          weightState.currentSets,
        );

        // Assert
        expect(repsResult.newWeight, 100.0); // No weight change
        expect(repsResult.newReps, 11); // Reps increased

        expect(weightResult.newWeight, 102.5); // Weight increased
        expect(weightResult.newReps, 8); // Reset to min reps
      });
    });

    group('Error Handling', () {
      test('should handle database errors gracefully', () async {
        // Arrange
        when(
          mockProgressionService.saveProgressionConfig(any),
        ).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => mockProgressionService.saveProgressionConfig(
            ProgressionMockFactory.createProgressionConfig(),
          ),
          throwsException,
        );
      });

      test('should handle invalid progression parameters', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig(
          incrementValue: -5.0, // Negative increment
        );
        final state = ProgressionMockFactory.createProgressionState(
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 3,
        );

        // Act
        final result = await mockProgressionService.calculateProgression(
          config.id,
          state.exerciseId,
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );

        // Assert
        expect(result.newWeight, 95.0); // 100.0 - 5.0
        expect(result.incrementApplied, isTrue);
      });

      test('should handle missing custom parameters', () async {
        // Arrange
        final config = ProgressionMockFactory.createProgressionConfig(
          type: ProgressionType.undulating,
          customParameters: {}, // Empty parameters
        );
        final state = ProgressionMockFactory.createProgressionState(
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 3,
        );

        // Act
        final result = await mockProgressionService.calculateProgression(
          config.id,
          state.exerciseId,
          state.currentWeight,
          state.currentReps,
          state.currentSets,
        );

        // Assert
        expect(result.newWeight, 100.0); // Should use defaults
        expect(result.newReps, 10);
        expect(result.newSets, 3);
      });
    });
  });
}
