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
  /// Configuración de incrementos de peso por OBJETIVO, tipo de ejercicio y carga
  /// Se alinea al formato de `_objectiveSeriesConfig` para facilitar la eliminación
  /// de `customParameters` en el futuro. Por ahora, los valores son equivalentes
  /// a `_incrementConfig` para todos los objetivos (comportamiento estable).
  static const Map<
    TrainingObjective,
    Map<ExerciseType, Map<LoadType, IncrementRange>>
  >
  _objectiveIncrementConfig = {
    TrainingObjective.strength: {
      ExerciseType.multiJoint: {
        LoadType.barbell: IncrementRange(min: 5.0, max: 7.5, defaultValue: 5.0),
        LoadType.dumbbell: IncrementRange(
          min: 2.5,
          max: 5.0,
          defaultValue: 2.5,
        ),
        LoadType.machine: IncrementRange(
          min: 5.0,
          max: 10.0,
          defaultValue: 5.0,
        ),
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
        ),
        LoadType.resistanceBand: IncrementRange(
          min: 0.0,
          max: 0.0,
          defaultValue: 0.0,
        ),
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
        ),
        LoadType.resistanceBand: IncrementRange(
          min: 0.0,
          max: 0.0,
          defaultValue: 0.0,
        ),
      },
    },
    TrainingObjective.hypertrophy: {
      ExerciseType.multiJoint: {
        LoadType.barbell: IncrementRange(min: 2.5, max: 5.0, defaultValue: 2.5),
        LoadType.dumbbell: IncrementRange(
          min: 1.25,
          max: 2.5,
          defaultValue: 1.25,
        ),
        LoadType.machine: IncrementRange(min: 2.5, max: 7.5, defaultValue: 2.5),
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
        ),
        LoadType.resistanceBand: IncrementRange(
          min: 0.0,
          max: 0.0,
          defaultValue: 0.0,
        ),
      },
      ExerciseType.isolation: {
        LoadType.barbell: IncrementRange(min: 2.5, max: 5.0, defaultValue: 2.5),
        LoadType.dumbbell: IncrementRange(
          min: 1.25,
          max: 2.0,
          defaultValue: 1.25,
        ),
        LoadType.machine: IncrementRange(min: 2.0, max: 4.0, defaultValue: 2.0),
        LoadType.cable: IncrementRange(min: 1.25, max: 2.0, defaultValue: 1.25),
        LoadType.kettlebell: IncrementRange(
          min: 2.0,
          max: 3.0,
          defaultValue: 2.0,
        ),
        LoadType.plate: IncrementRange(min: 2.5, max: 5.0, defaultValue: 2.5),
        LoadType.bodyweight: IncrementRange(
          min: 0.0,
          max: 0.0,
          defaultValue: 0.0,
        ),
        LoadType.resistanceBand: IncrementRange(
          min: 0.0,
          max: 0.0,
          defaultValue: 0.0,
        ),
      },
    },
    TrainingObjective.endurance: {
      ExerciseType.multiJoint: {
        LoadType.barbell: IncrementRange(
          min: 1.25,
          max: 2.5,
          defaultValue: 1.25,
        ),
        LoadType.dumbbell: IncrementRange(
          min: 1.25,
          max: 2.0,
          defaultValue: 1.25,
        ),
        LoadType.machine: IncrementRange(
          min: 1.25,
          max: 2.5,
          defaultValue: 1.25,
        ),
        LoadType.cable: IncrementRange(min: 1.25, max: 2.0, defaultValue: 1.25),
        LoadType.kettlebell: IncrementRange(
          min: 2.0,
          max: 3.0,
          defaultValue: 2.0,
        ),
        LoadType.plate: IncrementRange(min: 2.5, max: 5.0, defaultValue: 2.5),
        LoadType.bodyweight: IncrementRange(
          min: 0.0,
          max: 0.0,
          defaultValue: 0.0,
        ),
        LoadType.resistanceBand: IncrementRange(
          min: 0.0,
          max: 0.0,
          defaultValue: 0.0,
        ),
      },
      ExerciseType.isolation: {
        LoadType.barbell: IncrementRange(
          min: 1.25,
          max: 2.5,
          defaultValue: 1.25,
        ),
        LoadType.dumbbell: IncrementRange(
          min: 1.25,
          max: 1.25,
          defaultValue: 1.25,
        ),
        LoadType.machine: IncrementRange(
          min: 1.25,
          max: 2.0,
          defaultValue: 1.25,
        ),
        LoadType.cable: IncrementRange(min: 1.25, max: 1.5, defaultValue: 1.25),
        LoadType.kettlebell: IncrementRange(
          min: 2.0,
          max: 2.5,
          defaultValue: 2.0,
        ),
        LoadType.plate: IncrementRange(min: 2.5, max: 5.0, defaultValue: 2.5),
        LoadType.bodyweight: IncrementRange(
          min: 0.0,
          max: 0.0,
          defaultValue: 0.0,
        ),
        LoadType.resistanceBand: IncrementRange(
          min: 0.0,
          max: 0.0,
          defaultValue: 0.0,
        ),
      },
    },
    TrainingObjective.power: {
      ExerciseType.multiJoint: {
        LoadType.barbell: IncrementRange(
          min: 5.0,
          max: 10.0,
          defaultValue: 5.0,
        ),
        LoadType.dumbbell: IncrementRange(
          min: 2.5,
          max: 5.0,
          defaultValue: 2.5,
        ),
        LoadType.machine: IncrementRange(
          min: 5.0,
          max: 10.0,
          defaultValue: 5.0,
        ),
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
        ),
        LoadType.resistanceBand: IncrementRange(
          min: 0.0,
          max: 0.0,
          defaultValue: 0.0,
        ),
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
        ),
        LoadType.resistanceBand: IncrementRange(
          min: 0.0,
          max: 0.0,
          defaultValue: 0.0,
        ),
      },
    },
  };

  // Eliminado: _incrementConfig sustituido por _objectiveIncrementConfig

  /// Configuración base de rangos de SERIES por objetivo, tipo de ejercicio y carga
  /// Estos valores establecen mínimos/máximos coherentes por objetivo; los presets
  /// pueden sobreescribirlos vía customParameters (sets_min/sets_max).
  static const Map<
    TrainingObjective,
    Map<ExerciseType, Map<LoadType, SeriesIncrementRange>>
  >
  _objectiveSeriesConfig = {
    // FUERZA: Series moderadas para maximizar adaptación neural
    TrainingObjective.strength: {
      ExerciseType.multiJoint: {
        LoadType.barbell: SeriesIncrementRange(
          min: 4,
          max: 6,
          defaultValue: 5,
        ), // 4-6 series para fuerza máxima
        LoadType.dumbbell: SeriesIncrementRange(
          min: 3,
          max: 5,
          defaultValue: 4, // Menos series por inestabilidad
        ),
        LoadType.machine: SeriesIncrementRange(
          min: 4,
          max: 6,
          defaultValue: 5,
        ), // Estable, más series
        LoadType.cable: SeriesIncrementRange(
          min: 3,
          max: 5,
          defaultValue: 4,
        ), // Moderado
        LoadType.kettlebell: SeriesIncrementRange(
          min: 3,
          max: 5,
          defaultValue: 4, // Moderado por naturaleza balística
        ),
        LoadType.plate: SeriesIncrementRange(
          min: 4,
          max: 6,
          defaultValue: 5,
        ), // Estándar para fuerza
        LoadType.bodyweight: SeriesIncrementRange(
          min: 3,
          max: 5,
          defaultValue: 4, // Moderado para peso corporal
        ),
        LoadType.resistanceBand: SeriesIncrementRange(
          min: 3,
          max: 5,
          defaultValue: 4, // Moderado
        ),
      },
      ExerciseType.isolation: {
        LoadType.barbell: SeriesIncrementRange(
          min: 3,
          max: 5,
          defaultValue: 4,
        ), // Menos series para aislamiento
        LoadType.dumbbell: SeriesIncrementRange(
          min: 3,
          max: 4,
          defaultValue: 3, // Conservador por inestabilidad
        ),
        LoadType.machine: SeriesIncrementRange(
          min: 3,
          max: 5,
          defaultValue: 4,
        ), // Moderado
        LoadType.cable: SeriesIncrementRange(
          min: 3,
          max: 4,
          defaultValue: 3,
        ), // Conservador
        LoadType.kettlebell: SeriesIncrementRange(
          min: 2,
          max: 4,
          defaultValue: 3, // Conservador para aislamiento
        ),
        LoadType.plate: SeriesIncrementRange(
          min: 3,
          max: 4,
          defaultValue: 3,
        ), // Conservador
        LoadType.bodyweight: SeriesIncrementRange(
          min: 3,
          max: 4,
          defaultValue: 3, // Conservador
        ),
        LoadType.resistanceBand: SeriesIncrementRange(
          min: 3,
          max: 4,
          defaultValue: 3, // Conservador
        ),
      },
    },
    // HIPERTROFIA: Series moderadas-altas para máximo crecimiento muscular
    TrainingObjective.hypertrophy: {
      ExerciseType.multiJoint: {
        LoadType.barbell: SeriesIncrementRange(
          min: 3,
          max: 5,
          defaultValue: 4,
        ), // 3-5 series para hipertrofia
        LoadType.dumbbell: SeriesIncrementRange(
          min: 3,
          max: 5,
          defaultValue: 4, // Igual que barbell
        ),
        LoadType.machine: SeriesIncrementRange(
          min: 3,
          max: 5,
          defaultValue: 4,
        ), // Estable
        LoadType.cable: SeriesIncrementRange(
          min: 3,
          max: 4,
          defaultValue: 3,
        ), // Moderado
        LoadType.kettlebell: SeriesIncrementRange(
          min: 3,
          max: 5,
          defaultValue: 4, // Moderado
        ),
        LoadType.plate: SeriesIncrementRange(
          min: 3,
          max: 5,
          defaultValue: 4,
        ), // Estándar
        LoadType.bodyweight: SeriesIncrementRange(
          min: 3,
          max: 5,
          defaultValue: 4, // Moderado para peso corporal
        ),
        LoadType.resistanceBand: SeriesIncrementRange(
          min: 3,
          max: 5,
          defaultValue: 4, // Moderado
        ),
      },
      ExerciseType.isolation: {
        LoadType.barbell: SeriesIncrementRange(
          min: 3,
          max: 4,
          defaultValue: 3,
        ), // Menos series para aislamiento
        LoadType.dumbbell: SeriesIncrementRange(
          min: 3,
          max: 4,
          defaultValue: 3, // Conservador por inestabilidad
        ),
        LoadType.machine: SeriesIncrementRange(
          min: 3,
          max: 4,
          defaultValue: 3,
        ), // Moderado
        LoadType.cable: SeriesIncrementRange(
          min: 3,
          max: 4,
          defaultValue: 3,
        ), // Conservador
        LoadType.kettlebell: SeriesIncrementRange(
          min: 3,
          max: 4,
          defaultValue: 3, // Conservador para aislamiento
        ),
        LoadType.plate: SeriesIncrementRange(
          min: 3,
          max: 4,
          defaultValue: 3,
        ), // Conservador
        LoadType.bodyweight: SeriesIncrementRange(
          min: 3,
          max: 4,
          defaultValue: 3, // Conservador
        ),
        LoadType.resistanceBand: SeriesIncrementRange(
          min: 3,
          max: 4,
          defaultValue: 3, // Conservador
        ),
      },
    },
    // RESISTENCIA: Series bajas para mantener intensidad de resistencia
    TrainingObjective.endurance: {
      ExerciseType.multiJoint: {
        LoadType.barbell: SeriesIncrementRange(
          min: 2,
          max: 3,
          defaultValue: 2,
        ), // Pocas series para resistencia
        LoadType.dumbbell: SeriesIncrementRange(
          min: 2,
          max: 3,
          defaultValue: 2, // Pocas series por inestabilidad
        ),
        LoadType.machine: SeriesIncrementRange(
          min: 2,
          max: 3,
          defaultValue: 2,
        ), // Pocas series
        LoadType.cable: SeriesIncrementRange(
          min: 2,
          max: 3,
          defaultValue: 2,
        ), // Pocas series
        LoadType.kettlebell: SeriesIncrementRange(
          min: 2,
          max: 3,
          defaultValue: 2, // Pocas series para resistencia
        ),
        LoadType.plate: SeriesIncrementRange(
          min: 2,
          max: 3,
          defaultValue: 2,
        ), // Pocas series
        LoadType.bodyweight: SeriesIncrementRange(
          min: 2,
          max: 4,
          defaultValue: 3, // Más series para peso corporal
        ),
        LoadType.resistanceBand: SeriesIncrementRange(
          min: 2,
          max: 4,
          defaultValue: 3, // Más series para bandas
        ),
      },
      ExerciseType.isolation: {
        LoadType.barbell: SeriesIncrementRange(
          min: 2,
          max: 3,
          defaultValue: 2,
        ), // Muy pocas series
        LoadType.dumbbell: SeriesIncrementRange(
          min: 2,
          max: 3,
          defaultValue: 2, // Muy pocas series
        ),
        LoadType.machine: SeriesIncrementRange(
          min: 2,
          max: 3,
          defaultValue: 2,
        ), // Muy pocas series
        LoadType.cable: SeriesIncrementRange(
          min: 2,
          max: 3,
          defaultValue: 2,
        ), // Muy pocas series
        LoadType.kettlebell: SeriesIncrementRange(
          min: 2,
          max: 3,
          defaultValue: 2, // Muy pocas series
        ),
        LoadType.plate: SeriesIncrementRange(
          min: 2,
          max: 3,
          defaultValue: 2,
        ), // Muy pocas series
        LoadType.bodyweight: SeriesIncrementRange(
          min: 2,
          max: 3,
          defaultValue: 2, // Muy pocas series
        ),
        LoadType.resistanceBand: SeriesIncrementRange(
          min: 2,
          max: 3,
          defaultValue: 2, // Muy pocas series
        ),
      },
    },
    // POTENCIA: Series altas para maximizar potencia explosiva
    TrainingObjective.power: {
      ExerciseType.multiJoint: {
        LoadType.barbell: SeriesIncrementRange(
          min: 4,
          max: 8,
          defaultValue: 6,
        ), // Muchas series para potencia
        LoadType.dumbbell: SeriesIncrementRange(
          min: 3,
          max: 6,
          defaultValue: 4, // Menos series por inestabilidad
        ),
        LoadType.machine: SeriesIncrementRange(
          min: 4,
          max: 8,
          defaultValue: 6,
        ), // Muchas series
        LoadType.cable: SeriesIncrementRange(
          min: 3,
          max: 6,
          defaultValue: 4,
        ), // Moderado
        LoadType.kettlebell: SeriesIncrementRange(
          min: 4,
          max: 8,
          defaultValue: 6, // Muchas series para potencia
        ),
        LoadType.plate: SeriesIncrementRange(
          min: 4,
          max: 8,
          defaultValue: 6,
        ), // Muchas series
        LoadType.bodyweight: SeriesIncrementRange(
          min: 4,
          max: 8,
          defaultValue: 6, // Muchas series para peso corporal
        ),
        LoadType.resistanceBand: SeriesIncrementRange(
          min: 4,
          max: 8,
          defaultValue: 6, // Muchas series
        ),
      },
      ExerciseType.isolation: {
        LoadType.barbell: SeriesIncrementRange(
          min: 3,
          max: 5,
          defaultValue: 4,
        ), // Moderado para aislamiento
        LoadType.dumbbell: SeriesIncrementRange(
          min: 3,
          max: 4,
          defaultValue: 3, // Conservador por inestabilidad
        ),
        LoadType.machine: SeriesIncrementRange(
          min: 3,
          max: 5,
          defaultValue: 4,
        ), // Moderado
        LoadType.cable: SeriesIncrementRange(
          min: 3,
          max: 4,
          defaultValue: 3,
        ), // Conservador
        LoadType.kettlebell: SeriesIncrementRange(
          min: 3,
          max: 4,
          defaultValue: 3, // Conservador para aislamiento
        ),
        LoadType.plate: SeriesIncrementRange(
          min: 3,
          max: 4,
          defaultValue: 3,
        ), // Conservador
        LoadType.bodyweight: SeriesIncrementRange(
          min: 3,
          max: 5,
          defaultValue: 4, // Moderado
        ),
        LoadType.resistanceBand: SeriesIncrementRange(
          min: 3,
          max: 5,
          defaultValue: 4, // Moderado
        ),
      },
    },
  };

  /// Configuración base de tiempos de descanso por objetivo y tipo de ejercicio (segundos)
  /// Configuración OPTIMIZADA de tiempo de descanso por objetivo y tipo de ejercicio (segundos)
  /// Basada en investigación científica para maximizar adaptaciones específicas
  static const Map<TrainingObjective, Map<ExerciseType, int>>
  _objectiveRestSeconds = {
    TrainingObjective.strength: {
      ExerciseType.multiJoint:
          240, // 4 min - Recuperación completa del sistema nervioso
      ExerciseType.isolation:
          180, // 3 min - Recuperación parcial para ejercicios auxiliares
    },
    TrainingObjective.hypertrophy: {
      ExerciseType.multiJoint:
          120, // 2 min - Recuperación metabólica para volumen
      ExerciseType.isolation:
          90, // 1.5 min - Recuperación más rápida para aislamiento
    },
    TrainingObjective.endurance: {
      ExerciseType.multiJoint:
          60, // 1 min - Recuperación mínima para resistencia
      ExerciseType.isolation:
          45, // 45 seg - Recuperación muy corta para resistencia
    },
    TrainingObjective.power: {
      ExerciseType.multiJoint:
          300, // 5 min - Recuperación completa para potencia máxima
      ExerciseType.isolation:
          180, // 3 min - Recuperación para ejercicios auxiliares
    },
  };

  /// Configuración de incrementos de series por OBJETIVO, tipo de ejercicio y carga
  static const Map<
    TrainingObjective,
    Map<ExerciseType, Map<LoadType, SeriesIncrementRange>>
  >
  _objectiveSeriesIncrementConfig = {
    TrainingObjective.strength: {
      ExerciseType.multiJoint: {
        LoadType.barbell: SeriesIncrementRange(min: 1, max: 2, defaultValue: 1),
        LoadType.dumbbell: SeriesIncrementRange(
          min: 1,
          max: 2,
          defaultValue: 1,
        ),
        LoadType.machine: SeriesIncrementRange(min: 1, max: 3, defaultValue: 2),
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
          defaultValue: 2,
        ),
        LoadType.resistanceBand: SeriesIncrementRange(
          min: 1,
          max: 3,
          defaultValue: 2,
        ),
      },
      ExerciseType.isolation: {
        LoadType.barbell: SeriesIncrementRange(min: 1, max: 2, defaultValue: 1),
        LoadType.dumbbell: SeriesIncrementRange(
          min: 1,
          max: 2,
          defaultValue: 1,
        ),
        LoadType.machine: SeriesIncrementRange(min: 1, max: 3, defaultValue: 2),
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
          defaultValue: 2,
        ),
        LoadType.resistanceBand: SeriesIncrementRange(
          min: 1,
          max: 3,
          defaultValue: 2,
        ),
      },
    },
    TrainingObjective.hypertrophy: {
      ExerciseType.multiJoint: {
        LoadType.barbell: SeriesIncrementRange(min: 1, max: 2, defaultValue: 1),
        LoadType.dumbbell: SeriesIncrementRange(
          min: 1,
          max: 2,
          defaultValue: 1,
        ),
        LoadType.machine: SeriesIncrementRange(min: 1, max: 3, defaultValue: 2),
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
          defaultValue: 2,
        ),
        LoadType.resistanceBand: SeriesIncrementRange(
          min: 1,
          max: 3,
          defaultValue: 2,
        ),
      },
      ExerciseType.isolation: {
        LoadType.barbell: SeriesIncrementRange(min: 1, max: 2, defaultValue: 1),
        LoadType.dumbbell: SeriesIncrementRange(
          min: 1,
          max: 2,
          defaultValue: 1,
        ),
        LoadType.machine: SeriesIncrementRange(min: 1, max: 3, defaultValue: 2),
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
          defaultValue: 2,
        ),
        LoadType.resistanceBand: SeriesIncrementRange(
          min: 1,
          max: 3,
          defaultValue: 2,
        ),
      },
    },
    TrainingObjective.endurance: {
      ExerciseType.multiJoint: {
        LoadType.barbell: SeriesIncrementRange(min: 1, max: 3, defaultValue: 2),
        LoadType.dumbbell: SeriesIncrementRange(
          min: 1,
          max: 3,
          defaultValue: 2,
        ),
        LoadType.machine: SeriesIncrementRange(min: 1, max: 3, defaultValue: 2),
        LoadType.cable: SeriesIncrementRange(min: 1, max: 3, defaultValue: 2),
        LoadType.kettlebell: SeriesIncrementRange(
          min: 1,
          max: 3,
          defaultValue: 2,
        ),
        LoadType.plate: SeriesIncrementRange(min: 1, max: 3, defaultValue: 2),
        LoadType.bodyweight: SeriesIncrementRange(
          min: 1,
          max: 3,
          defaultValue: 2,
        ),
        LoadType.resistanceBand: SeriesIncrementRange(
          min: 1,
          max: 3,
          defaultValue: 2,
        ),
      },
      ExerciseType.isolation: {
        LoadType.barbell: SeriesIncrementRange(min: 1, max: 3, defaultValue: 2),
        LoadType.dumbbell: SeriesIncrementRange(
          min: 1,
          max: 2,
          defaultValue: 1,
        ),
        LoadType.machine: SeriesIncrementRange(min: 1, max: 3, defaultValue: 2),
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
          defaultValue: 2,
        ),
        LoadType.resistanceBand: SeriesIncrementRange(
          min: 1,
          max: 3,
          defaultValue: 2,
        ),
      },
    },
    TrainingObjective.power: {
      ExerciseType.multiJoint: {
        LoadType.barbell: SeriesIncrementRange(min: 1, max: 2, defaultValue: 1),
        LoadType.dumbbell: SeriesIncrementRange(
          min: 1,
          max: 2,
          defaultValue: 1,
        ),
        LoadType.machine: SeriesIncrementRange(min: 1, max: 3, defaultValue: 2),
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
          defaultValue: 2,
        ),
        LoadType.resistanceBand: SeriesIncrementRange(
          min: 1,
          max: 3,
          defaultValue: 2,
        ),
      },
      ExerciseType.isolation: {
        LoadType.barbell: SeriesIncrementRange(min: 1, max: 2, defaultValue: 1),
        LoadType.dumbbell: SeriesIncrementRange(
          min: 1,
          max: 2,
          defaultValue: 1,
        ),
        LoadType.machine: SeriesIncrementRange(min: 1, max: 3, defaultValue: 2),
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
          defaultValue: 2,
        ),
        LoadType.resistanceBand: SeriesIncrementRange(
          min: 1,
          max: 3,
          defaultValue: 2,
        ),
      },
    },
  };

  // Repeticiones: ahora derivadas en tiempo de ejecución en getRepetitionsRange

  /// Obtiene el incremento por defecto para un ejercicio específico
  static double getDefaultIncrement(Exercise exercise) {
    final range = getIncrementRangeByObjective(
      exercise,
      objective: TrainingObjective.hypertrophy,
    );
    return range?.defaultValue ?? 2.5; // Fallback por defecto
  }

  /// Obtiene el incremento mínimo para un ejercicio específico
  static double getMinIncrement(Exercise exercise) {
    final range = getIncrementRangeByObjective(
      exercise,
      objective: TrainingObjective.hypertrophy,
    );
    return range?.min ?? 1.25; // Fallback por defecto
  }

  /// Obtiene el incremento máximo para un ejercicio específico
  static double getMaxIncrement(Exercise exercise) {
    final range = getIncrementRangeByObjective(
      exercise,
      objective: TrainingObjective.hypertrophy,
    );
    return range?.max ?? 5.0; // Fallback por defecto
  }

  /// Obtiene el rango completo de incrementos para un ejercicio específico
  static IncrementRange? getIncrementRange(Exercise exercise) {
    return getIncrementRangeByObjective(
      exercise,
      objective: TrainingObjective.hypertrophy,
    );
  }

  /// Obtiene el rango de incrementos por OBJETIVO
  static IncrementRange? getIncrementRangeByObjective(
    Exercise exercise, {
    required TrainingObjective objective,
  }) {
    return _objectiveIncrementConfig[objective]?[exercise
        .exerciseType]?[exercise.loadType];
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

  /// Igual que `getRecommendedIncrement` pero considerando OBJETIVO
  static double getRecommendedIncrementByObjective(
    Exercise exercise,
    ExperienceLevel level, {
    required TrainingObjective objective,
  }) {
    final range =
        getIncrementRangeByObjective(exercise, objective: objective) ??
        getIncrementRange(exercise);
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
        final range =
            _objectiveIncrementConfig[TrainingObjective
                .hypertrophy]?[exerciseType]?[loadType];
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
        final range =
            _objectiveIncrementConfig[TrainingObjective
                .hypertrophy]?[exerciseType]?[loadType];
        if (range != null && range.max > 0) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // ===== MÉTODOS PARA INCREMENTOS DE SERIES =====

  /// Obtiene el incremento de series por defecto para un ejercicio específico
  static int getDefaultSeriesIncrement(
    Exercise exercise, {
    required TrainingObjective objective,
  }) {
    final range =
        _objectiveSeriesIncrementConfig[objective]?[exercise
            .exerciseType]?[exercise.loadType];
    return range?.defaultValue ?? 1; // Fallback por defecto
  }

  /// Obtiene el incremento mínimo de series para un ejercicio específico
  static int getMinSeriesIncrement(
    Exercise exercise, {
    required TrainingObjective objective,
  }) {
    final range =
        _objectiveSeriesIncrementConfig[objective]?[exercise
            .exerciseType]?[exercise.loadType];
    return range?.min ?? 1; // Fallback por defecto
  }

  /// Obtiene el incremento máximo de series para un ejercicio específico
  static int getMaxSeriesIncrement(
    Exercise exercise, {
    required TrainingObjective objective,
  }) {
    final range =
        _objectiveSeriesIncrementConfig[objective]?[exercise
            .exerciseType]?[exercise.loadType];
    return range?.max ?? 2; // Fallback por defecto
  }

  /// Obtiene el rango completo de incrementos de series para un ejercicio específico
  static SeriesIncrementRange? getSeriesIncrementRangeByObjective(
    Exercise exercise, {
    required TrainingObjective objective,
  }) {
    return _objectiveSeriesIncrementConfig[objective]?[exercise
        .exerciseType]?[exercise.loadType];
  }

  /// Obtiene el incremento de series recomendado basado en el nivel de experiencia
  static int getRecommendedSeriesIncrement(
    Exercise exercise,
    ExperienceLevel level, {
    required TrainingObjective objective,
    Map<String, dynamic>? customParameters,
  }) {
    // Derivar desde la configuración por objetivo para alinear con `_objectiveSeriesConfig`
    final seriesRange =
        getSeriesIncrementRangeByObjective(exercise, objective: objective) ??
        SeriesIncrementRange(min: 1, max: 2, defaultValue: 1);
    switch (level) {
      case ExperienceLevel.initiated:
        return seriesRange.min;
      case ExperienceLevel.intermediate:
        return (seriesRange.min + seriesRange.max) ~/ 2;
      case ExperienceLevel.advanced:
        return seriesRange.max;
    }
  }

  /// Backward-compat: versión sin objetivo (usa hypertrophy por defecto)
  static int getRecommendedSeriesIncrementLegacy(
    Exercise exercise,
    ExperienceLevel level,
  ) {
    return getRecommendedSeriesIncrement(
      exercise,
      level,
      objective: TrainingObjective.hypertrophy,
    );
  }

  /// Verifica si un incremento de series es válido para un ejercicio específico
  static bool isValidSeriesIncrement(Exercise exercise, int increment) {
    final range = getSeriesIncrementRangeByObjective(
      exercise,
      objective: TrainingObjective.hypertrophy,
    );
    if (range == null) return true; // Si no hay restricciones, es válido

    return increment >= range.min && increment <= range.max;
  }

  /// Obtiene una descripción del rango de incrementos de series para un ejercicio
  static String getSeriesIncrementDescription(Exercise exercise) {
    final range = getSeriesIncrementRangeByObjective(
      exercise,
      objective: TrainingObjective.hypertrophy,
    );
    if (range == null) return 'Incremento de series personalizable';

    if (range.min == range.max) {
      return 'Incremento de series fijo: ${range.defaultValue} serie(s)';
    }

    return 'Rango de incremento de series: ${range.min}-${range.max} serie(s) (por defecto: ${range.defaultValue} serie(s))';
  }

  // ===== MÉTODOS PARA REPETICIONES =====

  /// Obtiene el rango de repeticiones a usar combinando objetivo del preset y overrides en customParameters
  /// Obtiene rangos de repeticiones OPTIMIZADOS por objetivo y tipo de ejercicio
  /// Basado en investigación científica para maximizar adaptaciones específicas
  static (int min, int max) getRepetitionsRange(
    Exercise exercise, {
    TrainingObjective? objective,
  }) {
    // Rangos optimizados por objetivo basados en investigación científica
    int min;
    int max;
    switch (objective) {
      case TrainingObjective.strength:
        // Fuerza: 1-6 reps para máxima fuerza, 3-8 para fuerza funcional
        min = exercise.exerciseType == ExerciseType.multiJoint ? 3 : 5;
        max = exercise.exerciseType == ExerciseType.multiJoint ? 6 : 8;
        break;
      case TrainingObjective.hypertrophy:
        // Hipertrofia: 6-12 reps para máximo crecimiento muscular
        min = exercise.exerciseType == ExerciseType.multiJoint ? 6 : 8;
        max = exercise.exerciseType == ExerciseType.multiJoint ? 12 : 15;
        break;
      case TrainingObjective.endurance:
        // Resistencia: 12+ reps para adaptaciones cardiovasculares y resistencia muscular
        min = exercise.exerciseType == ExerciseType.multiJoint ? 15 : 20;
        max = exercise.exerciseType == ExerciseType.multiJoint ? 25 : 30;
        break;
      case TrainingObjective.power:
        // Potencia: 1-5 reps para máxima potencia explosiva
        min = exercise.exerciseType == ExerciseType.multiJoint ? 1 : 3;
        max = exercise.exerciseType == ExerciseType.multiJoint ? 5 : 8;
        break;
      default:
        // Fallback a hipertrofia (más común)
        min = exercise.exerciseType == ExerciseType.multiJoint ? 6 : 8;
        max = exercise.exerciseType == ExerciseType.multiJoint ? 12 : 15;
    }

    // Validación de rangos
    if (min > max) {
      final tmp = min;
      min = max;
      max = tmp;
    }
    return (min, max);
  }

  /// Devuelve el tiempo de descanso recomendado por objetivo (segundos)
  static int getRestTimeSeconds(
    Exercise exercise, {
    required TrainingObjective objective,
  }) {
    return _objectiveRestSeconds[objective]?[exercise.exerciseType] ??
        (exercise.exerciseType == ExerciseType.multiJoint ? 90 : 60);
  }

  /// Utilidad: mapear una cadena de objetivo a enum (compatibilidad con presets existentes)
  static TrainingObjective parseObjective(String objective) {
    switch (objective.toLowerCase()) {
      case 'strength':
        return TrainingObjective.strength;
      case 'hypertrophy':
        return TrainingObjective.hypertrophy;
      case 'endurance':
        return TrainingObjective.endurance;
      case 'power':
        return TrainingObjective.power;
      default:
        return TrainingObjective.hypertrophy;
    }
  }

  // ===== MÉTODOS PARA SERIES POR OBJETIVO =====

  /// Devuelve el rango de series según objetivo + overrides de preset.
  static SeriesIncrementRange getSeriesRangeByObjective(
    Exercise exercise, {
    required TrainingObjective objective,
  }) {
    final base =
        _objectiveSeriesConfig[objective]?[exercise.exerciseType]?[exercise
            .loadType];
    var min =
        base?.min ?? getMinSeriesIncrement(exercise, objective: objective);
    var max =
        base?.max ?? getMaxSeriesIncrement(exercise, objective: objective);
    var def =
        base?.defaultValue ??
        getDefaultSeriesIncrement(exercise, objective: objective);

    // Overrides por preset eliminados
    if (min > max) {
      final t = min;
      min = max;
      max = t;
    }
    if (def < min) def = min;
    if (def > max) def = max;

    return SeriesIncrementRange(min: min, max: max, defaultValue: def);
  }

  static int getMinBaseSetsByObjective(
    Exercise exercise, {
    required TrainingObjective objective,
  }) => getSeriesRangeByObjective(exercise, objective: objective).min;

  static int getMaxBaseSetsByObjective(
    Exercise exercise, {
    required TrainingObjective objective,
  }) => getSeriesRangeByObjective(exercise, objective: objective).max;

  /// Obtiene las repeticiones mínimas recomendadas
  static int getMinRepetitions(Exercise exercise) {
    final (min, _) = getRepetitionsRange(exercise);
    return min;
  }

  /// Obtiene las repeticiones máximas recomendadas
  static int getMaxRepetitions(Exercise exercise) {
    final (_, max) = getRepetitionsRange(exercise);
    return max;
  }

  /// Obtiene todos los tipos de carga que soportan incrementos de series
  static List<LoadType> getLoadTypesWithSeriesIncrement() {
    return LoadType.values.where((loadType) {
      // Verificar si al menos un tipo de ejercicio tiene incremento de series > 0
      for (final exerciseType in ExerciseType.values) {
        final range =
            _objectiveSeriesIncrementConfig[TrainingObjective
                .hypertrophy]?[exerciseType]?[loadType];
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
        final range =
            _objectiveSeriesIncrementConfig[TrainingObjective
                .hypertrophy]?[exerciseType]?[loadType];
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
