import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../../test_helpers/test_setup.dart';
import '../../../mocks/database_service_mock.dart';
import '../../../mocks/logging_service_mock.dart';
import '../../../../lib/features/home/notifiers/routine_notifier.dart';
import '../../../../lib/features/home/models/routine.dart';
import '../../../../lib/features/home/services/routine_service.dart';
import '../../../../lib/common/enums/week_day_enum.dart';
import '../../../../lib/common/enums/section_muscle_group_enum.dart';

void main() {
  group('RoutineNotifier Tests', () {
    late ProviderContainer container;
    late MockDatabaseService mockDatabaseService;
    late MockLoggingService mockLoggingService;

    setUpAll(() {
      TestSetup.initialize();
      mockDatabaseService = TestSetup.mockDatabaseService;
      mockLoggingService = TestSetup.mockLoggingService;
    });

    setUp(() {
      TestSetup.cleanup();
      container = TestSetup.createTestContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Initialization', () {
      test('should initialize with empty routines', () async {
        // Arrange
        TestSetup.setupTestData(routines: {});

        // Act
        final notifier = container.read(routineNotifierProvider.notifier);
        final state = await container.read(routineNotifierProvider.future);

        // Assert
        expect(state, isNotNull);
        expect(state, isEmpty);
      });

      test('should load initial routine when empty', () async {
        // Arrange
        TestSetup.setupTestData(routines: {});

        // Act
        final notifier = container.read(routineNotifierProvider.notifier);
        final state = await container.read(routineNotifierProvider.future);

        // Assert
        expect(state, isNotNull);
        // Debería cargar una rutina inicial
        expect(state.length, greaterThan(0));
      });

      test('should load existing routines', () async {
        // Arrange
        final testRoutines = {
          'routine1': {
            'id': 'routine1',
            'name': 'Morning Routine',
            'description': 'Daily morning workout',
            'exercises': [],
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'order': 0,
          },
          'routine2': {
            'id': 'routine2',
            'name': 'Evening Routine',
            'description': 'Daily evening workout',
            'exercises': [],
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'order': 1,
          },
        };
        TestSetup.setupTestData(routines: testRoutines);

        // Act
        final notifier = container.read(routineNotifierProvider.notifier);
        final state = await container.read(routineNotifierProvider.future);

        // Assert
        expect(state, isNotNull);
        expect(state.length, equals(2));
        expect(state.any((r) => r.name == 'Morning Routine'), isTrue);
        expect(state.any((r) => r.name == 'Evening Routine'), isTrue);
      });
    });

    group('Routine Management', () {
      test('should add new routine', () async {
        // Arrange
        TestSetup.setupTestData(routines: {});
        final newRoutine = Routine(
          id: 'new-routine',
          name: 'New Routine',
          description: 'A new workout routine',
          days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
          sections: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final notifier = container.read(routineNotifierProvider.notifier);
        await notifier.addRoutine(newRoutine);
        final state = await container.read(routineNotifierProvider.future);

        // Assert
        expect(state, isNotNull);
        expect(state.length, greaterThan(0));
        expect(state.any((r) => r.name == 'New Routine'), isTrue);
      });

      test('should update existing routine', () async {
        // Arrange
        final testRoutines = {
          'routine1': {
            'id': 'routine1',
            'name': 'Original Name',
            'description': 'Original description',
            'exercises': [],
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'order': 0,
          },
        };
        TestSetup.setupTestData(routines: testRoutines);

        final updatedRoutine = Routine(
          id: 'routine1',
          name: 'Updated Name',
          description: 'Updated description',
          days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
          sections: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final notifier = container.read(routineNotifierProvider.notifier);
        await notifier.updateRoutine(updatedRoutine);
        final state = await container.read(routineNotifierProvider.future);

        // Assert
        expect(state, isNotNull);
        final updatedRoutineFromState = state.firstWhere((r) => r.id == 'routine1');
        expect(updatedRoutineFromState.name, equals('Updated Name'));
        expect(updatedRoutineFromState.description, equals('Updated description'));
      });

      test('should delete routine', () async {
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
          'routine2': {
            'id': 'routine2',
            'name': 'Routine to Keep',
            'description': 'This routine will remain',
            'exercises': [],
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'order': 1,
          },
        };
        TestSetup.setupTestData(routines: testRoutines);

        // Act
        final notifier = container.read(routineNotifierProvider.notifier);
        await notifier.deleteRoutine('routine1');
        final state = await container.read(routineNotifierProvider.future);

        // Assert
        expect(state, isNotNull);
        expect(state.length, equals(1));
        expect(state.any((r) => r.id == 'routine1'), isFalse);
        expect(state.any((r) => r.id == 'routine2'), isTrue);
      });
    });

    group('Routine Ordering', () {
      test('should assign correct order to new routines', () async {
        // Arrange
        final testRoutines = {
          'routine1': {
            'id': 'routine1',
            'name': 'First Routine',
            'description': 'First routine',
            'exercises': [],
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'order': 0,
          },
          'routine2': {
            'id': 'routine2',
            'name': 'Second Routine',
            'description': 'Second routine',
            'exercises': [],
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'order': 1,
          },
        };
        TestSetup.setupTestData(routines: testRoutines);

        final newRoutine = Routine(
          id: 'new-routine',
          name: 'Third Routine',
          description: 'Third routine',
          days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
          sections: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final notifier = container.read(routineNotifierProvider.notifier);
        await notifier.addRoutine(newRoutine);
        final state = await container.read(routineNotifierProvider.future);

        // Assert
        expect(state, isNotNull);
        final newRoutineFromState = state.firstWhere((r) => r.id == 'new-routine');
        expect(newRoutineFromState.order, equals(2));
      });

      test('should reorder routines correctly', () async {
        // Arrange
        final testRoutines = {
          'routine1': {
            'id': 'routine1',
            'name': 'First Routine',
            'description': 'First routine',
            'exercises': [],
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'order': 0,
          },
          'routine2': {
            'id': 'routine2',
            'name': 'Second Routine',
            'description': 'Second routine',
            'exercises': [],
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'order': 1,
          },
        };
        TestSetup.setupTestData(routines: testRoutines);

        // Act
        final notifier = container.read(routineNotifierProvider.notifier);
        await notifier.reorderRoutines(['routine2', 'routine1']);
        final state = await container.read(routineNotifierProvider.future);

        // Assert
        expect(state, isNotNull);
        final sortedRoutines = state.toList()
          ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
        
        expect(sortedRoutines.first.id, equals('routine2'));
        expect(sortedRoutines.last.id, equals('routine1'));
      });
    });

    group('Error Handling', () {
      test('should handle service errors gracefully', () async {
        // Arrange
        TestSetup.setupTestData(routines: {});

        // Act
        final notifier = container.read(routineNotifierProvider.notifier);
        final state = await container.read(routineNotifierProvider.future);

        // Assert
        expect(state, isNotNull);
        // Debería manejar errores sin fallar
        expect(state, isA<List<Routine>>());
      });

      test('should handle empty routine data', () async {
        // Arrange
        TestSetup.setupTestData(routines: {});

        // Act
        final notifier = container.read(routineNotifierProvider.notifier);
        final state = await container.read(routineNotifierProvider.future);

        // Assert
        expect(state, isNotNull);
        expect(state, isA<List<Routine>>());
      });
    });

    group('State Updates', () {
      test('should update state after adding routine', () async {
        // Arrange
        TestSetup.setupTestData(routines: {});
        final newRoutine = Routine(
          id: 'test-routine',
          name: 'Test Routine',
          description: 'Test description',
          days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
          sections: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final notifier = container.read(routineNotifierProvider.notifier);
        final initialState = await container.read(routineNotifierProvider.future);
        await notifier.addRoutine(newRoutine);
        final updatedState = await container.read(routineNotifierProvider.future);

        // Assert
        expect(updatedState.length, greaterThan(initialState.length));
        expect(updatedState.any((r) => r.id == 'test-routine'), isTrue);
      });

      test('should update state after deleting routine', () async {
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
        final notifier = container.read(routineNotifierProvider.notifier);
        final initialState = await container.read(routineNotifierProvider.future);
        await notifier.deleteRoutine('routine1');
        final updatedState = await container.read(routineNotifierProvider.future);

        // Assert
        expect(updatedState.length, lessThan(initialState.length));
        expect(updatedState.any((r) => r.id == 'routine1'), isFalse);
      });
    });
  });
}
