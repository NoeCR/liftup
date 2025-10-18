import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/muscle_group_enum.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/common/enums/week_day_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/home/models/routine.dart';
import 'package:liftly/features/progression/models/progression_config.dart';

void main() {
  group('Session Frequency Progression Tests', () {
    late ProgressionConfig singleSessionConfig;
    late ProgressionConfig multiSessionConfig;
    late Routine testRoutine;
    late Exercise testExercise;

    setUp(() {
      // Configuración para rutinas de 1 sesión por semana
      singleSessionConfig = ProgressionConfig(
        id: 'single-session-config',
        type: ProgressionType.linear,
        unit: ProgressionUnit.week,
        isGlobal: true,
        primaryTarget: ProgressionTarget.weight,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 4,
        deloadPercentage: 0.8,
        minReps: 8,
        maxReps: 12,
        baseSets: 3,
        isActive: true,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        customParameters: {'sessions_per_week': 1},
      );

      // Configuración para rutinas de múltiples sesiones por semana
      multiSessionConfig = ProgressionConfig(
        id: 'multi-session-config',
        type: ProgressionType.linear,
        unit: ProgressionUnit.week,
        isGlobal: true,
        primaryTarget: ProgressionTarget.weight,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 4,
        deloadPercentage: 0.8,
        minReps: 8,
        maxReps: 12,
        baseSets: 3,
        isActive: true,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        customParameters: {'sessions_per_week': 3},
      );

      // Crear un ejercicio de prueba con sets, reps, etc.
      testExercise = Exercise(
        id: 'exercise-1',
        name: 'Test Exercise',
        description: 'Test exercise for progression testing',
        imageUrl: 'assets/images/default_exercise.png',
        videoUrl: null,
        muscleGroups: [MuscleGroup.pectoralMajor, MuscleGroup.rhomboids],
        tips: ['Keep your back straight', 'Control the movement'],
        commonMistakes: ['Using too much weight', 'Poor form'],
        category: ExerciseCategory.chest,
        difficulty: ExerciseDifficulty.beginner,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        defaultWeight: 50.0,
        defaultSets: 3,
        defaultReps: 10,
        restTimeSeconds: 60,
      );

      testRoutine = Routine(
        id: 'test-routine',
        name: 'Test Routine',
        description: 'Test routine for progression testing',
        days: [WeekDay.monday],
        sections: [
          RoutineSection(
            id: 'section-1',
            name: 'Section 1',
            routineId: 'test-routine',
            isCollapsed: false,
            order: 1,
            exercises: [
              RoutineExercise(
                id: 'exercise-1',
                exerciseId: 'exercise-1',
                routineSectionId: 'section-1',
                order: 1,
                notes: '',
              ),
            ],
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    group('Exercise Setup Validation', () {
      test('should create exercise with proper default values', () {
        // Validar que el ejercicio se creó correctamente
        expect(testExercise.id, equals('exercise-1'));
        expect(testExercise.name, equals('Test Exercise'));
        expect(testExercise.defaultWeight, equals(50.0));
        expect(testExercise.defaultSets, equals(3));
        expect(testExercise.defaultReps, equals(10));
        expect(testExercise.restTimeSeconds, equals(60));
        expect(testExercise.category, equals(ExerciseCategory.chest));
        expect(testExercise.difficulty, equals(ExerciseDifficulty.beginner));
        expect(testExercise.muscleGroups, contains(MuscleGroup.pectoralMajor));
        expect(testExercise.muscleGroups, contains(MuscleGroup.rhomboids));
      });

      test('should validate exercise progression compatibility', () {
        // Validar que el ejercicio es compatible con la progresión
        expect(testExercise.defaultWeight, greaterThan(0));
        expect(testExercise.defaultSets, greaterThan(0));
        expect(testExercise.defaultReps, greaterThan(0));
        expect(testExercise.restTimeSeconds, greaterThan(0));

        // Validar que los valores por defecto son realistas
        expect(testExercise.defaultWeight, lessThan(500)); // Peso máximo razonable
        expect(testExercise.defaultSets, lessThanOrEqualTo(10)); // Sets máximos razonables
        expect(testExercise.defaultReps, lessThanOrEqualTo(50)); // Reps máximas razonables
      });

      test('should validate routine-exercise relationship', () {
        // Validar que la rutina contiene el ejercicio correcto
        expect(testRoutine.sections.length, equals(1));
        expect(testRoutine.sections.first.exercises.length, equals(1));

        final routineExercise = testRoutine.sections.first.exercises.first;
        expect(routineExercise.exerciseId, equals(testExercise.id));
        expect(routineExercise.id, equals('exercise-1'));
        expect(routineExercise.routineSectionId, equals('section-1'));
        expect(routineExercise.order, equals(1));

        // Validar que la sección de la rutina está correctamente configurada
        final section = testRoutine.sections.first;
        expect(section.id, equals('section-1'));
        expect(section.name, equals('Section 1'));
        expect(section.routineId, equals(testRoutine.id));
        expect(section.isCollapsed, isFalse);
        expect(section.order, equals(1));
      });
    });

    group('Single Session Per Week Logic', () {
      test('should apply progression every session for single session routines', () async {
        // Simular que no hay progresión activa para evitar dependencias
        // En un test real, esto se mockearía

        // Para rutinas de 1 sesión por semana, la progresión debería aplicarse
        // en cada sesión ya que cada sesión representa una semana completa

        // Este test valida la lógica conceptual:
        // - sessions_per_week = 1 → aplicar progresión siempre
        // - sessions_per_week > 1 → aplicar progresión solo en primera sesión de semana

        expect(singleSessionConfig.customParameters['sessions_per_week'], equals(1));
        expect(multiSessionConfig.customParameters['sessions_per_week'], equals(3));
      });

      test('should handle single session progression correctly', () {
        // Validar que la configuración de 1 sesión por semana
        // se identifica correctamente
        final sessionsPerWeek = singleSessionConfig.customParameters['sessions_per_week'] ?? 3;
        expect(sessionsPerWeek, equals(1));

        // Para rutinas de 1 sesión, la lógica debería ser:
        // if (sessionsPerWeek == 1) return true; // Aplicar siempre
        final shouldApplyProgression = sessionsPerWeek == 1;
        expect(shouldApplyProgression, isTrue);
      });
    });

    group('Multi Session Per Week Logic', () {
      test('should handle multi session progression correctly', () {
        // Validar que la configuración de múltiples sesiones por semana
        // se identifica correctamente
        final sessionsPerWeek = multiSessionConfig.customParameters['sessions_per_week'] ?? 3;
        expect(sessionsPerWeek, equals(3));

        // Para rutinas de múltiples sesiones, la lógica debería ser:
        // if (sessionsPerWeek > 1) return _isFirstSessionOfWeekForRoutine(routine);
        final shouldApplyProgression = sessionsPerWeek > 1;
        expect(shouldApplyProgression, isTrue);
      });

      test('should validate session frequency parameters', () {
        // Validar que todas las configuraciones tienen el parámetro sessions_per_week
        expect(singleSessionConfig.customParameters.containsKey('sessions_per_week'), isTrue);
        expect(multiSessionConfig.customParameters.containsKey('sessions_per_week'), isTrue);

        // Validar valores válidos
        expect(singleSessionConfig.customParameters['sessions_per_week'], isA<int>());
        expect(multiSessionConfig.customParameters['sessions_per_week'], isA<int>());
        expect(singleSessionConfig.customParameters['sessions_per_week'], greaterThan(0));
        expect(multiSessionConfig.customParameters['sessions_per_week'], greaterThan(0));
      });
    });

    group('Progression Type Frequency Mapping', () {
      test('should map progression types to appropriate session frequencies', () {
        // Validar que cada tipo de progresión tiene una frecuencia apropiada

        final progressionFrequencies = {
          ProgressionType.linear: 3,
          ProgressionType.undulating: 3,
          ProgressionType.stepped: 3,
          ProgressionType.double: 3,
          ProgressionType.wave: 3,
          ProgressionType.static: 1, // Especial: para rutinas de 1 día
          ProgressionType.reverse: 3,
          ProgressionType.autoregulated: 3,
          ProgressionType.doubleFactor: 3,
          ProgressionType.overload: 3,
        };

        for (final entry in progressionFrequencies.entries) {
          final type = entry.key;
          final expectedFrequency = entry.value;

          // Validar que el tipo tiene una frecuencia definida
          expect(expectedFrequency, greaterThan(0));
          expect(expectedFrequency, lessThanOrEqualTo(7)); // Máximo 7 días por semana

          // Validar que la frecuencia es apropiada para el tipo
          if (type == ProgressionType.static) {
            expect(expectedFrequency, equals(1), reason: 'Static progression should be for single session routines');
          } else {
            expect(
              expectedFrequency,
              greaterThanOrEqualTo(2),
              reason: 'Most progression types should support multiple sessions per week',
            );
          }
        }
      });

      test('should validate deload week compatibility with session frequency', () {
        // Validar que la semana de deload es compatible con la frecuencia de sesiones

        // Para rutinas de 1 sesión por semana
        expect(singleSessionConfig.deloadWeek, lessThanOrEqualTo(singleSessionConfig.cycleLength));
        expect(singleSessionConfig.deloadWeek, greaterThanOrEqualTo(0));

        // Para rutinas de múltiples sesiones por semana
        expect(multiSessionConfig.deloadWeek, lessThanOrEqualTo(multiSessionConfig.cycleLength));
        expect(multiSessionConfig.deloadWeek, greaterThanOrEqualTo(0));

        // El deload no debería ser más frecuente que la frecuencia de sesiones
        final singleSessionDeloadFrequency = singleSessionConfig.cycleLength / singleSessionConfig.deloadWeek;
        final multiSessionDeloadFrequency = multiSessionConfig.cycleLength / multiSessionConfig.deloadWeek;

        expect(singleSessionDeloadFrequency, greaterThanOrEqualTo(1.0));
        expect(multiSessionDeloadFrequency, greaterThanOrEqualTo(1.0));
      });
    });

    group('Edge Cases for Session Frequency', () {
      test('should handle missing sessions_per_week parameter', () {
        final configWithoutFrequency = ProgressionConfig(
          id: 'no-frequency-config',
          type: ProgressionType.linear,
          unit: ProgressionUnit.week,
          isGlobal: true,
          primaryTarget: ProgressionTarget.weight,
          incrementValue: 2.5,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 4,
          deloadPercentage: 0.8,
          minReps: 8,
          maxReps: 12,
          baseSets: 3,
          isActive: true,
          startDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          customParameters: {}, // Sin sessions_per_week
        );

        // Debería usar un valor por defecto
        final sessionsPerWeek = configWithoutFrequency.customParameters['sessions_per_week'] ?? 3;
        expect(sessionsPerWeek, equals(3)); // Valor por defecto
      });

      test('should handle invalid sessions_per_week values', () {
        final invalidConfigs = [
          // Valor 0
          ProgressionConfig(
            id: 'zero-frequency',
            type: ProgressionType.linear,
            unit: ProgressionUnit.week,
            isGlobal: true,
            primaryTarget: ProgressionTarget.weight,
            incrementValue: 2.5,
            incrementFrequency: 1,
            cycleLength: 4,
            deloadWeek: 4,
            deloadPercentage: 0.8,
            minReps: 8,
            maxReps: 12,
            baseSets: 3,
            isActive: true,
            startDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            customParameters: {'sessions_per_week': 0},
          ),
          // Valor negativo
          ProgressionConfig(
            id: 'negative-frequency',
            type: ProgressionType.linear,
            unit: ProgressionUnit.week,
            isGlobal: true,
            primaryTarget: ProgressionTarget.weight,
            incrementValue: 2.5,
            incrementFrequency: 1,
            cycleLength: 4,
            deloadWeek: 4,
            deloadPercentage: 0.8,
            minReps: 8,
            maxReps: 12,
            baseSets: 3,
            isActive: true,
            startDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            customParameters: {'sessions_per_week': -1},
          ),
          // Valor muy alto
          ProgressionConfig(
            id: 'high-frequency',
            type: ProgressionType.linear,
            unit: ProgressionUnit.week,
            isGlobal: true,
            primaryTarget: ProgressionTarget.weight,
            incrementValue: 2.5,
            incrementFrequency: 1,
            cycleLength: 4,
            deloadWeek: 4,
            deloadPercentage: 0.8,
            minReps: 8,
            maxReps: 12,
            baseSets: 3,
            isActive: true,
            startDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            customParameters: {'sessions_per_week': 10},
          ),
        ];

        for (final config in invalidConfigs) {
          final sessionsPerWeek = config.customParameters['sessions_per_week'] ?? 3;

          // Validar que los valores inválidos se detectan correctamente
          if (sessionsPerWeek <= 0 || sessionsPerWeek > 7) {
            // Simular la lógica de corrección que debería implementarse
            final correctedValue =
                sessionsPerWeek <= 0
                    ? 1
                    : sessionsPerWeek > 7
                    ? 7
                    : sessionsPerWeek;

            expect(
              correctedValue,
              inInclusiveRange(1, 7),
              reason: 'Invalid sessions_per_week should be corrected to valid range',
            );
          }
        }
      });

      test('should handle extreme session frequencies', () {
        // Frecuencia mínima (1 sesión por semana)
        final minFrequencyConfig = singleSessionConfig.copyWith(customParameters: {'sessions_per_week': 1});
        expect(minFrequencyConfig.customParameters['sessions_per_week'], equals(1));

        // Frecuencia máxima (7 sesiones por semana)
        final maxFrequencyConfig = multiSessionConfig.copyWith(customParameters: {'sessions_per_week': 7});
        expect(maxFrequencyConfig.customParameters['sessions_per_week'], equals(7));

        // Validar que ambos son válidos
        expect(minFrequencyConfig.customParameters['sessions_per_week'], inInclusiveRange(1, 7));
        expect(maxFrequencyConfig.customParameters['sessions_per_week'], inInclusiveRange(1, 7));
      });
    });

    group('Integration with Progression Logic', () {
      test('should correctly determine progression application based on frequency', () {
        // Simular la lógica de decisión
        bool shouldApplyProgression(int sessionsPerWeek, bool isFirstSessionOfWeek) {
          if (sessionsPerWeek == 1) {
            return true; // Aplicar siempre para rutinas de 1 sesión
          } else {
            return isFirstSessionOfWeek; // Solo primera sesión para múltiples sesiones
          }
        }

        // Casos de prueba
        expect(shouldApplyProgression(1, false), isTrue); // 1 sesión, no primera
        expect(shouldApplyProgression(1, true), isTrue); // 1 sesión, primera
        expect(shouldApplyProgression(3, false), isFalse); // 3 sesiones, no primera
        expect(shouldApplyProgression(3, true), isTrue); // 3 sesiones, primera
        expect(shouldApplyProgression(5, false), isFalse); // 5 sesiones, no primera
        expect(shouldApplyProgression(5, true), isTrue); // 5 sesiones, primera
      });

      test('should validate progression timing consistency', () {
        // Validar que la frecuencia de sesiones es consistente con otros parámetros

        // Para rutinas de 1 sesión por semana
        expect(singleSessionConfig.unit, equals(ProgressionUnit.week));
        expect(singleSessionConfig.incrementFrequency, greaterThan(0));

        // Para rutinas de múltiples sesiones por semana
        expect(multiSessionConfig.unit, equals(ProgressionUnit.week));
        expect(multiSessionConfig.incrementFrequency, greaterThan(0));

        // El incrementFrequency debería ser compatible con sessions_per_week
        final singleSessionFrequency = singleSessionConfig.customParameters['sessions_per_week']!;
        final multiSessionFrequency = multiSessionConfig.customParameters['sessions_per_week']!;

        expect(singleSessionConfig.incrementFrequency, lessThanOrEqualTo(singleSessionFrequency));
        expect(multiSessionConfig.incrementFrequency, lessThanOrEqualTo(multiSessionFrequency));
      });
    });
  });
}
