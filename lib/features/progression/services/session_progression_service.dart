import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/progression_state.dart';
import '../notifiers/progression_notifier.dart';
import '../../exercise/models/exercise_set.dart';
import '../../home/models/routine.dart';
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

      LoggingService.instance.info('Applying progression to routine', {
        'routineId': routine.id,
        'routineName': routine.name,
        'progressionType': progressionNotifier.activeProgressionType?.name,
      });

      final updatedExercises = <RoutineExercise>[];

      for (final section in routine.sections) {
        for (final exercise in section.exercises) {
          try {
            // Obtener o inicializar el estado de progresión para este ejercicio
            ProgressionState? progressionState = await progressionNotifier
                .getExerciseProgressionState(exercise.exerciseId);

            if (progressionState == null) {
              // Inicializar progresión para este ejercicio
              progressionState = await progressionNotifier
                  .initializeExerciseProgression(
                    exerciseId: exercise.exerciseId,
                    baseWeight: exercise.weight,
                    baseReps: exercise.reps,
                    baseSets: exercise.sets,
                  );
            }

            // Calcular nuevos valores basados en la progresión
            final calculationResult = await progressionNotifier
                .calculateExerciseProgression(
                  exerciseId: exercise.exerciseId,
                  currentWeight: progressionState.currentWeight,
                  currentReps: progressionState.currentReps,
                  currentSets: progressionState.currentSets,
                );

            if (calculationResult != null) {
              // Crear ejercicio actualizado con los nuevos valores
              final updatedExercise = exercise.copyWith(
                weight: calculationResult.newWeight,
                reps: calculationResult.newReps,
                sets: calculationResult.newSets,
              );

              updatedExercises.add(updatedExercise);

              LoggingService.instance.debug('Exercise progression applied', {
                'exerciseId': exercise.exerciseId,
                'oldWeight': exercise.weight,
                'newWeight': calculationResult.newWeight,
                'oldReps': exercise.reps,
                'newReps': calculationResult.newReps,
                'oldSets': exercise.sets,
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
        // Crear sets basados en la configuración del ejercicio
        for (int i = 0; i < exercise.sets; i++) {
          final exerciseSet = ExerciseSet(
            id:
                '${exercise.id}_set_${i + 1}_${DateTime.now().millisecondsSinceEpoch}',
            exerciseId: exercise.exerciseId,
            reps: exercise.reps,
            weight: exercise.weight,
            restTimeSeconds: exercise.restTimeSeconds,
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
        description: config.type.description,
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
