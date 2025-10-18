import '../../../../features/exercise/models/exercise.dart';
import '../../enums/double_factor_mode.dart';
import '../../models/progression_calculation_result.dart';
import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../base_progression_strategy.dart';
import '../progression_strategy.dart';

/// Estrategia de Progresión Doble Factor (Double Factor)
///
/// Esta estrategia implementa la progresión "Double Factor", donde se manipulan
/// dos variables simultáneamente o de forma alternada: peso y repeticiones.
/// A diferencia de la doble progresión clásica (secuencial), aquí ambas variables
/// pueden progresar en la misma sesión o alternarse entre sesiones.
///
/// **Fundamentos teóricos:**
/// - Basada en el concepto de "double factor progression" de la literatura avanzada
/// - Manipula dos variables simultáneamente para mayor estímulo de adaptación
/// - Permite progresión más rápida pero requiere mayor control de fatiga
/// - Ideal para atletas intermedios/avanzados con experiencia en autoregulación
/// - Requiere monitoreo de RPE/RIR y deloads apropiados
///
/// **Modos de progresión:**
/// 1. **Alternado (alternate)**: Alterna entre incrementar peso (semanas impares) y reps (semanas pares)
///    - Ideal para: fuerza, resistencia, general
///    - Nivel: principiante-intermedio
///    - Progresión controlada y predecible
///
/// 2. **Simultáneo (both)**: Incrementa peso y reps en la misma sesión
///    - Ideal para: hipertrofia
///    - Nivel: intermedio-avanzado
///    - Progresión más rápida, mayor estímulo
///
/// 3. **Compuesto (composite)**: Usa un índice compuesto que prioriza peso sobre reps
///    - Ideal para: potencia
///    - Nivel: intermedio-avanzado
///    - Mantiene alta intensidad, progresión conservadora en reps
///
/// **Algoritmo:**
/// 1. Calcula la posición actual en el ciclo
/// 2. Verifica si es período de deload
/// 3. Determina el modo de progresión desde customParameters['double_factor_mode']
/// 4. Aplica la progresión según el modo seleccionado
/// 5. Durante deload:
///    - Reduce peso manteniendo incremento sobre base
///    - Reduce series al 70%
///
/// **Parámetros clave:**
/// - minReps: Repeticiones mínimas del rango
/// - maxReps: Repeticiones máximas del rango
/// - incrementValue: Cantidad de peso a incrementar
/// - deloadWeek: Semana de deload
/// - deloadPercentage: Porcentaje de reducción durante deload
/// - double_factor_mode: Modo de progresión (alternate, both, composite)
///
/// **Ventajas:**
/// - Progresión más rápida que la doble progresión clásica
/// - Mayor estímulo de adaptación al manipular dos variables
/// - Flexibilidad para diferentes objetivos de entrenamiento
/// - Efectiva para atletas experimentados
/// - Permite mayor control sobre el volumen e intensidad
///
/// **Limitaciones:**
/// - Mayor riesgo de fatiga acumulada
/// - Requiere experiencia en autoregulación (RPE/RIR)
/// - Necesita deloads más frecuentes
/// - Puede ser abrumadora para principiantes
class DoubleFactorProgressionStrategy extends BaseProgressionStrategy implements ProgressionStrategy {
  @override
  bool isDeloadPeriod(ProgressionConfig config, int currentInCycle) {
    // En Double Factor, aplicar deload cuando se alcance la semana configurada
    // independientemente de si es par o impar
    return config.deloadWeek > 0 && currentInCycle >= config.deloadWeek;
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
    // Verificar si la progresión está bloqueada
    if (isProgressionBlocked(state, state.exerciseId, routineId, isExerciseLocked)) {
      return createBlockedResult(
        currentWeight: currentWeight,
        currentReps: currentReps,
        currentSets: state.baseSets,
        reason: 'Double factor progression: blocked for exercise ${state.exerciseId} in routine $routineId',
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
          reason: 'Double factor progression: exercise required for deload',
        );
      }

      return _applyDoubleFactorDeload(
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
        reason: 'Double factor progression: exercise required for progression',
      );
    }

    // Obtener parámetros de doble factor
    final maxReps = getMaxRepsSync(config, exercise);
    final minReps = getMinRepsSync(config, exercise);

    // Determinar el modo de progresión desde customParameters
    final modeString = config.customParameters['double_factor_mode'] as String? ?? 'alternate';
    final mode = _parseDoubleFactorMode(modeString);

    // Aplicar progresión según el modo seleccionado
    return _applyProgressionByMode(
      config: config,
      state: state,
      currentWeight: currentWeight,
      currentReps: currentReps,
      minReps: minReps,
      maxReps: maxReps,
      currentInCycle: currentInCycle,
      mode: mode,
      exercise: exercise,
    );
  }

  @override
  bool shouldApplyProgressionValues(ProgressionState? progressionState, String routineId, bool isExerciseLocked) {
    return true; // Double factor progression siempre aplica valores
  }

  /// Parsea el modo de Double Factor desde string
  DoubleFactorMode _parseDoubleFactorMode(String modeString) {
    switch (modeString.toLowerCase()) {
      case 'both':
        return DoubleFactorMode.both;
      case 'composite':
        return DoubleFactorMode.composite;
      case 'alternate':
      default:
        return DoubleFactorMode.alternate;
    }
  }

  /// Aplica la progresión según el modo seleccionado
  ProgressionCalculationResult _applyProgressionByMode({
    required ProgressionConfig config,
    required ProgressionState state,
    required double currentWeight,
    required int currentReps,
    required int minReps,
    required int maxReps,
    required int currentInCycle,
    required DoubleFactorMode mode,
    required Exercise exercise,
  }) {
    switch (mode) {
      case DoubleFactorMode.alternate:
        return _applyAlternateProgression(
          config: config,
          state: state,
          currentWeight: currentWeight,
          currentReps: currentReps,
          minReps: minReps,
          maxReps: maxReps,
          currentInCycle: currentInCycle,
          exercise: exercise,
        );
      case DoubleFactorMode.both:
        return _applyBothProgression(
          config: config,
          state: state,
          currentWeight: currentWeight,
          currentReps: currentReps,
          minReps: minReps,
          maxReps: maxReps,
          currentInCycle: currentInCycle,
          exercise: exercise,
        );
      case DoubleFactorMode.composite:
        return _applyCompositeProgression(
          config: config,
          state: state,
          currentWeight: currentWeight,
          currentReps: currentReps,
          minReps: minReps,
          maxReps: maxReps,
          currentInCycle: currentInCycle,
          exercise: exercise,
        );
    }
  }

  /// Aplica progresión alternada (peso en semanas impares, reps en pares)
  ProgressionCalculationResult _applyAlternateProgression({
    required ProgressionConfig config,
    required ProgressionState state,
    required double currentWeight,
    required int currentReps,
    required int minReps,
    required int maxReps,
    required int currentInCycle,
    required Exercise exercise,
  }) {
    final isOddWeek = currentInCycle % 2 == 1;

    if (isOddWeek) {
      // Semana impar: Incrementar peso, mantener reps
      final incrementValue = getIncrementValueSync(config, exercise, state);
      return createProgressionResult(
        newWeight: currentWeight + incrementValue,
        newReps: currentReps.clamp(minReps, maxReps),
        newSets: state.baseSets,
        incrementApplied: true,
        reason:
            'Double factor (alternate): increasing weight +${incrementValue}kg (week $currentInCycle of ${config.cycleLength})',
      );
    } else {
      // Semana par: Incrementar reps, mantener peso
      final newReps = (currentReps + 1).clamp(minReps, maxReps);
      return createProgressionResult(
        newWeight: currentWeight,
        newReps: newReps,
        newSets: state.baseSets,
        incrementApplied: true,
        reason:
            'Double factor (alternate): increasing reps to $newReps (week $currentInCycle of ${config.cycleLength})',
      );
    }
  }

  /// Aplica progresión simultánea (peso y reps en la misma sesión)
  ProgressionCalculationResult _applyBothProgression({
    required ProgressionConfig config,
    required ProgressionState state,
    required double currentWeight,
    required int currentReps,
    required int minReps,
    required int maxReps,
    required int currentInCycle,
    required Exercise exercise,
  }) {
    // Incrementar peso y reps simultáneamente
    final weightIncrement = getIncrementValueSync(config, exercise, state);
    final newWeight = currentWeight + weightIncrement;
    final newReps = (currentReps + 1).clamp(minReps, maxReps);

    return createProgressionResult(
      newWeight: newWeight,
      newReps: newReps,
      newSets: state.baseSets,
      incrementApplied: true,
      reason:
          'Double factor (both): increasing weight +${weightIncrement}kg and reps to $newReps (week $currentInCycle of ${config.cycleLength})',
    );
  }

  /// Aplica progresión compuesta (índice compuesto que prioriza peso)
  ProgressionCalculationResult _applyCompositeProgression({
    required ProgressionConfig config,
    required ProgressionState state,
    required double currentWeight,
    required int currentReps,
    required int minReps,
    required int maxReps,
    required int currentInCycle,
    required Exercise exercise,
  }) {
    // Calcular incrementos con prioridad en peso
    final weightIncrement = getIncrementValueSync(config, exercise, state);
    final repsIncrement = (weightIncrement * 0.3).round(); // 30% del incremento de peso para reps

    final newWeight = currentWeight + weightIncrement;
    final newReps = (currentReps + repsIncrement).clamp(minReps, maxReps);

    return createProgressionResult(
      newWeight: newWeight,
      newReps: newReps,
      newSets: state.baseSets,
      incrementApplied: true,
      reason:
          'Double factor (composite): increasing weight +${weightIncrement}kg and reps +$repsIncrement to $newReps (week $currentInCycle of ${config.cycleLength})',
    );
  }

  /// Aplica deload específico para Double Factor con reset de ciclo
  ProgressionCalculationResult _applyDoubleFactorDeload({
    required ProgressionConfig config,
    required ProgressionState state,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
    required int currentInCycle,
    required Exercise exercise,
  }) {
    // Calcular peso de deload manteniendo incremento sobre base
    final double increaseOverBase = (currentWeight - state.baseWeight).clamp(0, double.infinity);
    final double deloadWeight = state.baseWeight + (increaseOverBase * config.deloadPercentage);

    // Calcular reps de deload manteniendo incremento sobre base
    final int increaseOverBaseReps = (currentReps - state.baseReps).clamp(0, 100);
    final int deloadReps = state.baseReps + (increaseOverBaseReps * config.deloadPercentage).round();

    // Calcular series de deload (70% de las series base)
    final int baseSets = getBaseSetsSync(config, exercise);
    final int deloadSets = (baseSets * 0.7).round();

    return ProgressionCalculationResult(
      newWeight: deloadWeight,
      newReps: deloadReps,
      newSets: deloadSets,
      incrementApplied: true,
      isDeload: true,
      shouldResetCycle: true, // Double Factor resetea el ciclo después del deload
      reason:
          'Deload session (week $currentInCycle of ${config.cycleLength}). Next cycle starts as week 1 (odd) for weight increment.',
    );
  }
}
