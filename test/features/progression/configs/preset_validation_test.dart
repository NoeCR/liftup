import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/progression/configs/preset_progression_configs.dart';

/// Tests para validar la funcionalidad de presets de progresión
/// Verifica que cada preset tenga la configuración correcta para su objetivo
void main() {
  group('Preset Progression Configs Validation', () {
    group('Linear Presets', () {
      test('linear hypertrophy preset tiene configuración correcta', () {
        final preset = PresetProgressionConfigs.createLinearHypertrophyPreset();

        // Verificar tipo y objetivo
        expect(preset.type, equals(ProgressionType.linear));
        expect(preset.getTrainingObjective(), equals('hypertrophy'));

        // Verificar rangos para hipertrofia
        expect(preset.minReps, greaterThanOrEqualTo(6));
        expect(preset.maxReps, lessThanOrEqualTo(12));
        expect(preset.baseSets, greaterThanOrEqualTo(3));

        // Verificar ciclo y deload
        expect(preset.cycleLength, greaterThan(0));
        expect(preset.deloadWeek, greaterThan(0));
        expect(preset.deloadPercentage, lessThan(1.0));

        // Verificar parámetros personalizados
        expect(preset.customParameters, isNotEmpty);
        expect(preset.customParameters['title_key'], equals('presets.hypertrophy.title'));
      });

      test('linear strength preset tiene configuración correcta', () {
        final preset = PresetProgressionConfigs.createLinearStrengthPreset();

        expect(preset.type, equals(ProgressionType.linear));
        expect(preset.getTrainingObjective(), equals('strength'));

        // Verificar rangos para fuerza (menos reps, más peso)
        expect(preset.minReps, lessThanOrEqualTo(6));
        expect(preset.maxReps, lessThanOrEqualTo(8));
        expect(preset.baseSets, greaterThanOrEqualTo(3));

        // El preset debe usar AdaptiveIncrementConfig para incrementos adaptativos
        expect(preset.incrementValue, greaterThanOrEqualTo(0));
      });

      test('linear endurance preset tiene configuración correcta', () {
        final preset = PresetProgressionConfigs.createLinearEndurancePreset();

        expect(preset.type, equals(ProgressionType.linear));
        expect(preset.getTrainingObjective(), equals('endurance'));

        // Verificar rangos para resistencia (más reps, menos peso)
        expect(preset.minReps, greaterThanOrEqualTo(12));
        expect(preset.maxReps, greaterThanOrEqualTo(15));
      });

      test('linear power preset tiene configuración correcta', () {
        final preset = PresetProgressionConfigs.createLinearPowerPreset();

        expect(preset.type, equals(ProgressionType.linear));
        expect(preset.getTrainingObjective(), equals('power'));

        // Verificar rangos para potencia (pocas reps, explosivo)
        expect(preset.minReps, lessThanOrEqualTo(6));
        expect(preset.maxReps, lessThanOrEqualTo(8));
      });
    });

    group('Undulating Presets', () {
      test('undulating hypertrophy preset alterna correctamente', () {
        final preset = PresetProgressionConfigs.createUndulatingHypertrophyPreset();

        expect(preset.type, equals(ProgressionType.undulating));
        expect(preset.getTrainingObjective(), equals('hypertrophy'));

        // Verificar que tiene configuración para diferentes días
        expect(preset.customParameters, isNotEmpty);
      });

      test('undulating strength preset alterna correctamente', () {
        final preset = PresetProgressionConfigs.createUndulatingStrengthPreset();

        expect(preset.type, equals(ProgressionType.undulating));
        expect(preset.getTrainingObjective(), equals('strength'));
      });
    });

    // Wave presets se pueden agregar en el futuro

    group('Preset Metadata', () {
      test('todos los presets tienen metadata válida', () {
        final allPresets = PresetProgressionConfigs.getAllPresets();

        for (final preset in allPresets) {
          final metadata = PresetProgressionConfigs.getPresetMetadata(preset);

          // Verificar que tiene título y descripción
          expect(metadata['title'], isNotEmpty);
          expect(metadata['description'], isNotEmpty);

          // Verificar que tiene key_points
          expect(metadata['key_points'], isNotEmpty);
          expect(metadata['key_points'], isA<List>());
        }
      });

      test('presets están agrupados correctamente por objetivo', () {
        final allPresets = PresetProgressionConfigs.getAllPresets();
        final objectives = <String>{};

        for (final preset in allPresets) {
          final objective = preset.getTrainingObjective();
          objectives.add(objective);
        }

        // Verificar que tenemos los 4 objetivos principales
        expect(objectives, contains('hypertrophy'));
        expect(objectives, contains('strength'));
        expect(objectives, contains('endurance'));
        expect(objectives, contains('power'));
      });
    });

    group('Preset Consistency', () {
      test('todos los presets tienen parámetros requeridos', () {
        final allPresets = PresetProgressionConfigs.getAllPresets();

        for (final preset in allPresets) {
          // Verificar campos requeridos
          expect(preset.id, isNotEmpty);
          expect(preset.type, isNotNull);
          expect(preset.unit, isNotNull);
          expect(preset.incrementValue, greaterThanOrEqualTo(0));
          expect(preset.incrementFrequency, greaterThanOrEqualTo(0));
          expect(preset.cycleLength, greaterThanOrEqualTo(0));
          expect(preset.minReps, greaterThan(0));
          expect(preset.maxReps, greaterThanOrEqualTo(preset.minReps));
          expect(preset.baseSets, greaterThan(0));
        }
      });

      test('presets con deload tienen configuración válida', () {
        final allPresets = PresetProgressionConfigs.getAllPresets();

        for (final preset in allPresets) {
          if (preset.deloadWeek > 0) {
            // Si tiene deload, debe estar dentro del ciclo
            expect(preset.deloadWeek, lessThanOrEqualTo(preset.cycleLength));

            // Deload percentage debe ser menor a 1.0
            expect(preset.deloadPercentage, lessThan(1.0));
            expect(preset.deloadPercentage, greaterThan(0.0));
          }
        }
      });
    });
  });
}
