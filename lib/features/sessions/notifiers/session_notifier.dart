import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_session.dart';
import '../services/session_service.dart';
import '../../exercise/models/exercise_set.dart';

part 'session_notifier.g.dart';

@riverpod
class SessionNotifier extends _$SessionNotifier {
  late final SessionService _sessionService;
  late final Uuid _uuid;

  @override
  Future<List<WorkoutSession>> build() async {
    _sessionService = ref.read(sessionServiceProvider);
    _uuid = const Uuid();
    return await _sessionService.getAllSessions();
  }

  Future<WorkoutSession> startSession({
    String? routineId,
    required String name,
  }) async {
    final session = WorkoutSession(
      id: _uuid.v4(),
      routineId: routineId,
      name: name,
      startTime: DateTime.now(),
      exerciseSets: [],
      status: SessionStatus.active,
    );

    await _sessionService.saveSession(session);
    state = AsyncValue.data(await _sessionService.getAllSessions());
    return session;
  }

  Future<void> addExerciseSet(ExerciseSet exerciseSet) async {
    final currentSession = await getCurrentActiveSession();
    if (currentSession == null) return;

    final updatedSets = [...currentSession.exerciseSets, exerciseSet];
    final updatedSession = currentSession.copyWith(
      exerciseSets: updatedSets,
      totalWeight: _calculateTotalWeight(updatedSets),
      totalReps: _calculateTotalReps(updatedSets),
    );

    await _sessionService.saveSession(updatedSession);
    state = AsyncValue.data(await _sessionService.getAllSessions());
  }

  Future<void> updateExerciseSet(ExerciseSet exerciseSet) async {
    final currentSession = await getCurrentActiveSession();
    if (currentSession == null) return;

    final updatedSets =
        currentSession.exerciseSets.map((set) {
          return set.id == exerciseSet.id ? exerciseSet : set;
        }).toList();

    final updatedSession = currentSession.copyWith(
      exerciseSets: updatedSets,
      totalWeight: _calculateTotalWeight(updatedSets),
      totalReps: _calculateTotalReps(updatedSets),
    );

    await _sessionService.saveSession(updatedSession);
    state = AsyncValue.data(await _sessionService.getAllSessions());
  }

  Future<void> completeSession({String? notes}) async {
    final currentSession = await getCurrentActiveSession();
    if (currentSession == null) return;

    final completedSession = currentSession.copyWith(
      endTime: DateTime.now(),
      status: SessionStatus.completed,
      notes: notes,
    );

    await _sessionService.saveSession(completedSession);
    state = AsyncValue.data(await _sessionService.getAllSessions());
  }

  Future<void> pauseSession() async {
    final currentSession = await getCurrentActiveSession();
    if (currentSession == null) return;

    final pausedSession = currentSession.copyWith(status: SessionStatus.paused);

    await _sessionService.saveSession(pausedSession);
    state = AsyncValue.data(await _sessionService.getAllSessions());
  }

  Future<void> resumeSession() async {
    final currentSession = await getCurrentActiveSession();
    if (currentSession == null) return;

    final resumedSession = currentSession.copyWith(
      status: SessionStatus.active,
    );

    await _sessionService.saveSession(resumedSession);
    state = AsyncValue.data(await _sessionService.getAllSessions());
  }

  Future<WorkoutSession?> getCurrentActiveSession() async {
    final sessions = await _sessionService.getAllSessions();
    try {
      return sessions.firstWhere((session) => session.isActive);
    } catch (e) {
      return null;
    }
  }

  Future<List<WorkoutSession>> getSessionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _sessionService.getSessionsByDateRange(startDate, endDate);
  }

  Future<List<WorkoutSession>> getRecentSessions({int limit = 10}) async {
    return await _sessionService.getRecentSessions(limit: limit);
  }

  Future<void> deleteSession(String sessionId) async {
    await _sessionService.deleteSession(sessionId);
    state = AsyncValue.data(await _sessionService.getAllSessions());
  }

  double _calculateTotalWeight(List<ExerciseSet> sets) {
    return sets.fold(0.0, (sum, set) => sum + (set.weight * set.reps));
  }

  int _calculateTotalReps(List<ExerciseSet> sets) {
    return sets.fold(0, (sum, set) => sum + set.reps);
  }
}
