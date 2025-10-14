import '../../exercise/models/exercise.dart';

/// Configuración adaptable de rangos de repeticiones por tipo de ejercicio
class AdaptiveRepsConfig {
  final int multiJointMin;
  final int multiJointMax;
  final int isolationMin;
  final int isolationMax;

  const AdaptiveRepsConfig({
    required this.multiJointMin,
    required this.multiJointMax,
    required this.isolationMin,
    required this.isolationMax,
  });

  /// Deriva el rango de reps para un ejercicio concreto
  (int min, int max) rangeFor(Exercise exercise) {
    final isIsolation = exercise.exerciseType == ExerciseType.isolation;
    return isIsolation ? (isolationMin, isolationMax) : (multiJointMin, multiJointMax);
  }

  /// Construye desde `customParameters` de un preset, con valores por defecto razonables
  factory AdaptiveRepsConfig.fromCustomParams(Map<String, dynamic> params) {
    return AdaptiveRepsConfig(
      multiJointMin: (params['multi_reps_min'] as int?) ?? 6,
      multiJointMax: (params['multi_reps_max'] as int?) ?? 12,
      isolationMin: (params['iso_reps_min'] as int?) ?? 8,
      isolationMax: (params['iso_reps_max'] as int?) ?? 12,
    );
  }
}
