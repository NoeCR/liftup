import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/exercise/models/exercise_set.dart';
import 'package:liftly/features/exercise/notifiers/exercise_notifier.dart';
import 'package:liftly/features/home/models/routine.dart';
import 'package:liftly/features/home/notifiers/routine_notifier.dart';
import 'package:liftly/features/sessions/models/workout_session.dart';
import 'package:liftly/features/sessions/notifiers/performed_sets_notifier.dart';
import 'package:liftly/features/sessions/notifiers/session_notifier.dart';
import 'package:liftly/features/sessions/services/session_service.dart';

// Mock implementations that extend the real classes
class MockSessionService extends SessionService {
  final List<WorkoutSession> _sessions = [];
  WorkoutSession? _currentSession;

  @override
  Future<void> saveSession(WorkoutSession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index >= 0) {
      _sessions[index] = session;
    } else {
      _sessions.add(session);
    }
    _currentSession = session;
  }

  @override
  Future<WorkoutSession?> getSessionById(String id) async {
    try {
      return _sessions.firstWhere((session) => session.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<WorkoutSession>> getAllSessions() async {
    final list = List<WorkoutSession>.from(_sessions);
    list.sort((a, b) => b.startTime.compareTo(a.startTime));
    return list;
  }

  @override
  Future<List<WorkoutSession>> getSessionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _sessions.where((session) {
      return session.startTime.isAfter(startDate) &&
          session.startTime.isBefore(endDate);
    }).toList();
  }

  @override
  Future<List<WorkoutSession>> getRecentSessions({int limit = 10}) async {
    final sortedSessions = List<WorkoutSession>.from(_sessions);
    sortedSessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sortedSessions.take(limit).toList();
  }

  @override
  Future<List<WorkoutSession>> getCompletedSessions() async {
    return _sessions.where((session) => session.isCompleted).toList();
  }

  @override
  Future<List<WorkoutSession>> getActiveSessions() async {
    return _sessions.where((session) => session.isActive).toList();
  }

  @override
  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((session) => session.id == id);
  }

  @override
  Future<int> getSessionCount() async {
    return _sessions.length;
  }

  @override
  Future<Duration> getTotalWorkoutTime() async {
    final totalMinutes = _sessions
        .where((session) => session.duration != null)
        .fold<int>(0, (sum, session) => sum + session.duration!.inMinutes);
    return Duration(minutes: totalMinutes);
  }

  @override
  Future<double> getTotalWeightLifted() async {
    return _sessions.fold<double>(
      0.0,
      (sum, session) => sum + (session.totalWeight ?? 0.0),
    );
  }

  // Helper methods for testing
  void clearSessions() {
    _sessions.clear();
    _currentSession = null;
  }

  void addTestSession(WorkoutSession session) {
    _sessions.add(session);
  }
}

// Fakes mínimos para evitar accesos a base de datos via notifiers transistivos
class _FakeRoutineNotifier extends RoutineNotifier {
  @override
  Future<List<Routine>> build() async => <Routine>[];
}

class _FakeExerciseNotifier extends ExerciseNotifier {
  @override
  Future<List<Exercise>> build() async => <Exercise>[];
}

class _FakePerformedSetsNotifier extends PerformedSetsNotifier {
  @override
  void clearAll() {}
}

void main() {
  group('SessionNotifier - Simple Tests', () {
    late ProviderContainer container;
    late MockSessionService mockSessionService;

    setUp(() {
      mockSessionService = MockSessionService();
      container = ProviderContainer(
        overrides: [
          sessionServiceProvider.overrideWith(() => mockSessionService),
          routineNotifierProvider.overrideWith(() => _FakeRoutineNotifier()),
          exerciseNotifierProvider.overrideWith(() => _FakeExerciseNotifier()),
          performedSetsNotifierProvider.overrideWith(
            (ref) => _FakePerformedSetsNotifier(),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Basic Functionality', () {
      test('should initialize with empty sessions list', () async {
        // Act
        final notifier = container.read(sessionNotifierProvider.notifier);
        final sessions = await container.read(sessionNotifierProvider.future);

        // Assert
        expect(sessions, isEmpty);
      });

      test('should start a new session', () async {
        // Arrange
        final notifier = container.read(sessionNotifierProvider.notifier);

        // Act
        final session = await notifier.startSession(name: 'Test Session');

        // Assert
        expect(session.name, equals('Test Session'));
        expect(session.status, equals(SessionStatus.active));
        expect(session.startTime, isNotNull);
        expect(session.endTime, isNull);
      });

      test('should add exercise set to current session', () async {
        // Arrange
        final notifier = container.read(sessionNotifierProvider.notifier);
        final session = await notifier.startSession(name: 'Test Session');

        final exerciseSet = ExerciseSet(
          id: 'set-1',
          exerciseId: 'exercise-1',
          weight: 100.0,
          reps: 10,
          restTimeSeconds: 60,
          completedAt: DateTime.now(),
          isCompleted: true,
        );

        // Act
        await notifier.addExerciseSet(exerciseSet);

        // Assert
        final updatedSession = await notifier.getCurrentOngoingSession();
        expect(updatedSession, isNotNull);
        expect(updatedSession!.exerciseSets, contains(exerciseSet));
      });

      test('should complete a session', () async {
        // Arrange
        final notifier = container.read(sessionNotifierProvider.notifier);
        final session = await notifier.startSession(name: 'Test Session');

        // Act
        await notifier.completeSession(notes: 'Great workout!');

        // Assert
        final completedSession = await notifier.getCurrentOngoingSession();
        expect(completedSession, isNull); // No ongoing session after completion

        final sessions = await container.read(sessionNotifierProvider.future);
        final completed = sessions.firstWhere((s) => s.id == session.id);
        expect(completed.status, equals(SessionStatus.completed));
        expect(completed.notes, equals('Great workout!'));
        expect(completed.endTime, isNotNull);
      });

      test('should pause and resume a session', () async {
        // Arrange
        final notifier = container.read(sessionNotifierProvider.notifier);
        final session = await notifier.startSession(name: 'Test Session');

        // Act - Pause
        await notifier.pauseSession();

        // Assert - Paused
        final pausedSession = await notifier.getCurrentOngoingSession();
        expect(pausedSession, isNotNull);
        expect(pausedSession!.status, equals(SessionStatus.paused));

        // Act - Resume
        await notifier.resumeSession();

        // Assert - Resumed
        final resumedSession = await notifier.getCurrentOngoingSession();
        expect(resumedSession, isNotNull);
        expect(resumedSession!.status, equals(SessionStatus.active));
      });

      test('should delete a session', () async {
        // Arrange
        final notifier = container.read(sessionNotifierProvider.notifier);
        final session = await notifier.startSession(name: 'Test Session');
        await notifier.completeSession();

        // Act
        await notifier.deleteSession(session.id);

        // Assert
        final sessions = await container.read(sessionNotifierProvider.future);
        expect(sessions, isEmpty);
      });

      test('should get sessions by date range', () async {
        // Arrange
        final notifier = container.read(sessionNotifierProvider.notifier);
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final tomorrow = now.add(const Duration(days: 1));

        // Create sessions
        await notifier.startSession(name: 'Session 1');
        await notifier.completeSession();

        await notifier.startSession(name: 'Session 2');
        await notifier.completeSession();

        // Act
        final sessionsInRange = await notifier.getSessionsByDateRange(
          yesterday,
          tomorrow,
        );

        // Assert
        expect(sessionsInRange, hasLength(2));
      });

      test('should get recent sessions with limit', () async {
        // Arrange
        final notifier = container.read(sessionNotifierProvider.notifier);

        // Create multiple sessions
        for (int i = 1; i <= 5; i++) {
          await notifier.startSession(name: 'Session $i');
          await notifier.completeSession();
        }

        // Act
        final recentSessions = await notifier.getRecentSessions(limit: 3);

        // Assert
        expect(recentSessions, hasLength(3));
        // Validar orden por fecha, no el nombre exacto
        expect(
          recentSessions.first.startTime.isAfter(recentSessions.last.startTime),
          isTrue,
        );
      });
    });

    group('Edge Cases', () {
      test('should handle no current session gracefully', () async {
        // Arrange
        final notifier = container.read(sessionNotifierProvider.notifier);
        final exerciseSet = ExerciseSet(
          id: 'set-1',
          exerciseId: 'exercise-1',
          weight: 100.0,
          reps: 10,
          restTimeSeconds: 60,
          completedAt: DateTime.now(),
          isCompleted: true,
        );

        // Act & Assert - Should not throw
        await notifier.addExerciseSet(exerciseSet);
        await notifier.updateExerciseSet(exerciseSet);
        await notifier.pauseSession();
        await notifier.resumeSession();
        await notifier.completeSession();

        final currentSession = await notifier.getCurrentOngoingSession();
        expect(currentSession, isNull);
      });

      test('should handle session operations when no sessions exist', () async {
        // Arrange
        final notifier = container.read(sessionNotifierProvider.notifier);

        // Act
        final sessions = await container.read(sessionNotifierProvider.future);
        final recentSessions = await notifier.getRecentSessions(limit: 5);

        // Assert
        expect(sessions, isEmpty);
        expect(recentSessions, isEmpty);
      });
    });

    group('Session State Management', () {
      test('should maintain session state consistency', () async {
        // Arrange
        final notifier = container.read(sessionNotifierProvider.notifier);

        // Act - Start session
        final session = await notifier.startSession(name: 'Test Session');
        expect(session.status, equals(SessionStatus.active));

        // Act - Add exercise set
        final exerciseSet = ExerciseSet(
          id: 'set-1',
          exerciseId: 'exercise-1',
          weight: 100.0,
          reps: 10,
          restTimeSeconds: 60,
          completedAt: DateTime.now(),
          isCompleted: true,
        );
        await notifier.addExerciseSet(exerciseSet);

        // Assert - Session should still be active
        final currentSession = await notifier.getCurrentOngoingSession();
        expect(currentSession!.status, equals(SessionStatus.active));
        expect(currentSession.exerciseSets, hasLength(1));

        // Act - Complete session
        await notifier.completeSession();

        // Assert - No ongoing session
        final finalSession = await notifier.getCurrentOngoingSession();
        expect(finalSession, isNull);
      });

      test('should handle multiple exercise sets', () async {
        // Arrange
        final notifier = container.read(sessionNotifierProvider.notifier);
        await notifier.startSession(name: 'Test Session');

        // Act - Add multiple sets
        for (int i = 1; i <= 3; i++) {
          final exerciseSet = ExerciseSet(
            id: 'set-$i',
            exerciseId: 'exercise-1',
            weight: 100.0 + (i * 5.0),
            reps: 10,
            restTimeSeconds: 60,
            completedAt: DateTime.now(),
            isCompleted: true,
          );
          await notifier.addExerciseSet(exerciseSet);
        }

        // Assert
        final currentSession = await notifier.getCurrentOngoingSession();
        expect(currentSession!.exerciseSets, hasLength(3));
        final weights =
            currentSession.exerciseSets.map((e) => e.weight).toList();
        expect(weights, containsAll(<double>[105.0, 110.0, 115.0]));
      });
    });
  });
}
