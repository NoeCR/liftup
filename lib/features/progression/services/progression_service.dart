import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../models/progression_config.dart';
import '../models/progression_state.dart';
import '../models/progression_template.dart';
import '../../../common/enums/progression_type_enum.dart';
import '../../../core/database/database_service.dart';
import '../../../core/database/i_database_service.dart';
import '../../../core/logging/logging.dart';

part 'progression_service.g.dart';

// Provider para uso en producción (usa DatabaseService real)
@riverpod
ProgressionService productionProgressionService(
  ProductionProgressionServiceRef ref,
) {
  return ProgressionService();
}

// Provider para testing (permite inyección de dependencias)
@riverpod
ProgressionService testProgressionService(
  TestProgressionServiceRef ref,
  IDatabaseService databaseService,
) {
  return ProgressionService(databaseService: databaseService);
}

@riverpod
class ProgressionService extends _$ProgressionService {
  final IDatabaseService _databaseService;

  // Constructor con inyección de dependencias
  ProgressionService({IDatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService.getInstance();

  @override
  ProgressionService build() {
    return this;
  }

  Box get _configsBox => _databaseService.progressionConfigsBox;
  Box get _statesBox => _databaseService.progressionStatesBox;
  Box get _templatesBox => _databaseService.progressionTemplatesBox;

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

  /// Limpia los estados de progresión de configuraciones inactivas
  Future<void> cleanupInactiveProgressionStates() async {
    try {
      final allConfigs = _configsBox.values.cast<ProgressionConfig>();
      final activeConfigIds =
          allConfigs
              .where((config) => config.isActive)
              .map((config) => config.id)
              .toSet();

      final allStates = _statesBox.values.cast<ProgressionState>();
      final statesToDelete =
          allStates
              .where(
                (state) => !activeConfigIds.contains(state.progressionConfigId),
              )
              .toList();

      for (final state in statesToDelete) {
        await _statesBox.delete(state.id);
      }

      if (statesToDelete.isNotEmpty) {
        LoggingService.instance.info('Cleaned up inactive progression states', {
          'deletedCount': statesToDelete.length,
        });
      }
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error cleaning up inactive progression states',
        e,
        stackTrace,
      );
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

      // Calcular la semana actual basada en el número de sesiones
      // Asumiendo 3 sesiones por semana (configurable)
      final sessionsPerWeek = config.customParameters['sessions_per_week'] ?? 3;
      final newSession = state.currentSession + 1;
      final newWeek = ((newSession - 1) ~/ sessionsPerWeek) + 1;

      // Actualizar el estado de progresión
      final updatedState = state.copyWith(
        currentWeight: result.newWeight,
        currentReps: result.newReps,
        currentSets: result.newSets,
        currentSession: newSession,
        currentWeek: newWeek,
        lastUpdated: DateTime.now(),
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
      case ProgressionType.autoregulated:
        return _calculateAutoregulatedProgression(
          config,
          state,
          currentWeight,
          currentReps,
          currentSets,
        );
      case ProgressionType.doubleFactor:
        return _calculateDoubleFactorProgression(
          config,
          state,
          currentWeight,
          currentReps,
          currentSets,
        );
      case ProgressionType.overload:
        return _calculateOverloadProgression(
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
    // Calcular la sesión/semana actual en el ciclo según la unidad
    final currentInCycle =
        config.unit == ProgressionUnit.session
            ? ((state.currentSession - 1) % config.cycleLength) + 1
            : ((state.currentWeek - 1) % config.cycleLength) + 1;

    final isDeloadPeriod =
        config.deloadWeek > 0 && currentInCycle == config.deloadWeek;

    // Si es período de deload, aplicar deload
    if (isDeloadPeriod) {
      // Deload proporcional: reduce un porcentaje del aumento logrado desde el peso base
      // Ej.: base 100, actual 120, 90% => 100 + (20 * 0.9) = 118
      final double increaseOverBase = (currentWeight - state.baseWeight).clamp(
        0,
        double.infinity,
      );
      final double deloadWeight =
          state.baseWeight + (increaseOverBase * config.deloadPercentage);

      return ProgressionCalculationResult(
        newWeight: deloadWeight,
        newReps: currentReps,
        newSets: (currentSets * 0.7).round(),
        incrementApplied: true,
        reason:
            'Linear progression: deload ${config.unit.name} ($currentInCycle of ${config.cycleLength})',
      );
    }

    // Progresión lineal: incremento constante cada X períodos
    if (currentInCycle % config.incrementFrequency == 0) {
      return ProgressionCalculationResult(
        newWeight: currentWeight + config.incrementValue,
        newReps: currentReps,
        newSets: currentSets,
        incrementApplied: true,
        reason:
            'Linear progression: weight increased by ${config.incrementValue}kg (${config.unit.name} $currentInCycle of ${config.cycleLength})',
      );
    }

    return ProgressionCalculationResult(
      newWeight: currentWeight,
      newReps: currentReps,
      newSets: currentSets,
      incrementApplied: false,
      reason:
          'Linear progression: no increment this ${config.unit.name} ($currentInCycle of ${config.cycleLength})',
    );
  }

  ProgressionCalculationResult _calculateUndulatingProgression(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
  ) {
    // Calcular la semana actual en el ciclo
    final weekInCycle = ((state.currentWeek - 1) % config.cycleLength) + 1;
    final isDeloadWeek =
        config.deloadWeek > 0 && weekInCycle == config.deloadWeek;

    // Si es semana de deload, aplicar deload
    if (isDeloadWeek) {
      return ProgressionCalculationResult(
        newWeight: state.baseWeight * config.deloadPercentage,
        newReps: currentReps,
        newSets: (currentSets * 0.7).round(),
        incrementApplied: true,
        reason:
            'Undulating progression: deload week (week $weekInCycle of ${config.cycleLength})',
      );
    }

    // Progresión ondulante: alterna entre días pesados y ligeros
    final isHeavyDay = weekInCycle % 2 == 1;

    if (isHeavyDay) {
      // Día pesado: más peso, menos repeticiones
      return ProgressionCalculationResult(
        newWeight: currentWeight + (config.incrementValue * 0.5),
        newReps: (currentReps * 0.8).round(),
        newSets: currentSets,
        incrementApplied: true,
        reason:
            'Undulating progression: heavy day (week $weekInCycle of ${config.cycleLength})',
      );
    } else {
      // Día ligero: menos peso, más repeticiones
      return ProgressionCalculationResult(
        newWeight: currentWeight - (config.incrementValue * 0.5),
        newReps: (currentReps * 1.2).round(),
        newSets: currentSets,
        incrementApplied: true,
        reason:
            'Undulating progression: light day (week $weekInCycle of ${config.cycleLength})',
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
    // Calcular la semana actual en el ciclo
    final weekInCycle = ((state.currentWeek - 1) % config.cycleLength) + 1;
    final isDeloadWeek =
        config.deloadWeek > 0 && weekInCycle == config.deloadWeek;

    if (isDeloadWeek) {
      return ProgressionCalculationResult(
        newWeight: state.baseWeight * config.deloadPercentage,
        newReps: currentReps,
        newSets: (currentSets * 0.7).round(),
        incrementApplied: true,
        reason:
            'Stepped progression: deload week (week $weekInCycle of ${config.cycleLength})',
      );
    } else {
      // Progresión escalonada: acumula incrementos durante las semanas de acumulación
      final accumulationWeeks =
          config.customParameters['accumulation_weeks'] ?? 3;
      final totalIncrement =
          weekInCycle <= accumulationWeeks
              ? config.incrementValue * weekInCycle
              : config.incrementValue * accumulationWeeks;

      return ProgressionCalculationResult(
        newWeight: state.baseWeight + totalIncrement,
        newReps: currentReps,
        newSets: currentSets,
        incrementApplied: true,
        reason:
            'Stepped progression: accumulation phase (week $weekInCycle of ${config.cycleLength})',
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
    // Calcular el índice actual en el ciclo según la unidad configurada
    final currentInCycle =
        config.unit == ProgressionUnit.session
            ? ((state.currentSession - 1) % config.cycleLength) + 1
            : ((state.currentWeek - 1) % config.cycleLength) + 1;
    final isDeloadPeriod =
        config.deloadWeek > 0 && currentInCycle == config.deloadWeek;

    // Logs detallados para debugging
    LoggingService.instance.info('DOUBLE PROGRESSION CALCULATION', {
      'exerciseId': state.exerciseId,
      'currentWeek': state.currentWeek,
      'currentSession': state.currentSession,
      'unit': config.unit.name,
      'currentInCycle': currentInCycle,
      'cycleLength': config.cycleLength,
      'isDeloadPeriod': isDeloadPeriod,
      'deloadWeek': config.deloadWeek,
      'currentWeight': currentWeight,
      'currentReps': currentReps,
      'currentSets': currentSets,
      'baseWeight': state.baseWeight,
      'incrementValue': config.incrementValue,
      'maxReps': config.customParameters['max_reps'] ?? 12,
      'minReps': config.customParameters['min_reps'] ?? 5,
      'deloadPercentage': config.deloadPercentage,
    });

    // Si es período de deload, aplicar deload
    if (isDeloadPeriod) {
      final deloadWeight = state.baseWeight * config.deloadPercentage;
      final deloadSets = (currentSets * 0.7).round();

      LoggingService.instance.info('DOUBLE PROGRESSION: APPLYING DELOAD', {
        'exerciseId': state.exerciseId,
        'unit': config.unit.name,
        'currentInCycle': currentInCycle,
        'deloadWeight': deloadWeight,
        'deloadSets': deloadSets,
        'reason': 'Deload week reached',
      });

      return ProgressionCalculationResult(
        newWeight: deloadWeight,
        newReps: currentReps,
        newSets: deloadSets,
        incrementApplied: true,
        reason:
            'Double progression: deload ${config.unit.name} ($currentInCycle of ${config.cycleLength})',
      );
    }

    // Progresión doble: primero aumenta repeticiones, luego peso
    final maxReps = config.customParameters['max_reps'] ?? 12;
    final minReps = config.customParameters['min_reps'] ?? 5;

    if (currentReps < maxReps) {
      // Aumentar repeticiones
      LoggingService.instance.info('DOUBLE PROGRESSION: INCREASING REPS', {
        'exerciseId': state.exerciseId,
        'unit': config.unit.name,
        'currentInCycle': currentInCycle,
        'currentReps': currentReps,
        'newReps': currentReps + 1,
        'maxReps': maxReps,
        'weight': currentWeight,
        'reason': 'Reps below max threshold',
      });

      return ProgressionCalculationResult(
        newWeight: currentWeight,
        newReps: currentReps + 1,
        newSets: currentSets,
        incrementApplied: true,
        reason:
            'Double progression: increasing reps (${config.unit.name} $currentInCycle of ${config.cycleLength})',
      );
    } else {
      // Aumentar peso y resetear repeticiones
      final newWeight = currentWeight + config.incrementValue;

      LoggingService.instance
          .info('DOUBLE PROGRESSION: INCREASING WEIGHT & RESETTING REPS', {
            'exerciseId': state.exerciseId,
            'unit': config.unit.name,
            'currentInCycle': currentInCycle,
            'currentWeight': currentWeight,
            'newWeight': newWeight,
            'incrementValue': config.incrementValue,
            'currentReps': currentReps,
            'newReps': minReps,
            'maxReps': maxReps,
            'reason': 'Max reps reached, increasing weight and resetting reps',
          });

      return ProgressionCalculationResult(
        newWeight: newWeight,
        newReps: minReps,
        newSets: currentSets,
        incrementApplied: true,
        reason:
            'Double progression: increasing weight, resetting reps (${config.unit.name} $currentInCycle of ${config.cycleLength})',
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
    // Progresión por oleadas: usa el ciclo configurado
    final weekInCycle = ((state.currentWeek - 1) % config.cycleLength) + 1;

    switch (weekInCycle) {
      case 1: // Semana de alta intensidad
        return ProgressionCalculationResult(
          newWeight: currentWeight + config.incrementValue,
          newReps: (currentReps * 0.8).round(),
          newSets: currentSets,
          incrementApplied: true,
          reason:
              'Wave progression: high intensity week (week $weekInCycle of ${config.cycleLength})',
        );
      case 2: // Semana de alto volumen
        return ProgressionCalculationResult(
          newWeight: currentWeight - (config.incrementValue * 0.2),
          newReps: (currentReps * 1.3).round(),
          newSets: currentSets + 1,
          incrementApplied: true,
          reason:
              'Wave progression: high volume week (week $weekInCycle of ${config.cycleLength})',
        );
      case 3: // Semana de descarga
        return ProgressionCalculationResult(
          newWeight: state.baseWeight * config.deloadPercentage,
          newReps: currentReps,
          newSets: (currentSets * 0.7).round(),
          incrementApplied: true,
          reason:
              'Wave progression: deload week (week $weekInCycle of ${config.cycleLength})',
        );
      default:
        // Para ciclos más largos, aplicar progresión normal
        return ProgressionCalculationResult(
          newWeight: currentWeight + config.incrementValue,
          newReps: currentReps,
          newSets: currentSets,
          incrementApplied: true,
          reason:
              'Wave progression: normal progression (week $weekInCycle of ${config.cycleLength})',
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

  ProgressionCalculationResult _calculateAutoregulatedProgression(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
  ) {
    // Calcular la semana actual en el ciclo
    final weekInCycle = ((state.currentWeek - 1) % config.cycleLength) + 1;
    final isDeloadWeek =
        config.deloadWeek > 0 && weekInCycle == config.deloadWeek;

    // Si es semana de deload, aplicar deload
    if (isDeloadWeek) {
      return ProgressionCalculationResult(
        newWeight: state.baseWeight * config.deloadPercentage,
        newReps: currentReps,
        newSets: (currentSets * 0.7).round(),
        incrementApplied: true,
        reason:
            'Autoregulated progression: deload week (week $weekInCycle of ${config.cycleLength})',
      );
    }

    // Progresión autoregulada: ajusta basado en RPE/RIR
    // Calcula el RPE basado en las repeticiones realizadas vs objetivo

    final targetRPE = config.customParameters['target_rpe'] ?? 8.0;
    final rpeThreshold = config.customParameters['rpe_threshold'] ?? 0.5;
    final targetReps = config.customParameters['target_reps'] ?? 10;
    final maxReps = config.customParameters['max_reps'] ?? 12;
    final minReps = config.customParameters['min_reps'] ?? 5;

    // Obtener las repeticiones realizadas en la última sesión
    final lastSessionData =
        state.sessionHistory['session_${state.currentSession}'];
    final performedReps = lastSessionData?['reps'] ?? currentReps;

    // Calcular RPE estimado basado en repeticiones realizadas vs objetivo
    // Si realizó más repeticiones de las objetivo, RPE fue bajo
    // Si realizó menos repeticiones de las objetivo, RPE fue alto
    double estimatedRPE;
    if (performedReps >= targetReps) {
      // RPE bajo: pudo hacer más repeticiones de las objetivo
      estimatedRPE = targetRPE - ((performedReps - targetReps) * 0.5);
    } else {
      // RPE alto: no pudo completar las repeticiones objetivo
      estimatedRPE = targetRPE + ((targetReps - performedReps) * 0.8);
    }

    // Limitar RPE entre 1-10
    estimatedRPE = estimatedRPE.clamp(1.0, 10.0);

    // Si el RPE fue muy bajo, aumentar peso
    if (estimatedRPE < targetRPE - rpeThreshold) {
      return ProgressionCalculationResult(
        newWeight: currentWeight + config.incrementValue,
        newReps: currentReps,
        newSets: currentSets,
        incrementApplied: true,
        reason:
            'Autoregulated progression: RPE too low (${estimatedRPE.toStringAsFixed(1)}), increasing weight',
      );
    }
    // Si el RPE fue muy alto, reducir peso
    else if (estimatedRPE > targetRPE + rpeThreshold) {
      // Si las repeticiones están por debajo del mínimo, ajustarlas al mínimo
      final adjustedReps = currentReps < minReps ? minReps : currentReps;

      return ProgressionCalculationResult(
        newWeight: currentWeight - (config.incrementValue * 0.5),
        newReps: adjustedReps,
        newSets: currentSets,
        incrementApplied: true,
        reason:
            adjustedReps > currentReps
                ? 'Autoregulated progression: RPE too high (${estimatedRPE.toStringAsFixed(1)}), reducing weight and adjusting reps to minimum'
                : 'Autoregulated progression: RPE too high (${estimatedRPE.toStringAsFixed(1)}), reducing weight',
      );
    }
    // Si el RPE está en el rango objetivo, aumentar repeticiones (hasta el máximo)
    else {
      // Asegurar que las repeticiones estén al menos en el mínimo
      final baseReps = currentReps < minReps ? minReps : currentReps;
      final newReps = baseReps < maxReps ? baseReps + 1 : baseReps;

      return ProgressionCalculationResult(
        newWeight: currentWeight,
        newReps: newReps,
        newSets: currentSets,
        incrementApplied: newReps > currentReps,
        reason:
            newReps > currentReps
                ? 'Autoregulated progression: RPE optimal (${estimatedRPE.toStringAsFixed(1)}), increasing reps'
                : 'Autoregulated progression: RPE optimal (${estimatedRPE.toStringAsFixed(1)}), max reps reached',
      );
    }
  }

  ProgressionCalculationResult _calculateDoubleFactorProgression(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
  ) {
    // Calcular la semana actual en el ciclo
    final weekInCycle = ((state.currentWeek - 1) % config.cycleLength) + 1;
    final isDeloadWeek =
        config.deloadWeek > 0 && weekInCycle == config.deloadWeek;

    // Si es semana de deload, aplicar deload
    if (isDeloadWeek) {
      return ProgressionCalculationResult(
        newWeight: state.baseWeight * config.deloadPercentage,
        newReps: currentReps,
        newSets: (currentSets * 0.7).round(),
        incrementApplied: true,
        reason:
            'Double factor progression: deload week (week $weekInCycle of ${config.cycleLength})',
      );
    }

    // Progresión doble factor: balance entre fitness y fatiga
    final fitnessGain = config.customParameters['fitness_gain'] ?? 0.1;
    final fatigueDecay = config.customParameters['fatigue_decay'] ?? 0.05;

    // Simular fitness y fatiga acumulados
    final currentFitness = state.customData['fitness'] ?? 1.0;
    final currentFatigue = state.customData['fatigue'] ?? 0.0;

    final newFitness = currentFitness + fitnessGain;
    final newFatigue =
        (currentFatigue + fitnessGain * 0.8) * (1 - fatigueDecay);

    // Ajustar peso basado en la relación fitness/fatiga
    final fitnessFatigueRatio = newFitness / (1 + newFatigue);
    final weightMultiplier = fitnessFatigueRatio > 1.0 ? 1.05 : 0.95;

    return ProgressionCalculationResult(
      newWeight: currentWeight * weightMultiplier,
      newReps: currentReps,
      newSets: currentSets,
      incrementApplied: true,
      reason:
          'Double factor progression: fitness/fatigue ratio = ${fitnessFatigueRatio.toStringAsFixed(2)} (week $weekInCycle of ${config.cycleLength})',
    );
  }

  ProgressionCalculationResult _calculateOverloadProgression(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
  ) {
    // Calcular la semana actual en el ciclo
    final weekInCycle = ((state.currentWeek - 1) % config.cycleLength) + 1;
    final isDeloadWeek =
        config.deloadWeek > 0 && weekInCycle == config.deloadWeek;

    // Si es semana de deload, aplicar deload
    if (isDeloadWeek) {
      return ProgressionCalculationResult(
        newWeight: state.baseWeight * config.deloadPercentage,
        newReps: currentReps,
        newSets: (currentSets * 0.7).round(),
        incrementApplied: true,
        reason:
            'Overload progression: deload week (week $weekInCycle of ${config.cycleLength})',
      );
    }

    // Sobrecarga progresiva: incremento gradual de volumen o intensidad
    final overloadType = config.customParameters['overload_type'] ?? 'volume';
    final overloadRate = config.customParameters['overload_rate'] ?? 0.1;

    if (overloadType == 'volume') {
      // Aumentar volumen (series)
      return ProgressionCalculationResult(
        newWeight: currentWeight,
        newReps: currentReps,
        newSets: (currentSets * (1 + overloadRate)).round(),
        incrementApplied: true,
        reason:
            'Overload progression: increasing volume (sets) (week $weekInCycle of ${config.cycleLength})',
      );
    } else {
      // Aumentar intensidad (peso)
      return ProgressionCalculationResult(
        newWeight: currentWeight * (1 + overloadRate),
        newReps: currentReps,
        newSets: currentSets,
        incrementApplied: true,
        reason:
            'Overload progression: increasing intensity (weight) (week $weekInCycle of ${config.cycleLength})',
      );
    }
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
