import '../../../../common/enums/progression_type_enum.dart';
import '../../../features/exercise/models/exercise.dart';
import '../models/progression_config.dart';
import '../models/progression_state.dart';

/// Clase base abstracta que proporciona funcionalidad común
/// para las estrategias de progresión
///
/// Contiene métodos helper compartidos y utilidades comunes
abstract class BaseProgressionStrategy {
  /// Métodos de utilidad compartidos
  int getCurrentInCycle(ProgressionConfig config, ProgressionState state) {
    final bool isSessionUnit = config.unit == ProgressionUnit.session;
    final int rawIndex = isSessionUnit ? state.currentSession : state.currentWeek;
    if (rawIndex <= 0) {
      // Evita (-1 % n) -> n-1; la primera sesión/semana debe ser 1
      return 1;
    }
    return ((rawIndex - 1) % config.cycleLength) + 1;
  }

  bool isDeloadPeriod(ProgressionConfig config, int currentInCycle) {
    return config.deloadWeek > 0 && currentInCycle == config.deloadWeek;
  }

  /// Calcula la próxima sesión y semana basado en la configuración
  ({int session, int week}) calculateNextSessionAndWeek({
    required ProgressionConfig config,
    required ProgressionState state,
  }) {
    final sessionsPerWeek = config.customParameters['sessions_per_week'] ?? 3;
    final newSession = state.currentSession + 1;
    final newWeek = ((newSession - 1) ~/ sessionsPerWeek) + 1;

    return (session: newSession, week: newWeek);
  }

  /// Verifica si la progresión está bloqueada para una rutina específica
  bool isProgressionBlockedForRoutine(ProgressionState state, String routineId) {
    final customData = state.customData;
    final skipNextByRoutine = customData['skip_next_by_routine'] as Map<String, dynamic>?;
    if (skipNextByRoutine == null) return false;

    return skipNextByRoutine[routineId] == true;
  }

  /// Verifica si la progresión está bloqueada (por rutina O por ejercicio específico)
  bool isProgressionBlocked(ProgressionState state, String exerciseId, String routineId, bool isExerciseLocked) {
    // Verificar bloqueo por rutina completa
    if (isProgressionBlockedForRoutine(state, routineId)) {
      return true;
    }

    // Verificar bloqueo por ejercicio específico (usando el campo del modelo Exercise)
    if (isExerciseLocked) {
      return true;
    }

    return false;
  }

  /// Helper method to check if progression values should be applied to an exercise
  /// Returns true if progression values should be used, false if blocked
  bool shouldApplyProgressionValues(ProgressionState? progressionState, String routineId, bool isExerciseLocked) {
    if (progressionState == null) return false;

    return !isProgressionBlocked(progressionState, progressionState.exerciseId, routineId, isExerciseLocked);
  }

  /// Obtiene el valor de incremento desde parámetros personalizados
  /// Prioridad: per_exercise > global > defaults por tipo > fallback
  /// Considera el tipo de ejercicio para elegir el incremento apropiado
  double getIncrementValue(ProgressionConfig config, {ExerciseType? exerciseType, dynamic exercise}) {
    // Si se proporciona un ejercicio, usar el método adaptativo de ProgressionConfig
    if (exercise != null) {
      return config.getAdaptiveIncrement(exercise);
    }

    // Fallback al método original para compatibilidad
    final customParams = config.customParameters;

    // Buscar en per_exercise primero
    try {
      final perExercise = customParams['per_exercise'] as Map<String, dynamic>?;
      if (perExercise != null) {
        final exerciseParams = perExercise.values.first as Map<String, dynamic>?;
        if (exerciseParams != null) {
          // Priorizar incremento específico por tipo de ejercicio
          final increment =
              _getIncrementByExerciseType(exerciseParams, exerciseType) ?? exerciseParams['increment_value'];
          if (increment != null && increment is num) {
            return increment.toDouble();
          }
        }
      }
    } catch (e) {
      // Si hay error en per_exercise, continuar con fallbacks
    }

    // Fallback a global
    try {
      // Priorizar incremento específico por tipo de ejercicio
      final globalIncrement =
          _getIncrementByExerciseType(customParams, exerciseType) ?? customParams['increment_value'];
      if (globalIncrement != null && globalIncrement is num) {
        return globalIncrement.toDouble();
      }
    } catch (e) {
      // Si hay error en global, usar defaults por tipo
    }

    // Fallback a defaults por tipo de ejercicio
    final typeDefaultIncrement = _getDefaultIncrementByExerciseType(exerciseType);
    if (typeDefaultIncrement != null) {
      return typeDefaultIncrement;
    }

    return config.incrementValue; // fallback al valor base de la configuración
  }

  /// Obtiene el máximo de repeticiones desde parámetros personalizados
  /// Prioridad: per_exercise > global > defaults por tipo
  int getMaxReps(ProgressionConfig config, {ExerciseType? exerciseType, dynamic exercise}) {
    // Si se proporciona un ejercicio, usar el método adaptativo de ProgressionConfig
    if (exercise != null) {
      return config.getAdaptiveMaxReps(exercise);
    }

    // Fallback al método original para compatibilidad
    final customParams = config.customParameters;

    // Buscar en per_exercise primero
    try {
      final perExercise = customParams['per_exercise'] as Map<String, dynamic>?;
      if (perExercise != null) {
        final exerciseParams = perExercise.values.first as Map<String, dynamic>?;
        if (exerciseParams != null) {
          final maxReps = _getRepsByExerciseType(exerciseParams, exerciseType, 'max') ?? exerciseParams['max_reps'];
          if (maxReps != null && maxReps is num) {
            return maxReps.toInt();
          }
        }
      }
    } catch (e) {
      // Si hay error en per_exercise, continuar con fallbacks
    }

    // Fallback a global
    try {
      final globalMaxReps = _getRepsByExerciseType(customParams, exerciseType, 'max') ?? customParams['max_reps'];
      if (globalMaxReps != null && globalMaxReps is num) {
        return globalMaxReps.toInt();
      }
    } catch (e) {
      // Si hay error en global, usar defaults por tipo
    }

    // Fallback a defaults por tipo de ejercicio
    final typeDefaultMaxReps = _getDefaultRepsByExerciseType(exerciseType, 'max');
    if (typeDefaultMaxReps != null) {
      return typeDefaultMaxReps;
    }

    return config.maxReps; // Usar el campo maxReps de la configuración
  }

  /// Obtiene el mínimo de repeticiones desde parámetros personalizados
  /// Prioridad: per_exercise > global > defaults por tipo
  int getMinReps(ProgressionConfig config, {ExerciseType? exerciseType, dynamic exercise}) {
    // Si se proporciona un ejercicio, usar el método adaptativo de ProgressionConfig
    if (exercise != null) {
      return config.getAdaptiveMinReps(exercise);
    }

    // Fallback al método original para compatibilidad
    final customParams = config.customParameters;

    // Buscar en per_exercise primero
    try {
      final perExercise = customParams['per_exercise'] as Map<String, dynamic>?;
      if (perExercise != null) {
        final exerciseParams = perExercise.values.first as Map<String, dynamic>?;
        if (exerciseParams != null) {
          final minReps = _getRepsByExerciseType(exerciseParams, exerciseType, 'min') ?? exerciseParams['min_reps'];
          if (minReps != null && minReps is num) {
            return minReps.toInt();
          }
        }
      }
    } catch (e) {
      // Si hay error en per_exercise, continuar con fallbacks
    }

    // Fallback a global
    try {
      final globalMinReps = _getRepsByExerciseType(customParams, exerciseType, 'min') ?? customParams['min_reps'];
      if (globalMinReps != null && globalMinReps is num) {
        return globalMinReps.toInt();
      }
    } catch (e) {
      // Si hay error en global, usar defaults por tipo
    }

    // Fallback a defaults por tipo de ejercicio
    final typeDefaultMinReps = _getDefaultRepsByExerciseType(exerciseType, 'min');
    if (typeDefaultMinReps != null) {
      return typeDefaultMinReps;
    }

    return config.minReps; // Usar el campo minReps de la configuración
  }

  /// Obtiene las series base desde parámetros personalizados
  /// Prioridad: per_exercise > global > defaults por tipo
  int getBaseSets(ProgressionConfig config, {ExerciseType? exerciseType, dynamic exercise}) {
    // Si se proporciona un ejercicio, usar el método adaptativo de ProgressionConfig
    if (exercise != null) {
      return config.getAdaptiveBaseSets(exercise);
    }

    // Fallback al método original para compatibilidad
    final customParams = config.customParameters;

    // Buscar en per_exercise primero
    try {
      final perExercise = customParams['per_exercise'] as Map<String, dynamic>?;
      if (perExercise != null) {
        final exerciseParams = perExercise.values.first as Map<String, dynamic>?;
        if (exerciseParams != null) {
          final baseSets = exerciseParams['base_sets'];
          if (baseSets != null && baseSets is num) {
            return baseSets.toInt();
          }
        }
      }
    } catch (e) {
      // Si hay error en per_exercise, continuar con fallbacks
    }

    // Fallback a global
    try {
      final globalBaseSets = customParams['base_sets'];
      if (globalBaseSets != null && globalBaseSets is num) {
        return globalBaseSets.toInt();
      }
    } catch (e) {
      // Si hay error en global, usar defaults por tipo
    }

    return config.baseSets; // Usar el campo baseSets de la configuración
  }

  /// Métodos privados helper
  double? _getIncrementByExerciseType(Map<String, dynamic> params, ExerciseType? exerciseType) {
    if (exerciseType == null) return null;

    final bool isMulti = exerciseType == ExerciseType.multiJoint;
    final String prefix = isMulti ? 'multi' : 'iso';

    final value = params['${prefix}_increment_min'] as num?;
    return value?.toDouble();
  }

  int? _getRepsByExerciseType(
    Map<String, dynamic> params,
    ExerciseType? exerciseType,
    String type, // 'min' o 'max'
  ) {
    if (exerciseType == null) return null;

    final bool isMulti = exerciseType == ExerciseType.multiJoint;
    final String prefix = isMulti ? 'multi' : 'iso';

    final value = params['${prefix}_reps_$type'] as num?;
    return value?.toInt();
  }

  double? _getDefaultIncrementByExerciseType(ExerciseType? exerciseType) {
    if (exerciseType == null) return null;

    switch (exerciseType) {
      case ExerciseType.multiJoint:
        // Ejercicios multiarticulares (sentadilla, press banca, peso muerto)
        // Típicamente pueden manejar incrementos más grandes
        return 2.5;
      case ExerciseType.isolation:
        // Ejercicios de aislamiento (curl, extensiones, etc.)
        // Típicamente requieren incrementos más pequeños
        return 1.25;
    }
  }

  int? _getDefaultRepsByExerciseType(ExerciseType? exerciseType, String type) {
    if (exerciseType == null) return null;

    switch (exerciseType) {
      case ExerciseType.multiJoint:
        // Ejercicios multiarticulares típicamente usan rangos más bajos
        return type == 'max' ? 8 : 5;
      case ExerciseType.isolation:
        // Ejercicios de aislamiento típicamente usan rangos más altos
        return type == 'max' ? 15 : 8;
    }
  }
}
