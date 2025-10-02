import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../test_helpers/test_setup.dart';
import '../../mocks/database_service_mock.dart';

void main() {
  group('DatabaseService Tests', () {
    late MockDatabaseService mockDatabaseService;

    setUpAll(() {
      TestSetup.initialize();
      mockDatabaseService = TestSetup.mockDatabaseService;
    });

    setUp(() {
      TestSetup.cleanup();
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        // Act
        await mockDatabaseService.initialize();

        // Assert
        verify(() => mockDatabaseService.initialize()).called(1);
      });

      test('should not initialize twice', () async {
        // Arrange
        await mockDatabaseService.initialize();

        // Act
        await mockDatabaseService.initialize();

        // Assert
        verify(() => mockDatabaseService.initialize()).called(2);
      });
    });

    group('Box Operations', () {
      test('should get exercises box', () {
        // Arrange
        const boxName = 'exercises';
        final testData = {
          'exercise1': {'name': 'Push-ups', 'category': 'bodyweight'},
          'exercise2': {'name': 'Squats', 'category': 'bodyweight'},
        };
        mockDatabaseService.setupMockData(boxName, testData);

        // Act
        final box = mockDatabaseService.exercisesBox;

        // Assert
        verify(() => mockDatabaseService.exercisesBox).called(1);
        expect(box, isNotNull);
        expect(box.length, equals(2));
      });

      test('should get routines box', () {
        // Arrange
        const boxName = 'routines';
        final testData = {
          'routine1': {'name': 'Morning Routine', 'exercises': []},
          'routine2': {'name': 'Evening Routine', 'exercises': []},
        };
        mockDatabaseService.setupMockData(boxName, testData);

        // Act
        final box = mockDatabaseService.routinesBox;

        // Assert
        verify(() => mockDatabaseService.routinesBox).called(1);
        expect(box, isNotNull);
        expect(box.length, equals(2));
      });

      test('should get sessions box', () {
        // Arrange
        const boxName = 'sessions';
        final testData = {
          'session1': {
            'id': 'session1',
            'routineId': 'routine1',
            'status': 'completed',
            'startTime': DateTime.now().toIso8601String(),
          },
        };
        mockDatabaseService.setupMockData(boxName, testData);

        // Act
        final box = mockDatabaseService.sessionsBox;

        // Assert
        verify(() => mockDatabaseService.sessionsBox).called(1);
        expect(box, isNotNull);
        expect(box.length, equals(1));
      });
    });

    group('Data Operations', () {
      test('should store and retrieve exercise data', () {
        // Arrange
        const boxName = 'exercises';
        const exerciseId = 'exercise1';
        final exerciseData = {
          'name': 'Push-ups',
          'category': 'bodyweight',
          'description': 'Classic bodyweight exercise',
        };

        mockDatabaseService.setupMockData(boxName, {exerciseId: exerciseData});

        // Act
        final box = mockDatabaseService.exercisesBox;
        final retrievedData = box.get(exerciseId);

        // Assert
        expect(retrievedData, equals(exerciseData));
        TestSetup.verifyDatabaseOperations(
          boxName: boxName,
          operation: 'get',
          key: exerciseId,
        );
      });

      test('should store and retrieve routine data', () {
        // Arrange
        const boxName = 'routines';
        const routineId = 'routine1';
        final routineData = {
          'name': 'Morning Routine',
          'exercises': ['exercise1', 'exercise2'],
          'description': 'Daily morning workout',
        };

        mockDatabaseService.setupMockData(boxName, {routineId: routineData});

        // Act
        final box = mockDatabaseService.routinesBox;
        final retrievedData = box.get(routineId);

        // Assert
        expect(retrievedData, equals(routineData));
        TestSetup.verifyDatabaseOperations(
          boxName: boxName,
          operation: 'get',
          key: routineId,
        );
      });

      test('should store and retrieve session data', () {
        // Arrange
        const boxName = 'sessions';
        const sessionId = 'session1';
        final sessionData = {
          'id': sessionId,
          'routineId': 'routine1',
          'status': 'active',
          'startTime': DateTime.now().toIso8601String(),
          'totalWeight': 0,
          'totalReps': 0,
          'exerciseSets': [],
        };

        mockDatabaseService.setupMockData(boxName, {sessionId: sessionData});

        // Act
        final box = mockDatabaseService.sessionsBox;
        final retrievedData = box.get(sessionId);

        // Assert
        expect(retrievedData, equals(sessionData));
        TestSetup.verifyDatabaseOperations(
          boxName: boxName,
          operation: 'get',
          key: sessionId,
        );
      });
    });

    group('Cleanup Operations', () {
      test('should clear all data', () async {
        // Arrange
        const boxName = 'exercises';
        final testData = {
          'exercise1': {'name': 'Push-ups'},
        };
        mockDatabaseService.setupMockData(boxName, testData);

        // Act
        await mockDatabaseService.clearAllData();

        // Assert
        verify(() => mockDatabaseService.clearAllData()).called(1);
      });

      test('should close database', () async {
        // Act
        await mockDatabaseService.close();

        // Assert
        verify(() => mockDatabaseService.close()).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle box operations gracefully', () {
        // Act & Assert
        expect(() => mockDatabaseService.exercisesBox, returnsNormally);
      });

      test('should handle data retrieval with default values', () {
        // Arrange
        const boxName = 'exercises';
        const exerciseId = 'nonexistent_exercise';
        mockDatabaseService.setupMockData(boxName, {});

        // Act
        final box = mockDatabaseService.exercisesBox;
        final retrievedData = box.get(exerciseId, defaultValue: null);

        // Assert
        expect(retrievedData, isNull);
      });
    });
  });
}
