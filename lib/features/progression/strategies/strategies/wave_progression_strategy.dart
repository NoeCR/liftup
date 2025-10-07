import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../../models/progression_calculation_result.dart';
import '../../../../common/enums/progression_type_enum.dart';
import '../progression_strategy.dart';

class WaveProgressionStrategy implements ProgressionStrategy {
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

    final incrementValue = _getIncrementValue(config);

    // Verificar si es semana de deload
    final isDeloadPeriod = config.deloadWeek > 0 && currentInCycle == config.deloadWeek;

    if (isDeloadPeriod) {
      // Deload: reduce peso proporcionalmente, reduce series
      final double deloadWeight = state.baseWeight * config.deloadPercentage;
      return ProgressionCalculationResult(
        newWeight: deloadWeight,
        newReps: currentReps,
        newSets: (currentSets * 0.7).round(),
        incrementApplied: true,
        reason: 'Wave progression: deload ${config.unit.name} (week $currentInCycle of ${config.cycleLength})',
      );
    }

    switch (currentInCycle) {
      case 1:
        // Semana 1: Alta intensidad (más peso, menos reps)
        return ProgressionCalculationResult(
          newWeight: currentWeight + incrementValue,
          newReps: (currentReps * 0.85).round().clamp(1, currentReps),
          newSets: currentSets,
          incrementApplied: true,
          reason:
              'Wave progression: high intensity ${config.unit.name} (week $currentInCycle of ${config.cycleLength})',
        );
      case 2:
        // Semana 2: Alto volumen (menos peso, más reps, más series)
        return ProgressionCalculationResult(
          newWeight: (currentWeight - incrementValue * 0.3).clamp(0, currentWeight),
          newReps: (currentReps * 1.2).round(),
          newSets: currentSets + 1,
          incrementApplied: true,
          reason: 'Wave progression: high volume ${config.unit.name} (week $currentInCycle of ${config.cycleLength})',
        );
      default:
        // Semanas adicionales: progresión normal
        return ProgressionCalculationResult(
          newWeight: currentWeight + incrementValue,
          newReps: currentReps,
          newSets: currentSets,
          incrementApplied: true,
          reason: 'Wave progression: normal ${config.unit.name} (week $currentInCycle of ${config.cycleLength})',
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
}
