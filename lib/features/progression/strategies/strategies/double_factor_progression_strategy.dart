import '../../../../features/exercise/models/exercise.dart';
import '../../models/progression_calculation_result.dart';
import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../base_progression_strategy.dart';
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
class DoubleFactorProgressionStrategy extends BaseProgressionStrategy
    implements ProgressionStrategy {
  @override
  ProgressionCalculationResult calculate({
    required ProgressionConfig config,
    required ProgressionState state,
    required String routineId,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
    ExerciseType? exerciseType,
    bool isExerciseLocked = false,
  }) {
    // Verificar si la progresión está bloqueada (por rutina completa O por ejercicio específico)
    if (isProgressionBlocked(
      state,
      state.exerciseId,
      routineId,
      isExerciseLocked,
    )) {
      return ProgressionCalculationResult(
        newWeight: currentWeight,
        newReps: currentReps,
        newSets:
            state.baseSets, // Always use baseSets to avoid deload persistence
        incrementApplied: false,
        isDeload: false,
        reason:
            'Double factor progression: blocked for exercise ${state.exerciseId} in routine $routineId',
      );
    }

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

    // Obtener parámetros de doble progresión
    final maxReps = getMaxReps(config, exerciseType: exerciseType);
    final minReps = getMinReps(config, exerciseType: exerciseType);

    // 1. Aplicar lógica de doble progresión
    if (currentReps < maxReps) {
      // Incrementar repeticiones si no hemos llegado al máximo
      return ProgressionCalculationResult(
        newWeight: currentWeight,
        newReps: currentReps < minReps ? minReps : currentReps + 1,
        newSets: state.baseSets, // Ensure sets recover to base after deload
        incrementApplied: true,
        reason:
            'Double factor progression: increasing reps (week $currentInCycle of ${config.cycleLength})',
      );
    } else {
      // Incrementar peso y resetear reps al mínimo
      final incrementValue = getIncrementValue(
        config,
        exerciseType: exerciseType,
      );
      return ProgressionCalculationResult(
        newWeight: currentWeight + incrementValue,
        newReps: minReps,
        newSets: state.baseSets, // Ensure sets recover to base after deload
        incrementApplied: true,
        reason:
            'Double factor progression: increasing weight +${incrementValue}kg and resetting reps to $minReps (week $currentInCycle of ${config.cycleLength})',
      );
    }
  }

  /// Aplica deload específico para progresión doble factor
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
      newReps: currentReps, // Mantener las reps actuales
      newSets:
          (state.baseSets * 0.7).round(), // Use baseSets for deload calculation
      incrementApplied: true,
      isDeload: true,
      reason:
          'Double factor progression: deload week $currentInCycle of ${config.cycleLength}',
    );
  }
}
