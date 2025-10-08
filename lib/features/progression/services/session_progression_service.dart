import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/progression_state.dart';
import '../notifiers/progression_notifier.dart';
import '../../exercise/models/exercise_set.dart';
import '../../exercise/notifiers/exercise_notifier.dart';
import '../../exercise/models/exercise.dart';
import '../../home/models/routine.dart';
import '../../sessions/services/session_service.dart';
import '../../../core/logging/logging.dart';
import '../../../common/enums/progression_type_enum.dart';
import '../../settings/notifiers/rest_prefs.dart';
import '../services/progression_service.dart';
import 'package:flutter/foundation.dart';
part 'session_progression_service.g.dart';

int computeAdjustedSets({
  required int currentConfiguredSets,
  required int previousSetsInState,
  required int newSetsFromCalculation,
  required int maxSets,
}) {
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
  Future<List<RoutineExercise>> applyProgressionToRoutine(Routine routine) async {
    try {
      final progressionNotifier = ref.read(progressionNotifierProvider.notifier);

      // Fast-exit if there is no active progression
      if (!progressionNotifier.hasActiveProgression) {
        LoggingService.instance.debug('No active progression, returning routine as-is');
        return _getAllExercisesFromRoutine(routine);
      }

      // Resolve active progression configuration
      final config = await ref.read(progressionNotifierProvider.future);
      if (config == null) {
        LoggingService.instance.warning('No progression config found, returning routine as-is');
        return _getAllExercisesFromRoutine(routine);
      }

      // Decide whether progression should be applied based on routine frequency
      final shouldApplyProgression = await _shouldApplyProgressionForRoutine(routine);

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
            final exerciseData = await ref.read(exerciseNotifierProvider.future);
            final exerciseModel = exerciseData.firstWhere(
              (e) => e.id == exercise.exerciseId,
              orElse: () => throw Exception('Exercise not found: ${exercise.exerciseId}'),
            );

            // Skip if progression is locked for this exercise
            if (exerciseModel.isProgressionLocked) {
              updatedExercises.add(exercise);
              continue;
            }

            // Apply progression only to exercises previously performed
            if (exerciseModel.lastPerformedAt == null) {
              updatedExercises.add(exercise);
              continue;
            }

            // Get or initialize progression state for this exercise
            ProgressionState? progressionState = await progressionNotifier.getExerciseProgressionState(
              exercise.exerciseId,
            );

            // Check if the existing progression state is for the current routine
            // If not, we should initialize a new one with the configured values
            final isForCurrentRoutine = progressionState?.customData['current_routine_id'] == routine.id;
            
            // Initialize progression state for this exercise if:
            // 1. No progression state exists, OR
            // 2. The existing state is not for the current routine
            if (progressionState == null || !isForCurrentRoutine) {
              progressionState = await progressionNotifier.initializeExerciseProgression(
                exerciseId: exercise.exerciseId,
                baseWeight: exerciseModel.defaultWeight ?? 0.0,
                baseReps: exerciseModel.defaultReps ?? 10,
                baseSets: exerciseModel.defaultSets ?? 4,
              );
              
              // Mark this progression state as belonging to the current routine
              final updatedCustomData = Map<String, dynamic>.from(progressionState.customData);
              updatedCustomData['current_routine_id'] = routine.id;
              final updatedState = progressionState.copyWith(
                customData: updatedCustomData,
                lastUpdated: DateTime.now(),
              );
              await ref.read(progressionServiceProvider.notifier).saveProgressionState(updatedState);
              progressionState = updatedState;
            }

            // Skip if a skip flag is set for this routine in the exercise state
            final skipByRoutine = progressionState.customData['skip_next_by_routine'] as Map?;
            final shouldSkipForRoutine = skipByRoutine != null && skipByRoutine[routine.id] == true;
            if (shouldSkipForRoutine) {
              // Clear the skip flag for this routine after skipping once
              final cleaned = Map<String, dynamic>.from(progressionState.customData);
              final byRoutine = Map<String, dynamic>.from((cleaned['skip_next_by_routine'] as Map?) ?? const {});
              byRoutine.remove(routine.id);
              cleaned['skip_next_by_routine'] = byRoutine;
              final updatedState = progressionState.copyWith(customData: cleaned, lastUpdated: DateTime.now());
              await ref.read(progressionServiceProvider.notifier).saveProgressionState(updatedState);

              updatedExercises.add(exercise);
              continue;
            }

            // Log current state before calculation
            LoggingService.instance.info('SESSION PROGRESSION: BEFORE CALCULATION', {
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
            final calculationResult = await progressionNotifier.calculateExerciseProgression(
              exerciseId: exercise.exerciseId,
              currentWeight: progressionState.currentWeight,
              currentReps: progressionState.currentReps,
              currentSets: progressionState.currentSets,
            );

            if (calculationResult != null) {
              // Build per-exercise custom parameters by overlaying per_exercise overrides
              final Map<String, dynamic> mergedCustom = buildMergedCustomForExercise(
                globalCustom: config.customParameters,
                exerciseId: exercise.exerciseId,
              );

              // Adjust by exerciseType-specific configuration (increments and rep ranges)
              final adjusted = _adjustByExerciseType(
                exerciseType: exerciseModel.exerciseType,
                currentWeight: progressionState.currentWeight,
                proposedWeight: calculationResult.newWeight,
                proposedReps: calculationResult.newReps,
                custom: mergedCustom,
                incrementApplied: calculationResult.incrementApplied,
              );
              // Log calculation result
              LoggingService.instance.info('SESSION PROGRESSION: CALCULATION RESULT', {
                'exerciseId': exercise.exerciseId,
                'exerciseName': exerciseModel.name,
                'oldWeight': progressionState.currentWeight,
                'newWeight': adjusted.newWeight,
                'oldReps': progressionState.currentReps,
                'newReps': adjusted.newReps,
                'oldSets': progressionState.currentSets,
                'newSets': calculationResult.newSets,
                'incrementApplied': calculationResult.incrementApplied,
                'reason': calculationResult.reason,
              });

              // Update Exercise defaults with calculated values
              // Ajuste progresivo de series: aplicar delta sobre la configuración actual del usuario
              final currentConfiguredSets = exerciseModel.defaultSets ?? 4;
              final previousSetsInState = progressionState.currentSets;
              final maxSets = ref.read(maxSetsPerExerciseProvider);
              final int adjustedSets = computeAdjustedSets(
                currentConfiguredSets: currentConfiguredSets,
                previousSetsInState: previousSetsInState,
                newSetsFromCalculation: calculationResult.newSets,
                maxSets: maxSets,
              );

              final updatedExerciseModel = exerciseModel.copyWith(
                defaultWeight: adjusted.newWeight,
                defaultReps: adjusted.newReps,
                defaultSets: adjustedSets,
              );

              // Persist updated exercise
              await ref.read(exerciseNotifierProvider.notifier).updateExercise(updatedExerciseModel);

              // Persist adjusted progression state so next session uses adjusted values
              try {
                final sessionsPerWeek = config.customParameters['sessions_per_week'] ?? 3;
                final newSession = progressionState.currentSession + 1;
                final newWeek = ((newSession - 1) ~/ sessionsPerWeek) + 1;

                final int currentInCycle =
                    config.unit == ProgressionUnit.session
                        ? ((progressionState.currentSession - 1) % config.cycleLength) + 1
                        : ((progressionState.currentWeek - 1) % config.cycleLength) + 1;
                final bool isDeloadNow = config.deloadWeek > 0 && currentInCycle == config.deloadWeek;

                // Update customData (track deload application)
                final updatedCustom = Map<String, dynamic>.from(progressionState.customData);
                if (isDeloadNow) {
                  updatedCustom['deload_last_cycle_pos'] = currentInCycle;
                } else {
                  updatedCustom.remove('deload_last_cycle_pos');
                }

                final updatedState = progressionState.copyWith(
                  currentWeight: adjusted.newWeight,
                  currentReps: adjusted.newReps,
                  currentSets: calculationResult.newSets,
                  currentSession: newSession,
                  currentWeek: newWeek,
                  lastUpdated: DateTime.now(),
                  baseWeight: isDeloadNow ? adjusted.newWeight : progressionState.baseWeight,
                  isDeloadWeek: isDeloadNow,
                  sessionHistory: {
                    ...progressionState.sessionHistory,
                    'session_$newSession': {
                      'weight': adjusted.newWeight,
                      'reps': adjusted.newReps,
                      'sets': calculationResult.newSets,
                      'date': DateTime.now().toIso8601String(),
                      'increment_applied': calculationResult.incrementApplied,
                    },
                  },
                  customData: updatedCustom,
                );

                await ref.read(progressionServiceProvider.notifier).saveProgressionState(updatedState);
              } catch (_) {}

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
            LoggingService.instance.error('Error applying progression to exercise', e, stackTrace, {
              'exerciseId': exercise.exerciseId,
              'routineId': routine.id,
            });
            // On error: keep original values
            updatedExercises.add(exercise);
          }
        }
      }

      LoggingService.instance.info('Progression applied to routine successfully', {
        'routineId': routine.id,
        'exercisesUpdated': updatedExercises.length,
      });

      return updatedExercises;
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error applying progression to routine', e, stackTrace, {'routineId': routine.id});
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
          orElse: () => throw Exception('Exercise not found: ${exercise.exerciseId}'),
        );

        // Create sets based on exercise defaults
        final sets = exerciseModel.defaultSets ?? 4;
        final reps = exerciseModel.defaultReps ?? 10;
        final weight = exerciseModel.defaultWeight ?? 0.0;
        final restTime = exerciseModel.restTimeSeconds ?? 60;

        for (int i = 0; i < sets; i++) {
          final exerciseSet = ExerciseSet(
            id: '${exercise.id}_set_${i + 1}_${DateTime.now().millisecondsSinceEpoch}',
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
      LoggingService.instance.error('Error creating progression-based exercise sets', e, stackTrace);
      return [];
    }
  }

  /// Returns whether progression is currently applied for this routine.
  Future<bool> hasProgressionApplied(String routineId) async {
    try {
      final progressionNotifier = ref.read(progressionNotifierProvider.notifier);
      return progressionNotifier.hasActiveProgression;
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error checking if routine has progression applied', e, stackTrace, {
        'routineId': routineId,
      });
      return false;
    }
  }

  /// Returns progression info suitable for UI display.
  Future<ProgressionInfo?> getProgressionInfo() async {
    try {
      final progressionNotifier = ref.read(progressionNotifierProvider.notifier);

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
      LoggingService.instance.error('Error getting progression info', e, stackTrace);
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
        LoggingService.instance.debug('Session-based progression - applying progression every session', {
          'routineId': routine.id,
          'unit': config.unit.name,
        });
        return true;
      }

      // Read configured sessions per week
      final sessionsPerWeek = config.customParameters['sessions_per_week'] ?? 3;

      // Single-session-per-week routines: always apply
      if (sessionsPerWeek == 1) {
        LoggingService.instance.debug('Single session per week routine - applying progression every session', {
          'routineId': routine.id,
          'sessionsPerWeek': sessionsPerWeek,
        });
        return true;
      }

      // Multi-day routines with weekly progression: apply on first session of week only
      return await _isFirstSessionOfWeekForRoutine(routine);
    } catch (e) {
      LoggingService.instance.error('Error checking if should apply progression for routine', e, null, {
        'routineId': routine.id,
      });
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
      final routineSessions = allSessions.where((session) => session.routineId == routine.id).toList();

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
            return sessionDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                sessionDate.isBefore(endOfWeek.add(const Duration(days: 1)));
          }).toList();

      // No sessions this week => first
      if (sessionsThisWeek.isEmpty) {
        return true;
      }

      // Inspect progression state to infer whether progression already applied this week
      final progressionNotifier = ref.read(progressionNotifierProvider.notifier);

      // Get the first exercise in the routine to check its progression state
      if (routine.sections.isNotEmpty && routine.sections.first.exercises.isNotEmpty) {
        final firstExerciseId = routine.sections.first.exercises.first.exerciseId;
        final progressionState = await progressionNotifier.getExerciseProgressionState(firstExerciseId);

        if (progressionState != null) {
          // Check if progression was already applied this week
          final sessionsPerWeek = progressionState.customData['sessions_per_week'] ?? 3;
          final currentSession = progressionState.currentSession;

          // Derive session index within the current week
          final sessionsInCurrentWeek = ((currentSession - 1) % sessionsPerWeek) + 1;

          // First session of week => apply
          return sessionsInCurrentWeek == 1;
        }
      }

      // Fallback when uncertain: apply progression
      return true;
    } catch (e) {
      LoggingService.instance.error('Error checking if first session of week', e);
      // Conservative default on error: apply progression
      return true;
    }
  }
}

class _TypeAdjustedResult {
  final double newWeight;
  final int newReps;
  const _TypeAdjustedResult({required this.newWeight, required this.newReps});
}

@visibleForTesting
Map<String, dynamic> buildMergedCustomForExercise({
  required Map<String, dynamic> globalCustom,
  required String exerciseId,
}) {
  final Map<String, dynamic> merged = Map<String, dynamic>.from(globalCustom);
  final Map<String, dynamic>? perExerciseAll = (globalCustom['per_exercise'] as Map?)?.cast<String, dynamic>();
  final Map<String, dynamic>? overrides =
      perExerciseAll != null ? (perExerciseAll[exerciseId] as Map?)?.cast<String, dynamic>() : null;
  if (overrides != null) {
    merged.addAll(overrides);
  }
  return merged;
}

_TypeAdjustedResult _adjustByExerciseType({
  required ExerciseType exerciseType,
  required double currentWeight,
  required double proposedWeight,
  required int proposedReps,
  required Map<String, dynamic> custom,
  required bool incrementApplied,
}) {
  // Expected keys in custom parameters:
  // multi_increment_min, multi_increment_max, multi_reps_min, multi_reps_max
  // iso_increment_min, iso_increment_max, iso_reps_min, iso_reps_max
  final bool isMulti = exerciseType == ExerciseType.multiJoint;
  final String prefix = isMulti ? 'multi' : 'iso';

  final double incMin = (custom['${prefix}_increment_min'] as num?)?.toDouble() ?? (isMulti ? 2.5 : 1.25);
  final double incMax = (custom['${prefix}_increment_max'] as num?)?.toDouble() ?? (isMulti ? 5.0 : 2.5);
  final int repsMin = (custom['${prefix}_reps_min'] as num?)?.toInt() ?? (isMulti ? 15 : 8);
  final int repsMax = (custom['${prefix}_reps_max'] as num?)?.toInt() ?? (isMulti ? 20 : 12);

  double adjustedWeight = proposedWeight;
  int adjustedReps = proposedReps;

  if (incrementApplied) {
    final double delta = proposedWeight - currentWeight;
    if (delta > 0) {
      // Adjust to closest allowed step within [incMin, incMax]
      double step = incMin;
      if (delta >= incMax) {
        step = incMax;
      } else if (delta >= incMin) {
        step = incMin;
      } else {
        step = incMin; // enforce minimum step
      }
      adjustedWeight = currentWeight + step;
    }
  }

  // Clamp reps to [repsMin, repsMax]
  if (adjustedReps < repsMin) adjustedReps = repsMin;
  if (adjustedReps > repsMax) adjustedReps = repsMax;

  return _TypeAdjustedResult(newWeight: adjustedWeight, newReps: adjustedReps);
}

@visibleForTesting
Map<String, dynamic> debugAdjustByExerciseType({
  required ExerciseType exerciseType,
  required double currentWeight,
  required double proposedWeight,
  required int proposedReps,
  required Map<String, dynamic> custom,
  required bool incrementApplied,
}) {
  final r = _adjustByExerciseType(
    exerciseType: exerciseType,
    currentWeight: currentWeight,
    proposedWeight: proposedWeight,
    proposedReps: proposedReps,
    custom: custom,
    incrementApplied: incrementApplied,
  );
  return {'weight': r.newWeight, 'reps': r.newReps};
}

@visibleForTesting
Map<String, dynamic> evaluateAndConsumeSkipForRoutine({
  required Map<String, dynamic> customData,
  required String routineId,
}) {
  final cleaned = Map<String, dynamic>.from(customData);
  final byRoutine = Map<String, dynamic>.from((cleaned['skip_next_by_routine'] as Map?) ?? const {});
  final shouldSkip = byRoutine[routineId] == true;
  if (shouldSkip) {
    byRoutine.remove(routineId);
    cleaned['skip_next_by_routine'] = byRoutine;
  }
  return {'skip': shouldSkip, 'custom': cleaned};
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
