import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../../models/progression_calculation_result.dart';
import '../../../../common/enums/progression_type_enum.dart';
import '../../../../features/exercise/models/exercise.dart';
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
class ReverseProgressionStrategy implements ProgressionStrategy {
  @override
  ProgressionCalculationResult calculate({
    required ProgressionConfig config,
    required ProgressionState state,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
    ExerciseType? exerciseType,
  }) {
    final currentInCycle =
        config.unit == ProgressionUnit.session
            ? ((state.currentSession - 1) % config.cycleLength) + 1
            : ((state.currentWeek - 1) % config.cycleLength) + 1;

    final isDeloadPeriod = config.deloadWeek > 0 && currentInCycle == config.deloadWeek;

    if (isDeloadPeriod) {
      // Deload: reduce peso manteniendo el incremento sobre base, reduce series
      final double increaseOverBase = (currentWeight - state.baseWeight).clamp(0, double.infinity);
      final double deloadWeight = state.baseWeight + (increaseOverBase * config.deloadPercentage);
      return ProgressionCalculationResult(
        newWeight: deloadWeight,
        newReps: currentReps,
        newSets: (currentSets * 0.7).round(),
        incrementApplied: true,
        reason: 'Reverse progression: deload ${config.unit.name} (week $currentInCycle of ${config.cycleLength})',
      );
    }

    // Progresión inversa: reduce peso, aumenta reps
    final incrementValue = _getIncrementValue(config);
    final maxReps = _getMaxReps(config);

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

  /// Obtiene el valor de incremento desde parámetros personalizados
  double _getIncrementValue(ProgressionConfig config) {
    final customParams = config.customParameters;

    // Buscar en per_exercise primero
    final perExercise = customParams['per_exercise'] as Map<String, dynamic>?;
    if (perExercise != null) {
      final exerciseParams = perExercise.values.first as Map<String, dynamic>?;
      if (exerciseParams != null) {
        final increment =
            exerciseParams['increment_value'] ??
            exerciseParams['multi_increment_min'] ??
            exerciseParams['iso_increment_min'];
        if (increment != null) return (increment as num).toDouble();
      }
    }

    // Fallback a global
    return customParams['increment_value'] ??
        customParams['multi_increment_min'] ??
        customParams['iso_increment_min'] ??
        config.incrementValue; // fallback al valor base
  }

  /// Obtiene el máximo de repeticiones desde parámetros personalizados
  int _getMaxReps(ProgressionConfig config) {
    final customParams = config.customParameters;

    // Buscar en per_exercise primero
    final perExercise = customParams['per_exercise'] as Map<String, dynamic>?;
    if (perExercise != null) {
      final exerciseParams = perExercise.values.first as Map<String, dynamic>?;
      if (exerciseParams != null) {
        final maxReps =
            exerciseParams['max_reps'] ?? exerciseParams['multi_reps_max'] ?? exerciseParams['iso_reps_max'];
        if (maxReps != null) return maxReps as int;
      }
    }

    // Fallback a global
    return customParams['max_reps'] ??
        customParams['multi_reps_max'] ??
        customParams['iso_reps_max'] ??
        20; // default para progresión inversa
  }
}
