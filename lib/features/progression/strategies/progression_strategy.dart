import '../../../common/enums/progression_type_enum.dart';
import '../../../features/exercise/models/exercise.dart';
import '../models/progression_calculation_result.dart';
import '../models/progression_config.dart';
import '../models/progression_state.dart';
import 'strategies/autoregulated_progression_strategy.dart';
import 'strategies/default_progression_strategy.dart';
import 'strategies/double_factor_progression_strategy.dart';
import 'strategies/double_progression_strategy.dart';
import 'strategies/linear_progression_strategy.dart';
import 'strategies/overload_progression_strategy.dart';
import 'strategies/reverse_progression_strategy.dart';
import 'strategies/static_progression_strategy.dart';
import 'strategies/stepped_progression_strategy.dart';
import 'strategies/undulating_progression_strategy.dart';
import 'strategies/wave_progression_strategy.dart';

abstract class ProgressionStrategy {
  ProgressionCalculationResult calculate({
    required ProgressionConfig config,
    required ProgressionState state,
    required String routineId,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
    required Exercise exercise,
    bool isExerciseLocked = false,
  });

  /// Calcula la próxima sesión y semana basado en la configuración
  ({int session, int week}) calculateNextSessionAndWeek({
    required ProgressionConfig config,
    required ProgressionState state,
  });

  /// Helper method to check if progression values should be applied to an exercise
  /// Returns true if progression values should be used, false if blocked
  bool shouldApplyProgressionValues(ProgressionState? progressionState, String routineId, bool isExerciseLocked);
}

class ProgressionStrategyFactory {
  static ProgressionStrategy fromType(ProgressionType type) {
    switch (type) {
      case ProgressionType.linear:
        return LinearProgressionStrategy();
      case ProgressionType.double:
        return DoubleProgressionStrategy();
      case ProgressionType.undulating:
        return UndulatingProgressionStrategy();
      case ProgressionType.stepped:
        return SteppedProgressionStrategy();
      case ProgressionType.wave:
        return WaveProgressionStrategy();
      case ProgressionType.static:
        return StaticProgressionStrategy();
      case ProgressionType.reverse:
        return ReverseProgressionStrategy();
      case ProgressionType.autoregulated:
        return AutoregulatedProgressionStrategy();
      case ProgressionType.doubleFactor:
        return DoubleFactorProgressionStrategy();
      case ProgressionType.overload:
        return OverloadProgressionStrategy();
      case ProgressionType.none:
        return DefaultProgressionStrategy();
    }
    // Nunca null: usar estrategia por defecto sin cambios
  }
}
