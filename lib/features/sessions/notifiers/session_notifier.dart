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

part 'session_notifier.g.dart';

@riverpod
class SessionNotifier extends _$SessionNotifier {
  // Estado auxiliar en memoria para tiempos pausados y última reanudación
  final Map<String, int> _pausedElapsedBySession = {};
  final Map<String, DateTime> _lastResumeAtBySession = {};

  // Tags simples en notes para persistir datos entre vistas
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
    // Limpiar contadores de series realizadas al iniciar nueva sesión
    ref.read(performedSetsNotifierProvider.notifier).clearAll();
    
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

    // Convertir contadores de series realizadas en ExerciseSet reales
    final performedSets = ref.read(performedSetsNotifierProvider);
    final exerciseSets = await _convertPerformedSetsToExerciseSets(performedSets, currentSession);

    // Calcular totales al finalizar
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
    
    // NO limpiar contadores aquí - mantenerlos en memoria para vista rápida
    // Se limpiarán al iniciar una nueva sesión
  }

  Future<void> pauseSession() async {
    final currentSession = await getCurrentOngoingSession();
    if (currentSession == null) return;
    if (currentSession.status == SessionStatus.paused) {
      // Ya está pausada
      state = state;
      return;
    }

    // Guardar tiempo transcurrido acumulado al pausar (soporta múltiples pausas)
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

    // Persistir en notes
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

    // Registrar última reanudación
    final now = DateTime.now();
    _lastResumeAtBySession[resumedSession.id] = now;
    // Sembrar pausedElapsed en memoria si venimos de notes
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

  // Exponer datos auxiliares para UI
  int? getPausedElapsedSeconds(String sessionId) =>
      _pausedElapsedBySession[sessionId];
  DateTime? getLastResumeAt(String sessionId) =>
      _lastResumeAtBySession[sessionId];

  /// Limpia manualmente los contadores de series realizadas
  void clearPerformedSets() {
    ref.read(performedSetsNotifierProvider.notifier).clearAll();
  }

  // Helpers para notes
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

  /// Devuelve el tiempo pausado consolidado tomando memoria o notes
  int? resolvePausedElapsed(WorkoutSession session) {
    return _pausedElapsedBySession[session.id] ??
        readPausedFromNotes(session.notes);
  }

  /// Devuelve el instante de última reanudación desde memoria o notes
  DateTime? resolveLastResumeAt(WorkoutSession session) {
    return _lastResumeAtBySession[session.id] ??
        readResumeAtFromNotes(session.notes);
  }

  /// Calcula los segundos transcurridos que debe mostrar la UI
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

  /// Convierte los contadores de series realizadas en ExerciseSet reales
  Future<List<ExerciseSet>> _convertPerformedSetsToExerciseSets(
    Map<String, int> performedSets,
    WorkoutSession session,
  ) async {
    final exerciseSets = <ExerciseSet>[];
    final uuid = const Uuid();

    // Obtener rutina y ejercicios para acceder a los datos necesarios
    final routines = await ref.read(routineNotifierProvider.future);
    final exercises = await ref.read(exerciseNotifierProvider.future);
    
    // Encontrar la rutina actual
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

    // Procesar cada contador de series realizadas
    for (final entry in performedSets.entries) {
      final routineExerciseId = entry.key;
      final setsCount = entry.value;

      if (setsCount <= 0) continue;

      // Encontrar el RoutineExercise correspondiente
      RoutineExercise? routineExercise;
      for (final section in currentRoutine.sections) {
        try {
          routineExercise = section.exercises.firstWhere(
            (re) => re.id == routineExerciseId,
          );
          break;
        } catch (e) {
          // Continuar buscando en la siguiente sección
        }
      }

      if (routineExercise == null) continue;

      // Encontrar el ejercicio
      Exercise? exercise;
      try {
        exercise = exercises.firstWhere(
          (e) => e.id == routineExercise!.exerciseId,
        );
      } catch (e) {
        continue;
      }

      // Crear ExerciseSet para cada serie realizada
      for (int i = 0; i < setsCount; i++) {
        final exerciseSet = ExerciseSet(
          id: uuid.v4(),
          exerciseId: exercise.id,
          weight: routineExercise.weight,
          reps: routineExercise.reps,
          completedAt: DateTime.now(),
          isCompleted: true,
        );
        exerciseSets.add(exerciseSet);
      }
    }

    return exerciseSets;
  }
}
