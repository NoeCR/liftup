import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../models/progression_config.dart';
import '../models/progression_state.dart';
import '../models/progression_calculation_result.dart';
import '../models/progression_template.dart';
import '../../../common/enums/progression_type_enum.dart';
import '../strategies/progression_strategy.dart';
import '../../../core/database/database_service.dart';
import '../../../core/database/i_database_service.dart';
import '../../../core/logging/logging.dart';

part 'progression_service.g.dart';

// Provider used in production (backed by real DatabaseService)
@riverpod
ProgressionService productionProgressionService(Ref ref) {
  return ProgressionService();
}

// (Eliminado) Provider para pruebas con inyección de dependencias

@riverpod
class ProgressionService extends _$ProgressionService {
  final IDatabaseService _databaseService;

  // Constructor with dependency injection
  ProgressionService({IDatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService.getInstance();

  @override
  ProgressionService build() {
    return this;
  }

  Box get _configsBox => _databaseService.progressionConfigsBox;
  Box get _statesBox => _databaseService.progressionStatesBox;
  Box get _templatesBox => _databaseService.progressionTemplatesBox;

  // ========== PROGRESSION CONFIGS ==========

  Future<void> saveProgressionConfig(ProgressionConfig config) async {
    try {
      LoggingService.instance.debug('Saving progression config', {
        'configId': config.id,
        'isGlobal': config.isGlobal,
        'type': config.type.name,
      });

      await _configsBox.put(config.id, config);

      LoggingService.instance.info('Progression config saved successfully', {'configId': config.id});
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error saving progression config', e, stackTrace, {'configId': config.id});
      rethrow;
    }
  }

  Future<ProgressionConfig?> getProgressionConfig(String configId) async {
    try {
      return _configsBox.get(configId);
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error getting progression config', e, stackTrace, {'configId': configId});
      return null;
    }
  }

  Future<ProgressionConfig?> getActiveProgressionConfig() async {
    try {
      final allConfigs = _configsBox.values.cast<ProgressionConfig>();
      return allConfigs.firstWhere(
        (config) => config.isGlobal && config.isActive,
        orElse: () => throw StateError('No active global progression config found'),
      );
    } catch (e) {
      LoggingService.instance.debug('No active global progression config found');
      return null;
    }
  }

  Future<List<ProgressionConfig>> getAllProgressionConfigs() async {
    try {
      final allConfigs = _configsBox.values.cast<ProgressionConfig>().toList();
      allConfigs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return allConfigs;
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error getting all progression configs', e, stackTrace);
      return [];
    }
  }

  Future<void> deleteProgressionConfig(String configId) async {
    try {
      await _configsBox.delete(configId);
      LoggingService.instance.info('Progression config deleted', {'configId': configId});
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error deleting progression config', e, stackTrace, {'configId': configId});
      rethrow;
    }
  }

  /// Limpia los estados de progresión de configuraciones inactivas
  Future<void> cleanupInactiveProgressionStates() async {
    try {
      final activeConfigIds = <String>{};
      for (final raw in _configsBox.values) {
        ProgressionConfig? config;

        // Handle type casting issues from Hive
        if (raw is Map) {
          final Map<String, dynamic> typedMap = raw.cast<String, dynamic>();
          config = ProgressionConfig.fromJson(typedMap);
        } else {
          config = raw as ProgressionConfig?;
        }

        if (config != null && config.isActive) {
          activeConfigIds.add(config.id);
        }
      }

      final statesToDelete = <ProgressionState>[];
      for (final raw in _statesBox.values) {
        ProgressionState? state;

        // Handle type casting issues from Hive
        if (raw is Map) {
          final Map<String, dynamic> typedMap = raw.cast<String, dynamic>();
          state = ProgressionState.fromJson(typedMap);
        } else {
          state = raw as ProgressionState?;
        }

        if (state != null && !activeConfigIds.contains(state.progressionConfigId)) {
          statesToDelete.add(state);
        }
      }

      for (final state in statesToDelete) {
        await _statesBox.delete(state.id);
      }

      if (statesToDelete.isNotEmpty) {
        LoggingService.instance.info('Cleaned up inactive progression states', {'deletedCount': statesToDelete.length});
      }
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error cleaning up inactive progression states', e, stackTrace);
    }
  }

  // ========== PROGRESSION STATES ==========

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

  Future<ProgressionState?> getProgressionState(String stateId) async {
    try {
      return _statesBox.get(stateId);
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error getting progression state', e, stackTrace, {'stateId': stateId});
      return null;
    }
  }

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

  // ========== PROGRESSION TEMPLATES ==========

  Future<void> saveProgressionTemplate(ProgressionTemplate template) async {
    try {
      await _templatesBox.put(template.id, template);
      LoggingService.instance.info('Progression template saved', {'templateId': template.id});
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error saving progression template', e, stackTrace, {'templateId': template.id});
      rethrow;
    }
  }

  Future<List<ProgressionTemplate>> getAllProgressionTemplates() async {
    try {
      final allTemplates = _templatesBox.values.cast<ProgressionTemplate>().toList();
      allTemplates.sort((a, b) => a.name.compareTo(b.name));
      return allTemplates;
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error getting all progression templates', e, stackTrace);
      return [];
    }
  }

  Future<ProgressionTemplate?> getProgressionTemplate(String templateId) async {
    try {
      return _templatesBox.get(templateId);
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error getting progression template', e, stackTrace, {'templateId': templateId});
      return null;
    }
  }

  // ========== PROGRESSION LOGIC ==========

  /// Computes updated values for an exercise based on its progression
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

      // Usar factoría de estrategias SIEMPRE; default si no hay match
      final strategy = ProgressionStrategyFactory.fromType(config.type);
      final result = strategy.calculate(
        config: config,
        state: state,
        currentWeight: currentWeight,
        currentReps: currentReps,
        currentSets: currentSets,
      );

      // Compute current week based on session count (3 sessions/week by default; configurable)
      final sessionsPerWeek = config.customParameters['sessions_per_week'] ?? 3;
      final newSession = state.currentSession + 1;
      final newWeek = ((newSession - 1) ~/ sessionsPerWeek) + 1;

      // Detect if we are in deload position of the cycle (recomputable here)
      final int currentInCycle =
          config.unit == ProgressionUnit.session
              ? ((state.currentSession - 1) % config.cycleLength) + 1
              : ((state.currentWeek - 1) % config.cycleLength) + 1;
      final bool isDeloadNow = config.deloadWeek > 0 && currentInCycle == config.deloadWeek;

      // If deload just applied, set baseWeight to deloaded weight to resume next period from there
      final double nextBaseWeight = isDeloadNow ? result.newWeight : state.baseWeight;

      // Track deload application to avoid confusion and for debugging
      // Update progression state
      final updatedState = state.copyWith(
        currentWeight: result.newWeight,
        currentReps: result.newReps,
        currentSets: result.newSets,
        currentSession: newSession,
        currentWeek: newWeek,
        lastUpdated: DateTime.now(),
        baseWeight: nextBaseWeight,
        isDeloadWeek: isDeloadNow,
        sessionHistory: {
          ...state.sessionHistory,
          'session_$newSession': {
            'weight': result.newWeight,
            'reps': result.newReps,
            'sets': result.newSets,
            'date': DateTime.now().toIso8601String(),
            'increment_applied': result.incrementApplied,
          },
        },
        customData: {},
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
      LoggingService.instance.error('Error calculating progression', e, stackTrace, {
        'configId': configId,
        'exerciseId': exerciseId,
      });
      rethrow;
    }
  }

  // ========== PROGRESSION INITIALIZATION ==========

  /// Initializes a new global progression configuration
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
    bool isGlobal = true,
  }) async {
    try {
      final uuid = const Uuid();
      final config = ProgressionConfig(
        id: uuid.v4(),
        isGlobal: isGlobal,
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

      LoggingService.instance.info('Global progression initialized successfully', {
        'configId': config.id,
        'type': type.name,
      });

      return config;
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error initializing progression', e, stackTrace, {'type': type.name});
      rethrow;
    }
  }

  /// Initializes progression state for a specific exercise
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
      LoggingService.instance.error('Error initializing exercise progression state', e, stackTrace, {
        'configId': configId,
        'exerciseId': exerciseId,
      });
      rethrow;
    }
  }
}

// Moved to models/progression_calculation_result.dart
