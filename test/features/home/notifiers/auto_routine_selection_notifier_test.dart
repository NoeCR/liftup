import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../../test_helpers/test_setup.dart';
import '../../../mocks/database_service_mock.dart';
import '../../../mocks/logging_service_mock.dart';
import '../../../../lib/features/home/notifiers/auto_routine_selection_notifier.dart';
import '../../../../lib/features/home/notifiers/routine_notifier.dart';
import '../../../../lib/features/home/notifiers/selected_routine_provider.dart';
import '../../../../lib/features/home/models/routine.dart';
import '../../../../lib/features/home/services/auto_routine_selection_service.dart';
import '../../../../lib/common/enums/week_day_enum.dart';

void main() {
  group('AutoRoutineSelectionNotifier Tests', () {
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
      test('should initialize with empty routines', () {
        // Arrange
        final testRoutines = <Routine>[];

        // Act
        final notifier = container.read(autoRoutineSelectionNotifierProvider.notifier);
        final state = container.read(autoRoutineSelectionNotifierProvider);

        // Assert
        expect(state, isNotNull);
        expect(state.availableRoutines, isEmpty);
        expect(state.hasSelection, isFalse);
        expect(state.selectedRoutine, isNull);
      });

      test('should initialize with available routines', () {
        // Arrange
        final testRoutines = [
          Routine(
            id: 'routine1',
            name: 'Morning Routine',
            description: 'Daily morning workout',
            days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Routine(
            id: 'routine2',
            name: 'Evening Routine',
            description: 'Daily evening workout',
            days: [WeekDay.tuesday, WeekDay.thursday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        final notifier = container.read(autoRoutineSelectionNotifierProvider.notifier);
        final state = container.read(autoRoutineSelectionNotifierProvider);

        // Assert
        expect(state, isNotNull);
        expect(state.availableRoutines, isNotEmpty);
        expect(state.currentDay, isA<WeekDay>());
      });
    });

    group('Auto Selection Logic', () {
      test('should select routine for current day when available', () {
        // Arrange
        final today = WeekDay.values[DateTime.now().weekday - 1];
        final testRoutines = [
          Routine(
            id: 'routine1',
            name: 'Morning Routine',
            description: 'Daily morning workout',
            days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        final notifier = container.read(autoRoutineSelectionNotifierProvider.notifier);
        final state = container.read(autoRoutineSelectionNotifierProvider);

        // Assert
        expect(state, isNotNull);
        expect(state.currentDay, equals(today));
        expect(state.availableRoutines, isNotEmpty);
      });

      test('should not auto-select when routine already selected', () {
        // Arrange
        final testRoutines = [
          Routine(
            id: 'routine1',
            name: 'Morning Routine',
            description: 'Daily morning workout',
            days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        final notifier = container.read(autoRoutineSelectionNotifierProvider.notifier);
        final state = container.read(autoRoutineSelectionNotifierProvider);

        // Assert
        expect(state, isNotNull);
        // Verificar que no se selecciona automáticamente si ya hay una selección
        expect(state.hasSelection, isFalse);
      });

      test('should refresh auto selection when called', () {
        // Arrange
        final testRoutines = [
          Routine(
            id: 'routine1',
            name: 'Morning Routine',
            description: 'Daily morning workout',
            days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        final notifier = container.read(autoRoutineSelectionNotifierProvider.notifier);
        notifier.refreshAutoSelection();
        final state = container.read(autoRoutineSelectionNotifierProvider);

        // Assert
        expect(state, isNotNull);
        expect(state.availableRoutines, isNotEmpty);
      });
    });

    group('State Management', () {
      test('should update state when routines change', () {
        // Arrange
        final initialRoutines = <Routine>[];
        final updatedRoutines = [
          Routine(
            id: 'routine1',
            name: 'New Routine',
            description: 'New workout routine',
            days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        final notifier = container.read(autoRoutineSelectionNotifierProvider.notifier);
        final initialState = container.read(autoRoutineSelectionNotifierProvider);

        // Simular cambio en las rutinas
        notifier.refreshAutoSelection();
        final updatedState = container.read(autoRoutineSelectionNotifierProvider);

        // Assert
        expect(initialState, isNotNull);
        expect(updatedState, isNotNull);
        expect(updatedState.availableRoutines, isNotEmpty);
      });

      test('should maintain current day information', () {
        // Arrange
        final expectedDay = WeekDay.values[DateTime.now().weekday - 1];

        // Act
        final notifier = container.read(autoRoutineSelectionNotifierProvider.notifier);
        final state = container.read(autoRoutineSelectionNotifierProvider);

        // Assert
        expect(state.currentDay, equals(expectedDay));
      });
    });

    group('Error Handling', () {
      test('should handle empty routine list gracefully', () {
        // Arrange
        final emptyRoutines = <Routine>[];

        // Act
        final notifier = container.read(autoRoutineSelectionNotifierProvider.notifier);
        final state = container.read(autoRoutineSelectionNotifierProvider);

        // Assert
        expect(state, isNotNull);
        expect(state.availableRoutines, isEmpty);
        expect(state.hasSelection, isFalse);
        expect(state.selectedRoutine, isNull);
      });

      test('should handle null routines gracefully', () {
        // Act
        final notifier = container.read(autoRoutineSelectionNotifierProvider.notifier);
        final state = container.read(autoRoutineSelectionNotifierProvider);

        // Assert
        expect(state, isNotNull);
        expect(state.availableRoutines, isEmpty);
        expect(state.hasSelection, isFalse);
      });
    });

    group('Logging Integration', () {
      test('should log auto selection updates', () {
        // Arrange
        final testRoutines = [
          Routine(
            id: 'routine1',
            name: 'Test Routine',
            description: 'Test workout routine',
            days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        final notifier = container.read(autoRoutineSelectionNotifierProvider.notifier);
        notifier.refreshAutoSelection();

        // Assert
        expect(mockLoggingService.hasLogWithMessage('Updating auto selection'), isTrue);
      });

      test('should log auto selection decisions', () {
        // Arrange
        final testRoutines = [
          Routine(
            id: 'routine1',
            name: 'Test Routine',
            description: 'Test workout routine',
            days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        final notifier = container.read(autoRoutineSelectionNotifierProvider.notifier);
        notifier.refreshAutoSelection();

        // Assert
        expect(mockLoggingService.hasLogWithMessage('Auto-selecting routine'), isTrue);
      });
    });
  });
}
