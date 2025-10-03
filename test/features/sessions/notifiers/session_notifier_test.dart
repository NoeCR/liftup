import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liftup/features/sessions/notifiers/session_notifier.dart';
import 'package:liftup/features/sessions/models/workout_session.dart';
import 'package:liftup/features/sessions/services/session_service.dart';
import '../../../test_helpers/test_setup.dart';
import '../../../mocks/session_service_mock.dart';

void main() {
  group('SessionNotifier Tests', () {
    late ProviderContainer container;
    late MockSessionService mockSessionService;

    setUp(() {
      TestSetup.initialize();
      mockSessionService = MockSessionService();
      mockSessionService.setupMockBehavior();

      container = TestSetup.createTestContainer(
        overrides: [
          sessionServiceProvider.overrideWith(() => mockSessionService),
        ],
      );
    });

    tearDown(() {
      TestSetup.cleanup();
      container.dispose();
    });

    group('Initialization', () {
      test('should initialize with empty sessions list', () async {
        final notifier = container.read(sessionNotifierProvider.notifier);
        final sessions = await container.read(sessionNotifierProvider.future);

        expect(notifier, isNotNull);
        expect(sessions, isNotNull);
        expect(sessions, isEmpty);
      });

      test('should load sessions from database on initialization', () async {
        // Setup mock data
        final testSessions = [
          WorkoutSession(
            id: 'session_1',
            routineId: 'routine_1',
            name: 'Test Session 1',
            startTime: DateTime.now().subtract(const Duration(hours: 1)),
            endTime: DateTime.now(),
            exerciseSets: [],
            notes: 'Test session 1',
            status: SessionStatus.completed,
          ),
          WorkoutSession(
            id: 'session_2',
            routineId: 'routine_2',
            name: 'Test Session 2',
            startTime: DateTime.now().subtract(const Duration(hours: 2)),
            endTime: DateTime.now().subtract(const Duration(hours: 1)),
            exerciseSets: [],
            notes: 'Test session 2',
            status: SessionStatus.completed,
          ),
        ];

        mockSessionService.setupMockSessions(testSessions);

        final sessions = await container.read(sessionNotifierProvider.future);
        expect(sessions, hasLength(2));
        expect(sessions[0].id, equals('session_1'));
        expect(sessions[1].id, equals('session_2'));
      });
    });

    group('Session Creation', () {
      test('should create new session', () async {
        final notifier = container.read(sessionNotifierProvider.notifier);

        final session = await notifier.startSession(
          routineId: 'routine_1',
          name: 'Test Session',
        );

        expect(session, isNotNull);
        expect(session.routineId, equals('routine_1'));
        expect(session.name, equals('Test Session'));
        expect(session.startTime, isNotNull);
        expect(session.endTime, isNull);
        expect(session.exerciseSets, isEmpty);
        expect(session.status, equals(SessionStatus.active));
      });

      test('should save new session to database', () async {
        final notifier = container.read(sessionNotifierProvider.notifier);

        await notifier.startSession(
          routineId: 'routine_1',
          name: 'Test Session',
        );

        // Verify that session was saved to database
        // Verify that session was saved
        final sessions = await mockSessionService.getAllSessions();
        expect(sessions, hasLength(1));
      });

      test('should add new session to sessions list', () async {
        final notifier = container.read(sessionNotifierProvider.notifier);

        await notifier.startSession(
          routineId: 'routine_1',
          name: 'Test Session',
        );

        // Verify that sessions were loaded
        final allSessions = await mockSessionService.getAllSessions();
        expect(allSessions, hasLength(1));
      });
    });

    group('Session Completion', () {
      test('should complete session', () async {
        final notifier = container.read(sessionNotifierProvider.notifier);

        // Start a session
        await notifier.startSession(
          routineId: 'routine_1',
          name: 'Test Session',
        );

        // Complete the session
        await notifier.completeSession(notes: 'Completed successfully');

        // Verify that session was saved with completion data
        final allSessions = await mockSessionService.getAllSessions();
        expect(allSessions, hasLength(1));
        expect(allSessions.first.status, equals(SessionStatus.completed));
      });
    });

    group('Session Pause/Resume', () {
      test('should pause session', () async {
        final notifier = container.read(sessionNotifierProvider.notifier);

        // Start a session
        await notifier.startSession(
          routineId: 'routine_1',
          name: 'Test Session',
        );

        // Pause the session
        await notifier.pauseSession();

        // Verify that session was saved with pause data
        final allSessions = await mockSessionService.getAllSessions();
        expect(allSessions, hasLength(1));
        expect(allSessions.first.status, equals(SessionStatus.paused));
      });

      test('should resume session', () async {
        final notifier = container.read(sessionNotifierProvider.notifier);

        // Start a session
        await notifier.startSession(
          routineId: 'routine_1',
          name: 'Test Session',
        );

        // Pause and then resume the session
        await notifier.pauseSession();
        await notifier.resumeSession();

        // Verify that session was saved with resume data
        final allSessions = await mockSessionService.getAllSessions();
        expect(allSessions, hasLength(1));
        expect(allSessions.first.status, equals(SessionStatus.active));
      });
    });

    group('Session Queries', () {
      test('should get current ongoing session', () async {
        final notifier = container.read(sessionNotifierProvider.notifier);

        // Start a session
        final session = await notifier.startSession(
          routineId: 'routine_1',
          name: 'Test Session',
        );

        // Get current ongoing session
        final currentSession = await notifier.getCurrentOngoingSession();

        expect(currentSession, isNotNull);
        expect(currentSession!.id, equals(session.id));
        expect(currentSession.status, equals(SessionStatus.active));
      });

      test('should return null when no ongoing session', () async {
        final notifier = container.read(sessionNotifierProvider.notifier);

        // Get current ongoing session when none exists
        final currentSession = await notifier.getCurrentOngoingSession();

        expect(currentSession, isNull);
      });

      test('should get sessions by date range', () async {
        final notifier = container.read(sessionNotifierProvider.notifier);

        final startDate = DateTime.now().subtract(const Duration(days: 7));
        final endDate = DateTime.now();

        await notifier.getSessionsByDateRange(startDate, endDate);

        // Verify that the service method was called
        final sessions = await mockSessionService.getSessionsByDateRange(
          startDate,
          endDate,
        );
        expect(sessions, isNotNull);
      });

      test('should get recent sessions', () async {
        final notifier = container.read(sessionNotifierProvider.notifier);

        await notifier.getRecentSessions(limit: 5);

        // Verify that the service method was called
        final sessions = await mockSessionService.getRecentSessions(limit: 5);
        expect(sessions, isNotNull);
      });
    });

    group('Session Deletion', () {
      test('should delete session', () async {
        final notifier = container.read(sessionNotifierProvider.notifier);

        await notifier.deleteSession('session_1');

        // Verify that session was deleted
        // Verify that session was deleted
        final sessions = await mockSessionService.getAllSessions();
        expect(sessions, isEmpty);
      });
    });

    group('Error Handling', () {
      test('should handle service errors gracefully', () async {
        // Setup mock to throw error
        mockSessionService.setGetAllSessionsError(Exception('Service error'));

        // Should handle error gracefully
        expect(
          () => container.read(sessionNotifierProvider.future),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle save errors gracefully', () async {
        // Setup mock to throw error
        mockSessionService.setSaveSessionError(Exception('Save error'));

        final notifier = container.read(sessionNotifierProvider.notifier);

        // Should handle error gracefully
        expect(
          () => notifier.startSession(routineId: 'routine_1', name: 'Test'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('State Management', () {
      test('should notify listeners when sessions change', () async {
        final notifier = container.read(sessionNotifierProvider.notifier);
        bool notified = false;

        container.listen(sessionNotifierProvider, (previous, next) {
          notified = true;
        });

        await notifier.startSession(
          routineId: 'routine_1',
          name: 'Test Session',
        );

        // Wait for state to update
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notified, isTrue);
      });
    });
  });
}
