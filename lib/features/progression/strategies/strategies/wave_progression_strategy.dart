import 'dart:math' as math;

import '../../../../features/exercise/models/exercise.dart';
import '../../models/progression_calculation_result.dart';
import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../base_progression_strategy.dart';
import '../progression_strategy.dart';

/// Estrategia de Progresión por Oleadas
///
/// Esta estrategia implementa una progresión por oleadas de 3 semanas con diferentes énfasis
/// en cada semana: alta intensidad, alto volumen, y progresión normal.
///
/// **Fundamentos teóricos:**
/// - Basada en la periodización por oleadas (wave loading)
/// - Ciclos de 3 semanas con diferentes énfasis
/// - Semana 1: Alta intensidad (más peso, menos reps)
/// - Semana 2: Alto volumen (menos peso, más reps, más series)
/// - Semana 3+: Progresión normal
/// - Permite variación sistemática de estímulos
///
/// **Algoritmo:**
/// 1. Calcula la posición actual en el ciclo
/// 2. Verifica si es período de deload
/// 3. Según la semana del ciclo:
///    - Semana 1 (Alta intensidad):
///      * Incrementa peso por el valor configurado
///      * Reduce repeticiones al 85% del valor actual
///      * Mantiene series constantes
///    - Semana 2 (Alto volumen):
///      * Reduce peso al 70% del incremento
///      * Incrementa repeticiones al 120% del valor actual
///      * Incrementa series en 1
///    - Semana 3+ (Progresión normal):
///      * Incrementa peso por el valor configurado
///      * Mantiene repeticiones y series constantes
/// 4. Durante deload:
///    - Reduce peso al porcentaje configurado del peso base
///    - Reduce series al 70%
///
/// **Parámetros clave:**
/// - incrementValue: Cantidad de peso a incrementar
/// - deloadWeek: Semana de deload
/// - deloadPercentage: Porcentaje de reducción durante deload
///
/// **Ventajas:**
/// - Variación sistemática de estímulos
/// - Optimiza adaptaciones múltiples
/// - Reduce monotonía del entrenamiento
/// - Efectiva para atletas intermedios/avanzados
/// - Permite recuperación entre oleadas
///
/// **Limitaciones:**
/// - Más compleja de programar
/// - Requiere mayor experiencia
/// - Puede ser abrumadora para principiantes
/// - Necesita planificación cuidadosa de ciclos
class WaveProgressionStrategy extends BaseProgressionStrategy implements ProgressionStrategy {
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
    // Verificar si la progresión está bloqueada (por rutina completa O por ejercicio específico)
    if (isProgressionBlocked(state, state.exerciseId, routineId, isExerciseLocked)) {
      return ProgressionCalculationResult(
        newWeight: currentWeight,
        newReps: currentReps,
        newSets: state.baseSets, // Always use baseSets to avoid deload persistence
        incrementApplied: false,
        isDeload: false,
        reason: 'Wave progression: blocked for exercise ${state.exerciseId} in routine $routineId',
      );
    }

    final currentInCycle = getCurrentInCycle(config, state);
    final isDeload = isDeloadPeriod(config, currentInCycle);

    // Si es deload, aplicar deload directamente sobre el peso actual
    if (isDeload) {
      return _applyDeload(config, state, currentWeight, currentReps, currentSets, currentInCycle);
    }

    final incrementValue = getIncrementValue(config, exerciseType: exerciseType);

    // 1. Aplicar lógica específica de progresión por oleadas
    switch (currentInCycle) {
      case 1:
        // Semana 1: Alta intensidad (más peso, menos reps)
        final minReps = getMinReps(config, exerciseType: exerciseType);
        return ProgressionCalculationResult(
          newWeight: currentWeight + incrementValue,
          newReps: (currentReps * 0.85).round().clamp(math.min(minReps, currentReps), currentReps),
          newSets: state.baseSets, // Always use baseSets to avoid deload persistence
          incrementApplied: true,
          reason:
              'Wave progression: high intensity +${incrementValue}kg (week $currentInCycle of ${config.cycleLength})',
        );
      case 2:
        // Semana 2: Alto volumen (menos peso, más reps, más series)
        final minReps = getMinReps(config, exerciseType: exerciseType);
        return ProgressionCalculationResult(
          newWeight: (currentWeight - incrementValue * 0.3).clamp(0, currentWeight),
          newReps: ((currentReps * 1.2).round()).clamp(minReps, 1000),
          newSets: currentSets + 1,
          incrementApplied: true,
          reason:
              'Wave progression: high volume -${(incrementValue * 0.3).toStringAsFixed(1)}kg (week $currentInCycle of ${config.cycleLength})',
        );
      default:
        // Semanas adicionales: progresión normal
        final minReps = getMinReps(config, exerciseType: exerciseType);
        return ProgressionCalculationResult(
          newWeight: currentWeight + incrementValue,
          newReps: currentReps.clamp(minReps, 1000),
          newSets: state.baseSets, // Always use baseSets to avoid deload persistence
          incrementApplied: true,
          reason: 'Wave progression: normal +${incrementValue}kg (week $currentInCycle of ${config.cycleLength})',
        );
    }
  }

  /// Aplica deload específico para progresión por oleadas
  ProgressionCalculationResult _applyDeload(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
    int currentInCycle,
  ) {
    // Deload específico para wave: reduce peso proporcionalmente
    final double deloadWeight = state.baseWeight * config.deloadPercentage;

    return ProgressionCalculationResult(
      newWeight: deloadWeight,
      newReps: currentReps,
      newSets: (currentSets * config.deloadPercentage).round(), // Use currentSets for deload calculation
      incrementApplied: true,
      isDeload: true,
      shouldResetCycle: true, // Reiniciar ciclo después del deload
      reason: 'Wave progression: deload ${config.unit.name} (week $currentInCycle of ${config.cycleLength})',
    );
  }
}
