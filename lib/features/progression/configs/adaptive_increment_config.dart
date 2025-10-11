import '../../exercise/models/exercise.dart';

/// Configuración de incrementos adaptativos basados en el tipo de ejercicio y carga
///
/// Este sistema determina los incrementos de peso apropiados según:
/// - ExerciseType (multiJoint vs isolation)
/// - LoadType (barbell, dumbbell, machine, etc.)
///
/// Los incrementos se basan en la evidencia científica y las mejores prácticas
/// de entrenamiento de fuerza.
class AdaptiveIncrementConfig {
  /// Configuración de incrementos por tipo de ejercicio y carga
  static const Map<ExerciseType, Map<LoadType, IncrementRange>> _incrementConfig = {
    ExerciseType.multiJoint: {
      LoadType.barbell: IncrementRange(min: 5.0, max: 7.0, defaultValue: 5.0),
      LoadType.dumbbell: IncrementRange(min: 2.5, max: 5.0, defaultValue: 2.5),
      LoadType.machine: IncrementRange(min: 5.0, max: 10.0, defaultValue: 5.0),
      LoadType.cable: IncrementRange(min: 2.5, max: 5.0, defaultValue: 2.5),
      LoadType.kettlebell: IncrementRange(min: 4.0, max: 8.0, defaultValue: 4.0),
      LoadType.plate: IncrementRange(min: 5.0, max: 10.0, defaultValue: 5.0),
      LoadType.bodyweight: IncrementRange(min: 0.0, max: 0.0, defaultValue: 0.0), // Sin incremento de peso
      LoadType.resistanceBand: IncrementRange(min: 0.0, max: 0.0, defaultValue: 0.0), // Sin incremento de peso
    },
    ExerciseType.isolation: {
      LoadType.barbell: IncrementRange(min: 2.5, max: 5.0, defaultValue: 2.5),
      LoadType.dumbbell: IncrementRange(min: 1.25, max: 2.5, defaultValue: 1.25),
      LoadType.machine: IncrementRange(min: 2.5, max: 5.0, defaultValue: 2.5),
      LoadType.cable: IncrementRange(min: 1.25, max: 2.5, defaultValue: 1.25),
      LoadType.kettlebell: IncrementRange(min: 2.0, max: 4.0, defaultValue: 2.0),
      LoadType.plate: IncrementRange(min: 2.5, max: 5.0, defaultValue: 2.5),
      LoadType.bodyweight: IncrementRange(min: 0.0, max: 0.0, defaultValue: 0.0), // Sin incremento de peso
      LoadType.resistanceBand: IncrementRange(min: 0.0, max: 0.0, defaultValue: 0.0), // Sin incremento de peso
    },
  };

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
  static double getRecommendedIncrement(Exercise exercise, ExperienceLevel level) {
    final range = getIncrementRange(exercise);
    if (range == null) return 2.5;

    switch (level) {
      case ExperienceLevel.beginner:
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
}

/// Rango de incrementos para un tipo específico de ejercicio y carga
class IncrementRange {
  final double min;
  final double max;
  final double defaultValue;

  const IncrementRange({required this.min, required this.max, required this.defaultValue});

  @override
  String toString() {
    return 'IncrementRange(min: $min, max: $max, defaultValue: $defaultValue)';
  }
}

/// Nivel de experiencia del usuario
enum ExperienceLevel {
  beginner('Principiante'),
  intermediate('Intermedio'),
  advanced('Avanzado');

  const ExperienceLevel(this.displayName);

  final String displayName;
}
