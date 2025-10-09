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
class UndulatingProgressionStrategy extends BaseProgressionStrategy implements ProgressionStrategy {
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
    final currentInCycle = getCurrentInCycle(config, state);
    final isDeload = isDeloadPeriod(config, currentInCycle);

    // Si es deload, aplicar deload directamente sobre el peso actual
    if (isDeload) {
      return _applyDeload(config, state, currentWeight, currentReps, currentSets, currentInCycle);
    }

    // 1. Aplicar lógica específica de progresión ondulante
    final isHeavyDay = currentInCycle % 2 == 1;
    final incrementValue = getIncrementValue(config, exerciseType: exerciseType);

    if (isHeavyDay) {
      // Día pesado: más peso, menos reps
      return ProgressionCalculationResult(
        newWeight: currentWeight + incrementValue,
        newReps: (currentReps * 0.85).round().clamp(1, currentReps),
        newSets: currentSets,
        incrementApplied: true,
        reason:
            'Undulating progression: heavy day +${incrementValue}kg (week $currentInCycle of ${config.cycleLength})',
      );
    } else {
      // Día ligero: menos peso, más reps
      return ProgressionCalculationResult(
        newWeight: (currentWeight - incrementValue).clamp(0, currentWeight),
        newReps: (currentReps * 1.15).round(),
        newSets: currentSets,
        incrementApplied: true,
        reason:
            'Undulating progression: light day -${incrementValue}kg (week $currentInCycle of ${config.cycleLength})',
      );
    }
  }

  /// Aplica deload específico para progresión ondulante
  ProgressionCalculationResult _applyDeload(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
    int currentInCycle,
  ) {
    final double increaseOverBase = (currentWeight - state.baseWeight).clamp(0, double.infinity);
    final double deloadWeight = state.baseWeight + (increaseOverBase * config.deloadPercentage);

    return ProgressionCalculationResult(
      newWeight: deloadWeight,
      newReps: currentReps,
      newSets: (state.baseSets * 0.7).round(), // Use baseSets for deload calculation
      incrementApplied: true,
      isDeload: true,
      reason: 'Undulating progression: deload ${config.unit.name} (week $currentInCycle of ${config.cycleLength})',
    );
  }
}
