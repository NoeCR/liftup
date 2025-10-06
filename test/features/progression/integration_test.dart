import 'package:flutter_test/flutter_test.dart';
import 'package:liftup/common/enums/progression_type_enum.dart';

void main() {
  group('Progression Integration Tests', () {
    test('should validate progression type enum integration', () {
      // Arrange & Act
      final allTypes = ProgressionType.values;
      final allUnits = ProgressionUnit.values;
      final allTargets = ProgressionTarget.values;

      // Assert
      expect(allTypes.length, 11); // 11 tipos de progresión
      expect(allUnits.length, 3); // 3 unidades (sesión, semana, ciclo)
      expect(allTargets.length, 5); // 5 objetivos (peso, reps, sets, volumen, intensidad)
    });

    test('should validate progression type consistency', () {
      // Arrange & Act
      final types = ProgressionType.values;

      // Assert - Verificar que cada tipo tiene displayName y description
      for (final type in types) {
        expect(type.displayNameKey, isNotEmpty, reason: '${type.name} should have displayName');
        expect(type.descriptionKey, isNotEmpty, reason: '${type.name} should have description');
      }
    });

    test('should validate progression unit consistency', () {
      // Arrange & Act
      final units = ProgressionUnit.values;

      // Assert - Verificar que cada unidad tiene displayName
      for (final unit in units) {
        expect(unit.displayNameKey, isNotEmpty, reason: '${unit.name} should have displayName');
      }
    });

    test('should validate progression target consistency', () {
      // Arrange & Act
      final targets = ProgressionTarget.values;

      // Assert - Verificar que cada objetivo tiene displayName
      for (final target in targets) {
        expect(target.displayNameKey, isNotEmpty, reason: '${target.name} should have displayName');
      }
    });

    test('should validate progression type uniqueness', () {
      // Arrange & Act
      final types = ProgressionType.values;
      final displayNames = types.map((t) => t.displayNameKey).toList();
      final descriptions = types.map((t) => t.descriptionKey).toList();

      // Assert - Verificar que no hay duplicados
      expect(displayNames.toSet().length, displayNames.length, reason: 'Display names should be unique');
      expect(descriptions.toSet().length, descriptions.length, reason: 'Descriptions should be unique');
    });

    test('should validate progression unit uniqueness', () {
      // Arrange & Act
      final units = ProgressionUnit.values;
      final displayNames = units.map((u) => u.displayNameKey).toList();

      // Assert - Verificar que no hay duplicados
      expect(displayNames.toSet().length, displayNames.length, reason: 'Display names should be unique');
    });

    test('should validate progression target uniqueness', () {
      // Arrange & Act
      final targets = ProgressionTarget.values;
      final displayNames = targets.map((t) => t.displayNameKey).toList();

      // Assert - Verificar que no hay duplicados
      expect(displayNames.toSet().length, displayNames.length, reason: 'Display names should be unique');
    });

    test('should validate progression type enum values', () {
      // Arrange & Act
      final expectedTypes = [
        ProgressionType.none,
        ProgressionType.linear,
        ProgressionType.undulating,
        ProgressionType.stepped,
        ProgressionType.double,
        ProgressionType.autoregulated,
        ProgressionType.doubleFactor,
        ProgressionType.overload,
        ProgressionType.wave,
        ProgressionType.static,
        ProgressionType.reverse,
      ];

      // Assert
      expect(ProgressionType.values, containsAll(expectedTypes));
    });

    test('should validate progression unit enum values', () {
      // Arrange & Act
      final expectedUnits = [ProgressionUnit.session, ProgressionUnit.week, ProgressionUnit.cycle];

      // Assert
      expect(ProgressionUnit.values, containsAll(expectedUnits));
    });

    test('should validate progression target enum values', () {
      // Arrange & Act
      final expectedTargets = [
        ProgressionTarget.weight,
        ProgressionTarget.reps,
        ProgressionTarget.sets,
        ProgressionTarget.volume,
        ProgressionTarget.intensity,
      ];

      // Assert
      expect(ProgressionTarget.values, containsAll(expectedTargets));
    });

    test('should validate progression type display names in Spanish', () {
      // Arrange & Act
      final linearDisplayName = ProgressionType.linear.displayNameKey;
      final undulatingDisplayName = ProgressionType.undulating.displayNameKey;
      final steppedDisplayName = ProgressionType.stepped.displayNameKey;
      final doubleDisplayName = ProgressionType.double.displayNameKey;
      final waveDisplayName = ProgressionType.wave.displayNameKey;
      final staticDisplayName = ProgressionType.static.displayNameKey;
      final reverseDisplayName = ProgressionType.reverse.displayNameKey;

      // Assert - Verificar que están en español
      expect(linearDisplayName, equals('progression.types.linear'));
      expect(undulatingDisplayName, equals('progression.types.undulating'));
      expect(steppedDisplayName, equals('progression.types.stepped'));
      expect(doubleDisplayName, equals('progression.types.double'));
      expect(waveDisplayName, equals('progression.types.wave'));
      expect(staticDisplayName, equals('progression.types.static'));
      expect(reverseDisplayName, equals('progression.types.reverse'));
    });

    test('should validate progression unit display names in Spanish', () {
      // Arrange & Act
      final sessionDisplayName = ProgressionUnit.session.displayNameKey;
      final weekDisplayName = ProgressionUnit.week.displayNameKey;

      // Assert - Verificar que están en español
      expect(sessionDisplayName, equals('progression.units.session'));
      expect(weekDisplayName, equals('progression.units.week'));

      // Test cycle unit
      final cycleDisplayName = ProgressionUnit.cycle.displayNameKey;
      expect(cycleDisplayName, equals('progression.units.cycle'));
    });

    test('should validate progression target display names in Spanish', () {
      // Arrange & Act
      final weightDisplayName = ProgressionTarget.weight.displayNameKey;
      final repsDisplayName = ProgressionTarget.reps.displayNameKey;
      final setsDisplayName = ProgressionTarget.sets.displayNameKey;
      final volumeDisplayName = ProgressionTarget.volume.displayNameKey;

      // Assert - Verificar que están en español
      expect(weightDisplayName, equals('progression.targets.weight'));
      expect(repsDisplayName, equals('progression.targets.reps'));
      expect(setsDisplayName, equals('progression.targets.sets'));
      expect(volumeDisplayName, equals('progression.targets.volume'));

      // Test intensity target
      final intensityDisplayName = ProgressionTarget.intensity.displayNameKey;
      expect(intensityDisplayName, equals('progression.targets.intensity'));
    });

    test('should validate progression type descriptions are informative', () {
      // Arrange & Act
      final types = ProgressionType.values;

      // Assert - Verificar que las descripciones son informativas (más de 10 caracteres)
      for (final type in types) {
        expect(type.descriptionKey.length, greaterThan(10), reason: '${type.name} description should be informative');
      }
    });

    test('should validate progression type descriptions contain key concepts', () {
      // Arrange & Act
      final linearDescription = ProgressionType.linear.descriptionKey;
      final undulatingDescription = ProgressionType.undulating.descriptionKey;
      final steppedDescription = ProgressionType.stepped.descriptionKey;
      final doubleDescription = ProgressionType.double.descriptionKey;
      final waveDescription = ProgressionType.wave.descriptionKey;
      final staticDescription = ProgressionType.static.descriptionKey;
      final reverseDescription = ProgressionType.reverse.descriptionKey;

      // Assert - Verificar que contienen conceptos clave
      expect(linearDescription, equals('progression.types.linearDescription'));
      expect(undulatingDescription, equals('progression.types.undulatingDescription'));
      expect(steppedDescription, equals('progression.types.steppedDescription'));
      expect(doubleDescription, equals('progression.types.doubleDescription'));
      expect(waveDescription, equals('progression.types.waveDescription'));
      expect(staticDescription, equals('progression.types.staticDescription'));
      expect(reverseDescription, equals('progression.types.reverseDescription'));
    });

    test('should validate progression type enum serialization', () {
      // Arrange & Act
      final types = ProgressionType.values;

      // Assert - Verificar que se pueden serializar/deserializar
      for (final type in types) {
        final serialized = type.name;
        final deserialized = ProgressionType.values.firstWhere((t) => t.name == serialized);
        expect(deserialized, type, reason: '${type.name} should serialize/deserialize correctly');
      }
    });

    test('should validate progression unit enum serialization', () {
      // Arrange & Act
      final units = ProgressionUnit.values;

      // Assert - Verificar que se pueden serializar/deserializar
      for (final unit in units) {
        final serialized = unit.name;
        final deserialized = ProgressionUnit.values.firstWhere((u) => u.name == serialized);
        expect(deserialized, unit, reason: '${unit.name} should serialize/deserialize correctly');
      }
    });

    test('should validate progression target enum serialization', () {
      // Arrange & Act
      final targets = ProgressionTarget.values;

      // Assert - Verificar que se pueden serializar/deserializar
      for (final target in targets) {
        final serialized = target.name;
        final deserialized = ProgressionTarget.values.firstWhere((t) => t.name == serialized);
        expect(deserialized, target, reason: '${target.name} should serialize/deserialize correctly');
      }
    });

    test('should validate progression type enum completeness', () {
      // Arrange & Act
      final types = ProgressionType.values;

      // Assert - Verificar que tenemos todos los tipos esperados
      expect(types.contains(ProgressionType.linear), isTrue);
      expect(types.contains(ProgressionType.undulating), isTrue);
      expect(types.contains(ProgressionType.stepped), isTrue);
      expect(types.contains(ProgressionType.double), isTrue);
      expect(types.contains(ProgressionType.wave), isTrue);
      expect(types.contains(ProgressionType.static), isTrue);
      expect(types.contains(ProgressionType.reverse), isTrue);
      expect(types.contains(ProgressionType.none), isTrue);
      expect(types.contains(ProgressionType.autoregulated), isTrue);
      expect(types.contains(ProgressionType.doubleFactor), isTrue);
      expect(types.contains(ProgressionType.overload), isTrue);
    });

    test('should validate progression type enum ordering', () {
      // Arrange & Act
      final types = ProgressionType.values;

      // Assert - Verificar que el orden es consistente
      expect(types.first, ProgressionType.none);
      expect(types.last, ProgressionType.reverse);
    });

    test('should validate progression type enum accessibility', () {
      // Arrange & Act
      final types = ProgressionType.values;

      // Assert - Verificar que se puede acceder a cada tipo
      for (final type in types) {
        expect(type, isNotNull);
        expect(type.name, isNotEmpty);
        expect(type.displayNameKey, isNotEmpty);
        expect(type.descriptionKey, isNotEmpty);
      }
    });
  });
}
