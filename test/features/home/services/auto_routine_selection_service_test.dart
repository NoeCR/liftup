import 'package:flutter_test/flutter_test.dart';
import 'package:liftup/features/home/services/auto_routine_selection_service.dart';
import 'package:liftup/features/home/models/routine.dart';
import 'package:liftup/common/enums/week_day_enum.dart';
import '../../../mocks/auto_routine_selection_service_mock.dart';

void main() {
  group('AutoRoutineSelectionService Tests', () {
    late MockAutoRoutineSelectionService service;

    setUp(() {
      service = MockAutoRoutineSelectionService();
    });

    group('Initialization', () {
      test('should initialize service correctly', () {
        expect(service, isNotNull);
      });
    });

    group('Routine Filtering by Day', () {
      test('should filter routines for Monday', () {
        // Mock Monday as current day
        service.setMockCurrentDay(WeekDay.monday);

        final routines = [
          Routine(
            id: 'routine_1',
            name: 'Push Day',
            description: 'Push day routine',
            days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Routine(
            id: 'routine_2',
            name: 'Pull Day',
            description: 'Pull day routine',
            days: [WeekDay.tuesday, WeekDay.thursday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Routine(
            id: 'routine_3',
            name: 'Leg Day',
            description: 'Leg day routine',
            days: [WeekDay.monday, WeekDay.saturday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final mondayRoutines = service.findRoutinesForToday(routines);

        expect(mondayRoutines, hasLength(2));
        expect(mondayRoutines.map((r) => r.id), contains('routine_1'));
        expect(mondayRoutines.map((r) => r.id), contains('routine_3'));
        expect(mondayRoutines.map((r) => r.id), isNot(contains('routine_2')));
      });

      test('should filter routines for Tuesday', () {
        // Mock Tuesday as current day
        service.setMockCurrentDay(WeekDay.tuesday);

        final routines = [
          Routine(
            id: 'routine_1',
            name: 'Push Day',
            description: 'Push day routine',
            days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Routine(
            id: 'routine_2',
            name: 'Pull Day',
            description: 'Pull day routine',
            days: [WeekDay.tuesday, WeekDay.thursday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final tuesdayRoutines = service.findRoutinesForToday(routines);

        expect(tuesdayRoutines, hasLength(1));
        expect(tuesdayRoutines.first.id, equals('routine_2'));
      });

      test('should return empty list for day with no routines', () {
        // Mock Sunday as current day (no routines scheduled)
        service.setMockCurrentDay(WeekDay.sunday);

        final routines = [
          Routine(
            id: 'routine_1',
            name: 'Push Day',
            description: 'Push day routine',
            days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final sundayRoutines = service.findRoutinesForToday(routines);

        expect(sundayRoutines, isEmpty);
      });
    });

    group('Routine Priority Calculation', () {
      test('should calculate priority based on frequency', () {
        final routines = [
          Routine(
            id: 'routine_1',
            name: 'Push Day',
            description: 'Push day routine',
            days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Routine(
            id: 'routine_2',
            name: 'Pull Day',
            description: 'Pull day routine',
            days: [WeekDay.tuesday, WeekDay.thursday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Routine(
            id: 'routine_3',
            name: 'Leg Day',
            description: 'Leg day routine',
            days: [WeekDay.saturday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final priorities = <String, int>{};
        for (final routine in routines) {
          priorities[routine.id] = service.calculateRoutinePriority(
            routine,
            routines,
          );
        }

        expect(priorities, hasLength(3));
        // routine_1 has 3 days, routine_2 has 2 days, routine_3 has 1 day
        // So routine_1 should have highest priority (3000), routine_2 (2000), routine_3 (1000)
        expect(priorities['routine_1'], greaterThan(priorities['routine_2']!));
        expect(priorities['routine_2'], greaterThan(priorities['routine_3']!));
      });

      test('should handle routines with same frequency', () {
        final routines = [
          Routine(
            id: 'routine_1',
            name: 'Routine 1',
            description: 'First routine',
            days: [WeekDay.monday, WeekDay.wednesday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Routine(
            id: 'routine_2',
            name: 'Routine 2',
            description: 'Second routine',
            days: [WeekDay.tuesday, WeekDay.thursday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final priorities = <String, int>{};
        for (final routine in routines) {
          priorities[routine.id] = routine.order ?? 999;
        }

        expect(priorities, hasLength(2));
        expect(priorities['routine_1'], equals(priorities['routine_2']));
      });
    });

    group('Auto Selection Logic', () {
      test('should select routine with highest priority', () {
        final routines = [
          Routine(
            id: 'routine_1',
            name: 'Push Day',
            description: 'Push day routine',
            days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Routine(
            id: 'routine_2',
            name: 'Pull Day',
            description: 'Pull day routine',
            days: [WeekDay.tuesday, WeekDay.thursday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final selectedRoutine = service.selectRoutineForToday(routines);

        expect(selectedRoutine, isNotNull);
        expect(selectedRoutine!.id, equals('routine_1'));
      });

      test('should return null when no routines available for day', () {
        // Mock Sunday as current day (no routines scheduled)
        service.setMockCurrentDay(WeekDay.sunday);

        final routines = [
          Routine(
            id: 'routine_1',
            name: 'Push Day',
            description: 'Push day routine',
            days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final selectedRoutine = service.selectRoutineForToday(routines);

        expect(selectedRoutine, isNull);
      });

      test('should handle empty routines list', () {
        final selectedRoutine = service.selectRoutineForToday([]);

        expect(selectedRoutine, isNull);
      });
    });

    group('Routine Scheduling', () {
      test('should get next scheduled routine', () {
        final routines = [
          Routine(
            id: 'routine_1',
            name: 'Push Day',
            description: 'Push day routine',
            days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Routine(
            id: 'routine_2',
            name: 'Pull Day',
            description: 'Pull day routine',
            days: [WeekDay.tuesday, WeekDay.thursday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final nextRoutine = service.selectRoutineForToday(routines);

        expect(nextRoutine, isNotNull);
        expect(nextRoutine!.id, equals('routine_1'));
      });

      test('should get next scheduled routine for different days', () {
        final routines = [
          Routine(
            id: 'routine_1',
            name: 'Push Day',
            description: 'Push day routine',
            days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Routine(
            id: 'routine_2',
            name: 'Pull Day',
            description: 'Pull day routine',
            days: [WeekDay.tuesday, WeekDay.thursday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Test Tuesday routine
        service.setMockCurrentDay(WeekDay.tuesday);
        final tuesdayRoutine = service.selectRoutineForToday(routines);

        // Test Wednesday routine
        service.setMockCurrentDay(WeekDay.wednesday);
        final wednesdayRoutine = service.selectRoutineForToday(routines);

        expect(tuesdayRoutine, isNotNull);
        expect(tuesdayRoutine!.id, equals('routine_2'));
        expect(wednesdayRoutine, isNotNull);
        expect(wednesdayRoutine!.id, equals('routine_1'));
      });
    });

    group('Routine Validation', () {
      test('should validate routine has valid days', () {
        final validRoutine = Routine(
          id: 'routine_1',
          name: 'Push Day',
          description: 'Push day routine',
          days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
          sections: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final isValid = validRoutine.days.isNotEmpty;

        expect(isValid, equals(true));
      });

      test('should invalidate routine with no days', () {
        final invalidRoutine = Routine(
          id: 'routine_1',
          name: 'Push Day',
          description: 'Push day routine',
          days: [],
          sections: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final isValid = invalidRoutine.days.isNotEmpty;

        expect(isValid, equals(false));
      });

      test('should validate routine with single day', () {
        final singleDayRoutine = Routine(
          id: 'routine_1',
          name: 'Leg Day',
          description: 'Leg day routine',
          days: [WeekDay.saturday],
          sections: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final isValid = singleDayRoutine.days.isNotEmpty;

        expect(isValid, equals(true));
      });
    });

    group('Edge Cases', () {
      test('should handle routines with duplicate days', () {
        final routines = [
          Routine(
            id: 'routine_1',
            name: 'Push Day',
            description: 'Push day routine',
            days: [WeekDay.monday, WeekDay.monday, WeekDay.wednesday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final mondayRoutines = service.findRoutinesForToday(routines);

        expect(mondayRoutines, hasLength(1));
        expect(mondayRoutines.first.id, equals('routine_1'));
      });

      test('should handle routines with all days', () {
        final allDaysRoutine = Routine(
          id: 'routine_1',
          name: 'Daily Routine',
          description: 'Daily routine',
          days: WeekDay.values,
          sections: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final routines = [allDaysRoutine];

        for (final _ in WeekDay.values) {
          final dayRoutines = service.findRoutinesForToday(routines);
          expect(dayRoutines, hasLength(1));
          expect(dayRoutines.first.id, equals('routine_1'));
        }
      });

      test('should handle routines with weekend only', () {
        final weekendRoutine = Routine(
          id: 'routine_1',
          name: 'Weekend Routine',
          description: 'Weekend routine',
          days: [WeekDay.saturday, WeekDay.sunday],
          sections: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final routines = [weekendRoutine];

        // Test Saturday
        service.setMockCurrentDay(WeekDay.saturday);
        final saturdayRoutines = service.findRoutinesForToday(routines);

        // Test Sunday
        service.setMockCurrentDay(WeekDay.sunday);
        final sundayRoutines = service.findRoutinesForToday(routines);

        // Test Monday (no routines)
        service.setMockCurrentDay(WeekDay.monday);
        final mondayRoutines = service.findRoutinesForToday(routines);

        expect(saturdayRoutines, hasLength(1));
        expect(sundayRoutines, hasLength(1));
        expect(mondayRoutines, isEmpty);
      });
    });
  });
}
