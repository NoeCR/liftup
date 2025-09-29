import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/workout_session.dart';
import '../../../core/database/database_service.dart';

part 'session_service.g.dart';

@riverpod
class SessionService extends _$SessionService {
  @override
  SessionService build() {
    return this;
  }

  Box get _box {
    return DatabaseService.getInstance().sessionsBox;
  }

  Future<void> saveSession(WorkoutSession session) async {
    final box = _box;
    await box.put(session.id, session);
  }

  Future<WorkoutSession?> getSessionById(String id) async {
    final box = _box;
    return box.get(id);
  }

  Future<List<WorkoutSession>> getAllSessions() async {
    final box = _box;
    return box.values.cast<WorkoutSession>().toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  Future<List<WorkoutSession>> getSessionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allSessions = await getAllSessions();
    return allSessions.where((session) {
      return session.startTime.isAfter(startDate) &&
          session.startTime.isBefore(endDate);
    }).toList();
  }

  Future<List<WorkoutSession>> getRecentSessions({int limit = 10}) async {
    final allSessions = await getAllSessions();
    return allSessions.take(limit).toList();
  }

  Future<List<WorkoutSession>> getCompletedSessions() async {
    final allSessions = await getAllSessions();
    return allSessions.where((session) => session.isCompleted).toList();
  }

  Future<List<WorkoutSession>> getActiveSessions() async {
    final allSessions = await getAllSessions();
    return allSessions.where((session) => session.isActive).toList();
  }

  Future<void> deleteSession(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  Future<int> getSessionCount() async {
    final box = await _box;
    return box.length;
  }

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
