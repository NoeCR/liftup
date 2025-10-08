import '../models/progression_config.dart';
import '../models/progression_state.dart';
import '../models/progression_calculation_result.dart';
import 'progression_calculation_service.dart';
import 'progression_state_service.dart';
import '../../../core/logging/logging_service.dart';

/// Servicio coordinador que maneja la lógica completa de progresión
class ProgressionCoordinatorService {
  final ProgressionCalculationService _calculationService;
  final ProgressionStateService _stateService;

  ProgressionCoordinatorService({
    required ProgressionCalculationService calculationService,
    required ProgressionStateService stateService,
  }) : _calculationService = calculationService,
       _stateService = stateService;

  /// Procesa la progresión completa para un ejercicio
  Future<ProgressionCalculationResult> processProgression({
    required ProgressionConfig config,
    required String exerciseId,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
  }) async {
    try {
      // 1. Obtener o crear el estado de progresión
      ProgressionState state =
          await _stateService.getProgressionStateByExercise(
            config.id,
            exerciseId,
          ) ??
          await _stateService.createProgressionState(
            configId: config.id,
            exerciseId: exerciseId,
            initialWeight: currentWeight,
            initialReps: currentReps,
            initialSets: currentSets,
          );

      // 2. Detectar estancamiento
      final stalledWeeks = _stateService.detectStallWeeks(state);
      final customDataUpdates = <String, dynamic>{
        'stalled_weeks': stalledWeeks,
      };

      if (stalledWeeks >= 4) {
        customDataUpdates['deload_suggested'] = true;
        LoggingService.instance.warning('Stall detected', {
          'exerciseId': exerciseId,
          'stalledWeeks': stalledWeeks,
        });
      } else if (state.customData.containsKey('deload_suggested')) {
        customDataUpdates.remove('deload_suggested');
      }

      // 3. Calcular la progresión
      final result = _calculationService.calculateProgression(
        config: config,
        state: state,
        currentWeight: currentWeight,
        currentReps: currentReps,
        currentSets: currentSets,
      );

      // 4. Calcular próximos valores
      final nextSessionWeek = _calculationService.calculateNextSessionAndWeek(
        config: config,
        state: state,
      );

      final isDeloadWeek = _calculationService.isDeloadWeek(
        config: config,
        state: state,
      );

      final nextBaseWeight = _calculationService.calculateNextBaseWeight(
        config: config,
        state: state,
        result: result,
      );

      // 5. Actualizar el estado
      await _stateService.updateProgressionState(
        currentState: state,
        newWeight: result.newWeight,
        newReps: result.newReps,
        newSets: result.newSets,
        newSession: nextSessionWeek.session,
        newWeek: nextSessionWeek.week,
        isDeloadWeek: isDeloadWeek,
        newBaseWeight: nextBaseWeight,
        additionalCustomData: customDataUpdates,
      );

      LoggingService.instance.info('Progression processed successfully', {
        'exerciseId': exerciseId,
        'newWeight': result.newWeight,
        'newReps': result.newReps,
        'newSets': result.newSets,
        'isDeloadWeek': isDeloadWeek,
        'stalledWeeks': stalledWeeks,
      });

      return result;
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error processing progression',
        e,
        stackTrace,
        {'configId': config.id, 'exerciseId': exerciseId},
      );
      rethrow;
    }
  }

  /// Obtiene el estado actual de progresión para un ejercicio
  Future<ProgressionState?> getCurrentState({
    required String configId,
    required String exerciseId,
  }) async {
    return await _stateService.getProgressionStateByExercise(
      configId,
      exerciseId,
    );
  }

  /// Obtiene todos los estados de una configuración
  Future<List<ProgressionState>> getStatesByConfig(String configId) async {
    return await _stateService.getProgressionStatesByConfig(configId);
  }

  /// Limpia estados inactivos
  Future<void> cleanupInactiveStates(List<String> activeConfigIds) async {
    await _stateService.cleanupInactiveStates(activeConfigIds);
  }
}
