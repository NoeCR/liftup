import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../../models/progression_calculation_result.dart';
import '../../../../common/enums/progression_type_enum.dart';
import '../progression_strategy.dart';

class DoubleFactorProgressionStrategy implements ProgressionStrategy {
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
        reason: 'Double factor progression: deload ${config.unit.name} (week $currentInCycle of ${config.cycleLength})',
      );
    }

    final fitnessGain = (config.customParameters['fitness_gain'] as num?)?.toDouble() ?? 0.1;
    final fatigueDecay = (config.customParameters['fatigue_decay'] as num?)?.toDouble() ?? 0.05;
    final currentFitness = (state.customData['fitness'] as num?)?.toDouble() ?? 1.0;
    final currentFatigue = (state.customData['fatigue'] as num?)?.toDouble() ?? 0.0;

    final newFitness = currentFitness + fitnessGain;
    final newFatigue = (currentFatigue + fitnessGain * 0.8) * (1 - fatigueDecay);
    final fitnessFatigueRatio = newFitness / (1 + newFatigue);
    final weightMultiplier = fitnessFatigueRatio > 1.0 ? 1.05 : 0.95;

    return ProgressionCalculationResult(
      newWeight: currentWeight * weightMultiplier,
      newReps: currentReps,
      newSets: currentSets,
      incrementApplied: true,
      reason: 'Double factor progression: ratio=${fitnessFatigueRatio.toStringAsFixed(2)}',
    );
  }
}
