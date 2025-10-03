import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../models/progression_config.dart';
import '../models/progression_state.dart';
import '../models/progression_template.dart';
import '../../../common/enums/progression_type_enum.dart';
import '../../../core/database/database_service.dart';
import '../../../core/logging/logging.dart';

part 'progression_service.g.dart';

@riverpod
class ProgressionService extends _$ProgressionService {
  @override
  ProgressionService build() {
    return this;
  }

  Box get _configsBox => DatabaseService.getInstance().progressionConfigsBox;
  Box get _statesBox => DatabaseService.getInstance().progressionStatesBox;
  Box get _templatesBox =>
      DatabaseService.getInstance().progressionTemplatesBox;

  // ========== CONFIGURACIONES DE PROGRESIÓN ==========

  Future<void> saveProgressionConfig(ProgressionConfig config) async {
    try {
      LoggingService.instance.debug('Saving progression config', {
        'configId': config.id,
        'isGlobal': config.isGlobal,
        'type': config.type.name,
      });

      await _configsBox.put(config.id, config);

      LoggingService.instance.info('Progression config saved successfully', {
        'configId': config.id,
      });
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error saving progression config',
        e,
        stackTrace,
        {'configId': config.id},
      );
      rethrow;
    }
  }

  Future<ProgressionConfig?> getProgressionConfig(String configId) async {
    try {
      return _configsBox.get(configId);
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error getting progression config',
        e,
        stackTrace,
        {'configId': configId},
      );
      return null;
    }
  }

  Future<ProgressionConfig?> getActiveProgressionConfig() async {
    try {
      final allConfigs = _configsBox.values.cast<ProgressionConfig>();
      return allConfigs.firstWhere(
        (config) => config.isGlobal && config.isActive,
        orElse:
            () => throw StateError('No active global progression config found'),
      );
    } catch (e) {
      LoggingService.instance.debug(
        'No active global progression config found',
      );
      return null;
    }
  }

  Future<List<ProgressionConfig>> getAllProgressionConfigs() async {
    try {
      final allConfigs = _configsBox.values.cast<ProgressionConfig>().toList();
      allConfigs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return allConfigs;
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error getting all progression configs',
        e,
        stackTrace,
      );
      return [];
    }
  }

  Future<void> deleteProgressionConfig(String configId) async {
    try {
      await _configsBox.delete(configId);
      LoggingService.instance.info('Progression config deleted', {
        'configId': configId,
      });
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error deleting progression config',
        e,
        stackTrace,
        {'configId': configId},
      );
      rethrow;
    }
  }

  // ========== ESTADOS DE PROGRESIÓN ==========

  Future<void> saveProgressionState(ProgressionState state) async {
    try {
      LoggingService.instance.debug('Saving progression state', {
        'stateId': state.id,
        'exerciseId': state.exerciseId,
        'currentWeight': state.currentWeight,
        'currentReps': state.currentReps,
      });

      await _statesBox.put(state.id, state);

      LoggingService.instance.info('Progression state saved successfully', {
        'stateId': state.id,
      });
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error saving progression state',
        e,
        stackTrace,
        {'stateId': state.id},
      );
      rethrow;
    }
  }

  Future<ProgressionState?> getProgressionState(String stateId) async {
    try {
      return _statesBox.get(stateId);
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error getting progression state',
        e,
        stackTrace,
        {'stateId': stateId},
      );
      return null;
    }
  }

  Future<ProgressionState?> getProgressionStateByExercise(
    String configId,
    String exerciseId,
  ) async {
    try {
      final allStates = _statesBox.values.cast<ProgressionState>();
      return allStates.firstWhere(
        (state) =>
            state.progressionConfigId == configId &&
            state.exerciseId == exerciseId,
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

  Future<List<ProgressionState>> getProgressionStatesByConfig(
    String configId,
  ) async {
    try {
      final allStates = _statesBox.values.cast<ProgressionState>();
      return allStates
          .where((state) => state.progressionConfigId == configId)
          .toList();
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error getting progression states by config',
        e,
        stackTrace,
        {'configId': configId},
      );
      return [];
    }
  }

  // ========== PLANTILLAS DE PROGRESIÓN ==========

  Future<void> saveProgressionTemplate(ProgressionTemplate template) async {
    try {
      await _templatesBox.put(template.id, template);
      LoggingService.instance.info('Progression template saved', {
        'templateId': template.id,
      });
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error saving progression template',
        e,
        stackTrace,
        {'templateId': template.id},
      );
      rethrow;
    }
  }

  Future<List<ProgressionTemplate>> getAllProgressionTemplates() async {
    try {
      final allTemplates =
          _templatesBox.values.cast<ProgressionTemplate>().toList();
      allTemplates.sort((a, b) => a.name.compareTo(b.name));
      return allTemplates;
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error getting all progression templates',
        e,
        stackTrace,
      );
      return [];
    }
  }

  Future<ProgressionTemplate?> getProgressionTemplate(String templateId) async {
    try {
      return _templatesBox.get(templateId);
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error getting progression template',
        e,
        stackTrace,
        {'templateId': templateId},
      );
      return null;
    }
  }

  // ========== LÓGICA DE PROGRESIÓN ==========

  /// Calcula los valores actualizados para un ejercicio basado en su progresión
  Future<ProgressionCalculationResult> calculateProgression(
    String configId,
    String exerciseId,
    double currentWeight,
    int currentReps,
    int currentSets,
  ) async {
    try {
      final config = await getProgressionConfig(configId);
      if (config == null) {
        throw Exception('Progression config not found');
      }

      final state = await getProgressionStateByExercise(configId, exerciseId);
      if (state == null) {
        throw Exception('Progression state not found');
      }

      final result = _calculateProgressionValues(
        config: config,
        state: state,
        currentWeight: currentWeight,
        currentReps: currentReps,
        currentSets: currentSets,
      );

      // Actualizar el estado de progresión
      final updatedState = state.copyWith(
        currentWeight: result.newWeight,
        currentReps: result.newReps,
        currentSets: result.newSets,
        currentSession: state.currentSession + 1,
        lastUpdated: DateTime.now(),
        sessionHistory: {
          ...state.sessionHistory,
          'session_${state.currentSession + 1}': {
            'weight': result.newWeight,
            'reps': result.newReps,
            'sets': result.newSets,
            'date': DateTime.now().toIso8601String(),
            'increment_applied': result.incrementApplied,
          },
        },
      );

      await saveProgressionState(updatedState);

      LoggingService.instance.info('Progression calculated successfully', {
        'exerciseId': exerciseId,
        'newWeight': result.newWeight,
        'newReps': result.newReps,
        'newSets': result.newSets,
      });

      return result;
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error calculating progression',
        e,
        stackTrace,
        {'configId': configId, 'exerciseId': exerciseId},
      );
      rethrow;
    }
  }

  ProgressionCalculationResult _calculateProgressionValues({
    required ProgressionConfig config,
    required ProgressionState state,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
  }) {
    switch (config.type) {
      case ProgressionType.linear:
        return _calculateLinearProgression(
          config,
          state,
          currentWeight,
          currentReps,
          currentSets,
        );
      case ProgressionType.undulating:
        return _calculateUndulatingProgression(
          config,
          state,
          currentWeight,
          currentReps,
          currentSets,
        );
      case ProgressionType.stepped:
        return _calculateSteppedProgression(
          config,
          state,
          currentWeight,
          currentReps,
          currentSets,
        );
      case ProgressionType.double:
        return _calculateDoubleProgression(
          config,
          state,
          currentWeight,
          currentReps,
          currentSets,
        );
      case ProgressionType.wave:
        return _calculateWaveProgression(
          config,
          state,
          currentWeight,
          currentReps,
          currentSets,
        );
      case ProgressionType.static:
        return _calculateStaticProgression(
          config,
          state,
          currentWeight,
          currentReps,
          currentSets,
        );
      case ProgressionType.reverse:
        return _calculateReverseProgression(
          config,
          state,
          currentWeight,
          currentReps,
          currentSets,
        );
      default:
        return ProgressionCalculationResult(
          newWeight: currentWeight,
          newReps: currentReps,
          newSets: currentSets,
          incrementApplied: false,
          reason: 'No progression applied',
        );
    }
  }

  ProgressionCalculationResult _calculateLinearProgression(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
  ) {
    // Progresión lineal: incremento constante cada X sesiones
    if (state.currentSession % config.incrementFrequency == 0) {
      return ProgressionCalculationResult(
        newWeight: currentWeight + config.incrementValue,
        newReps: currentReps,
        newSets: currentSets,
        incrementApplied: true,
        reason:
            'Linear progression: weight increased by ${config.incrementValue}kg',
      );
    }

    return ProgressionCalculationResult(
      newWeight: currentWeight,
      newReps: currentReps,
      newSets: currentSets,
      incrementApplied: false,
      reason: 'Linear progression: no increment this session',
    );
  }

  ProgressionCalculationResult _calculateUndulatingProgression(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
  ) {
    // Progresión ondulante: alterna entre días pesados y ligeros
    final isHeavyDay = state.currentSession % 2 == 1;

    if (isHeavyDay) {
      // Día pesado: más peso, menos repeticiones
      return ProgressionCalculationResult(
        newWeight: currentWeight + (config.incrementValue * 0.5),
        newReps: (currentReps * 0.8).round(),
        newSets: currentSets,
        incrementApplied: true,
        reason: 'Undulating progression: heavy day',
      );
    } else {
      // Día ligero: menos peso, más repeticiones
      return ProgressionCalculationResult(
        newWeight: currentWeight - (config.incrementValue * 0.3),
        newReps: (currentReps * 1.2).round(),
        newSets: currentSets,
        incrementApplied: true,
        reason: 'Undulating progression: light day',
      );
    }
  }

  ProgressionCalculationResult _calculateSteppedProgression(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
  ) {
    // Progresión escalonada: acumula carga y luego deload
    final isDeloadWeek = state.currentWeek == config.deloadWeek;

    if (isDeloadWeek) {
      return ProgressionCalculationResult(
        newWeight: state.baseWeight * config.deloadPercentage,
        newReps: currentReps,
        newSets: (currentSets * 0.7).round(),
        incrementApplied: true,
        reason: 'Stepped progression: deload week',
      );
    } else {
      return ProgressionCalculationResult(
        newWeight: currentWeight + config.incrementValue,
        newReps: currentReps,
        newSets: currentSets,
        incrementApplied: true,
        reason: 'Stepped progression: accumulation phase',
      );
    }
  }

  ProgressionCalculationResult _calculateDoubleProgression(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
  ) {
    // Progresión doble: primero aumenta repeticiones, luego peso
    final maxReps = config.customParameters['max_reps'] ?? 12;

    if (currentReps < maxReps) {
      // Aumentar repeticiones
      return ProgressionCalculationResult(
        newWeight: currentWeight,
        newReps: currentReps + 1,
        newSets: currentSets,
        incrementApplied: true,
        reason: 'Double progression: increasing reps',
      );
    } else {
      // Aumentar peso y resetear repeticiones
      return ProgressionCalculationResult(
        newWeight: currentWeight + config.incrementValue,
        newReps: config.customParameters['min_reps'] ?? 5,
        newSets: currentSets,
        incrementApplied: true,
        reason: 'Double progression: increasing weight, resetting reps',
      );
    }
  }

  ProgressionCalculationResult _calculateWaveProgression(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
  ) {
    // Progresión por oleadas: ciclos de 3 semanas
    final weekInCycle = (state.currentWeek - 1) % 3 + 1;

    switch (weekInCycle) {
      case 1: // Semana de alta intensidad
        return ProgressionCalculationResult(
          newWeight: currentWeight + config.incrementValue,
          newReps: (currentReps * 0.8).round(),
          newSets: currentSets,
          incrementApplied: true,
          reason: 'Wave progression: high intensity week',
        );
      case 2: // Semana de alto volumen
        return ProgressionCalculationResult(
          newWeight: currentWeight - (config.incrementValue * 0.2),
          newReps: (currentReps * 1.3).round(),
          newSets: currentSets + 1,
          incrementApplied: true,
          reason: 'Wave progression: high volume week',
        );
      case 3: // Semana de descarga
        return ProgressionCalculationResult(
          newWeight: currentWeight * config.deloadPercentage,
          newReps: currentReps,
          newSets: (currentSets * 0.7).round(),
          incrementApplied: true,
          reason: 'Wave progression: deload week',
        );
      default:
        return ProgressionCalculationResult(
          newWeight: currentWeight,
          newReps: currentReps,
          newSets: currentSets,
          incrementApplied: false,
          reason: 'Wave progression: no change',
        );
    }
  }

  ProgressionCalculationResult _calculateStaticProgression(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
  ) {
    // Progresión estática: mantiene valores constantes
    return ProgressionCalculationResult(
      newWeight: currentWeight,
      newReps: currentReps,
      newSets: currentSets,
      incrementApplied: false,
      reason: 'Static progression: maintaining current values',
    );
  }

  ProgressionCalculationResult _calculateReverseProgression(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
  ) {
    // Progresión inversa: reduce peso, aumenta repeticiones
    return ProgressionCalculationResult(
      newWeight: currentWeight - config.incrementValue,
      newReps: currentReps + 1,
      newSets: currentSets,
      incrementApplied: true,
      reason: 'Reverse progression: decreasing weight, increasing reps',
    );
  }

  // ========== INICIALIZACIÓN DE PROGRESIONES ==========

  /// Inicializa una nueva progresión global
  Future<ProgressionConfig> initializeProgression({
    required ProgressionType type,
    required ProgressionUnit unit,
    required ProgressionTarget primaryTarget,
    ProgressionTarget? secondaryTarget,
    required double incrementValue,
    required int incrementFrequency,
    required int cycleLength,
    required int deloadWeek,
    required double deloadPercentage,
    Map<String, dynamic>? customParameters,
  }) async {
    try {
      final uuid = const Uuid();
      final config = ProgressionConfig(
        id: uuid.v4(),
        isGlobal: true,
        type: type,
        unit: unit,
        primaryTarget: primaryTarget,
        secondaryTarget: secondaryTarget,
        incrementValue: incrementValue,
        incrementFrequency: incrementFrequency,
        cycleLength: cycleLength,
        deloadWeek: deloadWeek,
        deloadPercentage: deloadPercentage,
        customParameters: customParameters ?? {},
        startDate: DateTime.now(),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await saveProgressionConfig(config);

      LoggingService.instance.info(
        'Global progression initialized successfully',
        {'configId': config.id, 'type': type.name},
      );

      return config;
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error initializing progression',
        e,
        stackTrace,
        {'type': type.name},
      );
      rethrow;
    }
  }

  /// Inicializa el estado de progresión para un ejercicio específico
  Future<ProgressionState> initializeExerciseProgression({
    required String configId,
    required String exerciseId,
    required double baseWeight,
    required int baseReps,
    required int baseSets,
    double? oneRepMax,
  }) async {
    try {
      final uuid = const Uuid();
      final state = ProgressionState(
        id: uuid.v4(),
        progressionConfigId: configId,
        exerciseId: exerciseId,
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 0,
        currentWeight: baseWeight,
        currentReps: baseReps,
        currentSets: baseSets,
        baseWeight: baseWeight,
        baseReps: baseReps,
        baseSets: baseSets,
        sessionHistory: {},
        lastUpdated: DateTime.now(),
        isDeloadWeek: false,
        oneRepMax: oneRepMax,
        customData: {},
      );

      await saveProgressionState(state);

      LoggingService.instance.info('Exercise progression state initialized', {
        'stateId': state.id,
        'exerciseId': exerciseId,
        'baseWeight': baseWeight,
      });

      return state;
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error initializing exercise progression state',
        e,
        stackTrace,
        {'configId': configId, 'exerciseId': exerciseId},
      );
      rethrow;
    }
  }
}

class ProgressionCalculationResult {
  final double newWeight;
  final int newReps;
  final int newSets;
  final bool incrementApplied;
  final String reason;

  const ProgressionCalculationResult({
    required this.newWeight,
    required this.newReps,
    required this.newSets,
    required this.incrementApplied,
    required this.reason,
  });
}
