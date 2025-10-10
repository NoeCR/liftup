import '../../../../features/exercise/models/exercise.dart';
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
/// **Algoritmo:**
/// 1. Calcula la posición actual en el ciclo
/// 2. Verifica si es período de deload
/// 3. Determina el patrón de progresión basado en la semana del ciclo:
///    - Semanas impares: Incrementa peso, mantiene reps
///    - Semanas pares: Incrementa reps, mantiene peso
/// 4. Durante deload:
///    - Reduce peso manteniendo incremento sobre base
///    - Reduce series al 70%
///
/// **Parámetros clave:**
/// - minReps: Repeticiones mínimas del rango
/// - maxReps: Repeticiones máximas del rango
/// - incrementValue: Cantidad de peso a incrementar
/// - deloadWeek: Semana de deload
/// - deloadPercentage: Porcentaje de reducción durante deload
///
/// **Ventajas:**
/// - Progresión más rápida que la doble progresión clásica
/// - Mayor estímulo de adaptación al manipular dos variables
/// - Efectiva para atletas experimentados
/// - Permite mayor control sobre el volumen e intensidad
///
/// **Limitaciones:**
/// - Mayor riesgo de fatiga acumulada
/// - Requiere experiencia en autoregulación (RPE/RIR)
/// - Necesita deloads más frecuentes
/// - Puede ser abrumadora para principiantes
class DoubleFactorProgressionStrategy extends BaseProgressionStrategy
    implements ProgressionStrategy {
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

    // Obtener parámetros de doble factor
    final maxReps = getMaxReps(config, exerciseType: exerciseType);
    final minReps = getMinReps(config, exerciseType: exerciseType);

    // Determinar patrón de progresión basado en la semana del ciclo
    final isOddWeek = currentInCycle % 2 == 1;

    if (isOddWeek) {
      // Semana impar: Incrementar peso, mantener reps
      final incrementValue = getIncrementValue(
        config,
        exerciseType: exerciseType,
      );
      return ProgressionCalculationResult(
        newWeight: currentWeight + incrementValue,
        newReps: currentReps.clamp(
          minReps,
          maxReps,
        ), // Asegurar que esté en rango
        newSets: state.baseSets, // Ensure sets recover to base after deload
        incrementApplied: true,
        reason:
            'Double factor progression: increasing weight +${incrementValue}kg (week $currentInCycle of ${config.cycleLength})',
      );
    } else {
      // Semana par: Incrementar reps, mantener peso
      final newReps = (currentReps + 1).clamp(minReps, maxReps);
      return ProgressionCalculationResult(
        newWeight: currentWeight,
        newReps: newReps,
        newSets: state.baseSets, // Ensure sets recover to base after deload
        incrementApplied: true,
        reason:
            'Double factor progression: increasing reps to $newReps (week $currentInCycle of ${config.cycleLength})',
      );
    }
  }

  /// Aplica deload específico para progresión doble factor
  /// Reduce tanto peso como reps proporcionalmente al progreso sobre los valores base
  /// Después del deload, el siguiente ciclo empezará como "semana 1" (impar) para incrementar peso
  ProgressionCalculationResult _applyDeload(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
    int currentInCycle,
  ) {
    // Calcular incremento sobre peso base
    final double increaseOverBase = (currentWeight - state.baseWeight).clamp(
      0,
      double.infinity,
    );
    final double deloadWeight =
        state.baseWeight + (increaseOverBase * config.deloadPercentage);

    // Calcular incremento sobre reps base
    final int increaseOverReps = (currentReps - state.baseReps).clamp(0, 100);
    final int deloadReps =
        state.baseReps + (increaseOverReps * config.deloadPercentage).round();

    return ProgressionCalculationResult(
      newWeight: deloadWeight,
      newReps: deloadReps, // Reducir reps proporcionalmente al progreso
      newSets: (state.baseSets * 0.7).round(), // Reducir volumen
      incrementApplied: true,
      isDeload: true,
      shouldResetCycle: true, // Reiniciar ciclo después del deload
      reason:
          'Double factor progression: deload week $currentInCycle of ${config.cycleLength} (weight: ${deloadWeight.toStringAsFixed(1)}kg, reps: $deloadReps). Next cycle starts as week 1 (odd) for weight increment.',
    );
  }
}
