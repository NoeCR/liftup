import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../../models/progression_calculation_result.dart';
import '../progression_strategy.dart';

class StaticProgressionStrategy implements ProgressionStrategy {
  @override
  ProgressionCalculationResult calculate({
    required ProgressionConfig config,
    required ProgressionState state,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
  }) {
    return ProgressionCalculationResult(
      newWeight: currentWeight,
      newReps: currentReps,
      newSets: currentSets,
      incrementApplied: false,
      reason: 'Static progression: maintaining current values',
    );
  }
}
