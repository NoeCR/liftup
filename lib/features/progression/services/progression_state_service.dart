import 'package:hive/hive.dart';
import '../models/progression_state.dart';
import '../../../core/logging/logging_service.dart';

/// Servicio especializado en el manejo de estados de progresión
class ProgressionStateService {
  static const String _statesBoxName = 'progression_states';
  late Box<ProgressionState> _statesBox;

  /// Inicializa el servicio
  Future<void> initialize() async {
    _statesBox = await Hive.openBox<ProgressionState>(_statesBoxName);
  }

  /// Cierra el servicio
  Future<void> close() async {
    await _statesBox.close();
  }

  /// Guarda un estado de progresión
  Future<void> saveProgressionState(ProgressionState state) async {
    try {
      LoggingService.instance.debug('Saving progression state', {
        'stateId': state.id,
        'exerciseId': state.exerciseId,
        'currentWeight': state.currentWeight,
        'currentReps': state.currentReps,
      });

      await _statesBox.put(state.id, state);

      LoggingService.instance.info('Progression state saved successfully', {'stateId': state.id});
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error saving progression state', e, stackTrace, {'stateId': state.id});
      rethrow;
    }
  }

  /// Obtiene un estado de progresión por ejercicio
  Future<ProgressionState?> getProgressionStateByExercise(String configId, String exerciseId) async {
    try {
      final allStates = _statesBox.values.cast<ProgressionState>();
      return allStates.firstWhere(
        (state) => state.progressionConfigId == configId && state.exerciseId == exerciseId,
        orElse: () => throw StateError('No progression state found'),
      );
    } catch (e) {
      LoggingService.instance.debug('No progression state found for exercise', {
        'configId': configId,
        'exerciseId': exerciseId,
      });
      return null;
    }
  }

  /// Obtiene todos los estados de progresión por configuración
  Future<List<ProgressionState>> getProgressionStatesByConfig(String configId) async {
    try {
      final allStates = _statesBox.values.cast<ProgressionState>();
      return allStates.where((state) => state.progressionConfigId == configId).toList();
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error getting progression states by config', e, stackTrace, {
        'configId': configId,
      });
      return [];
    }
  }

  /// Crea un nuevo estado de progresión para un ejercicio
  Future<ProgressionState> createProgressionState({
    required String configId,
    required String exerciseId,
    required double initialWeight,
    required int initialReps,
    required int initialSets,
  }) async {
    final state = ProgressionState(
      id: '${configId}_$exerciseId',
      progressionConfigId: configId,
      exerciseId: exerciseId,
      currentCycle: 1,
      currentWeek: 1,
      currentSession: 0,
      currentWeight: initialWeight,
      currentReps: initialReps,
      currentSets: initialSets,
      baseWeight: initialWeight,
      baseReps: initialReps,
      baseSets: initialSets,
      sessionHistory: {},
      lastUpdated: DateTime.now(),
      isDeloadWeek: false,
      customData: {},
    );

    await saveProgressionState(state);
    return state;
  }

  /// Actualiza un estado de progresión con nuevos valores
  Future<ProgressionState> updateProgressionState({
    required ProgressionState currentState,
    required double newWeight,
    required int newReps,
    required int newSets,
    required int newSession,
    required int newWeek,
    required bool isDeloadWeek,
    required double? newBaseWeight,
    required Map<String, dynamic> additionalCustomData,
  }) async {
    final updatedCustomData = Map<String, dynamic>.from(currentState.customData);
    updatedCustomData.addAll(additionalCustomData);

    final updatedState = currentState.copyWith(
      currentWeight: newWeight,
      currentReps: newReps,
      currentSets: newSets,
      currentSession: newSession,
      currentWeek: newWeek,
      lastUpdated: DateTime.now(),
      baseWeight: newBaseWeight ?? currentState.baseWeight,
      isDeloadWeek: isDeloadWeek,
      sessionHistory: {
        ...currentState.sessionHistory,
        'session_$newSession': {
          'weight': newWeight,
          'reps': newReps,
          'sets': newSets,
          'date': DateTime.now().toIso8601String(),
        },
      },
      customData: updatedCustomData,
    );

    await saveProgressionState(updatedState);
    return updatedState;
  }

  /// Detecta semanas de estancamiento
  int detectStallWeeks(ProgressionState state) {
    final history = state.sessionHistory;
    if (history.isEmpty) return 0;

    final sessions = history.keys.map((key) => int.parse(key.replaceFirst('session_', ''))).toList()..sort();

    if (sessions.length < 4) return 0;

    // Verificar si las últimas 4 sesiones tienen el mismo peso
    final lastSessions = sessions.length >= 4 ? sessions.sublist(sessions.length - 4) : sessions;
    final weights =
        lastSessions
            .map((session) => history['session_$session']?['weight'] as double?)
            .where((weight) => weight != null)
            .toList();

    if (weights.length < 4) return 0;

    final firstWeight = weights.first;
    final allSameWeight = weights.every((weight) => weight == firstWeight);

    return allSameWeight ? 4 : 0;
  }

  /// Limpia estados de configuraciones inactivas
  Future<void> cleanupInactiveStates(List<String> activeConfigIds) async {
    try {
      final allStates = _statesBox.values.cast<ProgressionState>();
      final statesToDelete = allStates.where((state) => !activeConfigIds.contains(state.progressionConfigId)).toList();

      for (final state in statesToDelete) {
        await _statesBox.delete(state.id);
      }

      if (statesToDelete.isNotEmpty) {
        LoggingService.instance.info('Cleaned up inactive progression states', {'deletedCount': statesToDelete.length});
      }
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error cleaning up inactive progression states', e, stackTrace);
      rethrow;
    }
  }
}
