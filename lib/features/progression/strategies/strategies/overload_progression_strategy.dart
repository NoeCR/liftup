import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../../models/progression_calculation_result.dart';
import '../../../../common/enums/progression_type_enum.dart';
import '../progression_strategy.dart';

class OverloadProgressionStrategy implements ProgressionStrategy {
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
        reason: 'Overload progression: deload ${config.unit.name} (week $currentInCycle of ${config.cycleLength})',
      );
    }

    final overloadType = (config.customParameters['overload_type'] as String?) ?? 'volume';
    final overloadRate = (config.customParameters['overload_rate'] as num?)?.toDouble() ?? 0.1;

    if (overloadType == 'volume') {
      return ProgressionCalculationResult(
        newWeight: currentWeight,
        newReps: currentReps,
        newSets: (currentSets * (1 + overloadRate)).round(),
        incrementApplied: true,
        reason: 'Overload progression: increasing volume',
      );
    } else {
      return ProgressionCalculationResult(
        newWeight: currentWeight * (1 + overloadRate),
        newReps: currentReps,
        newSets: currentSets,
        incrementApplied: true,
        reason: 'Overload progression: increasing intensity',
      );
    }
  }
}
