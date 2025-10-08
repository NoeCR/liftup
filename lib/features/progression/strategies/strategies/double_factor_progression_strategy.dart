import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../../models/progression_calculation_result.dart';
import '../../../../common/enums/progression_type_enum.dart';
import '../../../../features/exercise/models/exercise.dart';
import '../progression_strategy.dart';

/// Estrategia de Progresión Doble Factor (Doble Progresión)
///
/// Esta estrategia implementa la doble progresión (double progression), una estrategia
/// muy usada en fuerza e hipertrofia que controla dos variables clave: repeticiones y peso.
/// Primero se incrementan las repeticiones dentro de un rango objetivo, y cuando se alcanza
/// el máximo de repeticiones en todas las series, se incrementa el peso y se resetea al mínimo.
///
/// **Fundamentos teóricos:**
/// - Basada en el concepto de "double progression" de la literatura de entrenamiento
/// - Controla volumen (reps) e intensidad (peso) de manera sistemática
/// - Reduce el riesgo de estancamiento al no depender solo del peso
/// - Permite adaptación técnica antes de incrementar peso
/// - Ideal para ejercicios de fuerza-hipertrofia
///
/// **Algoritmo:**
/// 1. Calcula la posición actual en el ciclo
/// 2. Verifica si es período de deload
/// 3. Obtiene parámetros de doble progresión:
///    - minReps: Repeticiones mínimas del rango (valor de reset)
///    - maxReps: Repeticiones máximas antes de incrementar peso
///    - incrementValue: Cantidad de peso a incrementar
/// 4. Lógica de progresión:
///    - Si currentReps < maxReps: Incrementa repeticiones en 1
///    - Si currentReps >= maxReps: Incrementa peso y resetea reps a minReps
/// 5. Durante deload:
///    - Reduce peso manteniendo incremento sobre base
///    - Reduce series al 70%
///
/// **Parámetros clave:**
/// - minReps: Repeticiones mínimas (valor de reset)
/// - maxReps: Repeticiones máximas antes de incrementar peso
/// - incrementValue: Cantidad de peso a incrementar
/// - deloadWeek: Semana de deload
/// - deloadPercentage: Porcentaje de reducción durante deload
///
/// **Ventajas:**
/// - Progresión más gradual y sostenible
/// - Mejora técnica antes de incrementar peso
/// - Reduce riesgo de lesiones
/// - Efectiva para hipertrofia y fuerza
/// - Fácil de seguir y monitorear
///
/// **Limitaciones:**
/// - Progresión más lenta en peso absoluto
/// - Requiere rangos de repeticiones apropiados
/// - Necesita registro detallado de series
/// - Puede ser menos efectiva para fuerza máxima pura
class DoubleFactorProgressionStrategy implements ProgressionStrategy {
  @override
  ProgressionCalculationResult calculate({
    required ProgressionConfig config,
    required ProgressionState state,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
    ExerciseType? exerciseType,
  }) {
    final currentInCycle =
        config.unit == ProgressionUnit.session
            ? ((state.currentSession - 1) % config.cycleLength) + 1
            : ((state.currentWeek - 1) % config.cycleLength) + 1;

    final isDeloadPeriod = config.deloadWeek > 0 && currentInCycle == config.deloadWeek;

    // Obtener parámetros de doble progresión
    final maxReps = _getMaxReps(config);
    final minReps = _getMinReps(config);

    // 1. PRIMERO: Aplicar lógica de doble progresión
    ProgressionCalculationResult result;
    if (currentReps < maxReps) {
      // Incrementar repeticiones si no hemos llegado al máximo
      result = ProgressionCalculationResult(
        newWeight: currentWeight,
        newReps: currentReps + 1,
        newSets: currentSets,
        incrementApplied: true,
        reason: 'Double factor progression: increasing reps (week $currentInCycle of ${config.cycleLength})',
      );
    } else {
      // Incrementar peso y resetear reps al mínimo
      final incrementValue = _getIncrementValue(config, exerciseType: exerciseType);
      result = ProgressionCalculationResult(
        newWeight: currentWeight + incrementValue,
        newReps: minReps,
        newSets: currentSets,
        incrementApplied: true,
        reason:
            'Double factor progression: increasing weight +${incrementValue}kg and resetting reps to $minReps (week $currentInCycle of ${config.cycleLength})',
      );
    }

    // 2. DESPUÉS: Si es deload, aplicar reducción de peso y sets
    if (isDeloadPeriod) {
      final double increaseOverBase = (result.newWeight - state.baseWeight).clamp(0, double.infinity);
      final double deloadWeight = state.baseWeight + (increaseOverBase * config.deloadPercentage);

      return ProgressionCalculationResult(
        newWeight: deloadWeight,
        newReps: result.newReps, // Mantener las reps de la progresión normal
        newSets: (result.newSets * 0.7).round(), // Reducir sets
        incrementApplied: true,
        reason: 'Double factor progression: deload week $currentInCycle of ${config.cycleLength}',
      );
    }

    return result;
  }

  /// Obtiene el máximo de repeticiones desde parámetros personalizados
  int _getMaxReps(ProgressionConfig config) {
    // Prioridad: per_exercise > global > defaults por tipo
    final customParams = config.customParameters;

    // Buscar en per_exercise primero
    final perExercise = customParams['per_exercise'];
    if (perExercise is Map) {
      final exerciseParams = perExercise.values.first;
      if (exerciseParams is Map) {
        final maxReps =
            exerciseParams['max_reps'] ?? exerciseParams['multi_reps_max'] ?? exerciseParams['iso_reps_max'];
        if (maxReps != null) return maxReps as int;
      }
    }

    // Fallback a global
    return customParams['max_reps'] ?? customParams['multi_reps_max'] ?? customParams['iso_reps_max'] ?? 12; // default
  }

  /// Obtiene el mínimo de repeticiones desde parámetros personalizados
  int _getMinReps(ProgressionConfig config) {
    // Prioridad: per_exercise > global > defaults por tipo
    final customParams = config.customParameters;

    // Buscar en per_exercise primero
    final perExercise = customParams['per_exercise'];
    if (perExercise is Map) {
      final exerciseParams = perExercise.values.first;
      if (exerciseParams is Map) {
        final minReps =
            exerciseParams['min_reps'] ?? exerciseParams['multi_reps_min'] ?? exerciseParams['iso_reps_min'];
        if (minReps != null) return minReps as int;
      }
    }

    // Fallback a global
    return customParams['min_reps'] ?? customParams['multi_reps_min'] ?? customParams['iso_reps_min'] ?? 5; // default
  }

  /// Obtiene el valor de incremento desde parámetros personalizados
  /// Prioridad: per_exercise > global > defaults por tipo
  /// Considera el tipo de ejercicio para elegir el incremento apropiado
  double _getIncrementValue(ProgressionConfig config, {ExerciseType? exerciseType}) {
    final customParams = config.customParameters;

    // Buscar en per_exercise primero
    final perExercise = customParams['per_exercise'];
    if (perExercise is Map) {
      final exerciseParams = perExercise.values.first;
      if (exerciseParams is Map) {
        // Priorizar incremento específico por tipo de ejercicio
        final increment =
            _getIncrementByExerciseType(exerciseParams.cast<String, dynamic>(), exerciseType) ??
            exerciseParams['increment_value'];
        if (increment != null) return (increment as num).toDouble();
      }
    }

    // Fallback a global
    final globalIncrement = _getIncrementByExerciseType(customParams, exerciseType) ?? customParams['increment_value'];
    if (globalIncrement != null) return (globalIncrement as num).toDouble();

    return config.incrementValue; // fallback al valor base
  }

  /// Obtiene el incremento apropiado según el tipo de ejercicio
  double? _getIncrementByExerciseType(Map<String, dynamic> params, ExerciseType? exerciseType) {
    if (exerciseType == null) return null;

    final bool isMulti = exerciseType == ExerciseType.multiJoint;
    final String prefix = isMulti ? 'multi' : 'iso';

    final value = params['${prefix}_increment_min'] as num?;
    return value?.toDouble();
  }
}
