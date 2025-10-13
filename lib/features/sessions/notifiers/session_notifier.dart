import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/logging/logging.dart';
import '../../exercise/models/exercise.dart';
import '../../exercise/models/exercise_set.dart';
import '../../exercise/notifiers/exercise_notifier.dart';
import '../../home/models/routine.dart';
import '../../home/notifiers/routine_notifier.dart';
import '../../progression/models/progression_config.dart';
import '../../progression/notifiers/progression_notifier.dart';
import '../../progression/services/progression_service.dart';
import '../../progression/strategies/progression_strategy.dart';
import '../models/workout_session.dart';
import '../services/session_service.dart';
import '../utils/session_calculations.dart';
import 'performed_sets_notifier.dart';

part 'session_notifier.g.dart';

@riverpod
class SessionNotifier extends _$SessionNotifier {
  // Auxiliary in-memory state for paused time and last resume
  final Map<String, int> _pausedElapsedBySession = {};
  final Map<String, DateTime> _lastResumeAtBySession = {};

  // Store progression values for current session (exerciseId -> progression values)
  final Map<String, Map<String, dynamic>> _sessionProgressionValues = {};

  // Cache for frequently accessed data
  ProgressionConfig? _cachedProgressionConfig;
  ProgressionStrategy? _cachedProgressionStrategy;
  List<Exercise>? _cachedExercises;
  List<Routine>? _cachedRoutines;

  /// Gets progression values for an exercise during the current session
  /// Returns null if no progression values are stored for this exercise
  Map<String, dynamic>? getSessionProgressionValues(String exerciseId) {
    return _sessionProgressionValues[exerciseId];
  }

  /// Gets cached progression configuration or fetches it if not cached
  Future<ProgressionConfig?> _getProgressionConfig() async {
    _cachedProgressionConfig ??= await ref.read(
      progressionNotifierProvider.future,
    );
    return _cachedProgressionConfig;
  }

  /// Gets cached progression strategy or creates it if not cached
  Future<ProgressionStrategy?> _getProgressionStrategy() async {
    if (_cachedProgressionStrategy == null) {
      final config = await _getProgressionConfig();
      if (config != null) {
        _cachedProgressionStrategy = ProgressionStrategyFactory.fromType(
          config.type,
        );
      }
    }
    return _cachedProgressionStrategy;
  }

  /// Gets cached exercises or fetches them if not cached
  Future<List<Exercise>> _getExercises() async {
    _cachedExercises ??= await ref.read(exerciseNotifierProvider.future);
    return _cachedExercises!;
  }

  /// Gets cached routines or fetches them if not cached
  Future<List<Routine>> _getRoutines() async {
    _cachedRoutines ??= await ref.read(routineNotifierProvider.future);
    return _cachedRoutines!;
  }

  /// Gets an exercise by ID from cached data
  Future<Exercise?> _getExerciseById(String exerciseId) async {
    final exercises = await _getExercises();
    try {
      return exercises.firstWhere((e) => e.id == exerciseId);
    } catch (e) {
      return null;
    }
  }

  /// Gets a routine by ID from cached data
  Future<Routine?> _getRoutineById(String routineId) async {
    final routines = await _getRoutines();
    try {
      return routines.firstWhere((r) => r.id == routineId);
    } catch (e) {
      return null;
    }
  }

  /// Clears all cached data (call when starting a new session)
  void _clearCache() {
    _cachedProgressionConfig = null;
    _cachedProgressionStrategy = null;
    _cachedExercises = null;
    _cachedRoutines = null;
    _sessionProgressionValues.clear();
  }

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

    // Clear cache when starting a new session
    _clearCache();

    // Load progression values for exercises in the selected routine
    if (routineId != null) {
      try {
        final routine = await _getRoutineById(routineId);
        if (routine != null) {
          // Load progression state for each exercise in the routine
          for (final section in routine.sections) {
            for (final routineExercise in section.exercises) {
              try {
                final progressionState = await ref
                    .read(progressionNotifierProvider.notifier)
                    .getExerciseProgressionState(
                      routineExercise.exerciseId,
                      routineId,
                    );

                if (progressionState != null) {
                  final exercise = await _getExerciseById(
                    routineExercise.exerciseId,
                  );

                  if (exercise != null) {
                    // Get progression strategy using cached helper
                    final strategy = await _getProgressionStrategy();
                    if (strategy != null) {
                      // Use centralized helper to check if progression values should be applied
                      final shouldApply = strategy.shouldApplyProgressionValues(
                        progressionState,
                        routineId,
                        exercise.isProgressionLocked,
                      );

                      if (shouldApply) {
                        // Store progression values for this session without modifying Exercise defaults
                        _sessionProgressionValues[exercise.id] = {
                          'weight': progressionState.currentWeight,
                          'reps': progressionState.currentReps,
                          'sets': progressionState.currentSets,
                        };

                        LoggingService.instance.info(
                          'Using progression values for session',
                          {
                            'exerciseId': exercise.id,
                            'exerciseName': exercise.name,
                            'progressionWeight': progressionState.currentWeight,
                            'progressionReps': progressionState.currentReps,
                            'progressionSets': progressionState.currentSets,
                            'originalWeight': exercise.defaultWeight,
                            'originalReps': exercise.defaultReps,
                            'originalSets': exercise.defaultSets,
                          },
                        );
                      }
                    }
                  }
                }
              } catch (e) {
                // Log error for individual exercise but continue with others
                print(
                  'Error loading progression for exercise ${routineExercise.exerciseId}: $e',
                );
              }
            }
          }
        }
      } catch (e) {
        // Log error but don't fail session creation
        print('Error loading progression values for routine $routineId: $e');
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
      totalWeight: SessionCalculations.calculateTotalWeight(updatedSets),
      totalReps: SessionCalculations.calculateTotalReps(updatedSets),
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
      totalWeight: SessionCalculations.calculateTotalWeight(updatedSets),
      totalReps: SessionCalculations.calculateTotalReps(updatedSets),
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

    // Save the completed session
    await _saveCompletedSession(currentSession, exerciseSets, notes);

    // Process completed exercises (update lastPerformedAt and initialize progression)
    await _processCompletedExercises(exerciseSets, currentSession);

    // Apply progression to completed exercises
    await _applyProgressionToCompletedExercises(exerciseSets, currentSession);
  }

  /// Saves the completed session with calculated totals
  Future<void> _saveCompletedSession(
    WorkoutSession currentSession,
    List<ExerciseSet> exerciseSets,
    String? notes,
  ) async {
    // Calculate totals upon completion
    final totalWeight = SessionCalculations.calculateTotalWeight(exerciseSets);
    final totalReps = SessionCalculations.calculateTotalReps(exerciseSets);

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
    _sessionProgressionValues
        .clear(); // Clear progression values after session completion

    // Clear cache after session completion
    _clearCache();
  }

  /// Processes completed exercises: updates lastPerformedAt and initializes progression state
  Future<void> _processCompletedExercises(
    List<ExerciseSet> exerciseSets,
    WorkoutSession currentSession,
  ) async {
    if (currentSession.routineId == null) return;

    try {
      final exercisesNotifier = ref.read(exerciseNotifierProvider.notifier);
      final allExercises = await ref.read(exerciseNotifierProvider.future);
      final progressionNotifier = ref.read(
        progressionNotifierProvider.notifier,
      );

      final exerciseValuesUsed = _collectExerciseValuesUsed(exerciseSets);
      final now = DateTime.now();

      for (final exercise in allExercises) {
        if (exerciseValuesUsed.containsKey(exercise.id)) {
          // Update lastPerformedAt
          final updated = exercise.copyWith(lastPerformedAt: now);
          await exercisesNotifier.updateExercise(updated);

          // Initialize progression state if it doesn't exist
          await _initializeProgressionStateIfNeeded(
            exercise,
            exerciseValuesUsed[exercise.id]!,
            currentSession.routineId!,
            progressionNotifier,
          );
        }
      }
    } catch (e) {
      LoggingService.instance.warning('Error processing completed exercises', {
        'error': e.toString(),
      });
    }
  }

  /// Applies progression to completed exercises
  Future<void> _applyProgressionToCompletedExercises(
    List<ExerciseSet> exerciseSets,
    WorkoutSession currentSession,
  ) async {
    if (currentSession.routineId == null) return;

    try {
      final progressionNotifier = ref.read(
        progressionNotifierProvider.notifier,
      );
      final progressionService = ref.read(progressionServiceProvider.notifier);

      // Get the active progression config
      final config = await ref.read(progressionNotifierProvider.future);
      if (config == null) {
        LoggingService.instance.debug(
          'No active progression config, skipping progression',
        );
        return;
      }

      final completedExerciseIds =
          exerciseSets.map((set) => set.exerciseId).toSet();

      for (final exerciseId in completedExerciseIds) {
        await _applyProgressionToExercise(
          exerciseId,
          currentSession.routineId!,
          config.id,
          progressionNotifier,
          progressionService,
        );
      }

      LoggingService.instance
          .info('Progression applied after session completion', {
            'routineId': currentSession.routineId,
            'exercisesProcessed': completedExerciseIds.length,
          });
    } catch (e) {
      LoggingService.instance.error(
        'Error applying progression after session',
        e,
        null,
      );
    }
  }

  /// Collects the actual values used for each exercise in the session
  Map<String, Map<String, dynamic>> _collectExerciseValuesUsed(
    List<ExerciseSet> exerciseSets,
  ) {
    final exerciseValuesUsed = <String, Map<String, dynamic>>{};

    for (final set in exerciseSets) {
      if (!exerciseValuesUsed.containsKey(set.exerciseId)) {
        exerciseValuesUsed[set.exerciseId] = {
          'weight': set.weight,
          'reps': set.reps,
          'sets': 1,
        };
      } else {
        final current = exerciseValuesUsed[set.exerciseId]!;
        exerciseValuesUsed[set.exerciseId] = {
          'weight':
              set.weight > current['weight'] ? set.weight : current['weight'],
          'reps': set.reps > current['reps'] ? set.reps : current['reps'],
          'sets': current['sets'] + 1,
        };
      }
    }

    return exerciseValuesUsed;
  }

  /// Initializes progression state for an exercise if it doesn't exist
  Future<void> _initializeProgressionStateIfNeeded(
    Exercise exercise,
    Map<String, dynamic> valuesUsed,
    String routineId,
    ProgressionNotifier progressionNotifier,
  ) async {
    try {
      final existingState = await progressionNotifier
          .getExerciseProgressionState(exercise.id, routineId);

      if (existingState == null) {
        await progressionNotifier.initializeExerciseProgression(
          exerciseId: exercise.id,
          routineId: routineId,
          baseWeight: valuesUsed['weight'] as double,
          baseReps: valuesUsed['reps'] as int,
          baseSets: exercise.defaultSets ?? (valuesUsed['sets'] as int),
        );

        LoggingService.instance
            .info('Initialized progression state with session values', {
              'exerciseId': exercise.id,
              'exerciseName': exercise.name,
              'baseWeight': valuesUsed['weight'],
              'baseReps': valuesUsed['reps'],
              'baseSets': valuesUsed['sets'],
            });
      }
    } catch (e) {
      LoggingService.instance.warning(
        'Failed to initialize progression state',
        {'exerciseId': exercise.id, 'error': e.toString()},
      );
    }
  }

  /// Applies progression to a specific exercise
  Future<void> _applyProgressionToExercise(
    String exerciseId,
    String routineId,
    String configId,
    ProgressionNotifier progressionNotifier,
    ProgressionService progressionService,
  ) async {
    try {
      final progressionState = await progressionNotifier
          .getExerciseProgressionState(exerciseId, routineId);

      if (progressionState == null) {
        LoggingService.instance.debug(
          'No progression state for exercise, skipping',
          {'exerciseId': exerciseId, 'routineId': routineId},
        );
        return;
      }

      final allExercises = await ref.read(exerciseNotifierProvider.future);
      final exercise = allExercises.firstWhere(
        (e) => e.id == exerciseId,
        orElse: () => throw Exception('Exercise not found: $exerciseId'),
      );

      final progressionResult = await progressionService.calculateProgression(
        configId,
        exerciseId,
        routineId,
        progressionState.currentWeight,
        progressionState.currentReps,
        progressionState.currentSets,
        exercise: exercise,
        isExerciseLocked: exercise.isProgressionLocked,
      );

      LoggingService.instance.info('Progression applied to exercise', {
        'exerciseId': exerciseId,
        'exerciseName': exercise.name,
        'newWeight': progressionResult.newWeight,
        'newReps': progressionResult.newReps,
        'newSets': progressionResult.newSets,
      });
    } catch (e) {
      LoggingService.instance.error(
        'Error applying progression to exercise',
        e,
        null,
        {'exerciseId': exerciseId},
      );
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

    // Get routine and exercises using cached helpers
    final routines = await _getRoutines();
    final exercises = await _getExercises();

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

      // Try to read progression state for this exercise in the current routine
      double? progressedWeight;
      int? progressedReps;

      // First, try to get progression values stored for this session
      final sessionProgressionValues = getSessionProgressionValues(exercise.id);
      if (sessionProgressionValues != null) {
        progressedWeight = sessionProgressionValues['weight'] as double?;
        progressedReps = sessionProgressionValues['reps'] as int?;
      } else {
        // Fallback: try to get progression values from progression state
        try {
          if (session.routineId != null) {
            final progressionState = await ref
                .read(progressionNotifierProvider.notifier)
                .getExerciseProgressionState(exercise.id, session.routineId!);
            if (progressionState != null) {
              // Get progression strategy using cached helper
              final strategy = await _getProgressionStrategy();
              if (strategy != null) {
                // Use centralized helper to check if progression values should be applied
                final shouldApply = strategy.shouldApplyProgressionValues(
                  progressionState,
                  session.routineId!,
                  exercise.isProgressionLocked,
                );

                if (shouldApply) {
                  progressedWeight = progressionState.currentWeight;
                  progressedReps = progressionState.currentReps;
                }
              }
            }
          }
        } catch (_) {
          // ignore progression lookup errors and fall back to exercise defaults
        }
      }

      // Create an ExerciseSet for each performed set
      for (int i = 0; i < setsCount; i++) {
        final exerciseSet = ExerciseSet(
          id: uuid.v4(),
          exerciseId: exercise.id,
          weight: progressedWeight ?? (exercise.defaultWeight ?? 0.0),
          reps: progressedReps ?? (exercise.defaultReps ?? 10),
          completedAt: DateTime.now(),
          isCompleted: true,
        );
        exerciseSets.add(exerciseSet);
      }
    }

    return exerciseSets;
  }
}
