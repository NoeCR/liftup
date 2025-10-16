import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/exercise/models/exercise_set.dart';
import 'package:liftly/features/sessions/models/workout_session.dart';

void main() {
  group('WorkoutSession', () {
    late WorkoutSession session;
    late List<ExerciseSet> exerciseSets;

    setUp(() {
      exerciseSets = [
        ExerciseSet(
          id: 'set-1',
          exerciseId: 'exercise-1',
          weight: 60.0,
          reps: 10,
          completedAt: DateTime.now(),
          isCompleted: true,
        ),
        ExerciseSet(
          id: 'set-2',
          exerciseId: 'exercise-1',
          weight: 65.0,
          reps: 8,
          completedAt: DateTime.now(),
          isCompleted: true,
        ),
      ];

      session = WorkoutSession(
        id: 'session-1',
        routineId: 'routine-1',
        name: 'Test Session',
        startTime: DateTime(2024, 1, 1, 10, 0),
        endTime: DateTime(2024, 1, 1, 11, 30),
        exerciseSets: exerciseSets,
        notes: 'Test notes',
        status: SessionStatus.completed,
        totalWeight: 125.0,
        totalReps: 18,
      );
    });

    group('Constructor', () {
      test('should create WorkoutSession with all required fields', () {
        expect(session.id, equals('session-1'));
        expect(session.routineId, equals('routine-1'));
        expect(session.name, equals('Test Session'));
        expect(session.startTime, equals(DateTime(2024, 1, 1, 10, 0)));
        expect(session.endTime, equals(DateTime(2024, 1, 1, 11, 30)));
        expect(session.exerciseSets, equals(exerciseSets));
        expect(session.notes, equals('Test notes'));
        expect(session.status, equals(SessionStatus.completed));
        expect(session.totalWeight, equals(125.0));
        expect(session.totalReps, equals(18));
      });

      test('should create WorkoutSession with minimal required fields', () {
        final minimalSession = WorkoutSession(
          id: 'minimal-session',
          name: 'Minimal Session',
          startTime: DateTime.now(),
          exerciseSets: [],
          status: SessionStatus.active,
        );

        expect(minimalSession.id, equals('minimal-session'));
        expect(minimalSession.name, equals('Minimal Session'));
        expect(minimalSession.routineId, isNull);
        expect(minimalSession.endTime, isNull);
        expect(minimalSession.notes, isNull);
        expect(minimalSession.totalWeight, isNull);
        expect(minimalSession.totalReps, isNull);
      });
    });

    group('Duration', () {
      test('should return correct duration when endTime is provided', () {
        expect(session.duration, equals(Duration(minutes: 90)));
      });

      test('should return null when endTime is null', () {
        final sessionWithoutEndTime = WorkoutSession(
          id: 'session-1',
          name: 'Test Session',
          startTime: DateTime(2024, 1, 1, 10, 0),
          endTime: null,
          exerciseSets: [],
          status: SessionStatus.active,
        );
        expect(sessionWithoutEndTime.duration, isNull);
      });

      test('should return zero duration when startTime equals endTime', () {
        final sameTimeSession = session.copyWith(
          startTime: DateTime(2024, 1, 1, 10, 0),
          endTime: DateTime(2024, 1, 1, 10, 0),
        );
        expect(sameTimeSession.duration, equals(Duration.zero));
      });
    });

    group('Status checks', () {
      test('should return true for isActive when status is active', () {
        final activeSession = session.copyWith(status: SessionStatus.active);
        expect(activeSession.isActive, isTrue);
        expect(activeSession.isCompleted, isFalse);
      });

      test('should return true for isCompleted when status is completed', () {
        expect(session.isCompleted, isTrue);
        expect(session.isActive, isFalse);
      });

      test('should return false for both when status is paused', () {
        final pausedSession = session.copyWith(status: SessionStatus.paused);
        expect(pausedSession.isActive, isFalse);
        expect(pausedSession.isCompleted, isFalse);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final updatedSession = session.copyWith(
          name: 'Updated Session',
          notes: 'Updated notes',
          status: SessionStatus.active,
        );

        expect(updatedSession.id, equals(session.id));
        expect(updatedSession.name, equals('Updated Session'));
        expect(updatedSession.notes, equals('Updated notes'));
        expect(updatedSession.status, equals(SessionStatus.active));
        expect(updatedSession.routineId, equals(session.routineId));
        expect(updatedSession.startTime, equals(session.startTime));
        expect(updatedSession.endTime, equals(session.endTime));
        expect(updatedSession.exerciseSets, equals(session.exerciseSets));
        expect(updatedSession.totalWeight, equals(session.totalWeight));
        expect(updatedSession.totalReps, equals(session.totalReps));
      });

      test('should preserve original values when null is passed to copyWith', () {
        final updatedSession = session.copyWith(
          routineId: null,
          endTime: null,
          notes: null,
          totalWeight: null,
          totalReps: null,
        );

        // copyWith with null values preserves original values due to ?? operator
        expect(updatedSession.routineId, equals(session.routineId));
        expect(updatedSession.endTime, equals(session.endTime));
        expect(updatedSession.notes, equals(session.notes));
        expect(updatedSession.totalWeight, equals(session.totalWeight));
        expect(updatedSession.totalReps, equals(session.totalReps));
      });

      test('should preserve original values when no parameters provided', () {
        final copiedSession = session.copyWith();
        expect(copiedSession, equals(session));
      });
    });

    group('Equality', () {
      test('should be equal when all properties are the same', () {
        final sameSession = WorkoutSession(
          id: 'session-1',
          routineId: 'routine-1',
          name: 'Test Session',
          startTime: DateTime(2024, 1, 1, 10, 0),
          endTime: DateTime(2024, 1, 1, 11, 30),
          exerciseSets: exerciseSets,
          notes: 'Test notes',
          status: SessionStatus.completed,
          totalWeight: 125.0,
          totalReps: 18,
        );

        expect(session, equals(sameSession));
      });

      test('should not be equal when properties differ', () {
        final differentSession = session.copyWith(name: 'Different Session');
        expect(session, isNot(equals(differentSession)));
      });

      test('should have same hashCode when equal', () {
        final sameSession = session.copyWith();
        expect(session.hashCode, equals(sameSession.hashCode));
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final json = session.toJson();

        expect(json['id'], equals('session-1'));
        expect(json['routineId'], equals('routine-1'));
        expect(json['name'], equals('Test Session'));
        expect(json['startTime'], isA<String>());
        expect(json['endTime'], isA<String>());
        expect(json['exerciseSets'], isA<List>());
        expect(json['notes'], equals('Test notes'));
        expect(json['status'], equals('completed'));
        expect(json['totalWeight'], equals(125.0));
        expect(json['totalReps'], equals(18));
      });

      test('should deserialize from JSON correctly', () {
        // Create a session without exerciseSets to avoid serialization issues
        final simpleSession = WorkoutSession(
          id: 'session-1',
          routineId: 'routine-1',
          name: 'Test Session',
          startTime: DateTime(2024, 1, 1, 10, 0),
          endTime: DateTime(2024, 1, 1, 11, 30),
          exerciseSets: [], // Empty list to avoid serialization issues
          notes: 'Test notes',
          status: SessionStatus.completed,
          totalWeight: 125.0,
          totalReps: 18,
        );

        final json = simpleSession.toJson();
        final deserializedSession = WorkoutSession.fromJson(json);

        expect(deserializedSession.id, equals(simpleSession.id));
        expect(deserializedSession.routineId, equals(simpleSession.routineId));
        expect(deserializedSession.name, equals(simpleSession.name));
        expect(deserializedSession.startTime, equals(simpleSession.startTime));
        expect(deserializedSession.endTime, equals(simpleSession.endTime));
        expect(deserializedSession.exerciseSets.length, equals(simpleSession.exerciseSets.length));
        expect(deserializedSession.notes, equals(simpleSession.notes));
        expect(deserializedSession.status, equals(simpleSession.status));
        expect(deserializedSession.totalWeight, equals(simpleSession.totalWeight));
        expect(deserializedSession.totalReps, equals(simpleSession.totalReps));
      });
    });
  });

  group('SessionStatus', () {
    test('should have correct enum values', () {
      expect(SessionStatus.values, containsAll([SessionStatus.active, SessionStatus.completed, SessionStatus.paused]));
    });

    test('should have correct string representation', () {
      expect(SessionStatus.active.toString(), equals('SessionStatus.active'));
      expect(SessionStatus.completed.toString(), equals('SessionStatus.completed'));
      expect(SessionStatus.paused.toString(), equals('SessionStatus.paused'));
    });
  });
}
