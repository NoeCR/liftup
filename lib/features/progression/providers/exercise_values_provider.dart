import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../exercise/models/exercise.dart';
import '../../sessions/notifiers/session_notifier.dart';
import '../notifiers/progression_notifier.dart';

part 'exercise_values_provider.g.dart';

/// Provider que determina qué valores mostrar para un ejercicio específico en una rutina
@riverpod
Future<ExerciseDisplayValues> exerciseDisplayValues(
  Ref ref, {
  required Exercise exercise,
  required String routineId,
}) async {
  // Depender reactivamente del AsyncValue para evitar recrear Futures
  final progressionAsync = ref.watch(progressionNotifierProvider);

  // Sin progresión cargada o desactivada → valores base
  if (!progressionAsync.hasValue || progressionAsync.value == null) {
    return ExerciseDisplayValues(
      weight: exercise.defaultWeight ?? 0.0,
      reps: exercise.defaultReps ?? 10,
      sets: exercise.defaultSets ?? 4,
      source: ExerciseValueSource.base,
    );
  }

  try {
    // Buscar estado de progresión para este ejercicio en esta rutina
    final progressionState = await ref
        .read(progressionNotifierProvider.notifier)
        .getExerciseProgressionState(exercise.id, routineId);

    // Valores base si no hay estado
    double weight = exercise.defaultWeight ?? 0.0;
    int reps = exercise.defaultReps ?? 10;
    int sets = exercise.defaultSets ?? 4;
    ExerciseValueSource source = ExerciseValueSource.base;
    dynamic attachedProgressionState;

    if (progressionState != null) {
      weight = progressionState.currentWeight;
      reps = progressionState.currentReps;
      sets = progressionState.currentSets;
      source = ExerciseValueSource.progression;
      attachedProgressionState = progressionState;
    }

    // Aplicar overrides de la sesión (plan actual) si existen
    final sessionValues = ref
        .read(sessionNotifierProvider.notifier)
        .getSessionProgressionValues(exercise.id);

    int? restTimeSeconds;
    if (sessionValues != null) {
      // Ajustar sets planificados desde la sesión (p. ej., base_sets del preset)
      final plannedSets = sessionValues['sets'] as int?;
      if (plannedSets != null) {
        sets = plannedSets;
      }
      // Propagar tiempo de descanso desde la sesión
      restTimeSeconds = (sessionValues['rest_time_seconds'] as num?)?.toInt();
    }

    return ExerciseDisplayValues(
      weight: weight,
      reps: reps,
      sets: sets,
      restTimeSeconds: restTimeSeconds,
      source: source,
      progressionState: attachedProgressionState,
    );
  } catch (_) {
    return ExerciseDisplayValues(
      weight: exercise.defaultWeight ?? 0.0,
      reps: exercise.defaultReps ?? 10,
      sets: exercise.defaultSets ?? 4,
      source: ExerciseValueSource.base,
    );
  }
}

/// Valores a mostrar para un ejercicio
class ExerciseDisplayValues {
  final double weight;
  final int reps;
  final int sets;
  final int? restTimeSeconds;
  final ExerciseValueSource source;
  final dynamic progressionState; // ProgressionState opcional

  const ExerciseDisplayValues({
    required this.weight,
    required this.reps,
    required this.sets,
    this.restTimeSeconds,
    required this.source,
    this.progressionState,
  });

  /// Indica si los valores provienen de una progresión activa
  bool get isFromProgression => source == ExerciseValueSource.progression;

  /// Indica si es una semana de deload
  bool get isDeloadWeek => progressionState?.isDeloadWeek ?? false;
}

/// Fuente de los valores del ejercicio
enum ExerciseValueSource {
  /// Valores base del ejercicio (sin progresión)
  base,

  /// Valores actuales de la progresión
  progression,
}
