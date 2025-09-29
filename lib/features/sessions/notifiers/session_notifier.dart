import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_session.dart';
import '../services/session_service.dart';
import '../../exercise/models/exercise_set.dart';

part 'session_notifier.g.dart';

@riverpod
class SessionNotifier extends _$SessionNotifier {
  @override
  Future<List<WorkoutSession>> build() async {
    final sessionService = ref.read(sessionServiceProvider);
    return await sessionService.getAllSessions();
  }

  Future<WorkoutSession> startSession({
    String? routineId,
    required String name,
  }) async {
    final sessionService = ref.read(sessionServiceProvider);
    final uuid = const Uuid();

    final session = WorkoutSession(
      id: uuid.v4(),
      routineId: routineId,
      name: name,
      startTime: DateTime.now(),
      exerciseSets: [],
      status: SessionStatus.active,
    );

    await sessionService.saveSession(session);
    state = AsyncValue.data(await sessionService.getAllSessions());
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

    final sessionService = ref.read(sessionServiceProvider);
    await sessionService.saveSession(updatedSession);
    state = AsyncValue.data(await sessionService.getAllSessions());
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

    final sessionService = ref.read(sessionServiceProvider);
    await sessionService.saveSession(updatedSession);
    state = AsyncValue.data(await sessionService.getAllSessions());
  }

  Future<void> completeSession({String? notes}) async {
    final currentSession = await getCurrentActiveSession();
    if (currentSession == null) return;

    final completedSession = currentSession.copyWith(
      endTime: DateTime.now(),
      status: SessionStatus.completed,
      notes: notes,
    );

    final sessionService = ref.read(sessionServiceProvider);
    await sessionService.saveSession(completedSession);
    state = AsyncValue.data(await sessionService.getAllSessions());
  }

  Future<void> pauseSession() async {
    final currentSession = await getCurrentActiveSession();
    if (currentSession == null) return;

    final pausedSession = currentSession.copyWith(status: SessionStatus.paused);

    final sessionService = ref.read(sessionServiceProvider);
    await sessionService.saveSession(pausedSession);
    state = AsyncValue.data(await sessionService.getAllSessions());
  }

  Future<void> resumeSession() async {
    final currentSession = await getCurrentActiveSession();
    if (currentSession == null) return;

    final resumedSession = currentSession.copyWith(
      status: SessionStatus.active,
    );

    final sessionService = ref.read(sessionServiceProvider);
    await sessionService.saveSession(resumedSession);
    state = AsyncValue.data(await sessionService.getAllSessions());
  }

  Future<WorkoutSession?> getCurrentActiveSession() async {
    final sessionService = ref.read(sessionServiceProvider);
    final sessions = await sessionService.getAllSessions();
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
    final sessionService = ref.read(sessionServiceProvider);
    return await sessionService.getSessionsByDateRange(startDate, endDate);
  }

  Future<List<WorkoutSession>> getRecentSessions({int limit = 10}) async {
    final sessionService = ref.read(sessionServiceProvider);
    return await sessionService.getRecentSessions(limit: limit);
  }

  Future<void> deleteSession(String sessionId) async {
    final sessionService = ref.read(sessionServiceProvider);
    await sessionService.deleteSession(sessionId);
    state = AsyncValue.data(await sessionService.getAllSessions());
  }

  double _calculateTotalWeight(List<ExerciseSet> sets) {
    return sets.fold(0.0, (sum, set) => sum + (set.weight * set.reps));
  }

  int _calculateTotalReps(List<ExerciseSet> sets) {
    return sets.fold(0, (sum, set) => sum + set.reps);
  }
}
