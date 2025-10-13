import 'package:hive/hive.dart';

import '../models/exercise_progression_config.dart';

/// Servicio para gestionar configuraciones de progresión específicas por ejercicio
class ExerciseProgressionConfigService {
  static const String _boxName = 'exercise_progression_configs';
  late Box<ExerciseProgressionConfig> _box;

  /// Inicializa el servicio
  Future<void> init() async {
    _box = await Hive.openBox<ExerciseProgressionConfig>(_boxName);
  }

  /// Obtiene la configuración de progresión para un ejercicio específico
  Future<ExerciseProgressionConfig?> getConfig(
    String exerciseId,
    String progressionConfigId,
  ) async {
    try {
      return _box.values.firstWhere(
        (config) =>
            config.exerciseId == exerciseId &&
            config.progressionConfigId == progressionConfigId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Guarda o actualiza la configuración de progresión para un ejercicio
  Future<void> saveConfig(ExerciseProgressionConfig config) async {
    await _box.put(config.id, config);
  }

  /// Elimina la configuración de progresión para un ejercicio
  Future<void> deleteConfig(
    String exerciseId,
    String progressionConfigId,
  ) async {
    final config = await getConfig(exerciseId, progressionConfigId);
    if (config != null) {
      await _box.delete(config.id);
    }
  }

  /// Obtiene todas las configuraciones para un ejercicio
  Future<List<ExerciseProgressionConfig>> getConfigsForExercise(
    String exerciseId,
  ) async {
    return _box.values
        .where((config) => config.exerciseId == exerciseId)
        .toList();
  }

  /// Obtiene todas las configuraciones para una progresión
  Future<List<ExerciseProgressionConfig>> getConfigsForProgression(
    String progressionConfigId,
  ) async {
    return _box.values
        .where((config) => config.progressionConfigId == progressionConfigId)
        .toList();
  }

  /// Migra datos de per_exercise a ExerciseProgressionConfig
  Future<void> migrateFromPerExercise(
    Map<String, dynamic> perExerciseData,
    String progressionConfigId,
  ) async {
    for (final entry in perExerciseData.entries) {
      final exerciseId = entry.key;
      final exerciseData = entry.value as Map<String, dynamic>?;

      if (exerciseData != null) {
        final config = ExerciseProgressionConfig(
          id: '${exerciseId}_$progressionConfigId',
          exerciseId: exerciseId,
          progressionConfigId: progressionConfigId,
          customIncrement: exerciseData['increment_value'] as double?,
          customMinReps: exerciseData['min_reps'] as int?,
          customMaxReps: exerciseData['max_reps'] as int?,
          customBaseSets: exerciseData['base_sets'] as int?,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await saveConfig(config);
      }
    }
  }

  /// Cierra el servicio
  Future<void> close() async {
    await _box.close();
  }
}
