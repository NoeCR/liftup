import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../../models/progression_calculation_result.dart';
import '../../../../features/exercise/models/exercise.dart';
import '../base_progression_strategy.dart';
import '../progression_strategy.dart';

/// Estrategia de Progresión Escalonada
///
/// Esta estrategia implementa una progresión escalonada donde se acumula carga progresivamente
/// durante un período específico, típicamente seguido de un deload.
///
/// **Fundamentos teóricos:**
/// - Basada en el concepto de acumulación de carga
/// - Incrementa peso de manera acumulativa durante semanas específicas
/// - Permite adaptación gradual a cargas crecientes
/// - Ideal para fases de acumulación en periodización
/// - Facilita la supercompensación
///
/// **Algoritmo:**
/// 1. Calcula la posición actual en el ciclo
/// 2. Verifica si es período de deload
/// 3. Calcula incremento acumulativo:
///    - Si currentInCycle <= accumulationWeeks:
///      * totalIncrement = incrementValue * currentInCycle
///    - Si currentInCycle > accumulationWeeks:
///      * totalIncrement = incrementValue * accumulationWeeks
/// 4. Aplica peso = baseWeight + totalIncrement
/// 5. Mantiene repeticiones y series constantes
/// 6. Durante deload:
///    - Reduce peso manteniendo incremento sobre base
///    - Reduce series al 70%
///
/// **Parámetros clave:**
/// - accumulationWeeks: Número de semanas de acumulación
/// - incrementValue: Cantidad de peso a incrementar por semana
/// - deloadWeek: Semana de deload
/// - deloadPercentage: Porcentaje de reducción durante deload
///
/// **Ventajas:**
/// - Progresión gradual y sostenible
/// - Permite adaptación a cargas crecientes
/// - Efectiva para fases de acumulación
/// - Reduce riesgo de sobreentrenamiento
/// - Facilita la supercompensación
///
/// **Limitaciones:**
/// - Progresión más lenta inicialmente
/// - Requiere planificación cuidadosa de fases
/// - Puede ser menos efectiva para ganancias rápidas
/// - Necesita deloads apropiados
class SteppedProgressionStrategy extends BaseProgressionStrategy
    implements ProgressionStrategy {
  @override
  ProgressionCalculationResult calculate({
    required ProgressionConfig config,
    required ProgressionState state,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
    ExerciseType? exerciseType,
  }) {
    final currentInCycle = getCurrentInCycle(config, state);
    final isDeload = isDeloadPeriod(config, currentInCycle);

    // Si es deload, aplicar deload directamente sobre el peso actual
    if (isDeload) {
      return _applyDeload(
        config,
        state,
        currentWeight,
        currentReps,
        currentSets,
        currentInCycle,
      );
    }

    // 1. Aplicar lógica específica de progresión escalonada
    final accumulationWeeks = _getAccumulationWeeks(config);
    final incrementValue = getIncrementValue(
      config,
      exerciseType: exerciseType,
    );

    final totalIncrement =
        currentInCycle <= accumulationWeeks
            ? incrementValue * currentInCycle
            : incrementValue * accumulationWeeks;

    return ProgressionCalculationResult(
      newWeight: state.baseWeight + totalIncrement,
      newReps: currentReps,
      newSets: currentSets,
      incrementApplied: true,
      reason:
          'Stepped progression: accumulation phase (week $currentInCycle of ${config.cycleLength})',
    );
  }

  /// Aplica deload específico para progresión escalonada
  ProgressionCalculationResult _applyDeload(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
    int currentInCycle,
  ) {
    final double increaseOverBase = (currentWeight - state.baseWeight).clamp(
      0,
      double.infinity,
    );
    final double deloadWeight =
        state.baseWeight + (increaseOverBase * config.deloadPercentage);

    return ProgressionCalculationResult(
      newWeight: deloadWeight,
      newReps: currentReps,
      newSets: (currentSets * 0.7).round(),
      incrementApplied: true,
      reason:
          'Stepped progression: deload ${config.unit.name} (week $currentInCycle of ${config.cycleLength})',
    );
  }

  /// Obtiene las semanas de acumulación desde parámetros personalizados
  int _getAccumulationWeeks(ProgressionConfig config) {
    final customParams = config.customParameters;

    // Buscar en per_exercise primero
    final perExercise = customParams['per_exercise'] as Map<String, dynamic>?;
    if (perExercise != null) {
      final exerciseParams = perExercise.values.first as Map<String, dynamic>?;
      if (exerciseParams != null) {
        final weeks = exerciseParams['accumulation_weeks'];
        if (weeks != null) return weeks as int;
      }
    }

    // Fallback a global
    return customParams['accumulation_weeks'] ?? 3; // default
  }
}
