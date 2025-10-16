import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/muscle_group_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/configs/adaptive_increment_config.dart';
import 'package:liftly/features/progression/configs/training_objective.dart';

/// Tests para validar incrementos adaptativos por exerciseType y loadType
/// Verifica que AdaptiveIncrementConfig devuelva valores correctos para cada combinación
void main() {
  group('Adaptive Increment Config Validation', () {
    // Helper para crear ejercicios de prueba
    Exercise createTestExercise({
      required ExerciseType exerciseType,
      required LoadType loadType,
      String name = 'Test Exercise',
    }) {
      return Exercise(
        id: 'test-${exerciseType.name}-${loadType.name}',
        name: name,
        exerciseType: exerciseType,
        loadType: loadType,
        muscleGroups: [MuscleGroup.pectoralMajor],
        description: 'Test description',
        imageUrl: 'test_image.png',
        tips: [],
        commonMistakes: [],
        category: ExerciseCategory.chest,
        difficulty: ExerciseDifficulty.intermediate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    group('Weight Increments - Multi-Joint', () {
      test('barbell multi-joint tiene incremento correcto', () {
        final exercise = createTestExercise(
          exerciseType: ExerciseType.multiJoint,
          loadType: LoadType.barbell,
        );

        final increment = AdaptiveIncrementConfig.getDefaultIncrement(exercise);
        final range = AdaptiveIncrementConfig.getIncrementRange(exercise);

        // Barbell multi-joint debería tener incrementos más grandes
        expect(increment, greaterThanOrEqualTo(2.5));
        expect(range?.min, lessThanOrEqualTo(increment));
        expect(range?.max, greaterThanOrEqualTo(increment));
        expect(range?.defaultValue, equals(increment));
      });

      test('dumbbell multi-joint tiene incremento correcto', () {
        final exercise = createTestExercise(
          exerciseType: ExerciseType.multiJoint,
          loadType: LoadType.dumbbell,
        );

        final increment = AdaptiveIncrementConfig.getDefaultIncrement(exercise);

        // Dumbbell debería tener incrementos menores que barbell
        expect(increment, lessThanOrEqualTo(5.0));
        expect(increment, greaterThanOrEqualTo(1.0));
      });

      test('machine multi-joint tiene incremento correcto', () {
        final exercise = createTestExercise(
          exerciseType: ExerciseType.multiJoint,
          loadType: LoadType.machine,
        );

        final increment = AdaptiveIncrementConfig.getDefaultIncrement(exercise);

        // Máquinas pueden tener incrementos más precisos
        expect(increment, greaterThan(0));
        expect(
          AdaptiveIncrementConfig.isValidIncrement(exercise, increment),
          isTrue,
        );
      });
    });

    group('Weight Increments - Isolation', () {
      test('barbell isolation tiene incremento más pequeño', () {
        final multiJoint = createTestExercise(
          exerciseType: ExerciseType.multiJoint,
          loadType: LoadType.barbell,
        );
        final isolation = createTestExercise(
          exerciseType: ExerciseType.isolation,
          loadType: LoadType.barbell,
        );

        final multiIncrement = AdaptiveIncrementConfig.getDefaultIncrement(
          multiJoint,
        );
        final isoIncrement = AdaptiveIncrementConfig.getDefaultIncrement(
          isolation,
        );

        // Isolation debería tener incrementos menores que multi-joint
        expect(isoIncrement, lessThanOrEqualTo(multiIncrement));
      });

      test('dumbbell isolation tiene incremento más pequeño', () {
        final exercise = createTestExercise(
          exerciseType: ExerciseType.isolation,
          loadType: LoadType.dumbbell,
        );

        final increment = AdaptiveIncrementConfig.getDefaultIncrement(exercise);

        // Isolation con dumbbell debería ser más pequeño
        expect(increment, lessThanOrEqualTo(2.5));
        expect(increment, greaterThan(0));
      });
    });

    group('Series Increments - Multi-Joint', () {
      test('barbell multi-joint tiene incremento de series correcto', () {
        final exercise = createTestExercise(
          exerciseType: ExerciseType.multiJoint,
          loadType: LoadType.barbell,
        );

        final seriesIncrement =
            AdaptiveIncrementConfig.getDefaultSeriesIncrement(
              exercise,
              objective: TrainingObjective.hypertrophy,
            );
        final range =
            AdaptiveIncrementConfig.getSeriesIncrementRangeByObjective(
              exercise,
              objective: TrainingObjective.hypertrophy,
            );

        expect(seriesIncrement, greaterThan(0));
        expect(range?.min ?? 0, lessThanOrEqualTo(seriesIncrement));
        expect(range?.max ?? 10, greaterThanOrEqualTo(seriesIncrement));
      });

      test('machine multi-joint tiene mayor flexibilidad en series', () {
        final exercise = createTestExercise(
          exerciseType: ExerciseType.multiJoint,
          loadType: LoadType.machine,
        );

        final seriesIncrement =
            AdaptiveIncrementConfig.getDefaultSeriesIncrement(
              exercise,
              objective: TrainingObjective.hypertrophy,
            );
        final range =
            AdaptiveIncrementConfig.getSeriesIncrementRangeByObjective(
              exercise,
              objective: TrainingObjective.hypertrophy,
            );

        // Máquinas deberían tener mayor flexibilidad
        expect(seriesIncrement, greaterThanOrEqualTo(1));
        expect(range?.max ?? 0, greaterThanOrEqualTo(2));
      });

      test('bodyweight multi-joint tiene mayor flexibilidad en series', () {
        final exercise = createTestExercise(
          exerciseType: ExerciseType.multiJoint,
          loadType: LoadType.bodyweight,
        );

        final seriesIncrement =
            AdaptiveIncrementConfig.getDefaultSeriesIncrement(
              exercise,
              objective: TrainingObjective.hypertrophy,
            );
        final range =
            AdaptiveIncrementConfig.getSeriesIncrementRangeByObjective(
              exercise,
              objective: TrainingObjective.hypertrophy,
            );

        // Peso corporal debería permitir más series
        expect(range?.max ?? 0, greaterThanOrEqualTo(2));
        expect(seriesIncrement, greaterThanOrEqualTo(1));
      });
    });

    group('Series Increments - Isolation', () {
      test('isolation exercises tienen incrementos de series válidos', () {
        for (final loadType in LoadType.values) {
          final exercise = createTestExercise(
            exerciseType: ExerciseType.isolation,
            loadType: loadType,
          );

          final seriesIncrement =
              AdaptiveIncrementConfig.getDefaultSeriesIncrement(
                exercise,
                objective: TrainingObjective.hypertrophy,
              );
          final range =
              AdaptiveIncrementConfig.getSeriesIncrementRangeByObjective(
                exercise,
                objective: TrainingObjective.hypertrophy,
              );

          expect(seriesIncrement, greaterThan(0));
          expect(range?.min, greaterThan(0));
          expect(range?.max ?? 0, greaterThanOrEqualTo(range?.min ?? 0));
          expect(
            AdaptiveIncrementConfig.isValidSeriesIncrement(
              exercise,
              seriesIncrement,
            ),
            isTrue,
          );
        }
      });
    });

    group('All Combinations', () {
      test(
        'todas las combinaciones de exerciseType y loadType tienen configuración',
        () {
          for (final exerciseType in ExerciseType.values) {
            for (final loadType in LoadType.values) {
              final exercise = createTestExercise(
                exerciseType: exerciseType,
                loadType: loadType,
              );

              // Verificar weight increment (excluir bodyweight y resistanceBand que no usan peso)
              if (loadType != LoadType.bodyweight &&
                  loadType != LoadType.resistanceBand) {
                final increment = AdaptiveIncrementConfig.getDefaultIncrement(
                  exercise,
                );
                expect(
                  increment,
                  greaterThan(0),
                  reason:
                      'Weight increment for $exerciseType + $loadType should be > 0',
                );

                final range = AdaptiveIncrementConfig.getIncrementRange(
                  exercise,
                );
                expect(range?.min, greaterThan(0));
                expect(range?.max ?? 0, greaterThanOrEqualTo(range?.min ?? 0));
              } else {
                // Para bodyweight y resistanceBand, verificar que el incremento es 0
                final increment = AdaptiveIncrementConfig.getDefaultIncrement(
                  exercise,
                );
                expect(
                  increment,
                  equals(0.0),
                  reason:
                      'Weight increment for $exerciseType + $loadType should be 0',
                );
              }

              // Verificar series increment
              final seriesIncrement =
                  AdaptiveIncrementConfig.getDefaultSeriesIncrement(
                    exercise,
                    objective: TrainingObjective.hypertrophy,
                  );
              expect(
                seriesIncrement,
                greaterThan(0),
                reason:
                    'Series increment for $exerciseType + $loadType should be > 0',
              );

              final seriesRange =
                  AdaptiveIncrementConfig.getSeriesIncrementRangeByObjective(
                    exercise,
                    objective: TrainingObjective.hypertrophy,
                  );
              expect(seriesRange?.min ?? 0, greaterThan(0));
              expect(
                seriesRange?.max ?? 0,
                greaterThanOrEqualTo(seriesRange?.min ?? 0),
              );
            }
          }
        },
      );

      test('incrementos son validados correctamente', () {
        for (final exerciseType in ExerciseType.values) {
          for (final loadType in LoadType.values) {
            final exercise = createTestExercise(
              exerciseType: exerciseType,
              loadType: loadType,
            );

            final increment = AdaptiveIncrementConfig.getDefaultIncrement(
              exercise,
            );
            final range = AdaptiveIncrementConfig.getIncrementRange(exercise);

            // Verificar que el incremento recomendado es válido
            expect(
              AdaptiveIncrementConfig.isValidIncrement(exercise, increment),
              isTrue,
            );

            // Verificar que valores fuera del rango son inválidos
            expect(
              AdaptiveIncrementConfig.isValidIncrement(
                exercise,
                (range?.min ?? 0) - 0.1,
              ),
              isFalse,
            );
            expect(
              AdaptiveIncrementConfig.isValidIncrement(
                exercise,
                (range?.max ?? 0) + 0.1,
              ),
              isFalse,
            );

            // Verificar que valores dentro del rango son válidos
            expect(
              AdaptiveIncrementConfig.isValidIncrement(
                exercise,
                range?.min ?? 0,
              ),
              isTrue,
            );
            expect(
              AdaptiveIncrementConfig.isValidIncrement(
                exercise,
                range?.max ?? 0,
              ),
              isTrue,
            );
          }
        }
      });
    });

    group('Descriptions', () {
      test('todas las combinaciones tienen descripciones', () {
        for (final exerciseType in ExerciseType.values) {
          for (final loadType in LoadType.values) {
            final exercise = createTestExercise(
              exerciseType: exerciseType,
              loadType: loadType,
            );

            final description = AdaptiveIncrementConfig.getIncrementDescription(
              exercise,
            );
            expect(description, isNotEmpty);

            final seriesDescription =
                AdaptiveIncrementConfig.getSeriesIncrementDescription(exercise);
            expect(seriesDescription, isNotEmpty);
          }
        }
      });
    });

    group('LoadType Filters', () {
      test('getLoadTypesWithIncrement devuelve loadTypes válidos', () {
        for (final _ in ExerciseType.values) {
          final loadTypes =
              AdaptiveIncrementConfig.getLoadTypesWithWeightIncrement();

          expect(loadTypes, isNotEmpty);
          // Debería devolver 6 loadTypes (excluyendo bodyweight y resistanceBand)
          expect(loadTypes.length, equals(6));

          for (final loadType in loadTypes) {
            expect(LoadType.values, contains(loadType));
            // Verificar que no incluye bodyweight ni resistanceBand
            expect(loadType, isNot(equals(LoadType.bodyweight)));
            expect(loadType, isNot(equals(LoadType.resistanceBand)));
          }
        }
      });

      test('getLoadTypesWithSeriesIncrement devuelve loadTypes válidos', () {
        for (final _ in ExerciseType.values) {
          final loadTypes =
              AdaptiveIncrementConfig.getLoadTypesWithSeriesIncrement();

          expect(loadTypes, isNotEmpty);

          for (final loadType in loadTypes) {
            expect(LoadType.values, contains(loadType));
          }
        }
      });
    });
  });
}
