import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/enums/progression_type_enum.dart';
import '../../../core/logging/logging.dart';
import '../../../features/exercise/models/exercise.dart';
import '../models/progression_calculation_result.dart';
import '../models/progression_config.dart';
import '../models/progression_state.dart';
import '../services/progression_service.dart';
import '../services/progression_template_service.dart';

part 'progression_notifier.g.dart';

@riverpod
class ProgressionNotifier extends _$ProgressionNotifier {
  @override
  Future<ProgressionConfig?> build() async {
    final progressionService = ref.read(progressionServiceProvider.notifier);
    return await progressionService.getActiveProgressionConfig();
  }

  /// Inicializa las plantillas predefinidas si no existen
  Future<void> initializeTemplates() async {
    try {
      final templateService = ref.read(progressionTemplateServiceProvider.notifier);
      await templateService.initializeBuiltInTemplates();

      LoggingService.instance.info('Progression templates initialized');
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error initializing progression templates', e, stackTrace);
      rethrow;
    }
  }

  /// Restaura todas las plantillas integradas (útil después de limpiar la base de datos)
  Future<void> restoreTemplates() async {
    try {
      final templateService = ref.read(progressionTemplateServiceProvider.notifier);
      await templateService.restoreBuiltInTemplates();

      // Invalidar el provider para que se recarguen las plantillas
      ref.invalidate(progressionTemplateServiceProvider);

      LoggingService.instance.info('Progression templates restored');
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error restoring progression templates', e, stackTrace);
      rethrow;
    }
  }

  /// Configura una nueva progresión global
  Future<void> setProgression({
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
      // Desactivar progresión actual si existe
      final currentConfig = await future;
      if (currentConfig != null) {
        final progressionService = ref.read(progressionServiceProvider.notifier);
        final deactivatedConfig = currentConfig.copyWith(
          isActive: false,
          endDate: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await progressionService.saveProgressionConfig(deactivatedConfig);
      }

      // Crear nueva configuración
      final progressionService = ref.read(progressionServiceProvider.notifier);
      final newConfig = await progressionService.initializeProgression(
        type: type,
        unit: unit,
        primaryTarget: primaryTarget,
        secondaryTarget: secondaryTarget,
        incrementValue: incrementValue,
        incrementFrequency: incrementFrequency,
        cycleLength: cycleLength,
        deloadWeek: deloadWeek,
        deloadPercentage: deloadPercentage,
        customParameters: customParameters,
      );

      // Limpiar estados de configuraciones inactivas
      await progressionService.cleanupInactiveProgressionStates();

      // Actualizar estado
      state = AsyncValue.data(newConfig);

      LoggingService.instance.info('Global progression set successfully', {
        'configId': newConfig.id,
        'type': type.name,
      });
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error setting global progression', e, stackTrace, {'type': type.name});
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Desactiva la progresión actual
  Future<void> disableProgression() async {
    try {
      final currentConfig = await future;
      if (currentConfig != null) {
        final progressionService = ref.read(progressionServiceProvider.notifier);
        final deactivatedConfig = currentConfig.copyWith(
          isActive: false,
          endDate: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await progressionService.saveProgressionConfig(deactivatedConfig);

        state = AsyncValue.data(null);

        LoggingService.instance.info('Global progression disabled', {'configId': currentConfig.id});
      }
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error disabling global progression', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Obtiene el estado de progresión para un ejercicio específico
  Future<ProgressionState?> getExerciseProgressionState(String exerciseId, String routineId) async {
    try {
      final config = await future;
      if (config == null) return null;

      final progressionService = ref.read(progressionServiceProvider.notifier);
      return await progressionService.getProgressionStateByExercise(config.id, exerciseId, routineId);
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error getting exercise progression state', e, stackTrace, {
        'exerciseId': exerciseId,
        'routineId': routineId,
      });
      return null;
    }
  }

  /// Inicializa el estado de progresión para un ejercicio
  Future<ProgressionState> initializeExerciseProgression({
    required String exerciseId,
    required String routineId,
    required double baseWeight,
    required int baseReps,
    required int baseSets,
    double? oneRepMax,
  }) async {
    try {
      final config = await future;
      if (config == null) {
        throw Exception('No active progression configuration found');
      }

      final progressionService = ref.read(progressionServiceProvider.notifier);
      final state = await progressionService.initializeExerciseProgression(
        configId: config.id,
        exerciseId: exerciseId,
        routineId: routineId,
        baseWeight: baseWeight,
        baseReps: baseReps,
        baseSets: baseSets,
        oneRepMax: oneRepMax,
      );

      LoggingService.instance.info('Exercise progression state initialized', {
        'exerciseId': exerciseId,
        'baseWeight': baseWeight,
      });

      return state;
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error initializing exercise progression state', e, stackTrace, {
        'exerciseId': exerciseId,
      });
      rethrow;
    }
  }

  /// Calcula la progresión para un ejercicio
  Future<ProgressionCalculationResult?> calculateExerciseProgression({
    required String exerciseId,
    required String routineId,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
    ExerciseType? exerciseType,
  }) async {
    try {
      final config = await future;
      if (config == null) return null;

      final progressionService = ref.read(progressionServiceProvider.notifier);
      return await progressionService.calculateProgression(
        config.id,
        exerciseId,
        routineId,
        currentWeight,
        currentReps,
        currentSets,
        exerciseType: exerciseType,
      );
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error calculating exercise progression', e, stackTrace, {
        'exerciseId': exerciseId,
      });
      return null;
    }
  }

  /// Marca/Desmarca que se omita la progresión en la próxima sesión para TODA la rutina
  /// Almacena en customData del ProgressionState un mapa: { 'skip_next_by_routine': { 'routineId': true/false } }
  Future<void> setSkipNextProgressionForRoutine({
    required String routineId,
    required List<String> exerciseIds,
    required bool skip,
  }) async {
    try {
      final config = await future;
      if (config == null) return;

      final progressionService = ref.read(progressionServiceProvider.notifier);

      for (final exerciseId in exerciseIds) {
        final state = await progressionService.getProgressionStateByExercise(config.id, exerciseId, routineId);
        if (state == null) continue;

        final existing = Map<String, dynamic>.from(state.customData);
        final updated = updateSkipNextByRoutineMap(existing, routineId, skip);

        final updatedState = state.copyWith(customData: updated);
        await progressionService.saveProgressionState(updatedState);
      }
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error setting skip_next_progression flag for routine', e, stackTrace, {
        'routineId': routineId,
        'exerciseIds': exerciseIds,
      });
    }
  }

  /// Marca/Desmarca que se omita la progresión en la próxima sesión para ejercicios específicos
  /// Almacena en customData del ProgressionState un mapa: { 'skip_next_by_exercise': { 'exerciseId': { 'routineId': true/false } } }
  Future<void> setSkipNextProgressionForExercises({
    required String routineId,
    required List<String> exerciseIds,
    required bool skip,
  }) async {
    try {
      final config = await future;
      if (config == null) return;

      final progressionService = ref.read(progressionServiceProvider.notifier);

      for (final exerciseId in exerciseIds) {
        final state = await progressionService.getProgressionStateByExercise(config.id, exerciseId, routineId);
        if (state == null) continue;

        final existing = Map<String, dynamic>.from(state.customData);
        final updated = updateSkipNextByExerciseMap(existing, exerciseId, routineId, skip);

        final updatedState = state.copyWith(customData: updated);
        await progressionService.saveProgressionState(updatedState);
      }
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error setting skip_next_progression flag for exercises', e, stackTrace, {
        'routineId': routineId,
        'exerciseIds': exerciseIds,
      });
    }
  }

  /// Verifica si hay una progresión activa
  bool get hasActiveProgression {
    return state.hasValue && state.value != null && state.value!.isActive;
  }

  /// Obtiene el tipo de progresión activa
  ProgressionType? get activeProgressionType {
    return state.hasValue ? state.value?.type : null;
  }
}

/// Helper pure function to update the skip_next_by_routine structure
Map<String, dynamic> updateSkipNextByRoutineMap(Map<String, dynamic> customData, String routineId, bool skip) {
  final next = Map<String, dynamic>.from(customData);
  final byRoutine = Map<String, dynamic>.from((next['skip_next_by_routine'] as Map?) ?? const {});
  if (skip) {
    byRoutine[routineId] = true;
  } else {
    byRoutine.remove(routineId);
  }
  next['skip_next_by_routine'] = byRoutine;
  return next;
}

/// Helper pure function to update the skip_next_by_exercise structure
Map<String, dynamic> updateSkipNextByExerciseMap(
  Map<String, dynamic> customData,
  String exerciseId,
  String routineId,
  bool skip,
) {
  final next = Map<String, dynamic>.from(customData);
  final byExercise = Map<String, dynamic>.from((next['skip_next_by_exercise'] as Map?) ?? const {});

  final exerciseData = Map<String, dynamic>.from((byExercise[exerciseId] as Map?) ?? const {});

  if (skip) {
    exerciseData[routineId] = true;
  } else {
    exerciseData.remove(routineId);
  }

  byExercise[exerciseId] = exerciseData;
  next['skip_next_by_exercise'] = byExercise;
  return next;
}
