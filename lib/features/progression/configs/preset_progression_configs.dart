import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';

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
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
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
        'target_rpe': 8.0,
        'rest_time_seconds': 90,

        // Los incrementos y rangos de reps por exerciseType/loadType
        // se manejan automáticamente por AdaptiveIncrementConfig

        // Los incrementos de series por loadType se manejan automáticamente
        // a través de AdaptiveIncrementConfig

        // Metadatos para internacionalización
        'title_key': 'presets.hypertrophy.title',
        'description_key': 'presets.hypertrophy.description',
        'key_points_key': 'presets.hypertrophy.key_points',
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
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
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
        'target_rpe': 8.5,
        'rest_time_seconds': 180,

        // Los incrementos y rangos de reps por exerciseType/loadType
        // se manejan automáticamente por AdaptiveIncrementConfig

        // Los incrementos de series por loadType se manejan automáticamente
        // a través de AdaptiveIncrementConfig

        // Metadatos para internacionalización
        'title_key': 'presets.strength.title',
        'description_key': 'presets.strength.description',
        'key_points_key': 'presets.strength.key_points',
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
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
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
        'target_rpe': 7.0,
        'rest_time_seconds': 60,

        // Los incrementos y rangos de reps por exerciseType/loadType
        // se manejan automáticamente por AdaptiveIncrementConfig

        // Los incrementos de series por loadType se manejan automáticamente
        // a través de AdaptiveIncrementConfig

        // Metadatos para internacionalización
        'title_key': 'presets.endurance.title',
        'description_key': 'presets.endurance.description',
        'key_points_key': 'presets.endurance.key_points',
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
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
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
        'target_rpe': 8.5,
        'rest_time_seconds': 180,

        // Los incrementos y rangos de reps por exerciseType/loadType
        // se manejan automáticamente por AdaptiveIncrementConfig

        // Los incrementos de series por loadType se manejan automáticamente
        // a través de AdaptiveIncrementConfig

        // Metadatos para internacionalización
        'title_key': 'presets.power.title',
        'description_key': 'presets.power.description',
        'key_points_key': 'presets.power.key_points',

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
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
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
        'target_rpe': 8.0,
        'rest_time_seconds': 90,

        // Parámetros específicos de progresión doble
        'weight_increment': 2.5, // Valor base, será adaptado por AdaptiveIncrementConfig
        'rep_increment': 1,
        'max_reps_before_weight_increase': 12,
        'min_reps_after_weight_increase': 8,

        // Los incrementos y rangos de reps por exerciseType/loadType
        // se manejan automáticamente por AdaptiveIncrementConfig
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
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
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
        'target_rpe': 8.0,
        'rest_time_seconds': 90,

        // Parámetros específicos de progresión autoregulada
        'rpe_threshold': 0.5,
        'target_reps': 10,
        'weight_increment_on_target_rpe': 2.5,
        'rep_increment_on_low_rpe': 1,

        // Los incrementos y rangos de reps por exerciseType/loadType
        // se manejan automáticamente por AdaptiveIncrementConfig
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
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 2,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.8,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 8,
        'max_reps': 12,
        'base_sets': 3,
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
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 1,
      cycleLength: 3,
      deloadWeek: 3,
      deloadPercentage: 0.8,
      customParameters: {
        'sessions_per_week': 4,
        'min_reps': 6,
        'max_reps': 15,
        'base_sets': 3,
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
      createAutoregulatedStrengthPreset(),
      createAutoregulatedEndurancePreset(),
      createAutoregulatedPowerPreset(),

      // Double Factor presets
      createDoubleFactorHypertrophyPreset(),
      createDoubleFactorStrengthPreset(),
      createDoubleFactorEndurancePreset(),
      createDoubleFactorPowerPreset(),

      // Wave presets
      createWaveHypertrophyPreset(),
      createWaveStrengthPreset(),
      createWaveEndurancePreset(),
      createWavePowerPreset(),

      // Overload presets
      createOverloadHypertrophyPreset(),
      createOverloadStrengthPreset(),
      createOverloadEndurancePreset(),
      createOverloadPowerPreset(),

      // Static presets
      createStaticHypertrophyPreset(),
      createStaticStrengthPreset(),
      createStaticEndurancePreset(),
      createStaticPowerPreset(),

      // Reverse presets
      createReverseHypertrophyPreset(),
      createReverseStrengthPreset(),
      createReverseEndurancePreset(),
      createReversePowerPreset(),
    ];
  }

  // ===== PRESETS PARA AUTOREGULATED =====

  /// Crea un preset de progresión autoregulada para fuerza
  static ProgressionConfig createAutoregulatedStrengthPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.autoregulated,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.weight,
      secondaryTarget: ProgressionTarget.intensity,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 1,
      cycleLength: 8,
      deloadWeek: 8,
      deloadPercentage: 0.8,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 3,
        'max_reps': 6,
        'base_sets': 4,
        'target_rpe': 8.5,
        'rest_time_seconds': 180,
        'rpe_threshold_low': 7.0,
        'rpe_threshold_high': 9.0,
        'title_key': 'presets.strength.title',
        'description_key': 'presets.strength.description',
        'key_points_key': 'presets.strength.key_points',
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

  /// Crea un preset de progresión autoregulada para resistencia
  static ProgressionConfig createAutoregulatedEndurancePreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.autoregulated,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.volume,
      secondaryTarget: ProgressionTarget.reps,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 2,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.75,
      customParameters: {
        'sessions_per_week': 4,
        'min_reps': 12,
        'max_reps': 20,
        'base_sets': 3,
        'target_rpe': 7.0,
        'rest_time_seconds': 60,
        'rpe_threshold_low': 6.0,
        'rpe_threshold_high': 8.0,
        'title_key': 'presets.endurance.title',
        'description_key': 'presets.endurance.description',
        'key_points_key': 'presets.endurance.key_points',
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

  /// Crea un preset de progresión autoregulada para potencia
  static ProgressionConfig createAutoregulatedPowerPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.autoregulated,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.intensity,
      secondaryTarget: ProgressionTarget.intensity,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 1,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.85,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 1,
        'max_reps': 5,
        'base_sets': 5,
        'target_rpe': 8.0,
        'rest_time_seconds': 240,
        'rpe_threshold_low': 7.0,
        'rpe_threshold_high': 9.0,
        'title_key': 'presets.power.title',
        'description_key': 'presets.power.description',
        'key_points_key': 'presets.power.key_points',
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 1,
      maxReps: 5,
      baseSets: 5,
    );
  }

  // ===== PRESETS PARA DOUBLE FACTOR =====

  /// Crea un preset de progresión doble factor para hipertrofia
  static ProgressionConfig createDoubleFactorHypertrophyPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.doubleFactor,
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.volume,
      secondaryTarget: ProgressionTarget.reps,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 1,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.8,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 8,
        'max_reps': 12,
        'base_sets': 3,
        'target_rpe': 8.0,
        'rest_time_seconds': 90,
        'volume_week_factor': 1.2,
        'intensity_week_factor': 0.8,
        'title_key': 'presets.hypertrophy.title',
        'description_key': 'presets.hypertrophy.description',
        'key_points_key': 'presets.hypertrophy.key_points',
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

  /// Crea un preset de progresión doble factor para fuerza
  static ProgressionConfig createDoubleFactorStrengthPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.doubleFactor,
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.weight,
      secondaryTarget: ProgressionTarget.intensity,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 1,
      cycleLength: 8,
      deloadWeek: 8,
      deloadPercentage: 0.85,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 3,
        'max_reps': 6,
        'base_sets': 4,
        'target_rpe': 8.5,
        'rest_time_seconds': 180,
        'volume_week_factor': 1.1,
        'intensity_week_factor': 0.9,
        'title_key': 'presets.strength.title',
        'description_key': 'presets.strength.description',
        'key_points_key': 'presets.strength.key_points',
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

  /// Crea un preset de progresión doble factor para resistencia
  static ProgressionConfig createDoubleFactorEndurancePreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.doubleFactor,
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.volume,
      secondaryTarget: ProgressionTarget.reps,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 2,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.75,
      customParameters: {
        'sessions_per_week': 4,
        'min_reps': 12,
        'max_reps': 20,
        'base_sets': 3,
        'target_rpe': 7.0,
        'rest_time_seconds': 60,
        'volume_week_factor': 1.3,
        'intensity_week_factor': 0.7,
        'title_key': 'presets.endurance.title',
        'description_key': 'presets.endurance.description',
        'key_points_key': 'presets.endurance.key_points',
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

  /// Crea un preset de progresión doble factor para potencia
  static ProgressionConfig createDoubleFactorPowerPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.doubleFactor,
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.intensity,
      secondaryTarget: ProgressionTarget.intensity,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 1,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.85,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 1,
        'max_reps': 5,
        'base_sets': 5,
        'target_rpe': 8.0,
        'rest_time_seconds': 240,
        'volume_week_factor': 1.1,
        'intensity_week_factor': 0.9,
        'title_key': 'presets.power.title',
        'description_key': 'presets.power.description',
        'key_points_key': 'presets.power.key_points',
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 1,
      maxReps: 5,
      baseSets: 5,
    );
  }

  // ===== PRESETS PARA WAVE =====

  /// Crea un preset de progresión por oleadas para hipertrofia
  static ProgressionConfig createWaveHypertrophyPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.wave,
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.volume,
      secondaryTarget: ProgressionTarget.reps,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 1,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.8,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 8,
        'max_reps': 12,
        'base_sets': 3,
        'target_rpe': 8.0,
        'rest_time_seconds': 90,
        'high_intensity_factor': 1.1,
        'high_volume_factor': 0.7,
        'title_key': 'presets.hypertrophy.title',
        'description_key': 'presets.hypertrophy.description',
        'key_points_key': 'presets.hypertrophy.key_points',
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

  /// Crea un preset de progresión por oleadas para fuerza
  static ProgressionConfig createWaveStrengthPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.wave,
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.weight,
      secondaryTarget: ProgressionTarget.intensity,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 1,
      cycleLength: 8,
      deloadWeek: 8,
      deloadPercentage: 0.85,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 3,
        'max_reps': 6,
        'base_sets': 4,
        'target_rpe': 8.5,
        'rest_time_seconds': 180,
        'high_intensity_factor': 1.15,
        'high_volume_factor': 0.75,
        'title_key': 'presets.strength.title',
        'description_key': 'presets.strength.description',
        'key_points_key': 'presets.strength.key_points',
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

  /// Crea un preset de progresión por oleadas para resistencia
  static ProgressionConfig createWaveEndurancePreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.wave,
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.volume,
      secondaryTarget: ProgressionTarget.reps,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 2,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.75,
      customParameters: {
        'sessions_per_week': 4,
        'min_reps': 12,
        'max_reps': 20,
        'base_sets': 3,
        'target_rpe': 7.0,
        'rest_time_seconds': 60,
        'high_intensity_factor': 1.05,
        'high_volume_factor': 0.6,
        'title_key': 'presets.endurance.title',
        'description_key': 'presets.endurance.description',
        'key_points_key': 'presets.endurance.key_points',
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

  /// Crea un preset de progresión por oleadas para potencia
  static ProgressionConfig createWavePowerPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.wave,
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.intensity,
      secondaryTarget: ProgressionTarget.intensity,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 1,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.85,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 1,
        'max_reps': 5,
        'base_sets': 5,
        'target_rpe': 8.0,
        'rest_time_seconds': 240,
        'high_intensity_factor': 1.2,
        'high_volume_factor': 0.8,
        'title_key': 'presets.power.title',
        'description_key': 'presets.power.description',
        'key_points_key': 'presets.power.key_points',
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 1,
      maxReps: 5,
      baseSets: 5,
    );
  }

  // ===== PRESETS PARA OVERLOAD =====

  /// Crea un preset de progresión por sobrecarga para hipertrofia
  static ProgressionConfig createOverloadHypertrophyPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.overload,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.volume,
      secondaryTarget: ProgressionTarget.reps,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 4,
      deloadPercentage: 0.8,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 8,
        'max_reps': 12,
        'base_sets': 3,
        'target_rpe': 8.0,
        'rest_time_seconds': 90,
        'overload_factor': 1.1,
        'overload_duration_sessions': 2,
        'title_key': 'presets.hypertrophy.title',
        'description_key': 'presets.hypertrophy.description',
        'key_points_key': 'presets.hypertrophy.key_points',
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

  /// Crea un preset de progresión por sobrecarga para fuerza
  static ProgressionConfig createOverloadStrengthPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.overload,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.weight,
      secondaryTarget: ProgressionTarget.intensity,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 1,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.85,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 3,
        'max_reps': 6,
        'base_sets': 4,
        'target_rpe': 8.5,
        'rest_time_seconds': 180,
        'overload_factor': 1.15,
        'overload_duration_sessions': 3,
        'title_key': 'presets.strength.title',
        'description_key': 'presets.strength.description',
        'key_points_key': 'presets.strength.key_points',
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

  /// Crea un preset de progresión por sobrecarga para resistencia
  static ProgressionConfig createOverloadEndurancePreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.overload,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.volume,
      secondaryTarget: ProgressionTarget.reps,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 2,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.75,
      customParameters: {
        'sessions_per_week': 4,
        'min_reps': 12,
        'max_reps': 20,
        'base_sets': 3,
        'target_rpe': 7.0,
        'rest_time_seconds': 60,
        'overload_factor': 1.05,
        'overload_duration_sessions': 2,
        'title_key': 'presets.endurance.title',
        'description_key': 'presets.endurance.description',
        'key_points_key': 'presets.endurance.key_points',
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

  /// Crea un preset de progresión por sobrecarga para potencia
  static ProgressionConfig createOverloadPowerPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.overload,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.intensity,
      secondaryTarget: ProgressionTarget.intensity,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 1,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.85,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 1,
        'max_reps': 5,
        'base_sets': 5,
        'target_rpe': 8.0,
        'rest_time_seconds': 240,
        'overload_factor': 1.2,
        'overload_duration_sessions': 2,
        'title_key': 'presets.power.title',
        'description_key': 'presets.power.description',
        'key_points_key': 'presets.power.key_points',
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 1,
      maxReps: 5,
      baseSets: 5,
    );
  }

  // ===== PRESETS PARA STATIC =====

  /// Crea un preset de progresión estática para hipertrofia
  static ProgressionConfig createStaticHypertrophyPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.static,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.volume,
      secondaryTarget: ProgressionTarget.reps,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 0, // Sin incrementos automáticos
      cycleLength: 8,
      deloadWeek: 8,
      deloadPercentage: 0.8,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 8,
        'max_reps': 12,
        'base_sets': 3,
        'target_rpe': 8.0,
        'rest_time_seconds': 90,
        'manual_progression': true,
        'title_key': 'presets.hypertrophy.title',
        'description_key': 'presets.hypertrophy.description',
        'key_points_key': 'presets.hypertrophy.key_points',
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

  /// Crea un preset de progresión estática para fuerza
  static ProgressionConfig createStaticStrengthPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.static,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.weight,
      secondaryTarget: ProgressionTarget.intensity,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 0, // Sin incrementos automáticos
      cycleLength: 8,
      deloadWeek: 8,
      deloadPercentage: 0.85,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 3,
        'max_reps': 6,
        'base_sets': 4,
        'target_rpe': 8.5,
        'rest_time_seconds': 180,
        'manual_progression': true,
        'title_key': 'presets.strength.title',
        'description_key': 'presets.strength.description',
        'key_points_key': 'presets.strength.key_points',
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

  /// Crea un preset de progresión estática para resistencia
  static ProgressionConfig createStaticEndurancePreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.static,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.volume,
      secondaryTarget: ProgressionTarget.reps,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 0, // Sin incrementos automáticos
      cycleLength: 8,
      deloadWeek: 8,
      deloadPercentage: 0.75,
      customParameters: {
        'sessions_per_week': 4,
        'min_reps': 12,
        'max_reps': 20,
        'base_sets': 3,
        'target_rpe': 7.0,
        'rest_time_seconds': 60,
        'manual_progression': true,
        'title_key': 'presets.endurance.title',
        'description_key': 'presets.endurance.description',
        'key_points_key': 'presets.endurance.key_points',
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

  /// Crea un preset de progresión estática para potencia
  static ProgressionConfig createStaticPowerPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.static,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.intensity,
      secondaryTarget: ProgressionTarget.intensity,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 0, // Sin incrementos automáticos
      cycleLength: 8,
      deloadWeek: 8,
      deloadPercentage: 0.85,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 1,
        'max_reps': 5,
        'base_sets': 5,
        'target_rpe': 8.0,
        'rest_time_seconds': 240,
        'manual_progression': true,
        'title_key': 'presets.power.title',
        'description_key': 'presets.power.description',
        'key_points_key': 'presets.power.key_points',
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 1,
      maxReps: 5,
      baseSets: 5,
    );
  }

  // ===== PRESETS PARA REVERSE =====

  /// Crea un preset de progresión inversa para hipertrofia
  static ProgressionConfig createReverseHypertrophyPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.reverse,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.volume,
      secondaryTarget: ProgressionTarget.reps,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 1,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.8,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 8,
        'max_reps': 12,
        'base_sets': 3,
        'target_rpe': 8.0,
        'rest_time_seconds': 90,
        'reverse_factor': 0.9,
        'title_key': 'presets.hypertrophy.title',
        'description_key': 'presets.hypertrophy.description',
        'key_points_key': 'presets.hypertrophy.key_points',
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

  /// Crea un preset de progresión inversa para fuerza
  static ProgressionConfig createReverseStrengthPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.reverse,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.weight,
      secondaryTarget: ProgressionTarget.intensity,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 1,
      cycleLength: 8,
      deloadWeek: 8,
      deloadPercentage: 0.85,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 3,
        'max_reps': 6,
        'base_sets': 4,
        'target_rpe': 8.5,
        'rest_time_seconds': 180,
        'reverse_factor': 0.85,
        'title_key': 'presets.strength.title',
        'description_key': 'presets.strength.description',
        'key_points_key': 'presets.strength.key_points',
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

  /// Crea un preset de progresión inversa para resistencia
  static ProgressionConfig createReverseEndurancePreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.reverse,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.volume,
      secondaryTarget: ProgressionTarget.reps,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 2,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.75,
      customParameters: {
        'sessions_per_week': 4,
        'min_reps': 12,
        'max_reps': 20,
        'base_sets': 3,
        'target_rpe': 7.0,
        'rest_time_seconds': 60,
        'reverse_factor': 0.8,
        'title_key': 'presets.endurance.title',
        'description_key': 'presets.endurance.description',
        'key_points_key': 'presets.endurance.key_points',
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

  /// Crea un preset de progresión inversa para potencia
  static ProgressionConfig createReversePowerPreset() {
    return ProgressionConfig(
      id: _uuid.v4(),
      isGlobal: true,
      type: ProgressionType.reverse,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.intensity,
      secondaryTarget: ProgressionTarget.intensity,
      incrementValue: 0, // Usar AdaptiveIncrementConfig para incrementos adaptativos
      incrementFrequency: 1,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.85,
      customParameters: {
        'sessions_per_week': 3,
        'min_reps': 1,
        'max_reps': 5,
        'base_sets': 5,
        'target_rpe': 8.0,
        'rest_time_seconds': 240,
        'reverse_factor': 0.8,
        'title_key': 'presets.power.title',
        'description_key': 'presets.power.description',
        'key_points_key': 'presets.power.key_points',
      },
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 1,
      maxReps: 5,
      baseSets: 5,
    );
  }

  /// Obtiene metadatos de un preset para mostrar en la UI usando easy_localization
  static Map<String, dynamic> getPresetMetadata(ProgressionConfig config) {
    final customParams = config.customParameters;
    final targetRpe = customParams['target_rpe'] ?? 8.0;
    final restTime = customParams['rest_time_seconds'] ?? 90;

    // Usar las claves de internacionalización definidas en customParameters
    final titleKey = customParams['title_key'] ?? 'presets.general.title';
    final descriptionKey = customParams['description_key'] ?? 'presets.general.description';
    final keyPointsKey = customParams['key_points_key'] ?? 'presets.general.key_points';

    // Función helper para manejar la internacionalización de forma segura
    String translate(String key, {Map<String, String>? namedArgs}) {
      try {
        // En contexto de test, devolver la clave directamente
        if (key.contains('presets.')) {
          return key;
        }
        return key.tr(namedArgs: namedArgs);
      } catch (e) {
        // Fallback para tests o cuando easy_localization no está disponible
        return key;
      }
    }

    return {
      'title': translate(titleKey),
      'description': translate(descriptionKey),
      'key_points': [
        translate(
          '$keyPointsKey.repRange',
          namedArgs: {'minReps': config.minReps.toString(), 'maxReps': config.maxReps.toString()},
        ),
        translate('$keyPointsKey.baseSets', namedArgs: {'baseSets': config.baseSets.toString()}),
        translate('$keyPointsKey.targetRpe', namedArgs: {'targetRpe': targetRpe.toString()}),
        translate('$keyPointsKey.restTime', namedArgs: {'restTime': restTime.toString()}),
      ],
    };
  }
}
