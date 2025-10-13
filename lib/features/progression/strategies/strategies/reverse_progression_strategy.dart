import '../../../../features/exercise/models/exercise.dart';
import '../../models/progression_calculation_result.dart';
import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../base_progression_strategy.dart';
import '../progression_strategy.dart';

/// Estrategia de Progresión Inversa
///
/// Esta estrategia implementa una progresión inversa donde se reduce el peso mientras
/// se incrementan las repeticiones, típicamente usada en fases de recuperación o
/// para enfocarse en el volumen sobre la intensidad.
///
/// **Fundamentos teóricos:**
/// - Basada en el concepto de progresión inversa
/// - Reduce peso progresivamente mientras aumenta repeticiones
/// - Útil para fases de recuperación y rehabilitación
/// - Permite enfocarse en volumen sobre intensidad
/// - Facilita la adaptación técnica con cargas menores
///
/// **Algoritmo:**
/// 1. Calcula la posición actual en el ciclo
/// 2. Verifica si es período de deload
/// 3. Si currentReps < maxReps:
///    - Reduce peso por el valor configurado
///    - Incrementa repeticiones en 1
///    - Mantiene series constantes
/// 4. Si currentReps >= maxReps:
///    - Reduce peso por el valor configurado
///    - Mantiene repeticiones en el máximo
///    - Mantiene series constantes
/// 5. Durante deload:
///    - Reduce peso manteniendo incremento sobre base
///    - Reduce series al 70%
///
/// **Parámetros clave:**
/// - incrementValue: Cantidad de peso a reducir
/// - maxReps: Repeticiones máximas antes de mantener reps
/// - deloadWeek: Semana de deload
/// - deloadPercentage: Porcentaje de reducción durante deload
///
/// **Ventajas:**
/// - Útil para fases de recuperación
/// - Permite enfocarse en volumen
/// - Reduce riesgo de lesiones
/// - Facilita la adaptación técnica
/// - Efectiva para rehabilitación
///
/// **Limitaciones:**
/// - No es efectiva para ganancias de fuerza máxima
/// - Puede llevar a pérdida de fuerza absoluta
/// - Requiere cambio eventual de estrategia
/// - No es ideal para atletas de fuerza
class ReverseProgressionStrategy extends BaseProgressionStrategy implements ProgressionStrategy {
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
        reason: 'Reverse progression: blocked for exercise ${state.exerciseId} in routine $routineId',
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
          reason: 'Reverse progression: exercise required for deload',
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
        reason: 'Reverse progression: exercise required for progression',
      );
    }

    // Aplicar lógica específica de progresión inversa
    final incrementValue = getIncrementValueSync(config, exercise);
    final maxReps = getMaxRepsSync(config, exercise);

    if (currentReps < maxReps) {
      // Aumentar reps si no hemos llegado al máximo
      return createProgressionResult(
        newWeight: (currentWeight - incrementValue).clamp(0, currentWeight),
        newReps: currentReps + 1,
        newSets: state.baseSets,
        incrementApplied: true,
        reason:
            'Reverse progression: decreasing weight -${incrementValue}kg, increasing reps (week $currentInCycle of ${config.cycleLength})',
      );
    } else {
      // Mantener reps en el máximo, seguir reduciendo peso
      return createProgressionResult(
        newWeight: (currentWeight - incrementValue).clamp(0, currentWeight),
        newReps: currentReps,
        newSets: state.baseSets,
        incrementApplied: true,
        reason:
            'Reverse progression: decreasing weight -${incrementValue}kg, maintaining max reps (week $currentInCycle of ${config.cycleLength})',
      );
    }
  }

  @override
  bool shouldApplyProgressionValues(ProgressionState? progressionState, String routineId, bool isExerciseLocked) {
    return true; // Reverse progression siempre aplica valores
  }
}
