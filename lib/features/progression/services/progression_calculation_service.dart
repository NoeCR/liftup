import '../models/progression_config.dart';
import '../models/progression_state.dart';
import '../models/progression_calculation_result.dart';
import '../strategies/progression_strategy.dart';
import '../strategies/strategies/double_progression_strategy.dart';
import '../strategies/strategies/double_factor_progression_strategy.dart';
import '../../../common/enums/progression_type_enum.dart';
import '../../../core/logging/logging_service.dart';

/// Servicio especializado en el cálculo de progresión
class ProgressionCalculationService {
  /// Calcula la progresión para un ejercicio
  ProgressionCalculationResult calculateProgression({
    required ProgressionConfig config,
    required ProgressionState state,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
  }) {
    try {
      // Obtener la estrategia correspondiente
      final strategy = _getStrategy(config.type);
      if (strategy == null) {
        throw Exception('No strategy found for type: ${config.type}');
      }

      // Calcular la progresión
      final result = strategy.calculate(
        config: config,
        state: state,
        currentWeight: currentWeight,
        currentReps: currentReps,
        currentSets: currentSets,
      );

      LoggingService.instance.info('Progression calculated', {
        'strategy': config.type.name,
        'exerciseId': state.exerciseId,
        'oldWeight': currentWeight,
        'newWeight': result.newWeight,
        'oldReps': currentReps,
        'newReps': result.newReps,
        'oldSets': currentSets,
        'newSets': result.newSets,
        'incrementApplied': result.incrementApplied,
        'reason': result.reason,
      });

      return result;
    } catch (e, stackTrace) {
      LoggingService.instance
          .error('Error calculating progression', e, stackTrace, {
            'configId': config.id,
            'exerciseId': state.exerciseId,
            'type': config.type.name,
          });
      rethrow;
    }
  }

  /// Obtiene la estrategia correspondiente al tipo de progresión
  ProgressionStrategy? _getStrategy(ProgressionType type) {
    switch (type) {
      case ProgressionType.double:
        return DoubleProgressionStrategy();
      case ProgressionType.doubleFactor:
        return DoubleFactorProgressionStrategy();
      // Agregar más estrategias aquí según sea necesario
      default:
        return null;
    }
  }

  /// Calcula la posición actual en el ciclo
  int calculateCurrentCyclePosition({
    required ProgressionConfig config,
    required ProgressionState state,
  }) {
    return config.unit == ProgressionUnit.session
        ? ((state.currentSession - 1) % config.cycleLength) + 1
        : ((state.currentWeek - 1) % config.cycleLength) + 1;
  }

  /// Determina si estamos en una semana de deload
  bool isDeloadWeek({
    required ProgressionConfig config,
    required ProgressionState state,
  }) {
    final currentPosition = calculateCurrentCyclePosition(
      config: config,
      state: state,
    );
    return config.deloadWeek > 0 && currentPosition == config.deloadWeek;
  }

  /// Calcula la próxima sesión y semana
  ({int session, int week}) calculateNextSessionAndWeek({
    required ProgressionConfig config,
    required ProgressionState state,
  }) {
    final sessionsPerWeek = config.customParameters['sessions_per_week'] ?? 3;
    final newSession = state.currentSession + 1;
    final newWeek = ((newSession - 1) ~/ sessionsPerWeek) + 1;

    return (session: newSession, week: newWeek);
  }

  /// Calcula el peso base para la próxima sesión (considerando deload)
  double calculateNextBaseWeight({
    required ProgressionConfig config,
    required ProgressionState state,
    required ProgressionCalculationResult result,
  }) {
    final isDeload = isDeloadWeek(config: config, state: state);
    return isDeload ? result.newWeight : state.baseWeight;
  }
}
