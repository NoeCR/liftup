import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../common/enums/progression_type_enum.dart';
import '../models/progression_config.dart';

/// Sistema de presets que configuran customParameters completos
/// para diferentes objetivos de entrenamiento y tipos de progresión
class PresetProgressionConfigs {
  static const _uuid = Uuid();

  /// Crea un preset de progresión lineal para hipertrofia
  static ProgressionConfig createLinearHypertrophyPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.linear,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.volume,
      secondaryTarget: ProgressionTarget.reps,
      incrementValue: 2.5, // Base, será adaptado por AdaptiveIncrementConfig
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 4,
      deloadPercentage: 0.8,
      customParameters: {
        // Configuración global para hipertrofia
        'sessions_per_week': 3,
        'min_reps': 8,
        'max_reps': 12,
        'base_sets': 3,
        'increment_value': 2.5,
        'target_rpe': 8.0,
        'rest_time_seconds': 90,

        // Configuración específica por tipo de ejercicio
        'multi_increment_min': 5.0,
        'multi_increment_max': 7.5,
        'iso_increment_min': 1.25,
        'iso_increment_max': 2.5,
        'multi_reps_min': 6,
        'multi_reps_max': 10,
        'iso_reps_min': 8,
        'iso_reps_max': 15,

        // Configuración por ejercicio específico (ejemplo)
        'per_exercise': {
          'bench_press': {'increment_value': 5.0, 'min_reps': 6, 'max_reps': 10, 'base_sets': 4, 'target_rpe': 8.5},
          'squat': {'increment_value': 7.5, 'min_reps': 5, 'max_reps': 8, 'base_sets': 4, 'target_rpe': 8.0},
        },
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 8,
      maxReps: 12,
      baseSets: 3,
    );
  }

  /// Crea un preset de progresión lineal para fuerza
  static ProgressionConfig createLinearStrengthPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.linear,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.weight,
      secondaryTarget: ProgressionTarget.intensity,
      incrementValue: 5.0, // Base, será adaptado por AdaptiveIncrementConfig
      incrementFrequency: 1,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.85,
      customParameters: {
        // Configuración global para fuerza
        'sessions_per_week': 3,
        'min_reps': 3,
        'max_reps': 6,
        'base_sets': 4,
        'increment_value': 5.0,
        'target_rpe': 8.5,
        'rest_time_seconds': 180,

        // Configuración específica por tipo de ejercicio
        'multi_increment_min': 5.0,
        'multi_increment_max': 10.0,
        'iso_increment_min': 2.5,
        'iso_increment_max': 5.0,
        'multi_reps_min': 3,
        'multi_reps_max': 5,
        'iso_reps_min': 5,
        'iso_reps_max': 8,

        // Configuración por ejercicio específico
        'per_exercise': {
          'bench_press': {'increment_value': 5.0, 'min_reps': 3, 'max_reps': 5, 'base_sets': 5, 'target_rpe': 9.0},
          'squat': {'increment_value': 10.0, 'min_reps': 3, 'max_reps': 5, 'base_sets': 5, 'target_rpe': 8.5},
          'deadlift': {'increment_value': 10.0, 'min_reps': 3, 'max_reps': 5, 'base_sets': 4, 'target_rpe': 9.0},
        },
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 3,
      maxReps: 6,
      baseSets: 4,
    );
  }

  /// Crea un preset de progresión lineal para resistencia
  static ProgressionConfig createLinearEndurancePreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.linear,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.reps,
      secondaryTarget: ProgressionTarget.volume,
      incrementValue: 1.25, // Base, será adaptado por AdaptiveIncrementConfig
      incrementFrequency: 2,
      cycleLength: 3,
      deloadWeek: 3,
      deloadPercentage: 0.7,
      customParameters: {
        // Configuración global para resistencia
        'sessions_per_week': 4,
        'min_reps': 12,
        'max_reps': 20,
        'base_sets': 3,
        'increment_value': 1.25,
        'target_rpe': 7.0,
        'rest_time_seconds': 60,

        // Configuración específica por tipo de ejercicio
        'multi_increment_min': 2.5,
        'multi_increment_max': 5.0,
        'iso_increment_min': 1.25,
        'iso_increment_max': 2.5,
        'multi_reps_min': 12,
        'multi_reps_max': 18,
        'iso_reps_min': 15,
        'iso_reps_max': 25,

        // Configuración por ejercicio específico
        'per_exercise': {
          'bench_press': {'increment_value': 2.5, 'min_reps': 12, 'max_reps': 18, 'base_sets': 3, 'target_rpe': 7.0},
          'squat': {'increment_value': 5.0, 'min_reps': 12, 'max_reps': 20, 'base_sets': 3, 'target_rpe': 7.5},
        },
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 12,
      maxReps: 20,
      baseSets: 3,
    );
  }

  /// Crea un preset de progresión lineal para potencia
  static ProgressionConfig createLinearPowerPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.linear,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.intensity,
      secondaryTarget: ProgressionTarget.intensity,
      incrementValue: 5.0, // Base, será adaptado por AdaptiveIncrementConfig
      incrementFrequency: 1,
      cycleLength: 3,
      deloadWeek: 3,
      deloadPercentage: 0.7,
      customParameters: {
        // Configuración global para potencia
        'sessions_per_week': 2,
        'min_reps': 3,
        'max_reps': 6,
        'base_sets': 4,
        'increment_value': 5.0,
        'target_rpe': 8.5,
        'rest_time_seconds': 180,

        // Configuración específica por tipo de ejercicio
        'multi_increment_min': 7.5,
        'multi_increment_max': 10.0,
        'iso_increment_min': 2.5,
        'iso_increment_max': 5.0,
        'multi_reps_min': 3,
        'multi_reps_max': 5,
        'iso_reps_min': 4,
        'iso_reps_max': 8,

        // Configuración por ejercicio específico (ejemplo)
        'per_exercise': {
          'bench_press': {'increment_value': 7.5, 'min_reps': 3, 'max_reps': 5, 'base_sets': 5},
          'squat': {'increment_value': 10.0, 'min_reps': 3, 'max_reps': 5, 'base_sets': 4},
          'deadlift': {'increment_value': 10.0, 'min_reps': 3, 'max_reps': 5, 'base_sets': 3},
        },

        // Configuración de progresión
        'progression_logic': 'power_focused',
        'intensity_range': '85-95%',
        'volume_priority': 'low',
        'frequency_priority': 'medium',
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 3,
      maxReps: 6,
      baseSets: 4,
    );
  }

  /// Crea un preset de progresión doble para hipertrofia
  static ProgressionConfig createDoubleHypertrophyPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.double,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.volume,
      secondaryTarget: ProgressionTarget.reps,
      incrementValue: 2.5,
      incrementFrequency: 1,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.8,
      customParameters: {
        // Configuración global para hipertrofia con progresión doble
        'sessions_per_week': 3,
        'min_reps': 8,
        'max_reps': 12,
        'base_sets': 3,
        'increment_value': 2.5,
        'target_rpe': 8.0,
        'rest_time_seconds': 90,

        // Parámetros específicos de progresión doble
        'weight_increment': 2.5,
        'rep_increment': 1,
        'max_reps_before_weight_increase': 12,
        'min_reps_after_weight_increase': 8,

        // Configuración específica por tipo de ejercicio
        'multi_increment_min': 5.0,
        'multi_increment_max': 7.5,
        'iso_increment_min': 1.25,
        'iso_increment_max': 2.5,
        'multi_reps_min': 6,
        'multi_reps_max': 10,
        'iso_reps_min': 8,
        'iso_reps_max': 15,
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 8,
      maxReps: 12,
      baseSets: 3,
    );
  }

  /// Crea un preset de progresión autoregulada para hipertrofia
  static ProgressionConfig createAutoregulatedHypertrophyPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.autoregulated,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.volume,
      secondaryTarget: ProgressionTarget.intensity,
      incrementValue: 2.5,
      incrementFrequency: 1,
      cycleLength: 0, // Autoregulada no tiene ciclo fijo
      deloadWeek: 0,
      deloadPercentage: 0.8,
      customParameters: {
        // Configuración global para hipertrofia autoregulada
        'sessions_per_week': 3,
        'min_reps': 6,
        'max_reps': 15,
        'base_sets': 3,
        'increment_value': 2.5,
        'target_rpe': 8.0,
        'rest_time_seconds': 90,

        // Parámetros específicos de progresión autoregulada
        'rpe_threshold': 0.5,
        'target_reps': 10,
        'weight_increment_on_target_rpe': 2.5,
        'rep_increment_on_low_rpe': 1,

        // Configuración específica por tipo de ejercicio
        'multi_increment_min': 5.0,
        'multi_increment_max': 7.5,
        'iso_increment_min': 1.25,
        'iso_increment_max': 2.5,
        'multi_reps_min': 6,
        'multi_reps_max': 12,
        'iso_reps_min': 8,
        'iso_reps_max': 15,
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 6,
      maxReps: 15,
      baseSets: 3,
    );
  }

  // ===== PRESETS DE PROGRESIÓN ESCALONADA (STEPPED) =====

  /// Crea un preset de progresión escalonada para hipertrofia
  static ProgressionConfig createSteppedHypertrophyPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.stepped,
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.volume,
      secondaryTarget: ProgressionTarget.reps,
      incrementValue: 2.5,
      incrementFrequency: 2,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.8,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 8,
        'max_reps': 12,
        'base_sets': 3,
        'increment_value': 2.5,
        'target_rpe': 8.0,
        'rest_time_seconds': 90,
        'step_duration_weeks': 2,
        'step_increment_percentage': 0.05,
        'progression_logic': 'stepped_hypertrophy',
        'intensity_range': '70-80%',
        'volume_priority': 'high',
        'frequency_priority': 'medium',
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 8,
      maxReps: 12,
      baseSets: 3,
    );
  }

  /// Crea un preset de progresión escalonada para fuerza
  static ProgressionConfig createSteppedStrengthPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.stepped,
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.intensity,
      secondaryTarget: ProgressionTarget.weight,
      incrementValue: 5.0,
      incrementFrequency: 2,
      cycleLength: 8,
      deloadWeek: 8,
      deloadPercentage: 0.75,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 3,
        'max_reps': 6,
        'base_sets': 4,
        'increment_value': 5.0,
        'target_rpe': 8.5,
        'rest_time_seconds': 180,
        'step_duration_weeks': 2,
        'step_increment_percentage': 0.075,
        'progression_logic': 'stepped_strength',
        'intensity_range': '80-90%',
        'volume_priority': 'medium',
        'frequency_priority': 'medium',
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 3,
      maxReps: 6,
      baseSets: 4,
    );
  }

  /// Crea un preset de progresión escalonada para resistencia
  static ProgressionConfig createSteppedEndurancePreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.stepped,
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.reps,
      secondaryTarget: ProgressionTarget.volume,
      incrementValue: 1.25,
      incrementFrequency: 2,
      cycleLength: 4,
      deloadWeek: 4,
      deloadPercentage: 0.85,
      customParameters: {
        'sessions_per_week': 4,
        'min_reps': 12,
        'max_reps': 20,
        'base_sets': 3,
        'increment_value': 1.25,
        'target_rpe': 7.0,
        'rest_time_seconds': 60,
        'step_duration_weeks': 2,
        'step_increment_percentage': 0.03,
        'progression_logic': 'stepped_endurance',
        'intensity_range': '60-70%',
        'volume_priority': 'high',
        'frequency_priority': 'high',
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 12,
      maxReps: 20,
      baseSets: 3,
    );
  }

  /// Crea un preset de progresión escalonada para potencia
  static ProgressionConfig createSteppedPowerPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.stepped,
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.intensity,
      secondaryTarget: ProgressionTarget.intensity,
      incrementValue: 5.0,
      incrementFrequency: 2,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.7,
      customParameters: {
        'sessions_per_week': 2,
        'min_reps': 3,
        'max_reps': 6,
        'base_sets': 4,
        'increment_value': 5.0,
        'target_rpe': 8.5,
        'rest_time_seconds': 180,
        'step_duration_weeks': 3,
        'step_increment_percentage': 0.08,
        'progression_logic': 'stepped_power',
        'intensity_range': '85-95%',
        'volume_priority': 'low',
        'frequency_priority': 'low',
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 3,
      maxReps: 6,
      baseSets: 4,
    );
  }

  // ===== PRESETS DE PROGRESIÓN DOBLE (DOUBLE) =====

  /// Crea un preset de progresión doble para fuerza
  static ProgressionConfig createDoubleStrengthPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.double,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.intensity,
      secondaryTarget: ProgressionTarget.weight,
      incrementValue: 5.0,
      incrementFrequency: 1,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.75,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 3,
        'max_reps': 6,
        'base_sets': 4,
        'increment_value': 5.0,
        'target_rpe': 8.5,
        'rest_time_seconds': 180,
        'rep_target': 6,
        'weight_increment_on_target_reps': 5.0,
        'rep_increment_on_low_reps': 1,
        'progression_logic': 'double_strength',
        'intensity_range': '80-90%',
        'volume_priority': 'medium',
        'frequency_priority': 'medium',
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 3,
      maxReps: 6,
      baseSets: 4,
    );
  }

  /// Crea un preset de progresión doble para resistencia
  static ProgressionConfig createDoubleEndurancePreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.double,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.reps,
      secondaryTarget: ProgressionTarget.volume,
      incrementValue: 1.25,
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 4,
      deloadPercentage: 0.85,
      customParameters: {
        'sessions_per_week': 4,
        'min_reps': 12,
        'max_reps': 20,
        'base_sets': 3,
        'increment_value': 1.25,
        'target_rpe': 7.0,
        'rest_time_seconds': 60,
        'rep_target': 15,
        'weight_increment_on_target_reps': 1.25,
        'rep_increment_on_low_reps': 2,
        'progression_logic': 'double_endurance',
        'intensity_range': '60-70%',
        'volume_priority': 'high',
        'frequency_priority': 'high',
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 12,
      maxReps: 20,
      baseSets: 3,
    );
  }

  /// Crea un preset de progresión doble para potencia
  static ProgressionConfig createDoublePowerPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.double,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.intensity,
      secondaryTarget: ProgressionTarget.intensity,
      incrementValue: 5.0,
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 4,
      deloadPercentage: 0.7,
      customParameters: {
        'sessions_per_week': 2,
        'min_reps': 3,
        'max_reps': 6,
        'base_sets': 4,
        'increment_value': 5.0,
        'target_rpe': 8.5,
        'rest_time_seconds': 180,
        'rep_target': 5,
        'weight_increment_on_target_reps': 5.0,
        'rep_increment_on_low_reps': 1,
        'progression_logic': 'double_power',
        'intensity_range': '85-95%',
        'volume_priority': 'low',
        'frequency_priority': 'low',
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 3,
      maxReps: 6,
      baseSets: 4,
    );
  }

  // ===== PRESETS DE PROGRESIÓN ONDULANTE (UNDULATING) =====

  /// Crea un preset de progresión ondulante para hipertrofia
  static ProgressionConfig createUndulatingHypertrophyPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.undulating,
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.volume,
      secondaryTarget: ProgressionTarget.reps,
      incrementValue: 2.5,
      incrementFrequency: 1,
      cycleLength: 3,
      deloadWeek: 3,
      deloadPercentage: 0.8,
      customParameters: {
        'sessions_per_week': 4,
        'min_reps': 6,
        'max_reps': 15,
        'base_sets': 3,
        'increment_value': 2.5,
        'target_rpe': 8.0,
        'rest_time_seconds': 90,
        'undulation_pattern': 'daily',
        'intensity_variation': 0.15,
        'volume_variation': 0.2,
        'progression_logic': 'undulating_hypertrophy',
        'intensity_range': '65-85%',
        'volume_priority': 'high',
        'frequency_priority': 'high',
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 6,
      maxReps: 15,
      baseSets: 3,
    );
  }

  /// Crea un preset de progresión ondulante para fuerza
  static ProgressionConfig createUndulatingStrengthPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.undulating,
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.intensity,
      secondaryTarget: ProgressionTarget.weight,
      incrementValue: 5.0,
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 4,
      deloadPercentage: 0.75,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 2,
        'max_reps': 8,
        'base_sets': 4,
        'increment_value': 5.0,
        'target_rpe': 8.5,
        'rest_time_seconds': 180,
        'undulation_pattern': 'daily',
        'intensity_variation': 0.2,
        'volume_variation': 0.15,
        'progression_logic': 'undulating_strength',
        'intensity_range': '75-95%',
        'volume_priority': 'medium',
        'frequency_priority': 'medium',
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 2,
      maxReps: 8,
      baseSets: 4,
    );
  }

  /// Crea un preset de progresión ondulante para resistencia
  static ProgressionConfig createUndulatingEndurancePreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.undulating,
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.reps,
      secondaryTarget: ProgressionTarget.volume,
      incrementValue: 1.25,
      incrementFrequency: 1,
      cycleLength: 2,
      deloadWeek: 2,
      deloadPercentage: 0.85,
      customParameters: {
        'sessions_per_week': 5,
        'min_reps': 10,
        'max_reps': 25,
        'base_sets': 3,
        'increment_value': 1.25,
        'target_rpe': 7.0,
        'rest_time_seconds': 60,
        'undulation_pattern': 'daily',
        'intensity_variation': 0.1,
        'volume_variation': 0.25,
        'progression_logic': 'undulating_endurance',
        'intensity_range': '55-75%',
        'volume_priority': 'high',
        'frequency_priority': 'high',
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 10,
      maxReps: 25,
      baseSets: 3,
    );
  }

  /// Crea un preset de progresión ondulante para potencia
  static ProgressionConfig createUndulatingPowerPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.undulating,
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.intensity,
      secondaryTarget: ProgressionTarget.intensity,
      incrementValue: 5.0,
      incrementFrequency: 1,
      cycleLength: 3,
      deloadWeek: 3,
      deloadPercentage: 0.7,
      customParameters: {
        'sessions_per_week': 2,
        'min_reps': 2,
        'max_reps': 6,
        'base_sets': 4,
        'increment_value': 5.0,
        'target_rpe': 8.5,
        'rest_time_seconds': 180,
        'undulation_pattern': 'daily',
        'intensity_variation': 0.25,
        'volume_variation': 0.1,
        'progression_logic': 'undulating_power',
        'intensity_range': '80-100%',
        'volume_priority': 'low',
        'frequency_priority': 'low',
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 2,
      maxReps: 6,
      baseSets: 4,
    );
  }

  /// Obtiene todos los presets disponibles para un tipo de progresión específico
  static List<ProgressionConfig> getPresetsForType(ProgressionType type) {
    switch (type) {
      case ProgressionType.linear:
        return [
          createLinearHypertrophyPreset(),
          createLinearStrengthPreset(),
          createLinearEndurancePreset(),
          createLinearPowerPreset(),
        ];
      case ProgressionType.stepped:
        return [
          createSteppedHypertrophyPreset(),
          createSteppedStrengthPreset(),
          createSteppedEndurancePreset(),
          createSteppedPowerPreset(),
        ];
      case ProgressionType.double:
        return [
          createDoubleHypertrophyPreset(),
          createDoubleStrengthPreset(),
          createDoubleEndurancePreset(),
          createDoublePowerPreset(),
        ];
      case ProgressionType.undulating:
        return [
          createUndulatingHypertrophyPreset(),
          createUndulatingStrengthPreset(),
          createUndulatingEndurancePreset(),
          createUndulatingPowerPreset(),
        ];
      case ProgressionType.autoregulated:
        return [createAutoregulatedHypertrophyPreset()];
      default:
        return [];
    }
  }

  /// Obtiene todos los presets disponibles
  static List<ProgressionConfig> getAllPresets() {
    return [
      // Linear presets
      createLinearHypertrophyPreset(),
      createLinearStrengthPreset(),
      createLinearEndurancePreset(),
      createLinearPowerPreset(),

      // Stepped presets
      createSteppedHypertrophyPreset(),
      createSteppedStrengthPreset(),
      createSteppedEndurancePreset(),
      createSteppedPowerPreset(),

      // Double presets
      createDoubleHypertrophyPreset(),
      createDoubleStrengthPreset(),
      createDoubleEndurancePreset(),
      createDoublePowerPreset(),

      // Undulating presets
      createUndulatingHypertrophyPreset(),
      createUndulatingStrengthPreset(),
      createUndulatingEndurancePreset(),
      createUndulatingPowerPreset(),

      // Autoregulated presets
      createAutoregulatedHypertrophyPreset(),
    ];
  }

  /// Obtiene metadatos de un preset para mostrar en la UI usando easy_localization
  static Map<String, dynamic> getPresetMetadata(ProgressionConfig config) {
    final objective = config.getTrainingObjective();
    final customParams = config.customParameters;
    final targetRpe = customParams['target_rpe'] ?? 8.0;
    final restTime = customParams['rest_time_seconds'] ?? 90;

    switch (objective) {
      case 'hypertrophy':
        return {
          'title': 'presets.hypertrophy.title'.tr(),
          'description': 'presets.hypertrophy.description'.tr(),
          'key_points': [
            'presets.hypertrophy.keyPoints.repRange'.tr(
              namedArgs: {'minReps': config.minReps.toString(), 'maxReps': config.maxReps.toString()},
            ),
            'presets.hypertrophy.keyPoints.baseSets'.tr(namedArgs: {'baseSets': config.baseSets.toString()}),
            'presets.hypertrophy.keyPoints.targetRpe'.tr(namedArgs: {'targetRpe': targetRpe.toString()}),
            'presets.hypertrophy.keyPoints.restTime'.tr(namedArgs: {'restTime': restTime.toString()}),
          ],
        };
      case 'strength':
        return {
          'title': 'presets.strength.title'.tr(),
          'description': 'presets.strength.description'.tr(),
          'key_points': [
            'presets.strength.keyPoints.repRange'.tr(
              namedArgs: {'minReps': config.minReps.toString(), 'maxReps': config.maxReps.toString()},
            ),
            'presets.strength.keyPoints.baseSets'.tr(namedArgs: {'baseSets': config.baseSets.toString()}),
            'presets.strength.keyPoints.targetRpe'.tr(namedArgs: {'targetRpe': targetRpe.toString()}),
            'presets.strength.keyPoints.restTime'.tr(namedArgs: {'restTime': restTime.toString()}),
          ],
        };
      case 'endurance':
        return {
          'title': 'presets.endurance.title'.tr(),
          'description': 'presets.endurance.description'.tr(),
          'key_points': [
            'presets.endurance.keyPoints.repRange'.tr(
              namedArgs: {'minReps': config.minReps.toString(), 'maxReps': config.maxReps.toString()},
            ),
            'presets.endurance.keyPoints.baseSets'.tr(namedArgs: {'baseSets': config.baseSets.toString()}),
            'presets.endurance.keyPoints.targetRpe'.tr(namedArgs: {'targetRpe': targetRpe.toString()}),
            'presets.endurance.keyPoints.restTime'.tr(namedArgs: {'restTime': restTime.toString()}),
          ],
        };
      case 'power':
        return {
          'title': 'presets.power.title'.tr(),
          'description': 'presets.power.description'.tr(),
          'key_points': [
            'presets.power.keyPoints.repRange'.tr(
              namedArgs: {'minReps': config.minReps.toString(), 'maxReps': config.maxReps.toString()},
            ),
            'presets.power.keyPoints.baseSets'.tr(namedArgs: {'baseSets': config.baseSets.toString()}),
            'presets.power.keyPoints.targetRpe'.tr(namedArgs: {'targetRpe': targetRpe.toString()}),
            'presets.power.keyPoints.restTime'.tr(namedArgs: {'restTime': restTime.toString()}),
          ],
        };
      default:
        return {
          'title': 'presets.general.title'.tr(),
          'description': 'presets.general.description'.tr(),
          'key_points': [
            'presets.general.keyPoints.repRange'.tr(
              namedArgs: {'minReps': config.minReps.toString(), 'maxReps': config.maxReps.toString()},
            ),
            'presets.general.keyPoints.baseSets'.tr(namedArgs: {'baseSets': config.baseSets.toString()}),
          ],
        };
    }
  }
}
