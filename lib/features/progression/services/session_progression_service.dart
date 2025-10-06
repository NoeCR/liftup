import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/progression_state.dart';
import '../notifiers/progression_notifier.dart';
import '../../exercise/models/exercise_set.dart';
import '../../exercise/notifiers/exercise_notifier.dart';
import '../../home/models/routine.dart';
import '../../sessions/services/session_service.dart';
import '../../../core/logging/logging.dart';
import '../../../common/enums/progression_type_enum.dart';
import '../../settings/notifiers/rest_prefs.dart';
part 'session_progression_service.g.dart';

int computeAdjustedSets({required int currentConfiguredSets, required int previousSetsInState, required int newSetsFromCalculation, required int maxSets}) {
  final delta = newSetsFromCalculation - previousSetsInState;
  final adjusted = currentConfiguredSets + delta;
  if (adjusted < 1) return 1;
  return adjusted > maxSets ? maxSets : adjusted;
}

@riverpod
class SessionProgressionService extends _$SessionProgressionService {
  @override
  SessionProgressionService build() {
    return this;
  }

  /// Applies progression to a routine's exercises before starting a session.
  /// Only applied on the first session of the week for this routine.
  Future<List<RoutineExercise>> applyProgressionToRoutine(
    Routine routine,
  ) async {
    try {
      final progressionNotifier = ref.read(
        progressionNotifierProvider.notifier,
      );

      // Fast-exit if there is no active progression
      if (!progressionNotifier.hasActiveProgression) {
        LoggingService.instance.debug(
          'No active progression, returning routine as-is',
        );
        return _getAllExercisesFromRoutine(routine);
      }

      // Resolve active progression configuration
      final config = await ref.read(progressionNotifierProvider.future);
      if (config == null) {
        LoggingService.instance.warning(
          'No progression config found, returning routine as-is',
        );
        return _getAllExercisesFromRoutine(routine);
      }

      // Decide whether progression should be applied based on routine frequency
      final shouldApplyProgression = await _shouldApplyProgressionForRoutine(
        routine,
      );

      LoggingService.instance.info('Applying progression to routine', {
        'routineId': routine.id,
        'routineName': routine.name,
        'progressionType': config.type.name,
        'progressionUnit': config.unit.name,
        'shouldApplyProgression': shouldApplyProgression,
      });

      final updatedExercises = <RoutineExercise>[];
      final processedExerciseIds = <String>{}; // Track processed exercises

      for (final section in routine.sections) {
        for (final exercise in section.exercises) {
          // Skip duplicates: process each exerciseId once per routine
          if (processedExerciseIds.contains(exercise.exerciseId)) {
            updatedExercises.add(exercise);
            continue;
          }
          processedExerciseIds.add(exercise.exerciseId);
          try {
            // Fetch exercise defaults
            final exerciseData = await ref.read(
              exerciseNotifierProvider.future,
            );
            final exerciseModel = exerciseData.firstWhere(
              (e) => e.id == exercise.exerciseId,
              orElse:
                  () =>
                      throw Exception(
                        'Exercise not found: ${exercise.exerciseId}',
                      ),
            );

            // Get or initialize progression state for this exercise
            ProgressionState? progressionState = await progressionNotifier
                .getExerciseProgressionState(exercise.exerciseId);

            // Initialize progression state for this exercise
            progressionState ??= await progressionNotifier
                .initializeExerciseProgression(
                  exerciseId: exercise.exerciseId,
                  baseWeight: exerciseModel.defaultWeight ?? 0.0,
                  baseReps: exerciseModel.defaultReps ?? 10,
                  baseSets: exerciseModel.defaultSets ?? 3,
                );

            // Log current state before calculation
            LoggingService.instance
                .info('SESSION PROGRESSION: BEFORE CALCULATION', {
                  'exerciseId': exercise.exerciseId,
                  'exerciseName': exerciseModel.name,
                  'currentWeight': progressionState.currentWeight,
                  'currentReps': progressionState.currentReps,
                  'currentSets': progressionState.currentSets,
                  'progressionType': config.type.name,
                  'progressionUnit': config.unit.name,
                  'shouldApplyProgression': shouldApplyProgression,
                });

            // Compute new values based on progression
            final calculationResult = await progressionNotifier
                .calculateExerciseProgression(
                  exerciseId: exercise.exerciseId,
                  currentWeight: progressionState.currentWeight,
                  currentReps: progressionState.currentReps,
                  currentSets: progressionState.currentSets,
                );

            if (calculationResult != null) {
              // Log calculation result
              LoggingService.instance
                  .info('SESSION PROGRESSION: CALCULATION RESULT', {
                    'exerciseId': exercise.exerciseId,
                    'exerciseName': exerciseModel.name,
                    'oldWeight': progressionState.currentWeight,
                    'newWeight': calculationResult.newWeight,
                    'oldReps': progressionState.currentReps,
                    'newReps': calculationResult.newReps,
                    'oldSets': progressionState.currentSets,
                    'newSets': calculationResult.newSets,
                    'incrementApplied': calculationResult.incrementApplied,
                    'reason': calculationResult.reason,
                  });

              // Update Exercise defaults with calculated values
              // Ajuste progresivo de series: aplicar delta sobre la configuración actual del usuario
              final currentConfiguredSets = exerciseModel.defaultSets ?? 3;
              final previousSetsInState = progressionState.currentSets;
              final maxSets = ref.read(maxSetsPerExerciseProvider);
              final int adjustedSets = computeAdjustedSets(
                currentConfiguredSets: currentConfiguredSets,
                previousSetsInState: previousSetsInState,
                newSetsFromCalculation: calculationResult.newSets,
                maxSets: maxSets,
              );

              final updatedExerciseModel = exerciseModel.copyWith(
                defaultWeight: calculationResult.newWeight,
                defaultReps: calculationResult.newReps,
                defaultSets: adjustedSets,
              );

              // Persist updated exercise
              await ref
                  .read(exerciseNotifierProvider.notifier)
                  .updateExercise(updatedExerciseModel);

              // Build updated routine exercise (structure unchanged; Exercise carries defaults)
              final updatedExercise = exercise.copyWith();

              updatedExercises.add(updatedExercise);

              LoggingService.instance.debug('Exercise progression applied', {
                'exerciseId': exercise.exerciseId,
                'oldWeight': exerciseModel.defaultWeight,
                'newWeight': calculationResult.newWeight,
                'oldReps': exerciseModel.defaultReps,
                'newReps': calculationResult.newReps,
                'oldSets': exerciseModel.defaultSets,
                'newSets': adjustedSets,
                'reason': calculationResult.reason,
              });
            } else {
              // No calculation: keep current values
              updatedExercises.add(exercise);
            }
          } catch (e, stackTrace) {
            LoggingService.instance.error(
              'Error applying progression to exercise',
              e,
              stackTrace,
              {'exerciseId': exercise.exerciseId, 'routineId': routine.id},
            );
            // On error: keep original values
            updatedExercises.add(exercise);
          }
        }
      }

      LoggingService.instance.info(
        'Progression applied to routine successfully',
        {'routineId': routine.id, 'exercisesUpdated': updatedExercises.length},
      );

      return updatedExercises;
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error applying progression to routine',
        e,
        stackTrace,
        {'routineId': routine.id},
      );
      // On error: return original routine exercises
      return _getAllExercisesFromRoutine(routine);
    }
  }

  /// Returns all routine exercises flattened from sections.
  List<RoutineExercise> _getAllExercisesFromRoutine(Routine routine) {
    final exercises = <RoutineExercise>[];
    for (final section in routine.sections) {
      exercises.addAll(section.exercises);
    }
    return exercises;
  }

  /// Creates ExerciseSet items based on the applied progression.
  Future<List<ExerciseSet>> createProgressionBasedSets(
    List<RoutineExercise> exercises,
    DateTime sessionStartTime,
  ) async {
    try {
      final exerciseSets = <ExerciseSet>[];

      for (final exercise in exercises) {
        // Fetch exercise defaults
        final exerciseData = await ref.read(exerciseNotifierProvider.future);
        final exerciseModel = exerciseData.firstWhere(
          (e) => e.id == exercise.exerciseId,
          orElse:
              () =>
                  throw Exception('Exercise not found: ${exercise.exerciseId}'),
        );

        // Create sets based on exercise defaults
        final sets = exerciseModel.defaultSets ?? 3;
        final reps = exerciseModel.defaultReps ?? 10;
        final weight = exerciseModel.defaultWeight ?? 0.0;
        final restTime = exerciseModel.restTimeSeconds ?? 60;

        for (int i = 0; i < sets; i++) {
          final exerciseSet = ExerciseSet(
            id:
                '${exercise.id}_set_${i + 1}_${DateTime.now().millisecondsSinceEpoch}',
            exerciseId: exercise.exerciseId,
            reps: reps,
            weight: weight,
            restTimeSeconds: restTime,
            notes: exercise.notes,
            completedAt: sessionStartTime,
            isCompleted: false,
          );

          exerciseSets.add(exerciseSet);
        }
      }

      LoggingService.instance.info('Progression-based exercise sets created', {
        'totalSets': exerciseSets.length,
        'exercises': exercises.length,
      });

      return exerciseSets;
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error creating progression-based exercise sets',
        e,
        stackTrace,
      );
      return [];
    }
  }

  /// Returns whether progression is currently applied for this routine.
  Future<bool> hasProgressionApplied(String routineId) async {
    try {
      final progressionNotifier = ref.read(
        progressionNotifierProvider.notifier,
      );
      return progressionNotifier.hasActiveProgression;
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error checking if routine has progression applied',
        e,
        stackTrace,
        {'routineId': routineId},
      );
      return false;
    }
  }

  /// Returns progression info suitable for UI display.
  Future<ProgressionInfo?> getProgressionInfo() async {
    try {
      final progressionNotifier = ref.read(
        progressionNotifierProvider.notifier,
      );

      if (!progressionNotifier.hasActiveProgression) {
        return null;
      }

      final config = await ref.read(progressionNotifierProvider.future);
      if (config == null) return null;

      return ProgressionInfo(
        type: config.type,
        description: config.type.descriptionKey,
        isActive: config.isActive,
        startDate: config.startDate,
      );
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error getting progression info',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Determines if progression should be applied based on routine frequency.
  Future<bool> _shouldApplyProgressionForRoutine(Routine routine) async {
    try {
      // Resolve active progression configuration
      final config = await ref.read(progressionNotifierProvider.future);
      if (config == null) return false;

      // If unit is per-session, always apply
      if (config.unit == ProgressionUnit.session) {
        LoggingService.instance.debug(
          'Session-based progression - applying progression every session',
          {'routineId': routine.id, 'unit': config.unit.name},
        );
        return true;
      }

      // Read configured sessions per week
      final sessionsPerWeek = config.customParameters['sessions_per_week'] ?? 3;

      // Single-session-per-week routines: always apply
      if (sessionsPerWeek == 1) {
        LoggingService.instance.debug(
          'Single session per week routine - applying progression every session',
          {'routineId': routine.id, 'sessionsPerWeek': sessionsPerWeek},
        );
        return true;
      }

      // Multi-day routines with weekly progression: apply on first session of week only
      return await _isFirstSessionOfWeekForRoutine(routine);
    } catch (e) {
      LoggingService.instance.error(
        'Error checking if should apply progression for routine',
        e,
        null,
        {'routineId': routine.id},
      );
      // Conservative default on error: apply progression
      return true;
    }
  }

  /// Checks whether this is the first session of the week for the routine.
  Future<bool> _isFirstSessionOfWeekForRoutine(Routine routine) async {
    try {
      // Get all sessions
      final sessionService = ref.read(sessionServiceProvider);
      final allSessions = await sessionService.getAllSessions();

      // Filter routine sessions
      final routineSessions =
          allSessions
              .where((session) => session.routineId == routine.id)
              .toList();

      if (routineSessions.isEmpty) {
        // No prior sessions => first of the week
        return true;
      }

      // Compute current week range
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      // Filter sessions for current week
      final sessionsThisWeek =
          routineSessions.where((session) {
            final sessionDate = session.startTime;
            return sessionDate.isAfter(
                  startOfWeek.subtract(const Duration(days: 1)),
                ) &&
                sessionDate.isBefore(endOfWeek.add(const Duration(days: 1)));
          }).toList();

      // No sessions this week => first
      if (sessionsThisWeek.isEmpty) {
        return true;
      }

      // Inspect progression state to infer whether progression already applied this week
      final progressionNotifier = ref.read(
        progressionNotifierProvider.notifier,
      );

      // Get the first exercise in the routine to check its progression state
      if (routine.sections.isNotEmpty &&
          routine.sections.first.exercises.isNotEmpty) {
        final firstExerciseId =
            routine.sections.first.exercises.first.exerciseId;
        final progressionState = await progressionNotifier
            .getExerciseProgressionState(firstExerciseId);

        if (progressionState != null) {
          // Check if progression was already applied this week
          final sessionsPerWeek =
              progressionState.customData['sessions_per_week'] ?? 3;
          final currentSession = progressionState.currentSession;

          // Derive session index within the current week
          final sessionsInCurrentWeek =
              ((currentSession - 1) % sessionsPerWeek) + 1;

          // First session of week => apply
          return sessionsInCurrentWeek == 1;
        }
      }

      // Fallback when uncertain: apply progression
      return true;
    } catch (e) {
      LoggingService.instance.error(
        'Error checking if first session of week',
        e,
      );
      // Conservative default on error: apply progression
      return true;
    }
  }
}

class ProgressionInfo {
  final ProgressionType type;
  final String description;
  final bool isActive;
  final DateTime startDate;

  const ProgressionInfo({
    required this.type,
    required this.description,
    required this.isActive,
    required this.startDate,
  });
}
