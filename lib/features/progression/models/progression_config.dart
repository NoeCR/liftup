import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../common/enums/progression_type_enum.dart';
import '../../exercise/models/exercise.dart';
import '../configs/adaptive_increment_config.dart';

part 'progression_config.g.dart';

@HiveType(typeId: 18)
@JsonSerializable()
class ProgressionConfig extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final bool isGlobal;

  @HiveField(2)
  final ProgressionType type;

  @HiveField(3)
  final ProgressionUnit unit;

  @HiveField(4)
  final ProgressionTarget primaryTarget;

  @HiveField(5)
  final ProgressionTarget? secondaryTarget;

  @HiveField(6)
  final double incrementValue;

  @HiveField(7)
  final int incrementFrequency;

  @HiveField(8)
  final int cycleLength;

  @HiveField(9)
  final int deloadWeek;

  @HiveField(10)
  final double deloadPercentage;

  @HiveField(11)
  final Map<String, dynamic> customParameters;

  @HiveField(12)
  final DateTime startDate;

  @HiveField(13)
  final DateTime? endDate;

  @HiveField(14)
  final bool isActive;

  @HiveField(15)
  final DateTime createdAt;

  @HiveField(16)
  final DateTime updatedAt;

  @HiveField(17)
  final int minReps;

  @HiveField(18)
  final int maxReps;

  @HiveField(19)
  final int baseSets;

  const ProgressionConfig({
    required this.id,
    required this.isGlobal,
    required this.type,
    required this.unit,
    required this.primaryTarget,
    this.secondaryTarget,
    required this.incrementValue,
    required this.incrementFrequency,
    required this.cycleLength,
    required this.deloadWeek,
    required this.deloadPercentage,
    required this.customParameters,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.minReps,
    required this.maxReps,
    required this.baseSets,
  });

  factory ProgressionConfig.fromJson(Map<String, dynamic> json) =>
      _$ProgressionConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ProgressionConfigToJson(this);

  ProgressionConfig copyWith({
    String? id,
    bool? isGlobal,
    ProgressionType? type,
    ProgressionUnit? unit,
    ProgressionTarget? primaryTarget,
    ProgressionTarget? secondaryTarget,
    double? incrementValue,
    int? incrementFrequency,
    int? cycleLength,
    int? deloadWeek,
    double? deloadPercentage,
    Map<String, dynamic>? customParameters,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? minReps,
    int? maxReps,
    int? baseSets,
  }) {
    return ProgressionConfig(
      id: id ?? this.id,
      isGlobal: isGlobal ?? this.isGlobal,
      type: type ?? this.type,
      unit: unit ?? this.unit,
      primaryTarget: primaryTarget ?? this.primaryTarget,
      secondaryTarget: secondaryTarget ?? this.secondaryTarget,
      incrementValue: incrementValue ?? this.incrementValue,
      incrementFrequency: incrementFrequency ?? this.incrementFrequency,
      cycleLength: cycleLength ?? this.cycleLength,
      deloadWeek: deloadWeek ?? this.deloadWeek,
      deloadPercentage: deloadPercentage ?? this.deloadPercentage,
      customParameters: customParameters ?? this.customParameters,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      minReps: minReps ?? this.minReps,
      maxReps: maxReps ?? this.maxReps,
      baseSets: baseSets ?? this.baseSets,
    );
  }

  @override
  List<Object?> get props => [
    id,
    isGlobal,
    type,
    unit,
    primaryTarget,
    secondaryTarget,
    incrementValue,
    incrementFrequency,
    cycleLength,
    deloadWeek,
    deloadPercentage,
    customParameters,
    startDate,
    endDate,
    isActive,
    createdAt,
    updatedAt,
    minReps,
    maxReps,
    baseSets,
  ];

  /// Obtiene el incremento adaptativo basado en el ejercicio específico
  ///
  /// Prioridad:
  /// 1. customParameters (configuración específica por ejercicio)
  /// 2. AdaptiveIncrementConfig (sistema de incrementos adaptativos)
  /// 3. incrementValue (valor base de la configuración)
  ///
  /// Si el ejercicio no soporta incrementos de peso (peso corporal, banda elástica),
  /// retorna 0.0.
  double getAdaptiveIncrement(dynamic exercise) {
    try {
      // Verificar si el ejercicio soporta incrementos de peso
      if (exercise != null && exercise.loadType != null) {
        final loadType = exercise.loadType.toString();
        if (loadType.contains('bodyweight') ||
            loadType.contains('resistanceBand')) {
          return 0.0; // Sin incremento de peso
        }
      }

      // Usar tablas por objetivo (sistema adaptativo)
      if (exercise is Exercise) {
        final objective = AdaptiveIncrementConfig.parseObjective(
          getTrainingObjective(),
        );
        return AdaptiveIncrementConfig.getRecommendedIncrementByObjective(
          exercise,
          ExperienceLevel.intermediate,
          objective: objective,
        );
      }
    } catch (e) {
      // Si hay error, usar el incremento por defecto
    }

    // 3. Fallback al valor base de la configuración
    return incrementValue;
  }

  // _getIncrementFromAdaptiveConfig eliminado; la ruta principal usa tablas por objetivo

  /// Obtiene las repeticiones mínimas adaptativas basadas en el ejercicio
  int getAdaptiveMinReps(dynamic exercise) {
    try {
      if (exercise is Exercise) {
        final objective = AdaptiveIncrementConfig.parseObjective(
          getTrainingObjective(),
        );
        final (min, _) = AdaptiveIncrementConfig.getRepetitionsRange(
          exercise,
          objective: objective,
        );
        return min;
      }
      return minReps;
    } catch (_) {
      return minReps;
    }
  }

  /// Obtiene las repeticiones máximas adaptativas basadas en el ejercicio
  int getAdaptiveMaxReps(dynamic exercise) {
    try {
      if (exercise is Exercise) {
        final objective = AdaptiveIncrementConfig.parseObjective(
          getTrainingObjective(),
        );
        final (_, max) = AdaptiveIncrementConfig.getRepetitionsRange(
          exercise,
          objective: objective,
        );
        return max;
      }
      return maxReps;
    } catch (_) {
      return maxReps;
    }
  }

  /// Obtiene las series base adaptativas basadas en el ejercicio
  int getAdaptiveBaseSets(dynamic exercise) {
    try {
      if (exercise is Exercise) {
        final objective = AdaptiveIncrementConfig.parseObjective(
          getTrainingObjective(),
        );
        final range = AdaptiveIncrementConfig.getSeriesRangeByObjective(
          exercise,
          objective: objective,
        );
        return range.defaultValue;
      }
      return baseSets;
    } catch (_) {
      return baseSets;
    }
  }

  /// Obtiene el incremento de series adaptativo basado en el ejercicio específico
  /// Ahora usa únicamente AdaptiveIncrementConfig como fuente de verdad
  /// para evitar duplicación de lógica con los presets
  /// Considera tanto exerciseType como loadType del ejercicio
  int getAdaptiveSeriesIncrement(dynamic exercise) {
    try {
      // Usar AdaptiveIncrementConfig como única fuente de verdad
      // Considera tanto exerciseType como loadType del ejercicio
      final adaptiveSeriesIncrement = _getSeriesIncrementFromAdaptiveConfig(
        exercise,
      );
      if (adaptiveSeriesIncrement != null) {
        return adaptiveSeriesIncrement;
      }
    } catch (e) {
      // Si hay error, usar el incremento por defecto
    }

    // Fallback al valor por defecto
    return 1;
  }

  // Overrides por customParameters eliminados: reps mínimas derivadas por objetivo

  // Overrides por customParameters eliminados: reps máximas derivadas por objetivo

  // Overrides por customParameters eliminados: base sets derivados por objetivo

  /// Determina si la progresión debe enfocarse en peso basado en los targets
  bool shouldFocusOnWeight() {
    return primaryTarget == ProgressionTarget.weight ||
        secondaryTarget == ProgressionTarget.weight;
  }

  /// Determina si la progresión debe enfocarse en repeticiones basado en los targets
  bool shouldFocusOnReps() {
    return primaryTarget == ProgressionTarget.reps ||
        secondaryTarget == ProgressionTarget.reps;
  }

  /// Determina si la progresión debe enfocarse en series basado en los targets
  bool shouldFocusOnSets() {
    return primaryTarget == ProgressionTarget.sets ||
        secondaryTarget == ProgressionTarget.sets;
  }

  /// Determina si la progresión debe enfocarse en volumen basado en los targets
  bool shouldFocusOnVolume() {
    return primaryTarget == ProgressionTarget.volume ||
        secondaryTarget == ProgressionTarget.volume;
  }

  /// Determina si la progresión debe enfocarse en intensidad basado en los targets
  bool shouldFocusOnIntensity() {
    return primaryTarget == ProgressionTarget.intensity ||
        secondaryTarget == ProgressionTarget.intensity;
  }

  /// Obtiene el target principal como string para logging/debugging
  String getPrimaryTargetName() {
    return primaryTarget.name;
  }

  /// Obtiene el target secundario como string para logging/debugging
  String? getSecondaryTargetName() {
    return secondaryTarget?.name;
  }

  /// Determina si los targets están configurados para hipertrofia
  bool isConfiguredForHypertrophy() {
    // Hipertrofia típicamente se enfoca en volumen y repeticiones
    return (primaryTarget == ProgressionTarget.volume ||
            primaryTarget == ProgressionTarget.reps) &&
        (secondaryTarget == ProgressionTarget.weight ||
            secondaryTarget == ProgressionTarget.sets ||
            secondaryTarget == ProgressionTarget.reps);
  }

  /// Determina si los targets están configurados para fuerza
  bool isConfiguredForStrength() {
    // Fuerza típicamente se enfoca en peso e intensidad
    // Excluir casos que son específicamente para power
    if (primaryTarget == ProgressionTarget.intensity &&
        secondaryTarget == ProgressionTarget.intensity) {
      return false; // Este caso es para power
    }
    return (primaryTarget == ProgressionTarget.weight ||
            primaryTarget == ProgressionTarget.intensity) &&
        (secondaryTarget == ProgressionTarget.reps ||
            secondaryTarget == ProgressionTarget.intensity ||
            secondaryTarget == ProgressionTarget.weight ||
            secondaryTarget == null);
  }

  /// Determina si los targets están configurados para resistencia
  bool isConfiguredForEndurance() {
    // Resistencia típicamente se enfoca en repeticiones y volumen
    return (primaryTarget == ProgressionTarget.reps ||
            primaryTarget == ProgressionTarget.volume) &&
        (secondaryTarget == ProgressionTarget.sets ||
            secondaryTarget == ProgressionTarget.volume ||
            secondaryTarget == null);
  }

  /// Determina si los targets están configurados para potencia
  bool isConfiguredForPower() {
    // Potencia típicamente se enfoca en intensidad y peso
    // Para power, ambos targets deben ser intensity o weight
    return (primaryTarget == ProgressionTarget.intensity &&
            secondaryTarget == ProgressionTarget.intensity) ||
        (primaryTarget == ProgressionTarget.weight &&
            secondaryTarget == ProgressionTarget.reps);
  }

  /// Obtiene el objetivo de entrenamiento basado en los targets configurados
  String getTrainingObjective() {
    if (isConfiguredForHypertrophy()) return 'hypertrophy';
    if (isConfiguredForStrength()) return 'strength';
    if (isConfiguredForEndurance()) return 'endurance';
    if (isConfiguredForPower()) return 'power';
    return 'general';
  }

  /// Crea una copia de la configuración con incremento adaptativo
  ProgressionConfig copyWithAdaptiveIncrement(dynamic exercise) {
    final adaptiveIncrement = getAdaptiveIncrement(exercise);
    return copyWith(incrementValue: adaptiveIncrement);
  }

  /// Obtiene incremento de series desde AdaptiveIncrementConfig
  int? _getSeriesIncrementFromAdaptiveConfig(dynamic exercise) {
    try {
      // Verificar que el ejercicio tenga los campos necesarios
      if (exercise == null) return null;

      // Verificar que sea un objeto Exercise válido
      if (exercise is! Exercise) return null;

      // Usar AdaptiveIncrementConfig para obtener el incremento de series recomendado
      final objective = AdaptiveIncrementConfig.parseObjective(
        getTrainingObjective(),
      );
      return AdaptiveIncrementConfig.getRecommendedSeriesIncrement(
        exercise,
        ExperienceLevel.intermediate, // Por defecto intermedio
        objective: objective,
        customParameters: customParameters,
      );
    } catch (e) {
      return null;
    }
  }
}
