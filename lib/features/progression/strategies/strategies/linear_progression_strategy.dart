import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../../models/progression_calculation_result.dart';
import '../../../../common/enums/progression_type_enum.dart';
import '../progression_strategy.dart';

class LinearProgressionStrategy implements ProgressionStrategy {
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
        reason: 'Linear progression: deload ${config.unit.name} (week $currentInCycle of ${config.cycleLength})',
      );
    }

    // Verificar si es momento de incrementar según la frecuencia
    if (currentInCycle % config.incrementFrequency == 0) {
      // Obtener incremento apropiado según parámetros personalizados
      final incrementValue = _getIncrementValue(config);

      return ProgressionCalculationResult(
        newWeight: currentWeight + incrementValue,
        newReps: currentReps,
        newSets: currentSets,
        incrementApplied: true,
        reason: 'Linear progression: weight +${incrementValue}kg (week $currentInCycle of ${config.cycleLength})',
      );
    }

    return ProgressionCalculationResult(
      newWeight: currentWeight,
      newReps: currentReps,
      newSets: currentSets,
      incrementApplied: false,
      reason: 'Linear progression: no increment (week $currentInCycle of ${config.cycleLength})',
    );
  }

  /// Obtiene el valor de incremento desde parámetros personalizados
  /// Prioridad: per_exercise > global > defaults por tipo
  double _getIncrementValue(ProgressionConfig config) {
    final customParams = config.customParameters;

    // Buscar en per_exercise primero
    try {
      final perExercise = customParams['per_exercise'] as Map<String, dynamic>?;
      if (perExercise != null) {
        final exerciseParams = perExercise.values.first as Map<String, dynamic>?;
        if (exerciseParams != null) {
          final increment =
              exerciseParams['increment_value'] ??
              exerciseParams['multi_increment_min'] ??
              exerciseParams['iso_increment_min'];
          if (increment != null && increment is num) {
            return increment.toDouble();
          }
        }
      }
    } catch (e) {
      // Si hay error en per_exercise, continuar con fallbacks
    }

    // Fallback a global
    try {
      final globalIncrement =
          customParams['increment_value'] ?? customParams['multi_increment_min'] ?? customParams['iso_increment_min'];
      if (globalIncrement != null && globalIncrement is num) {
        return globalIncrement.toDouble();
      }
    } catch (e) {
      // Si hay error en global, usar valor base
    }

    return config.incrementValue; // fallback al valor base
  }
}
