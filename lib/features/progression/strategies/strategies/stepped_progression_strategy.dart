import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../../models/progression_calculation_result.dart';
import '../../../../common/enums/progression_type_enum.dart';
import '../progression_strategy.dart';

class SteppedProgressionStrategy implements ProgressionStrategy {
  @override
  ProgressionCalculationResult calculate({
    required ProgressionConfig config,
    required ProgressionState state,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
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
        reason: 'Stepped progression: deload ${config.unit.name} (week $currentInCycle of ${config.cycleLength})',
      );
    }

    // Progresión escalonada: acumula incrementos durante semanas específicas
    final accumulationWeeks = _getAccumulationWeeks(config);
    final incrementValue = _getIncrementValue(config);

    final totalIncrement =
        currentInCycle <= accumulationWeeks ? incrementValue * currentInCycle : incrementValue * accumulationWeeks;

    return ProgressionCalculationResult(
      newWeight: state.baseWeight + totalIncrement,
      newReps: currentReps,
      newSets: currentSets,
      incrementApplied: true,
      reason: 'Stepped progression: accumulation phase (week $currentInCycle of ${config.cycleLength})',
    );
  }

  /// Obtiene las semanas de acumulación desde parámetros personalizados
  int _getAccumulationWeeks(ProgressionConfig config) {
    final customParams = config.customParameters;

    // Buscar en per_exercise primero
    final perExercise = customParams['per_exercise'] as Map<String, dynamic>?;
    if (perExercise != null) {
      final exerciseParams = perExercise.values.first as Map<String, dynamic>?;
      if (exerciseParams != null) {
        final weeks = exerciseParams['accumulation_weeks'];
        if (weeks != null) return weeks as int;
      }
    }

    // Fallback a global
    return customParams['accumulation_weeks'] ?? 3; // default
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
}
