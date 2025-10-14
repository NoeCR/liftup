import 'package:liftly/features/progression/models/progression_calculation_result.dart';

import '../../../../common/enums/progression_type_enum.dart';
import '../../../features/exercise/models/exercise.dart';
import '../configs/adaptive_increment_config.dart';
import '../models/progression_config.dart';
import '../models/progression_state.dart';
import '../services/exercise_progression_config_service.dart';

/// Clase base para estrategias de progresión
///
/// Esta versión elimina la complejidad innecesaria y se enfoca en:
/// 1. Usar AdaptiveIncrementConfig como fuente principal de verdad
/// 2. Fallbacks simples y claros
/// 3. Métodos más limpios y mantenibles
abstract class BaseProgressionStrategy {
  // ===== MÉTODOS DE UTILIDAD BÁSICOS =====

  /// Calcula la posición actual en el ciclo (sesión o semana)
  int getCurrentInCycle(ProgressionConfig config, ProgressionState state) {
    final bool isSessionUnit = config.unit == ProgressionUnit.session;
    final int rawIndex = isSessionUnit ? state.currentSession : state.currentWeek;
    if (rawIndex <= 0) return 1;

    // Si cycleLength es 0, no hay ciclo (estrategias autoreguladas)
    if (config.cycleLength <= 0) return 1;

    return ((rawIndex - 1) % config.cycleLength) + 1;
  }

  /// Verifica si es período de deload
  bool isDeloadPeriod(ProgressionConfig config, int currentInCycle) {
    return config.deloadWeek > 0 && currentInCycle == config.deloadWeek;
  }

  /// Calcula la próxima sesión y semana
  ({int session, int week}) calculateNextSessionAndWeek({
    required ProgressionConfig config,
    required ProgressionState state,
  }) {
    final sessionsPerWeek = (config.customParameters['sessions_per_week'] ?? 3) as int;
    final newSession = state.currentSession + 1;
    final newWeek = ((newSession - 1) ~/ sessionsPerWeek) + 1;
    return (session: newSession, week: newWeek);
  }

  /// Verifica si la progresión está bloqueada
  bool isProgressionBlocked(ProgressionState state, String exerciseId, String routineId, bool isExerciseLocked) {
    // Verificar bloqueo por rutina completa
    final customData = state.customData;
    final skipNextByRoutine = customData['skip_next_by_routine'] as Map<String, dynamic>?;
    if (skipNextByRoutine?[routineId] == true) return true;

    // Verificar bloqueo por ejercicio específico
    return isExerciseLocked;
  }

  // ===== MÉTODOS DE CONFIGURACIÓN SIMPLIFICADOS =====

  /// Obtiene el valor de incremento de peso
  /// Prioridad: ExerciseProgressionConfig > AdaptiveIncrementConfig > config.incrementValue > 0
  Future<double> getIncrementValue(
    ProgressionConfig config,
    Exercise exercise,
    ExerciseProgressionConfigService? configService,
  ) async {
    // 1. Buscar configuración específica del ejercicio
    if (configService != null) {
      final exerciseConfig = await configService.getConfig(exercise.id, config.id);
      if (exerciseConfig?.hasCustomIncrement == true) {
        return exerciseConfig!.customIncrement!;
      }
    }

    // 2. Usar AdaptiveIncrementConfig (fuente principal de verdad)
    return config.getAdaptiveIncrement(exercise);
  }

  /// Deriva el nivel de experiencia de forma dinámica a partir del estado
  /// Si `adaptive_experience` no está habilitado en `customParameters`, retorna `ExperienceLevel.intermediate`.
  ExperienceLevel _deriveExperienceLevel(ProgressionConfig config, ProgressionState state) {
    final adaptiveEnabled = (config.customParameters['adaptive_experience'] == true);
    if (!adaptiveEnabled) return ExperienceLevel.intermediate;

    // Progreso total dentro de los ciclos (independiente de si es por semana o sesión)
    final currentInCycle = getCurrentInCycle(config, state);
    final totalUnitsElapsed =
        ((state.currentCycle - 1) * (config.cycleLength > 0 ? config.cycleLength : 1)) + currentInCycle;

    // Heurística:
    // - initiated: primeras 1x ciclo
    // - intermediate: hasta 3 ciclos completos
    // - advanced: más de 3 ciclos completos
    if (totalUnitsElapsed <= (config.cycleLength.clamp(1, 999999))) {
      return ExperienceLevel.initiated;
    }
    if (state.currentCycle <= 3) {
      return ExperienceLevel.intermediate;
    }
    return ExperienceLevel.advanced;
  }

  /// Versión síncrona, con soporte opcional para experiencia dinámica basada en estado
  double getIncrementValueSync(ProgressionConfig config, Exercise exercise, [ProgressionState? state]) {
    if (state != null && (config.customParameters['adaptive_experience'] == true)) {
      final level = _deriveExperienceLevel(config, state);
      // Usar AdaptiveIncrementConfig con nivel derivado
      return AdaptiveIncrementConfig.getRecommendedIncrement(exercise, level);
    }
    // Fallback: usar AdaptiveIncrementConfig directamente (que internamente usará intermedio por defecto) o incrementValue
    return config.getAdaptiveIncrement(exercise);
  }

  /// Obtiene el máximo de repeticiones
  /// Prioridad: ExerciseProgressionConfig > AdaptiveIncrementConfig > config.maxReps
  Future<int> getMaxReps(
    ProgressionConfig config,
    Exercise exercise,
    ExerciseProgressionConfigService? configService,
  ) async {
    // 1. Buscar configuración específica del ejercicio
    if (configService != null) {
      final exerciseConfig = await configService.getConfig(exercise.id, config.id);
      if (exerciseConfig?.hasCustomMaxReps == true) {
        return exerciseConfig!.customMaxReps!;
      }
    }

    // 2. Usar AdaptiveIncrementConfig
    return config.getAdaptiveMaxReps(exercise);
  }

  /// Versión síncrona para compatibilidad
  int getMaxRepsSync(ProgressionConfig config, Exercise exercise) {
    return config.getAdaptiveMaxReps(exercise);
  }

  /// Obtiene el mínimo de repeticiones
  /// Prioridad: ExerciseProgressionConfig > AdaptiveIncrementConfig > config.minReps
  Future<int> getMinReps(
    ProgressionConfig config,
    Exercise exercise,
    ExerciseProgressionConfigService? configService,
  ) async {
    // 1. Buscar configuración específica del ejercicio
    if (configService != null) {
      final exerciseConfig = await configService.getConfig(exercise.id, config.id);
      if (exerciseConfig?.hasCustomMinReps == true) {
        return exerciseConfig!.customMinReps!;
      }
    }

    // 2. Usar AdaptiveIncrementConfig
    return config.getAdaptiveMinReps(exercise);
  }

  /// Versión síncrona para compatibilidad
  int getMinRepsSync(ProgressionConfig config, Exercise exercise) {
    return config.getAdaptiveMinReps(exercise);
  }

  /// Obtiene las series base
  /// Prioridad: ExerciseProgressionConfig > AdaptiveIncrementConfig > config.baseSets
  Future<int> getBaseSets(
    ProgressionConfig config,
    Exercise exercise,
    ExerciseProgressionConfigService? configService,
  ) async {
    // 1. Buscar configuración específica del ejercicio
    if (configService != null) {
      final exerciseConfig = await configService.getConfig(exercise.id, config.id);
      if (exerciseConfig?.hasCustomBaseSets == true) {
        return exerciseConfig!.customBaseSets!;
      }
    }

    // 2. Usar AdaptiveIncrementConfig
    return config.getAdaptiveBaseSets(exercise);
  }

  /// Versión síncrona para compatibilidad
  int getBaseSetsSync(ProgressionConfig config, Exercise exercise) {
    return config.getAdaptiveBaseSets(exercise);
  }

  // ===== MÉTODOS DE DELOAD SIMPLIFICADOS =====

  /// Aplica deload estándar
  /// Reduce el peso manteniendo el incremento sobre el peso base
  ProgressionCalculationResult applyStandardDeload({
    required ProgressionConfig config,
    required ProgressionState state,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
    required int currentInCycle,
    required Exercise exercise,
  }) {
    // Calcular peso de deload manteniendo incremento sobre base
    final double increaseOverBase = (currentWeight - state.baseWeight).clamp(0, double.infinity);
    final double deloadWeight = state.baseWeight + (increaseOverBase * config.deloadPercentage);

    // Calcular series de deload (70% de las series base)
    final int baseSets = getBaseSetsSync(config, exercise);
    final int deloadSets = (baseSets * 0.7).round();

    return ProgressionCalculationResult(
      newWeight: deloadWeight,
      newReps: currentReps,
      newSets: deloadSets,
      incrementApplied: true,
      isDeload: true,
      shouldResetCycle: false,
      reason: 'Deload session (week $currentInCycle of ${config.cycleLength})',
    );
  }

  // ===== MÉTODOS DE VALIDACIÓN =====

  /// Valida que los parámetros de progresión sean válidos
  bool validateProgressionParams(ProgressionConfig config) {
    return config.minReps > 0 &&
        config.maxReps > 0 &&
        config.minReps <= config.maxReps &&
        config.baseSets > 0 &&
        config.cycleLength > 0 &&
        config.deloadPercentage > 0 &&
        config.deloadPercentage <= 1.0;
  }

  /// Valida que el estado de progresión sea válido
  bool validateProgressionState(ProgressionState state) {
    return state.currentWeight >= 0 && state.currentReps > 0 && state.currentSets > 0 && state.currentSession > 0;
  }

  // ===== MÉTODOS DE UTILIDAD PARA ESTRATEGIAS =====

  /// Crea un resultado de progresión estándar
  ProgressionCalculationResult createProgressionResult({
    required double newWeight,
    required int newReps,
    required int newSets,
    required bool incrementApplied,
    required String reason,
    bool isDeload = false,
    bool shouldResetCycle = false,
  }) {
    return ProgressionCalculationResult(
      newWeight: newWeight,
      newReps: newReps,
      newSets: newSets,
      incrementApplied: incrementApplied,
      isDeload: isDeload,
      shouldResetCycle: shouldResetCycle,
      reason: reason,
    );
  }

  /// Crea un resultado de progresión bloqueada
  ProgressionCalculationResult createBlockedResult({
    required double currentWeight,
    required int currentReps,
    required int currentSets,
    required String reason,
  }) {
    return ProgressionCalculationResult(
      newWeight: currentWeight,
      newReps: currentReps,
      newSets: currentSets,
      incrementApplied: false,
      isDeload: false,
      shouldResetCycle: false,
      reason: reason,
    );
  }

  /// Verifica si se debe aplicar progresión en esta sesión
  bool shouldApplyProgression(ProgressionConfig config, int currentInCycle) {
    // Aplicar progresión cada incrementFrequency sesiones
    return currentInCycle % config.incrementFrequency == 0;
  }

  /// Calcula el incremento de series si es aplicable
  int? calculateSeriesIncrement(ProgressionConfig config, Exercise exercise) {
    final seriesIncrement = config.getAdaptiveSeriesIncrement(exercise);
    return seriesIncrement > 0 ? seriesIncrement : null;
  }
}
