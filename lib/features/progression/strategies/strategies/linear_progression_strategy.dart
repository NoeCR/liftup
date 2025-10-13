import '../../../../features/exercise/models/exercise.dart';
import '../../models/progression_calculation_result.dart';
import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../base_progression_strategy.dart';
import '../progression_strategy.dart';

/// Estrategia de Progresión Lineal
///
/// Esta estrategia implementa una progresión lineal clásica donde el peso se incrementa
/// de manera constante y predecible en intervalos regulares.
///
/// **Fundamentos teóricos:**
/// - Basada en el principio de sobrecarga progresiva
/// - Incremento constante de peso cada X sesiones/semanas
/// - Ideal para principiantes y fases de adaptación inicial
/// - Permite adaptación neuromuscular gradual
///
/// **Algoritmo:**
/// 1. Calcula la posición actual en el ciclo (sesión/semana)
/// 2. Verifica si es período de deload (reducción de carga)
/// 3. Si es momento de incrementar (según incrementFrequency):
///    - Aumenta el peso por el valor de incremento configurado
///    - Mantiene repeticiones y series constantes
/// 4. Durante deload:
///    - Reduce peso manteniendo incremento sobre peso base
///    - Reduce series al 70% del valor actual
///
/// **Parámetros clave:**
/// - incrementValue: Cantidad de peso a incrementar
/// - incrementFrequency: Cada cuántas sesiones/semanas incrementar
/// - cycleLength: Duración total del ciclo
/// - deloadWeek: Semana de deload (0 = sin deload)
/// - deloadPercentage: Porcentaje de reducción durante deload
///
/// **Ventajas:**
/// - Simple y predecible
/// - Fácil de seguir y monitorear
/// - Efectiva para ganancias iniciales de fuerza
///
/// **Limitaciones:**
/// - Puede volverse insostenible a largo plazo
/// - No considera fatiga acumulada
/// - Puede llevar a estancamiento
class LinearProgressionStrategy extends BaseProgressionStrategy
    implements ProgressionStrategy {
  @override
  bool shouldApplyProgressionValues(
    ProgressionState? progressionState,
    String routineId,
    bool isExerciseLocked,
  ) {
    if (progressionState == null) return false;
    return !isProgressionBlocked(
      progressionState,
      progressionState.exerciseId,
      routineId,
      isExerciseLocked,
    );
  }

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
    // 1. Validaciones básicas
    if (!validateProgressionParams(config) ||
        !validateProgressionState(state)) {
      return createBlockedResult(
        currentWeight: currentWeight,
        currentReps: currentReps,
        currentSets: currentSets,
        reason: 'Linear progression: invalid configuration or state',
      );
    }

    // 2. Verificar si la progresión está bloqueada
    if (isProgressionBlocked(
      state,
      state.exerciseId,
      routineId,
      isExerciseLocked,
    )) {
      return createBlockedResult(
        currentWeight: currentWeight,
        currentReps: currentReps,
        currentSets: currentSets,
        reason:
            'Linear progression: blocked for exercise ${state.exerciseId} in routine $routineId',
      );
    }

    // 3. Calcular posición en el ciclo
    final currentInCycle = getCurrentInCycle(config, state);
    final isDeload = isDeloadPeriod(config, currentInCycle);

    // 4. Aplicar deload si es necesario
    if (isDeload) {
      if (exercise == null) {
        return createBlockedResult(
          currentWeight: currentWeight,
          currentReps: currentReps,
          currentSets: currentSets,
          reason: 'Linear progression: exercise required for deload',
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

    // 5. Aplicar progresión lineal
    if (shouldApplyProgression(config, currentInCycle)) {
      // Requerir ejercicio para aplicar progresión
      if (exercise == null) {
        return createBlockedResult(
          currentWeight: currentWeight,
          currentReps: currentReps,
          currentSets: currentSets,
          reason: 'Linear progression: exercise required for progression',
        );
      }

      final incrementValue = getIncrementValueSync(config, exercise);
      final baseSets = getBaseSetsSync(config, exercise);

      return createProgressionResult(
        newWeight: currentWeight + incrementValue,
        newReps: currentReps, // Mantener repeticiones en progresión lineal
        newSets: baseSets,
        incrementApplied: true,
        reason:
            'Linear progression: weight +${incrementValue}kg (week $currentInCycle of ${config.cycleLength})',
      );
    } else {
      // 6. Mantener valores actuales
      if (exercise == null) {
        return createBlockedResult(
          currentWeight: currentWeight,
          currentReps: currentReps,
          currentSets: currentSets,
          reason: 'Linear progression: exercise required for progression',
        );
      }

      final baseSets = getBaseSetsSync(config, exercise);

      return createProgressionResult(
        newWeight: currentWeight,
        newReps: currentReps,
        newSets: baseSets,
        incrementApplied: false,
        reason:
            'Linear progression: maintaining current values (week $currentInCycle of ${config.cycleLength})',
      );
    }
  }
}
