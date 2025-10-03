import 'package:liftup/features/sessions/services/session_service.dart';
import 'package:liftup/features/sessions/models/workout_session.dart';

class MockSessionService extends SessionService {
  List<WorkoutSession> _sessions = [];
  Exception? _getAllSessionsError;
  Exception? _saveSessionError;

  @override
  SessionService build() {
    return this;
  }

  void setupMockBehavior() {
    _sessions = [];
    _getAllSessionsError = null;
    _saveSessionError = null;
  }

  void setGetAllSessionsError(Exception error) {
    _getAllSessionsError = error;
  }

  void setSaveSessionError(Exception error) {
    _saveSessionError = error;
  }

  void clearMockData() {
    _sessions = [];
  }

  void setupMockSessions(List<WorkoutSession> sessions) {
    _sessions = sessions;
  }

  @override
  Future<void> saveSession(WorkoutSession session) async {
    if (_saveSessionError != null) {
      throw _saveSessionError!;
    }
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _sessions[index] = session;
    } else {
      _sessions.add(session);
    }
  }

  @override
  Future<WorkoutSession?> getSessionById(String id) async {
    try {
      return _sessions.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<WorkoutSession>> getAllSessions() async {
    if (_getAllSessionsError != null) {
      throw _getAllSessionsError!;
    }
    return List.from(_sessions)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
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
    final sortedSessions = List<WorkoutSession>.from(_sessions)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
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
    _sessions.removeWhere((s) => s.id == id);
  }

  @override
  Future<int> getSessionCount() async {
    return _sessions.length;
  }

  @override
  Future<Duration> getTotalWorkoutTime() async {
    final completedSessions = await getCompletedSessions();
    Duration total = Duration.zero;
    for (final session in completedSessions) {
      if (session.duration != null) {
        total = total + session.duration!;
      }
    }
    return total;
  }

  @override
  Future<double> getTotalWeightLifted() async {
    final completedSessions = await getCompletedSessions();
    double total = 0.0;
    for (final session in completedSessions) {
      if (session.totalWeight != null) {
        total += session.totalWeight!;
      }
    }
    return total;
  }
}
