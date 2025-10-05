import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/progression_state.dart';
import '../notifiers/progression_notifier.dart';
import '../../exercise/models/exercise_set.dart';
import '../../exercise/notifiers/exercise_notifier.dart';
import '../../home/models/routine.dart';
import '../../sessions/services/session_service.dart';
import '../../../core/logging/logging.dart';
import '../../../common/enums/progression_type_enum.dart';

part 'session_progression_service.g.dart';

@riverpod
class SessionProgressionService extends _$SessionProgressionService {
  @override
  SessionProgressionService build() {
    return this;
  }

  /// Aplica la progresión a los ejercicios de una rutina antes de iniciar la sesión
  /// Solo se aplica en la primera sesión de la semana para esta rutina
  Future<List<RoutineExercise>> applyProgressionToRoutine(
    Routine routine,
  ) async {
    try {
      final progressionNotifier = ref.read(
        progressionNotifierProvider.notifier,
      );

      // Verificar si hay progresión activa
      if (!progressionNotifier.hasActiveProgression) {
        LoggingService.instance.debug(
          'No active progression, returning routine as-is',
        );
        return _getAllExercisesFromRoutine(routine);
      }

      // Obtener la configuración de progresión activa
      final config = await ref.read(progressionNotifierProvider.future);
      if (config == null) {
        LoggingService.instance.warning(
          'No progression config found, returning routine as-is',
        );
        return _getAllExercisesFromRoutine(routine);
      }

      // Verificar si se debe aplicar progresión basado en la frecuencia de la rutina
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
          // Skip if we've already processed this exercise in this routine
          if (processedExerciseIds.contains(exercise.exerciseId)) {
            updatedExercises.add(exercise);
            continue;
          }
          processedExerciseIds.add(exercise.exerciseId);
          try {
            // Obtener el ejercicio para acceder a sus valores por defecto
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

            // Obtener o inicializar el estado de progresión para este ejercicio
            ProgressionState? progressionState = await progressionNotifier
                .getExerciseProgressionState(exercise.exerciseId);

            // Inicializar progresión para este ejercicio
            progressionState ??= await progressionNotifier
                .initializeExerciseProgression(
                  exerciseId: exercise.exerciseId,
                  baseWeight: exerciseModel.defaultWeight ?? 0.0,
                  baseReps: exerciseModel.defaultReps ?? 10,
                  baseSets: exerciseModel.defaultSets ?? 3,
                );

            // Log del estado actual antes del cálculo
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

            // Calcular nuevos valores basados en la progresión
            final calculationResult = await progressionNotifier
                .calculateExerciseProgression(
                  exerciseId: exercise.exerciseId,
                  currentWeight: progressionState.currentWeight,
                  currentReps: progressionState.currentReps,
                  currentSets: progressionState.currentSets,
                );

            if (calculationResult != null) {
              // Log del resultado del cálculo
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

              // Actualizar el modelo Exercise con los nuevos valores calculados
              final updatedExerciseModel = exerciseModel.copyWith(
                defaultWeight: calculationResult.newWeight,
                defaultReps: calculationResult.newReps,
                defaultSets: calculationResult.newSets,
              );

              // Guardar el ejercicio actualizado
              await ref
                  .read(exerciseNotifierProvider.notifier)
                  .updateExercise(updatedExerciseModel);

              // Crear ejercicio actualizado (RoutineExercise no cambia, solo el Exercise)
              final updatedExercise = exercise.copyWith();

              updatedExercises.add(updatedExercise);

              LoggingService.instance.debug('Exercise progression applied', {
                'exerciseId': exercise.exerciseId,
                'oldWeight': exerciseModel.defaultWeight,
                'newWeight': calculationResult.newWeight,
                'oldReps': exerciseModel.defaultReps,
                'newReps': calculationResult.newReps,
                'oldSets': exerciseModel.defaultSets,
                'newSets': calculationResult.newSets,
                'reason': calculationResult.reason,
              });
            } else {
              // Si no hay cálculo, usar valores actuales
              updatedExercises.add(exercise);
            }
          } catch (e, stackTrace) {
            LoggingService.instance.error(
              'Error applying progression to exercise',
              e,
              stackTrace,
              {'exerciseId': exercise.exerciseId, 'routineId': routine.id},
            );
            // En caso de error, usar valores originales
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
      // En caso de error, devolver ejercicios originales
      return _getAllExercisesFromRoutine(routine);
    }
  }

  /// Obtiene todos los ejercicios de una rutina
  List<RoutineExercise> _getAllExercisesFromRoutine(Routine routine) {
    final exercises = <RoutineExercise>[];
    for (final section in routine.sections) {
      exercises.addAll(section.exercises);
    }
    return exercises;
  }

  /// Crea sets de ejercicio basados en la progresión aplicada
  Future<List<ExerciseSet>> createProgressionBasedSets(
    List<RoutineExercise> exercises,
    DateTime sessionStartTime,
  ) async {
    try {
      final exerciseSets = <ExerciseSet>[];

      for (final exercise in exercises) {
        // Obtener el ejercicio para acceder a sus valores por defecto
        final exerciseData = await ref.read(exerciseNotifierProvider.future);
        final exerciseModel = exerciseData.firstWhere(
          (e) => e.id == exercise.exerciseId,
          orElse:
              () =>
                  throw Exception('Exercise not found: ${exercise.exerciseId}'),
        );

        // Crear sets basados en la configuración del ejercicio
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

  /// Verifica si una rutina tiene progresión aplicada
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

  /// Obtiene información de progresión para mostrar al usuario
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

  /// Verifica si se debe aplicar progresión basado en la frecuencia de la rutina
  Future<bool> _shouldApplyProgressionForRoutine(Routine routine) async {
    try {
      // Obtener la configuración de progresión activa
      final config = await ref.read(progressionNotifierProvider.future);
      if (config == null) return false;

      // Si la progresión es por sesión, aplicar en cada sesión
      if (config.unit == ProgressionUnit.session) {
        LoggingService.instance.debug(
          'Session-based progression - applying progression every session',
          {'routineId': routine.id, 'unit': config.unit.name},
        );
        return true;
      }

      // Obtener la frecuencia de sesiones por semana de la configuración
      final sessionsPerWeek = config.customParameters['sessions_per_week'] ?? 3;

      // Si es una rutina de un solo día por semana, aplicar progresión en cada sesión
      if (sessionsPerWeek == 1) {
        LoggingService.instance.debug(
          'Single session per week routine - applying progression every session',
          {'routineId': routine.id, 'sessionsPerWeek': sessionsPerWeek},
        );
        return true;
      }

      // Para rutinas de múltiples días con progresión por semana, solo aplicar en la primera sesión de la semana
      return await _isFirstSessionOfWeekForRoutine(routine);
    } catch (e) {
      LoggingService.instance.error(
        'Error checking if should apply progression for routine',
        e,
        null,
        {'routineId': routine.id},
      );
      // En caso de error, aplicar progresión para ser conservador
      return true;
    }
  }

  /// Verifica si es la primera sesión de la semana para esta rutina
  Future<bool> _isFirstSessionOfWeekForRoutine(Routine routine) async {
    try {
      // Obtener las sesiones de esta rutina de la semana actual
      final sessionService = ref.read(sessionServiceProvider);
      final allSessions = await sessionService.getAllSessions();

      // Filtrar sesiones de esta rutina
      final routineSessions =
          allSessions
              .where((session) => session.routineId == routine.id)
              .toList();

      if (routineSessions.isEmpty) {
        // Si no hay sesiones previas, es la primera sesión
        return true;
      }

      // Obtener la fecha actual
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      // Filtrar sesiones de esta semana
      final sessionsThisWeek =
          routineSessions.where((session) {
            final sessionDate = session.startTime;
            return sessionDate.isAfter(
                  startOfWeek.subtract(const Duration(days: 1)),
                ) &&
                sessionDate.isBefore(endOfWeek.add(const Duration(days: 1)));
          }).toList();

      // Si no hay sesiones esta semana, es la primera
      if (sessionsThisWeek.isEmpty) {
        return true;
      }

      // Verificar si ya se aplicó progresión esta semana
      // Buscar en el historial de progresión si ya se aplicó esta semana
      final progressionNotifier = ref.read(
        progressionNotifierProvider.notifier,
      );

      // Obtener el primer ejercicio de la rutina para verificar el estado
      if (routine.sections.isNotEmpty &&
          routine.sections.first.exercises.isNotEmpty) {
        final firstExerciseId =
            routine.sections.first.exercises.first.exerciseId;
        final progressionState = await progressionNotifier
            .getExerciseProgressionState(firstExerciseId);

        if (progressionState != null) {
          // Verificar si ya se aplicó progresión esta semana
          final sessionsPerWeek =
              progressionState.customData['sessions_per_week'] ?? 3;
          final currentSession = progressionState.currentSession;

          // Calcular si ya se aplicó progresión esta semana
          final sessionsInCurrentWeek =
              ((currentSession - 1) % sessionsPerWeek) + 1;

          // Si es la primera sesión de la semana, aplicar progresión
          return sessionsInCurrentWeek == 1;
        }
      }

      // Por defecto, si no podemos determinar, aplicar progresión
      return true;
    } catch (e) {
      LoggingService.instance.error(
        'Error checking if first session of week',
        e,
      );
      // En caso de error, aplicar progresión para ser conservador
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
