import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/progression_config.dart';
import '../models/progression_state.dart';
import '../services/progression_service.dart';
import '../services/progression_template_service.dart';
import '../../../common/enums/progression_type_enum.dart';
import '../../../core/logging/logging.dart';

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
      final templateService = ref.read(
        progressionTemplateServiceProvider.notifier,
      );
      await templateService.initializeBuiltInTemplates();

      LoggingService.instance.info('Progression templates initialized');
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error initializing progression templates',
        e,
        stackTrace,
      );
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
        final progressionService = ref.read(
          progressionServiceProvider.notifier,
        );
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

      // Actualizar estado
      state = AsyncValue.data(newConfig);

      LoggingService.instance.info('Global progression set successfully', {
        'configId': newConfig.id,
        'type': type.name,
      });
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error setting global progression',
        e,
        stackTrace,
        {'type': type.name},
      );
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Desactiva la progresión actual
  Future<void> disableProgression() async {
    try {
      final currentConfig = await future;
      if (currentConfig != null) {
        final progressionService = ref.read(
          progressionServiceProvider.notifier,
        );
        final deactivatedConfig = currentConfig.copyWith(
          isActive: false,
          endDate: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await progressionService.saveProgressionConfig(deactivatedConfig);

        state = AsyncValue.data(null);

        LoggingService.instance.info('Global progression disabled', {
          'configId': currentConfig.id,
        });
      }
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error disabling global progression',
        e,
        stackTrace,
      );
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Obtiene el estado de progresión para un ejercicio específico
  Future<ProgressionState?> getExerciseProgressionState(
    String exerciseId,
  ) async {
    try {
      final config = await future;
      if (config == null) return null;

      final progressionService = ref.read(progressionServiceProvider.notifier);
      return await progressionService.getProgressionStateByExercise(
        config.id,
        exerciseId,
      );
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error getting exercise progression state',
        e,
        stackTrace,
        {'exerciseId': exerciseId},
      );
      return null;
    }
  }

  /// Inicializa el estado de progresión para un ejercicio
  Future<ProgressionState> initializeExerciseProgression({
    required String exerciseId,
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
      LoggingService.instance.error(
        'Error initializing exercise progression state',
        e,
        stackTrace,
        {'exerciseId': exerciseId},
      );
      rethrow;
    }
  }

  /// Calcula la progresión para un ejercicio
  Future<ProgressionCalculationResult?> calculateExerciseProgression({
    required String exerciseId,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
  }) async {
    try {
      final config = await future;
      if (config == null) return null;

      final progressionService = ref.read(progressionServiceProvider.notifier);
      return await progressionService.calculateProgression(
        config.id,
        exerciseId,
        currentWeight,
        currentReps,
        currentSets,
      );
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error calculating exercise progression',
        e,
        stackTrace,
        {'exerciseId': exerciseId},
      );
      return null;
    }
  }

  /// Verifica si hay una progresión activa
  bool get hasActiveProgression {
    return state.hasValue && state.value != null;
  }

  /// Obtiene el tipo de progresión activa
  ProgressionType? get activeProgressionType {
    return state.hasValue ? state.value?.type : null;
  }
}
