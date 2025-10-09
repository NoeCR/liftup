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
    bool isExerciseLocked = false,
  }) {
    final currentInCycle = getCurrentInCycle(config, state);
    final isDeload = isDeloadPeriod(config, currentInCycle);

    // Si es deload, aplicar deload directamente sobre el peso actual
    if (isDeload) {
      return _applyDeload(config, state, currentWeight, currentReps, currentSets, currentInCycle);
    }

    // 1. Aplicar lógica específica de progresión inversa
    final incrementValue = getIncrementValue(config, exerciseType: exerciseType);
    final maxReps = getMaxReps(config, exerciseType: exerciseType);

    if (currentReps < maxReps) {
      // Aumentar reps si no hemos llegado al máximo
      return ProgressionCalculationResult(
        newWeight: (currentWeight - incrementValue).clamp(0, currentWeight),
        newReps: currentReps + 1,
        newSets: currentSets,
        incrementApplied: true,
        reason:
            'Reverse progression: decreasing weight -${incrementValue}kg, increasing reps (week $currentInCycle of ${config.cycleLength})',
      );
    } else {
      // Mantener reps en el máximo, seguir reduciendo peso
      return ProgressionCalculationResult(
        newWeight: (currentWeight - incrementValue).clamp(0, currentWeight),
        newReps: currentReps,
        newSets: currentSets,
        incrementApplied: true,
        reason:
            'Reverse progression: decreasing weight -${incrementValue}kg, maintaining max reps (week $currentInCycle of ${config.cycleLength})',
      );
    }
  }

  /// Aplica deload específico para progresión inversa
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
      reason: 'Reverse progression: deload ${config.unit.name} (week $currentInCycle of ${config.cycleLength})',
    );
  }
}
