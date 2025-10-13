import '../../../../features/exercise/models/exercise.dart';
import '../../models/progression_calculation_result.dart';
import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
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
class SteppedProgressionStrategy extends BaseProgressionStrategy implements ProgressionStrategy {
  @override
  ProgressionCalculationResult calculate({
    required ProgressionConfig config,
    required ProgressionState state,
    required String routineId,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
    ExerciseType? exerciseType,
    Exercise? exercise,
    bool isExerciseLocked = false,
  }) {
    // Verificar si la progresión está bloqueada
    if (isProgressionBlocked(state, state.exerciseId, routineId, isExerciseLocked)) {
      return createBlockedResult(
        currentWeight: currentWeight,
        currentReps: currentReps,
        currentSets: state.baseSets,
        reason: 'Stepped progression: blocked for exercise ${state.exerciseId} in routine $routineId',
      );
    }

    final currentInCycle = getCurrentInCycle(config, state);
    final isDeload = isDeloadPeriod(config, currentInCycle);

    // Si es deload, aplicar deload estándar
    if (isDeload) {
      if (exercise == null) {
        return createBlockedResult(
          currentWeight: currentWeight,
          currentReps: currentReps,
          currentSets: currentSets,
          reason: 'Stepped progression: exercise required for deload',
        );
      }

      return applyStandardDeload(
        config: config,
        state: state,
        currentWeight: currentWeight,
        currentReps: currentReps,
        currentSets: currentSets,
        currentInCycle: currentInCycle,
        exercise: exercise,
      );
    }

    // Requerir ejercicio para aplicar progresión
    if (exercise == null) {
      return createBlockedResult(
        currentWeight: currentWeight,
        currentReps: currentReps,
        currentSets: currentSets,
        reason: 'Stepped progression: exercise required for progression',
      );
    }

    // Aplicar lógica específica de progresión escalonada
    final accumulationWeeks = _getAccumulationWeeks(config);
    final incrementValue = getIncrementValueSync(config, exercise);
    final baseSets = getBaseSetsSync(config, exercise);

    final totalIncrement =
        currentInCycle <= accumulationWeeks ? incrementValue * currentInCycle : incrementValue * accumulationWeeks;

    return createProgressionResult(
      newWeight: currentWeight + totalIncrement,
      newReps: currentReps,
      newSets: baseSets,
      incrementApplied: true,
      reason: 'Stepped progression: accumulation phase (week $currentInCycle of ${config.cycleLength})',
    );
  }

  @override
  bool shouldApplyProgressionValues(ProgressionState? progressionState, String routineId, bool isExerciseLocked) {
    return true; // Stepped progression siempre aplica valores
  }

  /// Obtiene las semanas de acumulación desde parámetros personalizados
  int _getAccumulationWeeks(ProgressionConfig config) {
    final customParams = config.customParameters;
    return customParams['accumulation_weeks'] ?? 3; // default
  }
}
