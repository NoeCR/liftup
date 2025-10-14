import 'dart:math' as math;

import '../../../../features/exercise/models/exercise.dart';
import '../../models/progression_calculation_result.dart';
import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../base_progression_strategy.dart';
import '../progression_strategy.dart';

/// Estrategia de Progresión Ondulante
///
/// Esta estrategia implementa una progresión ondulante diaria (DUP - Daily Undulating Periodization)
/// donde se alternan días de alta intensidad con días de alto volumen.
///
/// **Fundamentos teóricos:**
/// - Basada en la periodización ondulante diaria
/// - Alterna entre estímulos de alta intensidad y alto volumen
/// - Permite mayor frecuencia de entrenamiento
/// - Optimiza adaptaciones tanto de fuerza como de hipertrofia
/// - Reduce fatiga acumulada mediante variación
///
/// **Algoritmo:**
/// 1. Calcula la posición actual en el ciclo
/// 2. Verifica si es período de deload
/// 3. Determina si es día pesado (impar) o ligero (par):
///    - Día pesado (impar):
///      * Incrementa peso por el valor configurado
///      * Reduce repeticiones al 85% del valor actual
///    - Día ligero (par):
///      * Reduce peso por el valor configurado
///      * Incrementa repeticiones al 115% del valor actual
/// 4. Durante deload:
///    - Reduce peso manteniendo incremento sobre base
///    - Reduce series al 70%
///
/// **Parámetros clave:**
/// - incrementValue: Cantidad de peso a incrementar/reducir
/// - deloadWeek: Semana de deload
/// - deloadPercentage: Porcentaje de reducción durante deload
///
/// **Ventajas:**
/// - Mayor frecuencia de entrenamiento
/// - Variación constante de estímulos
/// - Efectiva para atletas intermedios/avanzados
/// - Reduce monotonía del entrenamiento
/// - Optimiza adaptaciones múltiples
///
/// **Limitaciones:**
/// - Requiere mayor experiencia técnica
/// - Más compleja de programar
/// - Puede ser abrumadora para principiantes
/// - Requiere mayor capacidad de recuperación
class UndulatingProgressionStrategy extends BaseProgressionStrategy
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
    Exercise? exercise,
    bool isExerciseLocked = false,
  }) {
    // Verificar si la progresión está bloqueada
    if (isProgressionBlocked(
      state,
      state.exerciseId,
      routineId,
      isExerciseLocked,
    )) {
      return createBlockedResult(
        currentWeight: currentWeight,
        currentReps: currentReps,
        currentSets: state.baseSets,
        reason:
            'Undulating progression: blocked for exercise ${state.exerciseId} in routine $routineId',
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
          reason: 'Undulating progression: exercise required for deload',
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
        reason: 'Undulating progression: exercise required for progression',
      );
    }

    // Aplicar lógica específica de progresión ondulante
    final isHeavyDay = currentInCycle % 2 == 1;
    final incrementValue = getIncrementValueSync(config, exercise, state);
    final minReps = getMinRepsSync(config, exercise);

    if (isHeavyDay) {
      // Día pesado: más peso, menos reps
      return createProgressionResult(
        newWeight: currentWeight + incrementValue,
        newReps: (currentReps * 0.85).round().clamp(
          math.min(minReps, currentReps),
          currentReps,
        ),
        newSets: state.baseSets,
        incrementApplied: true,
        reason:
            'Undulating progression: heavy day +${incrementValue}kg (week $currentInCycle of ${config.cycleLength})',
      );
    } else {
      // Día ligero: menos peso, más reps
      return createProgressionResult(
        newWeight: (currentWeight - incrementValue).clamp(0, currentWeight),
        newReps: ((currentReps * 1.15).round()).clamp(minReps, 1000),
        newSets: state.baseSets,
        incrementApplied: true,
        reason:
            'Undulating progression: light day -${incrementValue}kg (week $currentInCycle of ${config.cycleLength})',
      );
    }
  }

  @override
  bool shouldApplyProgressionValues(
    ProgressionState? progressionState,
    String routineId,
    bool isExerciseLocked,
  ) {
    return true; // Undulating progression siempre aplica valores
  }
}
