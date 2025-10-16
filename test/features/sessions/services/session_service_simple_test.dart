import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/exercise/models/exercise_set.dart';
import 'package:liftly/features/sessions/models/workout_session.dart';

void main() {
  group('SessionService Logic Tests', () {
    group('Session Calculations', () {
      test('should calculate session duration correctly', () {
        // Arrange
        final startTime = DateTime(2024, 1, 1, 10, 0);
        final endTime = DateTime(2024, 1, 1, 11, 30);
        final session = WorkoutSession(
          id: 'session-1',
          name: 'Test Session',
          startTime: startTime,
          endTime: endTime,
          exerciseSets: [],
          status: SessionStatus.completed,
        );

        // Act
        final duration = session.duration;

        // Assert
        expect(duration, equals(Duration(minutes: 90)));
      });

      test('should return null duration when endTime is null', () {
        // Arrange
        final session = WorkoutSession(
          id: 'session-1',
          name: 'Test Session',
          startTime: DateTime.now(),
          endTime: null,
          exerciseSets: [],
          status: SessionStatus.active,
        );

        // Act
        final duration = session.duration;

        // Assert
        expect(duration, isNull);
      });

      test('should identify active sessions correctly', () {
        // Arrange
        final activeSession = WorkoutSession(
          id: 'session-1',
          name: 'Active Session',
          startTime: DateTime.now(),
          exerciseSets: [],
          status: SessionStatus.active,
        );

        // Act & Assert
        expect(activeSession.isActive, isTrue);
        expect(activeSession.isCompleted, isFalse);
      });

      test('should identify completed sessions correctly', () {
        // Arrange
        final completedSession = WorkoutSession(
          id: 'session-1',
          name: 'Completed Session',
          startTime: DateTime.now().subtract(Duration(hours: 1)),
          endTime: DateTime.now(),
          exerciseSets: [],
          status: SessionStatus.completed,
        );

        // Act & Assert
        expect(completedSession.isCompleted, isTrue);
        expect(completedSession.isActive, isFalse);
      });
    });

    group('Session Data Processing', () {
      test('should filter sessions by status correctly', () {
        // Arrange
        final sessions = [
          WorkoutSession(
            id: 'session-1',
            name: 'Active Session',
            startTime: DateTime.now(),
            exerciseSets: [],
            status: SessionStatus.active,
          ),
          WorkoutSession(
            id: 'session-2',
            name: 'Completed Session',
            startTime: DateTime.now().subtract(Duration(hours: 1)),
            endTime: DateTime.now(),
            exerciseSets: [],
            status: SessionStatus.completed,
          ),
          WorkoutSession(
            id: 'session-3',
            name: 'Paused Session',
            startTime: DateTime.now().subtract(Duration(minutes: 30)),
            exerciseSets: [],
            status: SessionStatus.paused,
          ),
        ];

        // Act
        final activeSessions = sessions.where((s) => s.isActive).toList();
        final completedSessions = sessions.where((s) => s.isCompleted).toList();
        final pausedSessions = sessions.where((s) => s.status == SessionStatus.paused).toList();

        // Assert
        expect(activeSessions.length, equals(1));
        expect(activeSessions.first.id, equals('session-1'));

        expect(completedSessions.length, equals(1));
        expect(completedSessions.first.id, equals('session-2'));

        expect(pausedSessions.length, equals(1));
        expect(pausedSessions.first.id, equals('session-3'));
      });

      test('should sort sessions by start time correctly', () {
        // Arrange
        final now = DateTime.now();
        final sessions = [
          WorkoutSession(
            id: 'session-1',
            name: 'Oldest Session',
            startTime: now.subtract(Duration(hours: 2)),
            exerciseSets: [],
            status: SessionStatus.completed,
          ),
          WorkoutSession(
            id: 'session-2',
            name: 'Newest Session',
            startTime: now,
            exerciseSets: [],
            status: SessionStatus.active,
          ),
          WorkoutSession(
            id: 'session-3',
            name: 'Middle Session',
            startTime: now.subtract(Duration(hours: 1)),
            exerciseSets: [],
            status: SessionStatus.completed,
          ),
        ];

        // Act
        final sortedSessions = List<WorkoutSession>.from(sessions)..sort((a, b) => b.startTime.compareTo(a.startTime));

        // Assert
        expect(sortedSessions[0].id, equals('session-2')); // Newest first
        expect(sortedSessions[1].id, equals('session-3')); // Middle
        expect(sortedSessions[2].id, equals('session-1')); // Oldest last
      });

      test('should filter sessions by date range correctly', () {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);

        final sessions = [
          WorkoutSession(
            id: 'session-1',
            name: 'Session in Range',
            startTime: DateTime(2024, 1, 15),
            exerciseSets: [],
            status: SessionStatus.completed,
          ),
          WorkoutSession(
            id: 'session-2',
            name: 'Session out of Range',
            startTime: DateTime(2024, 2, 1),
            exerciseSets: [],
            status: SessionStatus.completed,
          ),
          WorkoutSession(
            id: 'session-3',
            name: 'Another Session in Range',
            startTime: DateTime(2024, 1, 20),
            exerciseSets: [],
            status: SessionStatus.completed,
          ),
        ];

        // Act
        final sessionsInRange =
            sessions.where((session) {
              return session.startTime.isAfter(startDate) && session.startTime.isBefore(endDate);
            }).toList();

        // Assert
        expect(sessionsInRange.length, equals(2));
        expect(sessionsInRange.any((s) => s.id == 'session-1'), isTrue);
        expect(sessionsInRange.any((s) => s.id == 'session-3'), isTrue);
        expect(sessionsInRange.any((s) => s.id == 'session-2'), isFalse);
      });

      test('should limit recent sessions correctly', () {
        // Arrange
        final now = DateTime.now();
        final sessions = List.generate(
          15,
          (index) => WorkoutSession(
            id: 'session-$index',
            name: 'Session $index',
            startTime: now.subtract(Duration(hours: index)),
            exerciseSets: [],
            status: SessionStatus.completed,
          ),
        );

        // Act
        final recentSessions = sessions.take(10).toList();

        // Assert
        expect(recentSessions.length, equals(10));
        expect(recentSessions[0].id, equals('session-0')); // Most recent
        expect(recentSessions[9].id, equals('session-9'));
      });
    });

    group('Session Statistics', () {
      test('should calculate total workout time correctly', () {
        // Arrange
        final now = DateTime.now();
        final sessions = [
          WorkoutSession(
            id: 'session-1',
            name: 'Session 1',
            startTime: now.subtract(Duration(hours: 2)),
            endTime: now.subtract(Duration(hours: 1)),
            exerciseSets: [],
            status: SessionStatus.completed,
          ),
          WorkoutSession(
            id: 'session-2',
            name: 'Session 2',
            startTime: now.subtract(Duration(hours: 3)),
            endTime: now.subtract(Duration(hours: 2, minutes: 30)),
            exerciseSets: [],
            status: SessionStatus.completed,
          ),
          WorkoutSession(
            id: 'session-3',
            name: 'Active Session',
            startTime: now.subtract(Duration(hours: 1)),
            exerciseSets: [],
            status: SessionStatus.active, // Not completed
          ),
        ];

        // Act
        final completedSessions = sessions.where((s) => s.isCompleted).toList();
        Duration totalTime = Duration.zero;
        for (final session in completedSessions) {
          if (session.duration != null) {
            totalTime = totalTime + session.duration!;
          }
        }

        // Assert
        expect(totalTime, equals(Duration(hours: 1, minutes: 30))); // 1 hour + 30 minutes
      });

      test('should calculate total weight lifted correctly', () {
        // Arrange
        final sessions = [
          WorkoutSession(
            id: 'session-1',
            name: 'Session 1',
            startTime: DateTime.now(),
            exerciseSets: [],
            status: SessionStatus.completed,
            totalWeight: 100.0,
          ),
          WorkoutSession(
            id: 'session-2',
            name: 'Session 2',
            startTime: DateTime.now(),
            exerciseSets: [],
            status: SessionStatus.completed,
            totalWeight: 150.0,
          ),
          WorkoutSession(
            id: 'session-3',
            name: 'Active Session',
            startTime: DateTime.now(),
            exerciseSets: [],
            status: SessionStatus.active, // Not completed
            totalWeight: 200.0,
          ),
        ];

        // Act
        final completedSessions = sessions.where((s) => s.isCompleted).toList();
        double totalWeight = 0.0;
        for (final session in completedSessions) {
          if (session.totalWeight != null) {
            totalWeight += session.totalWeight!;
          }
        }

        // Assert
        expect(totalWeight, equals(250.0)); // 100.0 + 150.0
      });
    });

    group('Session State Management', () {
      test('should handle session state transitions correctly', () {
        // Arrange
        final session = WorkoutSession(
          id: 'session-1',
          name: 'Test Session',
          startTime: DateTime.now(),
          exerciseSets: [],
          status: SessionStatus.active,
        );

        // Act - Transition to paused
        final pausedSession = session.copyWith(status: SessionStatus.paused);

        // Act - Transition to completed
        final completedSession = pausedSession.copyWith(status: SessionStatus.completed, endTime: DateTime.now());

        // Assert
        expect(session.isActive, isTrue);
        expect(pausedSession.status, equals(SessionStatus.paused));
        expect(completedSession.isCompleted, isTrue);
        expect(completedSession.endTime, isNotNull);
      });

      test('should preserve session data during state changes', () {
        // Arrange
        final originalSession = WorkoutSession(
          id: 'session-1',
          name: 'Test Session',
          startTime: DateTime.now(),
          exerciseSets: [
            ExerciseSet(
              id: 'set-1',
              exerciseId: 'exercise-1',
              weight: 60.0,
              reps: 10,
              completedAt: DateTime.now(),
              isCompleted: true,
            ),
          ],
          status: SessionStatus.active,
          totalWeight: 600.0,
          totalReps: 10,
        );

        // Act
        final updatedSession = originalSession.copyWith(status: SessionStatus.completed, endTime: DateTime.now());

        // Assert
        expect(updatedSession.id, equals(originalSession.id));
        expect(updatedSession.name, equals(originalSession.name));
        expect(updatedSession.startTime, equals(originalSession.startTime));
        expect(updatedSession.exerciseSets, equals(originalSession.exerciseSets));
        expect(updatedSession.totalWeight, equals(originalSession.totalWeight));
        expect(updatedSession.totalReps, equals(originalSession.totalReps));
        expect(updatedSession.status, equals(SessionStatus.completed));
        expect(updatedSession.endTime, isNotNull);
      });
    });
  });
}
