import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_session.dart';
import '../services/session_service.dart';
import '../../exercise/models/exercise_set.dart';
import '../../exercise/models/exercise.dart';
import 'performed_sets_notifier.dart';
import '../../home/notifiers/routine_notifier.dart';
import '../../home/models/routine.dart';
import '../../exercise/notifiers/exercise_notifier.dart';
import '../../progression/services/session_progression_service.dart';

part 'session_notifier.g.dart';

@riverpod
class SessionNotifier extends _$SessionNotifier {
  // Auxiliary in-memory state for paused time and last resume
  final Map<String, int> _pausedElapsedBySession = {};
  final Map<String, DateTime> _lastResumeAtBySession = {};

  // Simple tags in notes to persist data across views
  static const String _tagPaused = 'pausedElapsed=';
  static const String _tagResumeAt = 'lastResumeAt=';
  static const String _tagRestPrefix = 'rest_'; // rest_<exerciseId>=ISO8601
  @override
  Future<List<WorkoutSession>> build() async {
    final sessionService = ref.read(sessionServiceProvider);
    return await sessionService.getAllSessions();
  }

  Future<WorkoutSession> startSession({
    String? routineId,
    required String name,
  }) async {
    // Clear performed-set counters when starting a new session
    ref.read(performedSetsNotifierProvider.notifier).clearAll();

    // Apply progression if there is a selected routine
    if (routineId != null) {
      try {
        final routines = await ref.read(routineNotifierProvider.future);
        final routine = routines.firstWhere(
          (r) => r.id == routineId,
          orElse: () => throw Exception('Routine not found: $routineId'),
        );

        // Apply progression to the routine
        final sessionProgressionService = ref.read(
          sessionProgressionServiceProvider.notifier,
        );
        await sessionProgressionService.applyProgressionToRoutine(routine);
      } catch (e) {
        // Log error but don't fail session creation
      }
    }

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
    final currentSession = await getCurrentOngoingSession();
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
    final currentSession = await getCurrentOngoingSession();
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
    final currentSession = await getCurrentOngoingSession();
    if (currentSession == null) return;

    // Convert performed-set counters into real ExerciseSet entries
    final performedSets = ref.read(performedSetsNotifierProvider);
    final exerciseSets = await _convertPerformedSetsToExerciseSets(
      performedSets,
      currentSession,
    );

    // Calculate totals upon completion
    final totalWeight = _calculateTotalWeight(exerciseSets);
    final totalReps = _calculateTotalReps(exerciseSets);

    final completedSession = currentSession.copyWith(
      endTime: DateTime.now(),
      status: SessionStatus.completed,
      notes: notes,
      exerciseSets: exerciseSets,
      totalWeight: totalWeight,
      totalReps: totalReps,
    );

    final sessionService = ref.read(sessionServiceProvider);
    await sessionService.saveSession(completedSession);
    state = AsyncValue.data(await sessionService.getAllSessions());
    _pausedElapsedBySession.remove(currentSession.id);
    _lastResumeAtBySession.remove(currentSession.id);

    // Do NOT clear counters here — keep them in memory for quick view
    // They will be cleared when a new session starts

    // Update lastPerformedAt for exercises that were actually completed
    try {
      final exercisesNotifier = ref.read(exerciseNotifierProvider.notifier);
      final allExercises = await ref.read(exerciseNotifierProvider.future);

      final completedExerciseIds = <String>{};
      for (final set in exerciseSets) {
        completedExerciseIds.add(set.exerciseId);
      }

      final now = DateTime.now();
      for (final exercise in allExercises) {
        if (completedExerciseIds.contains(exercise.id)) {
          final updated = exercise.copyWith(lastPerformedAt: now);
          await exercisesNotifier.updateExercise(updated);
        }
      }
    } catch (_) {
      // Ignore update errors to not block completion
    }
  }

  Future<void> pauseSession() async {
    final currentSession = await getCurrentOngoingSession();
    if (currentSession == null) return;
    if (currentSession.status == SessionStatus.paused) {
      // Already paused
      state = state;
      return;
    }

    // Save accumulated elapsed time when pausing (supports multiple pauses)
    final now = DateTime.now();
    final previousPaused =
        _pausedElapsedBySession[currentSession.id] ??
        readPausedFromNotes(currentSession.notes);
    final lastResumeAt =
        _lastResumeAtBySession[currentSession.id] ??
        readResumeAtFromNotes(currentSession.notes);
    int elapsedAtPause;
    if (previousPaused != null && lastResumeAt != null) {
      elapsedAtPause = previousPaused + now.difference(lastResumeAt).inSeconds;
    } else {
      elapsedAtPause = now.difference(currentSession.startTime).inSeconds;
    }
    if (elapsedAtPause < 0) elapsedAtPause = 0;
    _pausedElapsedBySession[currentSession.id] = elapsedAtPause;

    // Persist into notes
    final updatedNotes = _setNoteValue(
      _setNoteValue(currentSession.notes, _tagPaused, '$elapsedAtPause'),
      _tagResumeAt,
      null,
    );

    final pausedSession = currentSession.copyWith(
      status: SessionStatus.paused,
      notes: updatedNotes,
    );

    final sessionService = ref.read(sessionServiceProvider);
    await sessionService.saveSession(pausedSession);
    state = AsyncValue.data(await sessionService.getAllSessions());
  }

  Future<void> resumeSession() async {
    final currentSession = await getCurrentOngoingSession();
    if (currentSession == null) return;

    final resumedSession = currentSession.copyWith(
      status: SessionStatus.active,
      notes: _setNoteValue(
        currentSession.notes,
        _tagResumeAt,
        DateTime.now().toIso8601String(),
      ),
    );

    // Record last resume instant
    final now = DateTime.now();
    _lastResumeAtBySession[resumedSession.id] = now;
    // Seed pausedElapsed in memory if read from notes
    _pausedElapsedBySession[resumedSession.id] =
        _pausedElapsedBySession[resumedSession.id] ??
        readPausedFromNotes(currentSession.notes) ??
        0;

    final sessionService = ref.read(sessionServiceProvider);
    await sessionService.saveSession(resumedSession);
    state = AsyncValue.data(await sessionService.getAllSessions());
  }

  // --- Rest timers per exercise ---
  Future<void> setExerciseRestEnd({
    required String exerciseId,
    required DateTime? restEndsAt,
  }) async {
    final currentSession = await getCurrentOngoingSession();
    if (currentSession == null) return;

    final tag = '$_tagRestPrefix$exerciseId=';
    final updatedNotes = _setNoteValue(
      currentSession.notes,
      tag,
      restEndsAt?.toIso8601String(),
    );

    final updatedSession = currentSession.copyWith(notes: updatedNotes);
    final sessionService = ref.read(sessionServiceProvider);
    await sessionService.saveSession(updatedSession);
    state = AsyncValue.data(await sessionService.getAllSessions());
  }

  DateTime? readExerciseRestEnd(String? notes, String exerciseId) {
    if (notes == null) return null;
    final tag = '$_tagRestPrefix$exerciseId=';
    for (final line in notes.split('\n')) {
      final l = line.trim();
      if (l.startsWith(tag)) {
        final v = l.substring(tag.length);
        return DateTime.tryParse(v);
      }
    }
    return null;
  }

  Future<WorkoutSession?> getCurrentOngoingSession() async {
    final sessionService = ref.read(sessionServiceProvider);
    final sessions = await sessionService.getAllSessions();
    try {
      return sessions.firstWhere(
        (session) =>
            (session.status == SessionStatus.active ||
                session.status == SessionStatus.paused) &&
            session.endTime == null,
      );
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

  // Expose auxiliary data for UI
  int? getPausedElapsedSeconds(String sessionId) =>
      _pausedElapsedBySession[sessionId];
  DateTime? getLastResumeAt(String sessionId) =>
      _lastResumeAtBySession[sessionId];

  /// Limpia manualmente los contadores de series realizadas
  void clearPerformedSets() {
    ref.read(performedSetsNotifierProvider.notifier).clearAll();
  }

  // Notes helpers
  String? _setNoteValue(String? notes, String tag, String? value) {
    final lines = (notes ?? '').split('\n');
    final filtered = lines.where((l) => !l.trim().startsWith(tag)).toList();
    if (value != null) {
      filtered.add('$tag$value');
    }
    final result = filtered.join('\n').trim();
    return result.isEmpty ? null : result;
  }

  static int? readPausedFromNotes(String? notes) {
    if (notes == null) return null;
    for (final line in notes.split('\n')) {
      final l = line.trim();
      if (l.startsWith(_tagPaused)) {
        final v = l.substring(_tagPaused.length);
        final n = int.tryParse(v);
        return n;
      }
    }
    return null;
  }

  static DateTime? readResumeAtFromNotes(String? notes) {
    if (notes == null) return null;
    for (final line in notes.split('\n')) {
      final l = line.trim();
      if (l.startsWith(_tagResumeAt)) {
        final v = l.substring(_tagResumeAt.length);
        return DateTime.tryParse(v);
      }
    }
    return null;
  }

  /// Returns consolidated paused time taking memory or notes
  int? resolvePausedElapsed(WorkoutSession session) {
    return _pausedElapsedBySession[session.id] ??
        readPausedFromNotes(session.notes);
  }

  /// Returns last resume instant from memory or notes
  DateTime? resolveLastResumeAt(WorkoutSession session) {
    return _lastResumeAtBySession[session.id] ??
        readResumeAtFromNotes(session.notes);
  }

  /// Calculates the elapsed seconds the UI should display
  int calculateElapsedForUI(WorkoutSession session, {required DateTime now}) {
    if (session.status == SessionStatus.paused) {
      final paused = resolvePausedElapsed(session);
      if (paused != null) return paused;
      final base = now.difference(session.startTime).inSeconds;
      return base < 0 ? 0 : base;
    }

    // Active
    final paused = resolvePausedElapsed(session);
    final resumeAt = resolveLastResumeAt(session);
    int base;
    if (paused != null && resumeAt != null) {
      base = paused + now.difference(resumeAt).inSeconds;
    } else {
      base = now.difference(session.startTime).inSeconds;
    }
    return base < 0 ? 0 : base;
  }

  /// Converts performed-set counters into real ExerciseSet objects
  Future<List<ExerciseSet>> _convertPerformedSetsToExerciseSets(
    Map<String, int> performedSets,
    WorkoutSession session,
  ) async {
    final exerciseSets = <ExerciseSet>[];
    final uuid = const Uuid();

    // Get routine and exercises to access required data
    final routines = await ref.read(routineNotifierProvider.future);
    final exercises = await ref.read(exerciseNotifierProvider.future);

    // Find the current routine
    Routine? currentRoutine;
    try {
      currentRoutine = routines.firstWhere(
        (routine) => routine.id == session.routineId,
      );
    } catch (e) {
      if (routines.isNotEmpty) {
        currentRoutine = routines.first;
      }
    }

    if (currentRoutine == null) return exerciseSets;

    // Process each performed-set counter
    for (final entry in performedSets.entries) {
      final routineExerciseId = entry.key;
      final setsCount = entry.value;

      if (setsCount <= 0) continue;

      // Find the corresponding RoutineExercise
      RoutineExercise? routineExercise;
      for (final section in currentRoutine.sections) {
        try {
          routineExercise = section.exercises.firstWhere(
            (re) => re.id == routineExerciseId,
          );
          break;
        } catch (e) {
          // Continue searching in the next section
        }
      }

      if (routineExercise == null) continue;

      // Find the exercise
      Exercise? exercise;
      try {
        exercise = exercises.firstWhere(
          (e) => e.id == routineExercise!.exerciseId,
        );
      } catch (e) {
        continue;
      }

      // Create an ExerciseSet for each performed set
      for (int i = 0; i < setsCount; i++) {
        final exerciseSet = ExerciseSet(
          id: uuid.v4(),
          exerciseId: exercise.id,
          weight: exercise.defaultWeight ?? 0.0,
          reps: exercise.defaultReps ?? 10,
          completedAt: DateTime.now(),
          isCompleted: true,
        );
        exerciseSets.add(exerciseSet);
      }
    }

    return exerciseSets;
  }
}
