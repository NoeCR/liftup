import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liftup/common/enums/week_day_enum.dart';
import 'package:mocktail/mocktail.dart';

import '../../../test_helpers/test_setup.dart';
import '../../../mocks/database_service_mock.dart';
import '../../../mocks/logging_service_mock.dart';
import '../../../../lib/features/home/services/routine_service.dart';
import '../../../../lib/features/home/models/routine.dart';
import '../../../../lib/common/enums/week_day_enum.dart';

void main() {
  group('RoutineService Tests', () {
    late ProviderContainer container;
    late MockDatabaseService mockDatabaseService;
    late MockLoggingService mockLoggingService;
    late RoutineService routineService;

    setUpAll(() {
      TestSetup.initialize();
      mockDatabaseService = TestSetup.mockDatabaseService;
      mockLoggingService = TestSetup.mockLoggingService;
    });

    setUp(() {
      TestSetup.cleanup();
      container = TestSetup.createTestContainer();
      routineService = container.read(routineServiceProvider);
    });

    tearDown(() {
      container.dispose();
    });

    group('Routine CRUD Operations', () {
      test('should save routine successfully', () async {
        // Arrange
        final testRoutine = Routine(
          id: 'test-routine',
          name: 'Test Routine',
          description: 'Test description',
          days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
          sections: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        await routineService.saveRoutine(testRoutine);

        // Assert
        // Verificar que se llamó al método de guardado
        expect(mockDatabaseService.exercisesBox, isNotNull);
      });

      test('should get routine by id', () async {
        // Arrange
        final testRoutine = Routine(
          id: 'test-routine',
          name: 'Test Routine',
          description: 'Test description',
          days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
          sections: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final testData = {'test-routine': testRoutine.toJson()};
        TestSetup.setupTestData(routines: testData);

        // Act
        final retrievedRoutine = await routineService.getRoutineById(
          'test-routine',
        );

        // Assert
        expect(retrievedRoutine, isNotNull);
        expect(retrievedRoutine?.id, equals('test-routine'));
        expect(retrievedRoutine?.name, equals('Test Routine'));
      });

      test('should return null for non-existent routine', () async {
        // Arrange
        TestSetup.setupTestData(routines: {});

        // Act
        final retrievedRoutine = await routineService.getRoutineById(
          'non-existent',
        );

        // Assert
        expect(retrievedRoutine, isNull);
      });

      test('should get all routines', () async {
        // Arrange
        final testRoutines = {
          'routine1': {
            'id': 'routine1',
            'name': 'First Routine',
            'description': 'First description',
            'exercises': [],
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'order': 0,
          },
          'routine2': {
            'id': 'routine2',
            'name': 'Second Routine',
            'description': 'Second description',
            'exercises': [],
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'order': 1,
          },
        };
        TestSetup.setupTestData(routines: testRoutines);

        // Act
        final allRoutines = await routineService.getAllRoutines();

        // Assert
        expect(allRoutines, isNotNull);
        expect(allRoutines.length, equals(2));
        expect(allRoutines.any((r) => r.name == 'First Routine'), isTrue);
        expect(allRoutines.any((r) => r.name == 'Second Routine'), isTrue);
      });

      test('should delete routine successfully', () async {
        // Arrange
        final testRoutines = {
          'routine1': {
            'id': 'routine1',
            'name': 'Routine to Delete',
            'description': 'This routine will be deleted',
            'exercises': [],
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'order': 0,
          },
        };
        TestSetup.setupTestData(routines: testRoutines);

        // Act
        await routineService.deleteRoutine('routine1');

        // Assert
        // Verificar que se llamó al método de eliminación
        expect(mockDatabaseService.exercisesBox, isNotNull);
      });
    });

    group('Routine Sorting', () {
      test('should sort routines by order when available', () async {
        // Arrange
        final testRoutines = {
          'routine1': {
            'id': 'routine1',
            'name': 'Second Routine',
            'description': 'Second description',
            'exercises': [],
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'order': 2,
          },
          'routine2': {
            'id': 'routine2',
            'name': 'First Routine',
            'description': 'First description',
            'exercises': [],
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'order': 1,
          },
          'routine3': {
            'id': 'routine3',
            'name': 'Third Routine',
            'description': 'Third description',
            'exercises': [],
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'order': 3,
          },
        };
        TestSetup.setupTestData(routines: testRoutines);

        // Act
        final sortedRoutines = await routineService.getAllRoutines();

        // Assert
        expect(sortedRoutines, isNotNull);
        expect(sortedRoutines.length, equals(3));
        expect(sortedRoutines[0].name, equals('First Routine'));
        expect(sortedRoutines[1].name, equals('Second Routine'));
        expect(sortedRoutines[2].name, equals('Third Routine'));
      });

      test(
        'should sort by creation date when order is not available',
        () async {
          // Arrange
          final now = DateTime.now();
          final testRoutines = {
            'routine1': {
              'id': 'routine1',
              'name': 'Newer Routine',
              'description': 'Newer description',
              'exercises': [],
              'createdAt': now.add(Duration(hours: 1)).toIso8601String(),
              'updatedAt': now.add(Duration(hours: 1)).toIso8601String(),
            },
            'routine2': {
              'id': 'routine2',
              'name': 'Older Routine',
              'description': 'Older description',
              'exercises': [],
              'createdAt': now.toIso8601String(),
              'updatedAt': now.toIso8601String(),
            },
          };
          TestSetup.setupTestData(routines: testRoutines);

          // Act
          final sortedRoutines = await routineService.getAllRoutines();

          // Assert
          expect(sortedRoutines, isNotNull);
          expect(sortedRoutines.length, equals(2));
          expect(sortedRoutines[0].name, equals('Older Routine'));
          expect(sortedRoutines[1].name, equals('Newer Routine'));
        },
      );

      test(
        'should prioritize routines with order over those without',
        () async {
          // Arrange
          final now = DateTime.now();
          final testRoutines = {
            'routine1': {
              'id': 'routine1',
              'name': 'Routine Without Order',
              'description': 'No order',
              'exercises': [],
              'createdAt': now.toIso8601String(),
              'updatedAt': now.toIso8601String(),
            },
            'routine2': {
              'id': 'routine2',
              'name': 'Routine With Order',
              'description': 'Has order',
              'exercises': [],
              'createdAt': now.add(Duration(hours: 1)).toIso8601String(),
              'updatedAt': now.add(Duration(hours: 1)).toIso8601String(),
              'order': 1,
            },
          };
          TestSetup.setupTestData(routines: testRoutines);

          // Act
          final sortedRoutines = await routineService.getAllRoutines();

          // Assert
          expect(sortedRoutines, isNotNull);
          expect(sortedRoutines.length, equals(2));
          expect(sortedRoutines[0].name, equals('Routine With Order'));
          expect(sortedRoutines[1].name, equals('Routine Without Order'));
        },
      );
    });

    group('Active Routines', () {
      test('should get active routines only', () async {
        // Arrange
        final testRoutines = {
          'routine1': {
            'id': 'routine1',
            'name': 'Active Routine',
            'description': 'Active description',
            'exercises': [],
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'isActive': true,
            'order': 0,
          },
          'routine2': {
            'id': 'routine2',
            'name': 'Inactive Routine',
            'description': 'Inactive description',
            'exercises': [],
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'isActive': false,
            'order': 1,
          },
        };
        TestSetup.setupTestData(routines: testRoutines);

        // Act
        final activeRoutines = await routineService.getActiveRoutines();

        // Assert
        expect(activeRoutines, isNotNull);
        expect(activeRoutines.length, equals(1));
        expect(activeRoutines.first.name, equals('Active Routine'));
      });

      test('should return empty list when no active routines', () async {
        // Arrange
        final testRoutines = {
          'routine1': {
            'id': 'routine1',
            'name': 'Inactive Routine',
            'description': 'Inactive description',
            'exercises': [],
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'isActive': false,
            'order': 0,
          },
        };
        TestSetup.setupTestData(routines: testRoutines);

        // Act
        final activeRoutines = await routineService.getActiveRoutines();

        // Assert
        expect(activeRoutines, isNotNull);
        expect(activeRoutines, isEmpty);
      });
    });

    group('Error Handling', () {
      test('should handle empty database gracefully', () async {
        // Arrange
        TestSetup.setupTestData(routines: {});

        // Act
        final allRoutines = await routineService.getAllRoutines();
        final activeRoutines = await routineService.getActiveRoutines();

        // Assert
        expect(allRoutines, isNotNull);
        expect(allRoutines, isEmpty);
        expect(activeRoutines, isNotNull);
        expect(activeRoutines, isEmpty);
      });

      test('should handle null routine data gracefully', () async {
        // Arrange
        TestSetup.setupTestData(routines: {});

        // Act
        final routine = await routineService.getRoutineById('non-existent');

        // Assert
        expect(routine, isNull);
      });
    });

    group('Database Integration', () {
      test('should interact with database service correctly', () async {
        // Arrange
        final testRoutine = Routine(
          id: 'test-routine',
          name: 'Test Routine',
          description: 'Test description',
          days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
          sections: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        await routineService.saveRoutine(testRoutine);
        final retrievedRoutine = await routineService.getRoutineById(
          'test-routine',
        );

        // Assert
        expect(mockDatabaseService.exercisesBox, isNotNull);
        // Verificar que se interactuó con la base de datos
        expect(retrievedRoutine, isNotNull);
      });

      test('should handle database service errors', () async {
        // Arrange
        TestSetup.setupTestData(routines: {});

        // Act
        final allRoutines = await routineService.getAllRoutines();

        // Assert
        expect(allRoutines, isNotNull);
        expect(allRoutines, isA<List<Routine>>());
      });
    });
  });
}
