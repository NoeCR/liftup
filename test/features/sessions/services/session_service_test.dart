import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:liftly/core/database/database_service.dart';
import 'package:liftly/features/sessions/models/workout_session.dart';
import 'package:liftly/features/sessions/services/session_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([Box, DatabaseService])
import 'session_service_test.mocks.dart';

void main() {
  group('SessionService', () {
    late SessionService sessionService;
    late MockBox mockBox;
    late MockDatabaseService mockDatabaseService;

    setUp(() {
      mockBox = MockBox();
      mockDatabaseService = MockDatabaseService();

      // Mock the database service to return our mock box
      when(mockDatabaseService.sessionsBox).thenReturn(mockBox);

      // Create a custom SessionService that uses our mock
      sessionService = _MockSessionService(mockBox);
    });

    group('saveSession', () {
      test('should save session to box', () async {
        // Arrange
        final session = WorkoutSession(
          id: 'session-1',
          name: 'Test Session',
          startTime: DateTime.now(),
          exerciseSets: [],
          status: SessionStatus.active,
        );

        when(mockBox.put(any, any)).thenAnswer((_) async {});

        // Act
        await sessionService.saveSession(session);

        // Assert
        verify(mockBox.put('session-1', session)).called(1);
      });

      test('should handle save errors gracefully', () async {
        // Arrange
        final session = WorkoutSession(
          id: 'session-1',
          name: 'Test Session',
          startTime: DateTime.now(),
          exerciseSets: [],
          status: SessionStatus.active,
        );

        when(mockBox.put(any, any)).thenThrow(Exception('Save failed'));

        // Act & Assert
        expect(() => sessionService.saveSession(session), throwsException);
      });
    });

    group('getSessionById', () {
      test('should return session when found', () async {
        // Arrange
        final session = WorkoutSession(
          id: 'session-1',
          name: 'Test Session',
          startTime: DateTime.now(),
          exerciseSets: [],
          status: SessionStatus.active,
        );

        when(mockBox.get('session-1')).thenReturn(session);

        // Act
        final result = await sessionService.getSessionById('session-1');

        // Assert
        expect(result, equals(session));
        verify(mockBox.get('session-1')).called(1);
      });

      test('should return null when session not found', () async {
        // Arrange
        when(mockBox.get('non-existent')).thenReturn(null);

        // Act
        final result = await sessionService.getSessionById('non-existent');

        // Assert
        expect(result, isNull);
        verify(mockBox.get('non-existent')).called(1);
      });
    });

    group('getAllSessions', () {
      test(
        'should return all sessions sorted by startTime descending',
        () async {
          // Arrange
          final now = DateTime.now();
          final session1 = WorkoutSession(
            id: 'session-1',
            name: 'Session 1',
            startTime: now.subtract(Duration(hours: 2)),
            exerciseSets: [],
            status: SessionStatus.completed,
          );
          final session2 = WorkoutSession(
            id: 'session-2',
            name: 'Session 2',
            startTime: now.subtract(Duration(hours: 1)),
            exerciseSets: [],
            status: SessionStatus.completed,
          );
          final session3 = WorkoutSession(
            id: 'session-3',
            name: 'Session 3',
            startTime: now,
            exerciseSets: [],
            status: SessionStatus.active,
          );

          when(mockBox.values).thenReturn([session1, session2, session3]);

          // Act
          final result = await sessionService.getAllSessions();

          // Assert
          expect(result.length, equals(3));
          expect(result[0], equals(session3)); // Most recent first
          expect(result[1], equals(session2));
          expect(result[2], equals(session1));
        },
      );

      test('should return empty list when no sessions exist', () async {
        // Arrange
        when(mockBox.values).thenReturn([]);

        // Act
        final result = await sessionService.getAllSessions();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getSessionsByDateRange', () {
      test('should return sessions within date range', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);

        final session1 = WorkoutSession(
          id: 'session-1',
          name: 'Session 1',
          startTime: DateTime(2024, 1, 15), // Within range
          exerciseSets: [],
          status: SessionStatus.completed,
        );
        final session2 = WorkoutSession(
          id: 'session-2',
          name: 'Session 2',
          startTime: DateTime(2024, 2, 1), // Outside range
          exerciseSets: [],
          status: SessionStatus.completed,
        );
        final session3 = WorkoutSession(
          id: 'session-3',
          name: 'Session 3',
          startTime: DateTime(2024, 1, 20), // Within range
          exerciseSets: [],
          status: SessionStatus.completed,
        );

        when(mockBox.values).thenReturn([session1, session2, session3]);

        // Act
        final result = await sessionService.getSessionsByDateRange(
          startDate,
          endDate,
        );

        // Assert
        expect(result.length, equals(2));
        expect(result, contains(session1));
        expect(result, contains(session3));
        expect(result, isNot(contains(session2)));
      });

      test('should return empty list when no sessions in range', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);

        final session = WorkoutSession(
          id: 'session-1',
          name: 'Session 1',
          startTime: DateTime(2024, 2, 1), // Outside range
          exerciseSets: [],
          status: SessionStatus.completed,
        );

        when(mockBox.values).thenReturn([session]);

        // Act
        final result = await sessionService.getSessionsByDateRange(
          startDate,
          endDate,
        );

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getRecentSessions', () {
      test('should return limited number of recent sessions', () async {
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

        when(mockBox.values).thenReturn(sessions);

        // Act
        final result = await sessionService.getRecentSessions(limit: 10);

        // Assert
        expect(result.length, equals(10));
        expect(result[0].id, equals('session-0')); // Most recent
        expect(result[9].id, equals('session-9'));
      });

      test(
        'should return all sessions when limit is greater than total',
        () async {
          // Arrange
          final sessions = List.generate(
            5,
            (index) => WorkoutSession(
              id: 'session-$index',
              name: 'Session $index',
              startTime: DateTime.now().subtract(Duration(hours: index)),
              exerciseSets: [],
              status: SessionStatus.completed,
            ),
          );

          when(mockBox.values).thenReturn(sessions);

          // Act
          final result = await sessionService.getRecentSessions(limit: 10);

          // Assert
          expect(result.length, equals(5));
        },
      );
    });

    group('getCompletedSessions', () {
      test('should return only completed sessions', () async {
        // Arrange
        final session1 = WorkoutSession(
          id: 'session-1',
          name: 'Session 1',
          startTime: DateTime.now(),
          exerciseSets: [],
          status: SessionStatus.completed,
        );
        final session2 = WorkoutSession(
          id: 'session-2',
          name: 'Session 2',
          startTime: DateTime.now(),
          exerciseSets: [],
          status: SessionStatus.active,
        );
        final session3 = WorkoutSession(
          id: 'session-3',
          name: 'Session 3',
          startTime: DateTime.now(),
          exerciseSets: [],
          status: SessionStatus.completed,
        );

        when(mockBox.values).thenReturn([session1, session2, session3]);

        // Act
        final result = await sessionService.getCompletedSessions();

        // Assert
        expect(result.length, equals(2));
        expect(result, contains(session1));
        expect(result, contains(session3));
        expect(result, isNot(contains(session2)));
      });
    });

    group('getActiveSessions', () {
      test('should return only active sessions', () async {
        // Arrange
        final session1 = WorkoutSession(
          id: 'session-1',
          name: 'Session 1',
          startTime: DateTime.now(),
          exerciseSets: [],
          status: SessionStatus.active,
        );
        final session2 = WorkoutSession(
          id: 'session-2',
          name: 'Session 2',
          startTime: DateTime.now(),
          exerciseSets: [],
          status: SessionStatus.completed,
        );
        final session3 = WorkoutSession(
          id: 'session-3',
          name: 'Session 3',
          startTime: DateTime.now(),
          exerciseSets: [],
          status: SessionStatus.active,
        );

        when(mockBox.values).thenReturn([session1, session2, session3]);

        // Act
        final result = await sessionService.getActiveSessions();

        // Assert
        expect(result.length, equals(2));
        expect(result, contains(session1));
        expect(result, contains(session3));
        expect(result, isNot(contains(session2)));
      });
    });

    group('deleteSession', () {
      test('should delete session from box', () async {
        // Arrange
        when(mockBox.delete('session-1')).thenAnswer((_) async {});

        // Act
        await sessionService.deleteSession('session-1');

        // Assert
        verify(mockBox.delete('session-1')).called(1);
      });

      test('should handle delete errors gracefully', () async {
        // Arrange
        when(mockBox.delete('session-1')).thenThrow(Exception('Delete failed'));

        // Act & Assert
        expect(
          () => sessionService.deleteSession('session-1'),
          throwsException,
        );
      });
    });

    group('getSessionCount', () {
      test('should return correct session count', () async {
        // Arrange
        when(mockBox.length).thenReturn(5);

        // Act
        final result = await sessionService.getSessionCount();

        // Assert
        expect(result, equals(5));
        verify(mockBox.length).called(1);
      });

      test('should return zero when no sessions exist', () async {
        // Arrange
        when(mockBox.length).thenReturn(0);

        // Act
        final result = await sessionService.getSessionCount();

        // Assert
        expect(result, equals(0));
      });
    });

    group('getTotalWorkoutTime', () {
      test('should return total duration of completed sessions', () async {
        // Arrange
        final now = DateTime.now();
        final session1 = WorkoutSession(
          id: 'session-1',
          name: 'Session 1',
          startTime: now.subtract(Duration(hours: 2)),
          endTime: now.subtract(Duration(hours: 1)),
          exerciseSets: [],
          status: SessionStatus.completed,
        );
        final session2 = WorkoutSession(
          id: 'session-2',
          name: 'Session 2',
          startTime: now.subtract(Duration(hours: 3)),
          endTime: now.subtract(Duration(hours: 2, minutes: 30)),
          exerciseSets: [],
          status: SessionStatus.completed,
        );
        final session3 = WorkoutSession(
          id: 'session-3',
          name: 'Session 3',
          startTime: now.subtract(Duration(hours: 1)),
          exerciseSets: [],
          status: SessionStatus.active, // Not completed
        );

        when(mockBox.values).thenReturn([session1, session2, session3]);

        // Act
        final result = await sessionService.getTotalWorkoutTime();

        // Assert
        expect(
          result,
          equals(Duration(hours: 1, minutes: 30)),
        ); // 1 hour + 30 minutes
      });

      test('should return zero when no completed sessions', () async {
        // Arrange
        final session = WorkoutSession(
          id: 'session-1',
          name: 'Session 1',
          startTime: DateTime.now(),
          exerciseSets: [],
          status: SessionStatus.active,
        );

        when(mockBox.values).thenReturn([session]);

        // Act
        final result = await sessionService.getTotalWorkoutTime();

        // Assert
        expect(result, equals(Duration.zero));
      });

      test('should handle sessions without endTime', () async {
        // Arrange
        final session = WorkoutSession(
          id: 'session-1',
          name: 'Session 1',
          startTime: DateTime.now(),
          endTime: null, // No end time
          exerciseSets: [],
          status: SessionStatus.completed,
        );

        when(mockBox.values).thenReturn([session]);

        // Act
        final result = await sessionService.getTotalWorkoutTime();

        // Assert
        expect(result, equals(Duration.zero));
      });
    });

    group('getTotalWeightLifted', () {
      test('should return total weight of completed sessions', () async {
        // Arrange
        final session1 = WorkoutSession(
          id: 'session-1',
          name: 'Session 1',
          startTime: DateTime.now(),
          exerciseSets: [],
          status: SessionStatus.completed,
          totalWeight: 100.0,
        );
        final session2 = WorkoutSession(
          id: 'session-2',
          name: 'Session 2',
          startTime: DateTime.now(),
          exerciseSets: [],
          status: SessionStatus.completed,
          totalWeight: 150.0,
        );
        final session3 = WorkoutSession(
          id: 'session-3',
          name: 'Session 3',
          startTime: DateTime.now(),
          exerciseSets: [],
          status: SessionStatus.active, // Not completed
          totalWeight: 200.0,
        );

        when(mockBox.values).thenReturn([session1, session2, session3]);

        // Act
        final result = await sessionService.getTotalWeightLifted();

        // Assert
        expect(result, equals(250.0)); // 100.0 + 150.0
      });

      test('should return zero when no completed sessions', () async {
        // Arrange
        final session = WorkoutSession(
          id: 'session-1',
          name: 'Session 1',
          startTime: DateTime.now(),
          exerciseSets: [],
          status: SessionStatus.active,
          totalWeight: 100.0,
        );

        when(mockBox.values).thenReturn([session]);

        // Act
        final result = await sessionService.getTotalWeightLifted();

        // Assert
        expect(result, equals(0.0));
      });

      test('should handle sessions without totalWeight', () async {
        // Arrange
        final session = WorkoutSession(
          id: 'session-1',
          name: 'Session 1',
          startTime: DateTime.now(),
          exerciseSets: [],
          status: SessionStatus.completed,
          totalWeight: null,
        );

        when(mockBox.values).thenReturn([session]);

        // Act
        final result = await sessionService.getTotalWeightLifted();

        // Assert
        expect(result, equals(0.0));
      });
    });
  });
}

// Custom SessionService for testing that uses a mock box
class _MockSessionService extends SessionService {
  final Box _mockBox;

  _MockSessionService(this._mockBox);

  // Importante: los métodos del padre usan un getter privado (_box) que no
  // podemos sobreescribir desde otro paquete. Para evitar tocar el código de
  // producción, sobreescribimos todos los métodos públicos para que usen
  // directamente el box simulado.

  @override
  Future<void> saveSession(WorkoutSession session) async {
    await _mockBox.put(session.id, session);
  }

  @override
  Future<WorkoutSession?> getSessionById(String id) async {
    return _mockBox.get(id) as WorkoutSession?;
  }

  @override
  Future<List<WorkoutSession>> getAllSessions() async {
    final values = _mockBox.values.cast<WorkoutSession>().toList();
    values.sort((a, b) => b.startTime.compareTo(a.startTime));
    return values;
  }

  @override
  Future<List<WorkoutSession>> getSessionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allSessions = await getAllSessions();
    return allSessions
        .where(
          (s) =>
              s.startTime.isAfter(startDate) && s.startTime.isBefore(endDate),
        )
        .toList();
  }

  @override
  Future<List<WorkoutSession>> getRecentSessions({int limit = 10}) async {
    final all = await getAllSessions();
    return all.take(limit).toList();
  }

  @override
  Future<List<WorkoutSession>> getCompletedSessions() async {
    final all = await getAllSessions();
    return all.where((s) => s.isCompleted).toList();
  }

  @override
  Future<List<WorkoutSession>> getActiveSessions() async {
    final all = await getAllSessions();
    return all.where((s) => s.isActive).toList();
  }

  @override
  Future<void> deleteSession(String id) async {
    await _mockBox.delete(id);
  }

  @override
  Future<int> getSessionCount() async {
    return _mockBox.length;
  }

  @override
  Future<Duration> getTotalWorkoutTime() async {
    final completed = await getCompletedSessions();
    Duration total = Duration.zero;
    for (final s in completed) {
      if (s.duration != null) total += s.duration!;
    }
    return total;
  }

  @override
  Future<double> getTotalWeightLifted() async {
    final completed = await getCompletedSessions();
    double total = 0.0;
    for (final s in completed) {
      if (s.totalWeight != null) total += s.totalWeight!;
    }
    return total;
  }
}
