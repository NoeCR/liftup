import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  Future<void> saveSession(WorkoutSession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index >= 0) {
      _sessions[index] = session;
    } else {
      _sessions.add(session);
    }
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
    return List.from(_sessions.reversed); // Most recent first
  }

  @override
  Future<List<WorkoutSession>> getSessionsByDateRange(DateTime startDate, DateTime endDate) async {
    return _sessions
        .where((session) => session.startTime.isAfter(startDate) && session.startTime.isBefore(endDate))
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<List<WorkoutSession>> getRecentSessions({int limit = 10}) async {
    final sessions = List<WorkoutSession>.from(_sessions.reversed);
    return sessions.take(limit).toList();
  }

  @override
  Future<List<WorkoutSession>> getCompletedSessions() async {
    return _sessions.where((session) => session.status == SessionStatus.completed).toList().reversed.toList();
  }

  @override
  Future<List<WorkoutSession>> getActiveSessions() async {
    return _sessions.where((session) => session.status == SessionStatus.active).toList();
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
    return _sessions.fold<Duration>(Duration.zero, (sum, session) => sum + (session.duration ?? Duration.zero));
  }

  @override
  Future<double> getTotalWeightLifted() async {
    return _sessions.fold<double>(0.0, (sum, session) => sum + (session.totalWeight ?? 0.0));
  }

  // Helper methods for testing
  void clearSessions() {
    _sessions.clear();
  }

  void addTestSession(WorkoutSession session) {
    _sessions.add(session);
  }
}

// Fake notifiers that extend the real ones
class _FakeExerciseNotifier extends ExerciseNotifier {
  List<Exercise> get _value => _exercises ?? const <Exercise>[];
  List<Exercise>? _exercises;
  void setExercises(List<Exercise> value) => _exercises = value;

  @override
  Future<List<Exercise>> build() async => _value.cast<Exercise>();
}

class _FakeRoutineNotifier extends RoutineNotifier {
  List<Routine> get _value => _routines ?? const <Routine>[];
  List<Routine>? _routines;
  void setRoutines(List<Routine> value) => _routines = value;

  @override
  Future<List<Routine>> build() async => _value.cast<Routine>();
}

class _FakePerformedSetsNotifier extends PerformedSetsNotifier {
  Future<List<ExerciseSet>> build() async => [];
}

void main() {
  group('SessionNotifier - Simple Tests', () {
    ProviderContainer createContainer() {
      final mockService = MockSessionService();
      return ProviderContainer(
        overrides: [
          sessionServiceProvider.overrideWith(() => mockService),
          routineNotifierProvider.overrideWith(() => _FakeRoutineNotifier()),
          exerciseNotifierProvider.overrideWith(() => _FakeExerciseNotifier()),
          performedSetsNotifierProvider.overrideWith((ref) => _FakePerformedSetsNotifier()),
        ],
      );
    }

    group('Basic Functionality', () {
      test('should initialize with empty sessions list', () async {
        // Arrange
        final container = createContainer();

        // Act
        final sessions = await container.read(sessionNotifierProvider.future);

        // Assert
        expect(sessions, isEmpty);

        // Cleanup
        container.dispose();
      });

      test('should start a new session', () async {
        // Arrange
        final container = createContainer();
        final notifier = container.read(sessionNotifierProvider.notifier);

        // Act
        final session = await notifier.startSession(name: 'Test Session');

        // Assert
        expect(session.name, equals('Test Session'));
        expect(session.status, equals(SessionStatus.active));
        expect(session.startTime, isNotNull);
        expect(session.endTime, isNull);

        // Cleanup
        container.dispose();
      });

      test('should add exercise set to current session', () async {
        // Arrange
        final container = createContainer();
        final notifier = container.read(sessionNotifierProvider.notifier);
        await notifier.startSession(name: 'Test Session');

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
        final currentSession = await notifier.getCurrentOngoingSession();
        expect(currentSession, isNotNull);
        expect(currentSession!.exerciseSets, hasLength(1));
        expect(currentSession.exerciseSets.first.weight, equals(100.0));

        // Cleanup
        container.dispose();
      });

      test('should complete a session', () async {
        // Arrange
        final container = createContainer();
        final notifier = container.read(sessionNotifierProvider.notifier);
        await notifier.startSession(name: 'Test Session');

        // Act
        await notifier.completeSession(notes: 'Great workout!');

        // Assert
        final currentSession = await notifier.getCurrentOngoingSession();
        expect(currentSession, isNull); // No ongoing session after completion

        final sessions = await container.read(sessionNotifierProvider.future);
        final completed = sessions.firstWhere((s) => s.name == 'Test Session');
        expect(completed.status, equals(SessionStatus.completed));
        expect(completed.notes, equals('Great workout!'));
        expect(completed.endTime, isNotNull);

        // Cleanup
        container.dispose();
      });

      test('should pause and resume a session', () async {
        // Arrange
        final container = createContainer();
        final notifier = container.read(sessionNotifierProvider.notifier);
        await notifier.startSession(name: 'Test Session');

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

        // Cleanup
        container.dispose();
      });

      test('should delete a session', () async {
        // Arrange
        final container = createContainer();
        final notifier = container.read(sessionNotifierProvider.notifier);
        await notifier.startSession(name: 'Test Session');
        await notifier.completeSession();

        // Act
        final sessions = await container.read(sessionNotifierProvider.future);
        final sessionToDelete = sessions.first;
        await notifier.deleteSession(sessionToDelete.id);

        // Assert
        final sessionsAfterDelete = await container.read(sessionNotifierProvider.future);
        expect(sessionsAfterDelete, isEmpty);

        // Cleanup
        container.dispose();
      });

      test('should get sessions by date range', () async {
        // Arrange
        final container = createContainer();
        final notifier = container.read(sessionNotifierProvider.notifier);
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final tomorrow = now.add(const Duration(days: 1));

        // Create sessions with manual timestamps
        final session1 = WorkoutSession(
          id: 'session-1',
          name: 'Session 1',
          startTime: now.subtract(const Duration(hours: 1)),
          endTime: now.subtract(const Duration(minutes: 30)),
          status: SessionStatus.completed,
          exerciseSets: [],
        );

        final session2 = WorkoutSession(
          id: 'session-2',
          name: 'Session 2',
          startTime: now.subtract(const Duration(minutes: 30)),
          endTime: now,
          status: SessionStatus.completed,
          exerciseSets: [],
        );

        // Add sessions directly to mock service
        final mockService = container.read(sessionServiceProvider) as MockSessionService;
        mockService.addTestSession(session1);
        mockService.addTestSession(session2);

        // Act
        final sessionsInRange = await notifier.getSessionsByDateRange(yesterday, tomorrow);

        // Assert
        expect(sessionsInRange, hasLength(2));

        // Cleanup
        container.dispose();
      });

      test('should get recent sessions with limit', () async {
        // Arrange
        final container = createContainer();
        final notifier = container.read(sessionNotifierProvider.notifier);
        final now = DateTime.now();

        // Create sessions with manual timestamps
        final sessions = List.generate(
          5,
          (i) => WorkoutSession(
            id: 'session-$i',
            name: 'Session ${i + 1}',
            startTime: now.subtract(Duration(minutes: (4 - i) * 10)),
            endTime: now.subtract(Duration(minutes: (4 - i) * 10 - 5)),
            status: SessionStatus.completed,
            exerciseSets: [],
          ),
        );

        // Add sessions directly to mock service
        final mockService = container.read(sessionServiceProvider) as MockSessionService;
        for (final session in sessions) {
          mockService.addTestSession(session);
        }

        // Act
        final recentSessions = await notifier.getRecentSessions(limit: 3);

        // Assert
        expect(recentSessions, hasLength(3));
        // Validar que las sesiones están ordenadas por fecha descendente (más reciente primero)
        for (int i = 0; i < recentSessions.length - 1; i++) {
          expect(
            recentSessions[i].startTime.isAfter(recentSessions[i + 1].startTime) ||
                recentSessions[i].startTime.isAtSameMomentAs(recentSessions[i + 1].startTime),
            isTrue,
          );
        }

        // Cleanup
        container.dispose();
      });
    });

    group('Edge Cases', () {
      test('should handle no current session gracefully', () async {
        // Arrange
        final container = createContainer();
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
        final currentSession = await notifier.getCurrentOngoingSession();
        expect(currentSession, isNull);

        // Cleanup
        container.dispose();
      });

      test('should handle session operations when no sessions exist', () async {
        // Arrange
        final container = createContainer();
        final notifier = container.read(sessionNotifierProvider.notifier);

        // Act
        final sessions = await container.read(sessionNotifierProvider.future);
        final currentSession = await notifier.getCurrentOngoingSession();

        // Assert
        expect(sessions, isEmpty);
        expect(currentSession, isNull);

        // Cleanup
        container.dispose();
      });

      test('should maintain session state consistency', () async {
        // Arrange
        final container = createContainer();
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

        // Assert - Session should still be active and have the set
        final currentSession = await notifier.getCurrentOngoingSession();
        expect(currentSession, isNotNull);
        expect(currentSession!.status, equals(SessionStatus.active));
        expect(currentSession.exerciseSets, hasLength(1));

        // Act - Complete session
        await notifier.completeSession();

        // Assert - No current session, but completed session exists
        final completedSession = await notifier.getCurrentOngoingSession();
        expect(completedSession, isNull);

        final allSessions = await container.read(sessionNotifierProvider.future);
        expect(allSessions, hasLength(1));
        expect(allSessions.first.status, equals(SessionStatus.completed));

        // Cleanup
        container.dispose();
      });

      test('should handle multiple exercise sets', () async {
        // Arrange
        final container = createContainer();
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

        // Validar que los sets están presentes (sin depender del orden exacto)
        final weights = currentSession.exerciseSets.map((s) => s.weight).toList();
        expect(weights, contains(105.0));
        expect(weights, contains(110.0));
        expect(weights, contains(115.0));

        // Cleanup
        container.dispose();
      });
    });
  });
}
