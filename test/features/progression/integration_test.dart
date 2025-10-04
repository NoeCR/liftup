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
      expect(
        allTargets.length,
        5,
      ); // 5 objetivos (peso, reps, sets, volumen, intensidad)
    });

    test('should validate progression type consistency', () {
      // Arrange & Act
      final types = ProgressionType.values;

      // Assert - Verificar que cada tipo tiene displayName y description
      for (final type in types) {
        expect(
          type.displayName,
          isNotEmpty,
          reason: '${type.name} should have displayName',
        );
        expect(
          type.description,
          isNotEmpty,
          reason: '${type.name} should have description',
        );
      }
    });

    test('should validate progression unit consistency', () {
      // Arrange & Act
      final units = ProgressionUnit.values;

      // Assert - Verificar que cada unidad tiene displayName
      for (final unit in units) {
        expect(
          unit.displayName,
          isNotEmpty,
          reason: '${unit.name} should have displayName',
        );
      }
    });

    test('should validate progression target consistency', () {
      // Arrange & Act
      final targets = ProgressionTarget.values;

      // Assert - Verificar que cada objetivo tiene displayName
      for (final target in targets) {
        expect(
          target.displayName,
          isNotEmpty,
          reason: '${target.name} should have displayName',
        );
      }
    });

    test('should validate progression type uniqueness', () {
      // Arrange & Act
      final types = ProgressionType.values;
      final displayNames = types.map((t) => t.displayName).toList();
      final descriptions = types.map((t) => t.description).toList();

      // Assert - Verificar que no hay duplicados
      expect(
        displayNames.toSet().length,
        displayNames.length,
        reason: 'Display names should be unique',
      );
      expect(
        descriptions.toSet().length,
        descriptions.length,
        reason: 'Descriptions should be unique',
      );
    });

    test('should validate progression unit uniqueness', () {
      // Arrange & Act
      final units = ProgressionUnit.values;
      final displayNames = units.map((u) => u.displayName).toList();

      // Assert - Verificar que no hay duplicados
      expect(
        displayNames.toSet().length,
        displayNames.length,
        reason: 'Display names should be unique',
      );
    });

    test('should validate progression target uniqueness', () {
      // Arrange & Act
      final targets = ProgressionTarget.values;
      final displayNames = targets.map((t) => t.displayName).toList();

      // Assert - Verificar que no hay duplicados
      expect(
        displayNames.toSet().length,
        displayNames.length,
        reason: 'Display names should be unique',
      );
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
      final expectedUnits = [
        ProgressionUnit.session,
        ProgressionUnit.week,
        ProgressionUnit.cycle,
      ];

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
      final linearDisplayName = ProgressionType.linear.displayName;
      final undulatingDisplayName = ProgressionType.undulating.displayName;
      final steppedDisplayName = ProgressionType.stepped.displayName;
      final doubleDisplayName = ProgressionType.double.displayName;
      final waveDisplayName = ProgressionType.wave.displayName;
      final staticDisplayName = ProgressionType.static.displayName;
      final reverseDisplayName = ProgressionType.reverse.displayName;

      // Assert - Verificar que están en español
      expect(linearDisplayName, contains('Lineal'));
      expect(undulatingDisplayName, contains('Ondulante'));
      expect(steppedDisplayName, contains('Escalonada'));
      expect(doubleDisplayName, contains('Doble'));
      expect(waveDisplayName, contains('Oleadas'));
      expect(staticDisplayName, contains('Estática'));
      expect(reverseDisplayName, contains('Inversa'));
    });

    test('should validate progression unit display names in Spanish', () {
      // Arrange & Act
      final sessionDisplayName = ProgressionUnit.session.displayName;
      final weekDisplayName = ProgressionUnit.week.displayName;

      // Assert - Verificar que están en español
      expect(sessionDisplayName, contains('sesión'));
      expect(weekDisplayName, contains('semana'));

      // Test cycle unit
      final cycleDisplayName = ProgressionUnit.cycle.displayName;
      expect(cycleDisplayName, contains('ciclo'));
    });

    test('should validate progression target display names in Spanish', () {
      // Arrange & Act
      final weightDisplayName = ProgressionTarget.weight.displayName;
      final repsDisplayName = ProgressionTarget.reps.displayName;
      final setsDisplayName = ProgressionTarget.sets.displayName;
      final volumeDisplayName = ProgressionTarget.volume.displayName;

      // Assert - Verificar que están en español
      expect(weightDisplayName, contains('Peso'));
      expect(repsDisplayName, contains('Repeticiones'));
      expect(setsDisplayName, contains('Series'));
      expect(volumeDisplayName, contains('Volumen'));

      // Test intensity target
      final intensityDisplayName = ProgressionTarget.intensity.displayName;
      expect(intensityDisplayName, contains('Intensidad'));
    });

    test('should validate progression type descriptions are informative', () {
      // Arrange & Act
      final types = ProgressionType.values;

      // Assert - Verificar que las descripciones son informativas (más de 10 caracteres)
      for (final type in types) {
        expect(
          type.description.length,
          greaterThan(10),
          reason: '${type.name} description should be informative',
        );
      }
    });

    test(
      'should validate progression type descriptions contain key concepts',
      () {
        // Arrange & Act
        final linearDescription = ProgressionType.linear.description;
        final undulatingDescription = ProgressionType.undulating.description;
        final steppedDescription = ProgressionType.stepped.description;
        final doubleDescription = ProgressionType.double.description;
        final waveDescription = ProgressionType.wave.description;
        final staticDescription = ProgressionType.static.description;
        final reverseDescription = ProgressionType.reverse.description;

        // Assert - Verificar que contienen conceptos clave
        expect(linearDescription.toLowerCase(), contains('incremento'));
        expect(undulatingDescription.toLowerCase(), contains('variación'));
        expect(steppedDescription.toLowerCase(), contains('deload'));
        expect(doubleDescription.toLowerCase(), contains('repeticiones'));
        expect(waveDescription.toLowerCase(), contains('ciclos'));
        expect(staticDescription.toLowerCase(), contains('constante'));
        expect(reverseDescription.toLowerCase(), contains('reduce'));
      },
    );

    test('should validate progression type enum serialization', () {
      // Arrange & Act
      final types = ProgressionType.values;

      // Assert - Verificar que se pueden serializar/deserializar
      for (final type in types) {
        final serialized = type.name;
        final deserialized = ProgressionType.values.firstWhere(
          (t) => t.name == serialized,
        );
        expect(
          deserialized,
          type,
          reason: '${type.name} should serialize/deserialize correctly',
        );
      }
    });

    test('should validate progression unit enum serialization', () {
      // Arrange & Act
      final units = ProgressionUnit.values;

      // Assert - Verificar que se pueden serializar/deserializar
      for (final unit in units) {
        final serialized = unit.name;
        final deserialized = ProgressionUnit.values.firstWhere(
          (u) => u.name == serialized,
        );
        expect(
          deserialized,
          unit,
          reason: '${unit.name} should serialize/deserialize correctly',
        );
      }
    });

    test('should validate progression target enum serialization', () {
      // Arrange & Act
      final targets = ProgressionTarget.values;

      // Assert - Verificar que se pueden serializar/deserializar
      for (final target in targets) {
        final serialized = target.name;
        final deserialized = ProgressionTarget.values.firstWhere(
          (t) => t.name == serialized,
        );
        expect(
          deserialized,
          target,
          reason: '${target.name} should serialize/deserialize correctly',
        );
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
        expect(type.displayName, isNotEmpty);
        expect(type.description, isNotEmpty);
      }
    });
  });
}
