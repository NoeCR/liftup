import '../../exercise/models/exercise.dart';
import '../models/exercise_progression_config.dart' as epc;
import 'training_objective.dart';

/// Configuración de incrementos adaptativos basados en el tipo de ejercicio y carga
///
/// Este sistema determina los incrementos de peso y series apropiados según:
/// - ExerciseType (multiJoint vs isolation)
/// - LoadType (barbell, dumbbell, machine, etc.)
///
/// Los incrementos se basan en la evidencia científica y las mejores prácticas
/// de entrenamiento de fuerza.
class AdaptiveIncrementConfig {
  /// Configuración de incrementos de peso por tipo de ejercicio y carga
  static const Map<ExerciseType, Map<LoadType, IncrementRange>>
  _incrementConfig = {
    ExerciseType.multiJoint: {
      LoadType.barbell: IncrementRange(min: 5.0, max: 7.0, defaultValue: 5.0),
      LoadType.dumbbell: IncrementRange(min: 2.5, max: 5.0, defaultValue: 2.5),
      LoadType.machine: IncrementRange(min: 5.0, max: 10.0, defaultValue: 5.0),
      LoadType.cable: IncrementRange(min: 2.5, max: 5.0, defaultValue: 2.5),
      LoadType.kettlebell: IncrementRange(
        min: 4.0,
        max: 8.0,
        defaultValue: 4.0,
      ),
      LoadType.plate: IncrementRange(min: 5.0, max: 10.0, defaultValue: 5.0),
      LoadType.bodyweight: IncrementRange(
        min: 0.0,
        max: 0.0,
        defaultValue: 0.0,
      ), // Sin incremento de peso por defecto
      LoadType.resistanceBand: IncrementRange(
        min: 0.0,
        max: 0.0,
        defaultValue: 0.0,
      ), // Sin incremento de peso por defecto
    },
    ExerciseType.isolation: {
      LoadType.barbell: IncrementRange(min: 2.5, max: 5.0, defaultValue: 2.5),
      LoadType.dumbbell: IncrementRange(
        min: 1.25,
        max: 2.5,
        defaultValue: 1.25,
      ),
      LoadType.machine: IncrementRange(min: 2.5, max: 5.0, defaultValue: 2.5),
      LoadType.cable: IncrementRange(min: 1.25, max: 2.5, defaultValue: 1.25),
      LoadType.kettlebell: IncrementRange(
        min: 2.0,
        max: 4.0,
        defaultValue: 2.0,
      ),
      LoadType.plate: IncrementRange(min: 2.5, max: 5.0, defaultValue: 2.5),
      LoadType.bodyweight: IncrementRange(
        min: 0.0,
        max: 0.0,
        defaultValue: 0.0,
      ), // Sin incremento de peso por defecto
      LoadType.resistanceBand: IncrementRange(
        min: 0.0,
        max: 0.0,
        defaultValue: 0.0,
      ), // Sin incremento de peso por defecto
    },
  };

  /// Configuración base de rangos de SERIES por objetivo, tipo de ejercicio y carga
  /// Estos valores establecen mínimos/máximos coherentes por objetivo; los presets
  /// pueden sobreescribirlos vía customParameters (sets_min/sets_max).
  static const Map<TrainingObjective, Map<ExerciseType, Map<LoadType, SeriesIncrementRange>>> _objectiveSeriesConfig = {
    // Fuerza
    TrainingObjective.strength: {
      ExerciseType.multiJoint: {
        LoadType.barbell: SeriesIncrementRange(min: 3, max: 5, defaultValue: 4),
        LoadType.dumbbell: SeriesIncrementRange(min: 3, max: 5, defaultValue: 4),
        LoadType.machine: SeriesIncrementRange(min: 3, max: 5, defaultValue: 4),
        LoadType.cable: SeriesIncrementRange(min: 2, max: 4, defaultValue: 3),
        LoadType.kettlebell: SeriesIncrementRange(min: 3, max: 5, defaultValue: 4),
        LoadType.plate: SeriesIncrementRange(min: 3, max: 5, defaultValue: 4),
        LoadType.bodyweight: SeriesIncrementRange(min: 2, max: 4, defaultValue: 3),
        LoadType.resistanceBand: SeriesIncrementRange(min: 2, max: 4, defaultValue: 3),
      },
      ExerciseType.isolation: {
        LoadType.barbell: SeriesIncrementRange(min: 2, max: 4, defaultValue: 3),
        LoadType.dumbbell: SeriesIncrementRange(min: 2, max: 4, defaultValue: 3),
        LoadType.machine: SeriesIncrementRange(min: 2, max: 4, defaultValue: 3),
        LoadType.cable: SeriesIncrementRange(min: 2, max: 4, defaultValue: 3),
        LoadType.kettlebell: SeriesIncrementRange(min: 2, max: 4, defaultValue: 3),
        LoadType.plate: SeriesIncrementRange(min: 2, max: 4, defaultValue: 3),
        LoadType.bodyweight: SeriesIncrementRange(min: 2, max: 4, defaultValue: 3),
        LoadType.resistanceBand: SeriesIncrementRange(min: 2, max: 4, defaultValue: 3),
      },
    },
    // Hipertrofia
    TrainingObjective.hypertrophy: {
      ExerciseType.multiJoint: {
        LoadType.barbell: SeriesIncrementRange(min: 3, max: 5, defaultValue: 4),
        LoadType.dumbbell: SeriesIncrementRange(min: 3, max: 5, defaultValue: 4),
        LoadType.machine: SeriesIncrementRange(min: 3, max: 5, defaultValue: 4),
        LoadType.cable: SeriesIncrementRange(min: 3, max: 4, defaultValue: 3),
        LoadType.kettlebell: SeriesIncrementRange(min: 3, max: 5, defaultValue: 4),
        LoadType.plate: SeriesIncrementRange(min: 3, max: 5, defaultValue: 4),
        LoadType.bodyweight: SeriesIncrementRange(min: 3, max: 5, defaultValue: 4),
        LoadType.resistanceBand: SeriesIncrementRange(min: 3, max: 5, defaultValue: 4),
      },
      ExerciseType.isolation: {
        LoadType.barbell: SeriesIncrementRange(min: 3, max: 4, defaultValue: 3),
        LoadType.dumbbell: SeriesIncrementRange(min: 3, max: 4, defaultValue: 3),
        LoadType.machine: SeriesIncrementRange(min: 3, max: 4, defaultValue: 3),
        LoadType.cable: SeriesIncrementRange(min: 3, max: 4, defaultValue: 3),
        LoadType.kettlebell: SeriesIncrementRange(min: 3, max: 4, defaultValue: 3),
        LoadType.plate: SeriesIncrementRange(min: 3, max: 4, defaultValue: 3),
        LoadType.bodyweight: SeriesIncrementRange(min: 3, max: 4, defaultValue: 3),
        LoadType.resistanceBand: SeriesIncrementRange(min: 3, max: 4, defaultValue: 3),
      },
    },
    // Resistencia
    TrainingObjective.endurance: {
      ExerciseType.multiJoint: {
        LoadType.barbell: SeriesIncrementRange(min: 2, max: 4, defaultValue: 3),
        LoadType.dumbbell: SeriesIncrementRange(min: 2, max: 4, defaultValue: 3),
        LoadType.machine: SeriesIncrementRange(min: 2, max: 4, defaultValue: 3),
        LoadType.cable: SeriesIncrementRange(min: 2, max: 4, defaultValue: 3),
        LoadType.kettlebell: SeriesIncrementRange(min: 2, max: 4, defaultValue: 3),
        LoadType.plate: SeriesIncrementRange(min: 2, max: 4, defaultValue: 3),
        LoadType.bodyweight: SeriesIncrementRange(min: 2, max: 5, defaultValue: 3),
        LoadType.resistanceBand: SeriesIncrementRange(min: 2, max: 5, defaultValue: 3),
      },
      ExerciseType.isolation: {
        LoadType.barbell: SeriesIncrementRange(min: 2, max: 3, defaultValue: 2),
        LoadType.dumbbell: SeriesIncrementRange(min: 2, max: 3, defaultValue: 2),
        LoadType.machine: SeriesIncrementRange(min: 2, max: 3, defaultValue: 2),
        LoadType.cable: SeriesIncrementRange(min: 2, max: 3, defaultValue: 2),
        LoadType.kettlebell: SeriesIncrementRange(min: 2, max: 3, defaultValue: 2),
        LoadType.plate: SeriesIncrementRange(min: 2, max: 3, defaultValue: 2),
        LoadType.bodyweight: SeriesIncrementRange(min: 2, max: 4, defaultValue: 2),
        LoadType.resistanceBand: SeriesIncrementRange(min: 2, max: 4, defaultValue: 2),
      },
    },
    // Potencia
    TrainingObjective.power: {
      ExerciseType.multiJoint: {
        LoadType.barbell: SeriesIncrementRange(min: 3, max: 6, defaultValue: 4),
        LoadType.dumbbell: SeriesIncrementRange(min: 3, max: 5, defaultValue: 4),
        LoadType.machine: SeriesIncrementRange(min: 3, max: 5, defaultValue: 4),
        LoadType.cable: SeriesIncrementRange(min: 2, max: 4, defaultValue: 3),
        LoadType.kettlebell: SeriesIncrementRange(min: 3, max: 6, defaultValue: 4),
        LoadType.plate: SeriesIncrementRange(min: 3, max: 6, defaultValue: 4),
        LoadType.bodyweight: SeriesIncrementRange(min: 3, max: 6, defaultValue: 4),
        LoadType.resistanceBand: SeriesIncrementRange(min: 3, max: 6, defaultValue: 4),
      },
      ExerciseType.isolation: {
        LoadType.barbell: SeriesIncrementRange(min: 2, max: 3, defaultValue: 2),
        LoadType.dumbbell: SeriesIncrementRange(min: 2, max: 3, defaultValue: 2),
        LoadType.machine: SeriesIncrementRange(min: 2, max: 3, defaultValue: 2),
        LoadType.cable: SeriesIncrementRange(min: 2, max: 3, defaultValue: 2),
        LoadType.kettlebell: SeriesIncrementRange(min: 2, max: 3, defaultValue: 2),
        LoadType.plate: SeriesIncrementRange(min: 2, max: 3, defaultValue: 2),
        LoadType.bodyweight: SeriesIncrementRange(min: 2, max: 3, defaultValue: 2),
        LoadType.resistanceBand: SeriesIncrementRange(min: 2, max: 3, defaultValue: 2),
      },
    },
  };

  /// Configuración de incrementos de series por tipo de ejercicio y carga
  /// Estos valores están optimizados para diferentes objetivos de entrenamiento
  static const Map<ExerciseType, Map<LoadType, SeriesIncrementRange>>
  _seriesIncrementConfig = {
    ExerciseType.multiJoint: {
      LoadType.barbell: SeriesIncrementRange(min: 1, max: 2, defaultValue: 1),
      LoadType.dumbbell: SeriesIncrementRange(min: 1, max: 2, defaultValue: 1),
      LoadType.machine: SeriesIncrementRange(
        min: 1,
        max: 3,
        defaultValue: 2,
      ), // Mayor flexibilidad para máquinas
      LoadType.cable: SeriesIncrementRange(min: 1, max: 2, defaultValue: 1),
      LoadType.kettlebell: SeriesIncrementRange(
        min: 1,
        max: 2,
        defaultValue: 1,
      ),
      LoadType.plate: SeriesIncrementRange(min: 1, max: 2, defaultValue: 1),
      LoadType.bodyweight: SeriesIncrementRange(
        min: 1,
        max: 3,
        defaultValue: 2, // Mayor flexibilidad para peso corporal
      ),
      LoadType.resistanceBand: SeriesIncrementRange(
        min: 1,
        max: 3,
        defaultValue: 2, // Mayor flexibilidad para bandas
      ),
    },
    ExerciseType.isolation: {
      LoadType.barbell: SeriesIncrementRange(min: 1, max: 2, defaultValue: 1),
      LoadType.dumbbell: SeriesIncrementRange(min: 1, max: 2, defaultValue: 1),
      LoadType.machine: SeriesIncrementRange(
        min: 1,
        max: 3,
        defaultValue: 2,
      ), // Mayor flexibilidad para máquinas
      LoadType.cable: SeriesIncrementRange(min: 1, max: 2, defaultValue: 1),
      LoadType.kettlebell: SeriesIncrementRange(
        min: 1,
        max: 2,
        defaultValue: 1,
      ),
      LoadType.plate: SeriesIncrementRange(min: 1, max: 2, defaultValue: 1),
      LoadType.bodyweight: SeriesIncrementRange(
        min: 1,
        max: 3,
        defaultValue: 2, // Mayor flexibilidad para peso corporal
      ),
      LoadType.resistanceBand: SeriesIncrementRange(
        min: 1,
        max: 3,
        defaultValue: 2, // Mayor flexibilidad para bandas
      ),
    },
  };

  // Repeticiones: ahora derivadas en tiempo de ejecución en getRepetitionsRange

  /// Obtiene el incremento por defecto para un ejercicio específico
  static double getDefaultIncrement(Exercise exercise) {
    final range = _incrementConfig[exercise.exerciseType]?[exercise.loadType];
    return range?.defaultValue ?? 2.5; // Fallback por defecto
  }

  /// Obtiene el incremento mínimo para un ejercicio específico
  static double getMinIncrement(Exercise exercise) {
    final range = _incrementConfig[exercise.exerciseType]?[exercise.loadType];
    return range?.min ?? 1.25; // Fallback por defecto
  }

  /// Obtiene el incremento máximo para un ejercicio específico
  static double getMaxIncrement(Exercise exercise) {
    final range = _incrementConfig[exercise.exerciseType]?[exercise.loadType];
    return range?.max ?? 5.0; // Fallback por defecto
  }

  /// Obtiene el rango completo de incrementos para un ejercicio específico
  static IncrementRange? getIncrementRange(Exercise exercise) {
    return _incrementConfig[exercise.exerciseType]?[exercise.loadType];
  }

  /// Obtiene el incremento recomendado basado en el nivel de experiencia
  static double getRecommendedIncrement(
    Exercise exercise,
    ExperienceLevel level,
  ) {
    final range = getIncrementRange(exercise);
    if (range == null) return 2.5;

    switch (level) {
      case ExperienceLevel.initiated:
        return range.min;
      case ExperienceLevel.intermediate:
        return (range.min + range.max) / 2;
      case ExperienceLevel.advanced:
        return range.max;
    }
  }

  /// Verifica si un incremento es válido para un ejercicio específico
  static bool isValidIncrement(Exercise exercise, double increment) {
    final range = getIncrementRange(exercise);
    if (range == null) return true; // Si no hay restricciones, es válido

    return increment >= range.min && increment <= range.max;
  }

  /// Obtiene una descripción del rango de incrementos para un ejercicio
  static String getIncrementDescription(Exercise exercise) {
    final range = getIncrementRange(exercise);
    if (range == null) return 'Incremento personalizable';

    if (range.min == 0.0 && range.max == 0.0) {
      return 'Sin incremento de peso (ejercicio de peso corporal o banda elástica)';
    }

    if (range.min == range.max) {
      return 'Incremento fijo: ${range.defaultValue} kg';
    }

    return 'Rango recomendado: ${range.min}-${range.max} kg (por defecto: ${range.defaultValue} kg)';
  }

  /// Obtiene todos los tipos de carga que soportan incrementos de peso
  static List<LoadType> getLoadTypesWithWeightIncrement() {
    return LoadType.values.where((loadType) {
      // Verificar si al menos un tipo de ejercicio tiene incremento > 0
      for (final exerciseType in ExerciseType.values) {
        final range = _incrementConfig[exerciseType]?[loadType];
        if (range != null && range.max > 0) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  /// Obtiene todos los tipos de carga que NO soportan incrementos de peso
  static List<LoadType> getLoadTypesWithoutWeightIncrement() {
    return LoadType.values.where((loadType) {
      // Verificar si todos los tipos de ejercicio tienen incremento = 0
      for (final exerciseType in ExerciseType.values) {
        final range = _incrementConfig[exerciseType]?[loadType];
        if (range != null && range.max > 0) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // ===== MÉTODOS PARA INCREMENTOS DE SERIES =====

  /// Obtiene el incremento de series por defecto para un ejercicio específico
  static int getDefaultSeriesIncrement(Exercise exercise) {
    final range =
        _seriesIncrementConfig[exercise.exerciseType]?[exercise.loadType];
    return range?.defaultValue ?? 1; // Fallback por defecto
  }

  /// Obtiene el incremento mínimo de series para un ejercicio específico
  static int getMinSeriesIncrement(Exercise exercise) {
    final range =
        _seriesIncrementConfig[exercise.exerciseType]?[exercise.loadType];
    return range?.min ?? 1; // Fallback por defecto
  }

  /// Obtiene el incremento máximo de series para un ejercicio específico
  static int getMaxSeriesIncrement(Exercise exercise) {
    final range =
        _seriesIncrementConfig[exercise.exerciseType]?[exercise.loadType];
    return range?.max ?? 2; // Fallback por defecto
  }

  /// Obtiene el rango completo de incrementos de series para un ejercicio específico
  static SeriesIncrementRange? getSeriesIncrementRange(Exercise exercise) {
    return _seriesIncrementConfig[exercise.exerciseType]?[exercise.loadType];
  }

  /// Obtiene el incremento de series recomendado basado en el nivel de experiencia
  static int getRecommendedSeriesIncrement(
    Exercise exercise,
    ExperienceLevel level,
  ) {
    final range = getSeriesIncrementRange(exercise);
    if (range == null) return 1;

    switch (level) {
      case ExperienceLevel.initiated:
        return range.min;
      case ExperienceLevel.intermediate:
        return (range.min + range.max) ~/ 2;
      case ExperienceLevel.advanced:
        return range.max;
    }
  }

  /// Verifica si un incremento de series es válido para un ejercicio específico
  static bool isValidSeriesIncrement(Exercise exercise, int increment) {
    final range = getSeriesIncrementRange(exercise);
    if (range == null) return true; // Si no hay restricciones, es válido

    return increment >= range.min && increment <= range.max;
  }

  /// Obtiene una descripción del rango de incrementos de series para un ejercicio
  static String getSeriesIncrementDescription(Exercise exercise) {
    final range = getSeriesIncrementRange(exercise);
    if (range == null) return 'Incremento de series personalizable';

    if (range.min == range.max) {
      return 'Incremento de series fijo: ${range.defaultValue} serie(s)';
    }

    return 'Rango de incremento de series: ${range.min}-${range.max} serie(s) (por defecto: ${range.defaultValue} serie(s))';
  }

  // ===== MÉTODOS PARA REPETICIONES =====

  /// Obtiene el rango de repeticiones a usar combinando objetivo del preset y overrides en customParameters
  static (int min, int max) getRepetitionsRange(
    Exercise exercise, {
    Map<String, dynamic>? customParameters,
  }) {
    // En esta versión, si vienen overrides de preset se respetan; si no, fallback simple según tipo
    int min = exercise.exerciseType == ExerciseType.multiJoint ? 8 : 8;
    int max = exercise.exerciseType == ExerciseType.multiJoint ? 15 : 12;

    if (customParameters != null) {
      final overrideMin =
          (exercise.exerciseType == ExerciseType.multiJoint)
              ? (customParameters['multi_reps_min'] as int?)
              : (customParameters['iso_reps_min'] as int?);
      final overrideMax =
          (exercise.exerciseType == ExerciseType.multiJoint)
              ? (customParameters['multi_reps_max'] as int?)
              : (customParameters['iso_reps_max'] as int?);
      if (overrideMin != null) min = overrideMin;
      if (overrideMax != null) max = overrideMax;
    }

    if (min > max) {
      final tmp = min;
      min = max;
      max = tmp;
    }
    return (min, max);
  }

  // ===== MÉTODOS PARA SERIES POR OBJETIVO =====

  /// Devuelve el rango de series según objetivo + overrides de preset.
  static SeriesIncrementRange getSeriesRangeByObjective(
    Exercise exercise, {
    required TrainingObjective objective,
    Map<String, dynamic>? customParameters,
  }) {
    final base = _objectiveSeriesConfig[objective]?[exercise.exerciseType]?[exercise.loadType];
    var min = base?.min ?? getMinSeriesIncrement(exercise);
    var max = base?.max ?? getMaxSeriesIncrement(exercise);
    var def = base?.defaultValue ?? getDefaultSeriesIncrement(exercise);

    // Overrides del preset
    final setsMin = customParameters?['sets_min'] as int?;
    final setsMax = customParameters?['sets_max'] as int?;
    if (setsMin != null) min = setsMin;
    if (setsMax != null) max = setsMax;
    if (min > max) {
      final t = min; min = max; max = t;
    }
    if (def < min) def = min; if (def > max) def = max;

    return SeriesIncrementRange(min: min, max: max, defaultValue: def);
  }

  static int getMinBaseSetsByObjective(
    Exercise exercise, {
    required TrainingObjective objective,
    Map<String, dynamic>? customParameters,
  }) => getSeriesRangeByObjective(
        exercise,
        objective: objective,
        customParameters: customParameters,
      ).min;

  static int getMaxBaseSetsByObjective(
    Exercise exercise, {
    required TrainingObjective objective,
    Map<String, dynamic>? customParameters,
  }) => getSeriesRangeByObjective(
        exercise,
        objective: objective,
        customParameters: customParameters,
      ).max;

  /// Obtiene las repeticiones mínimas recomendadas, considerando `customParameters` si existen.
  static int getMinRepetitions(
    Exercise exercise, {
    Map<String, dynamic>? customParameters,
  }) {
    final (min, _) = getRepetitionsRange(
      exercise,
      customParameters: customParameters,
    );
    return min;
  }

  /// Obtiene las repeticiones máximas recomendadas, considerando `customParameters` si existen.
  static int getMaxRepetitions(
    Exercise exercise, {
    Map<String, dynamic>? customParameters,
  }) {
    final (_, max) = getRepetitionsRange(
      exercise,
      customParameters: customParameters,
    );
    return max;
  }

  /// Obtiene todos los tipos de carga que soportan incrementos de series
  static List<LoadType> getLoadTypesWithSeriesIncrement() {
    return LoadType.values.where((loadType) {
      // Verificar si al menos un tipo de ejercicio tiene incremento de series > 0
      for (final exerciseType in ExerciseType.values) {
        final range = _seriesIncrementConfig[exerciseType]?[loadType];
        if (range != null && range.max > 0) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  /// Obtiene todos los tipos de carga que NO soportan incrementos de series
  static List<LoadType> getLoadTypesWithoutSeriesIncrement() {
    return LoadType.values.where((loadType) {
      // Verificar si todos los tipos de ejercicio tienen incremento de series = 0
      for (final exerciseType in ExerciseType.values) {
        final range = _seriesIncrementConfig[exerciseType]?[loadType];
        if (range != null && range.max > 0) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}

/// Rango de incrementos para un tipo específico de ejercicio y carga
class IncrementRange {
  final double min;
  final double max;
  final double defaultValue;

  const IncrementRange({
    required this.min,
    required this.max,
    required this.defaultValue,
  });

  @override
  String toString() {
    return 'IncrementRange(min: $min, max: $max, defaultValue: $defaultValue)';
  }
}

/// Rango de incrementos de series para un tipo específico de ejercicio y carga
class SeriesIncrementRange {
  final int min;
  final int max;
  final int defaultValue;

  const SeriesIncrementRange({
    required this.min,
    required this.max,
    required this.defaultValue,
  });

  @override
  String toString() {
    return 'SeriesIncrementRange(min: $min, max: $max, defaultValue: $defaultValue)';
  }
}

/// Rango de repeticiones por tipo de ejercicio
class RepsRange {
  final int min;
  final int max;
  final int defaultMin;

  const RepsRange({
    required this.min,
    required this.max,
    required this.defaultMin,
  });

  @override
  String toString() {
    return 'RepsRange(min: $min, max: $max, defaultMin: $defaultMin)';
  }
}

/// Nivel de experiencia del usuario
/// Lógica: initiated (grandes incrementos) → advanced (pequeños incrementos)
enum ExperienceLevel {
  initiated('Iniciado', 'Puedes progresar rápidamente'),
  intermediate('Intermedio', 'Progresión moderada'),
  advanced('Avanzado', 'Progresión lenta, cerca del límite');

  const ExperienceLevel(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Obtiene el factor de incremento (1.0 = normal, >1.0 = más rápido, <1.0 = más lento)
  double get incrementFactor {
    switch (this) {
      case ExperienceLevel.initiated:
        return 1.5; // 50% más rápido
      case ExperienceLevel.intermediate:
        return 1.0; // Normal
      case ExperienceLevel.advanced:
        return 0.5; // 50% más lento
    }
  }
}

/// Extensiones para soportar ExerciseProgressionConfig
extension AdaptiveIncrementConfigExtensions on AdaptiveIncrementConfig {
  /// Obtiene el incremento recomendado considerando ExerciseProgressionConfig
  static double getRecommendedIncrementWithConfig(
    Exercise exercise,
    epc.ExerciseProgressionConfig? exerciseConfig,
    ExperienceLevel defaultExperienceLevel,
  ) {
    // 1. Si hay configuración personalizada, usarla
    if (exerciseConfig?.hasCustomIncrement == true) {
      return exerciseConfig!.customIncrement!;
    }

    // 2. Usar ExperienceLevel del ejercicio o el por defecto
    final experienceLevel =
        exerciseConfig?.experienceLevel != null
            ? ExperienceLevel.values.firstWhere(
              (e) => e.name == exerciseConfig!.experienceLevel!.name,
              orElse: () => defaultExperienceLevel,
            )
            : defaultExperienceLevel;

    // 3. Obtener incremento base y aplicar factor de experiencia
    final baseIncrement = AdaptiveIncrementConfig.getRecommendedIncrement(
      exercise,
      experienceLevel,
    );
    return baseIncrement * experienceLevel.incrementFactor;
  }

  /// Obtiene las repeticiones mínimas considerando ExerciseProgressionConfig
  static int getMinRepsWithConfig(
    Exercise exercise,
    epc.ExerciseProgressionConfig? exerciseConfig,
    int defaultMinReps,
  ) {
    return exerciseConfig?.customMinReps ?? defaultMinReps;
  }

  /// Obtiene las repeticiones máximas considerando ExerciseProgressionConfig
  static int getMaxRepsWithConfig(
    Exercise exercise,
    epc.ExerciseProgressionConfig? exerciseConfig,
    int defaultMaxReps,
  ) {
    return exerciseConfig?.customMaxReps ?? defaultMaxReps;
  }

  /// Obtiene las series base considerando ExerciseProgressionConfig
  static int getBaseSetsWithConfig(
    Exercise exercise,
    epc.ExerciseProgressionConfig? exerciseConfig,
    int defaultBaseSets,
  ) {
    return exerciseConfig?.customBaseSets ?? defaultBaseSets;
  }
}
