import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/section_muscle_group_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/home/models/routine.dart';

void main() {
  group('Simple Removal Tests', () {
    late List<Exercise> testExercises;
    late Routine testRoutine;

    setUp(() {
      testExercises = [
        Exercise(
          id: '1',
          name: 'Sentadillas',
          description: 'Ejercicio básico',
          imageUrl: '',
          muscleGroups: [],
          tips: [],
          commonMistakes: [],
          category: ExerciseCategory.quadriceps,
          difficulty: ExerciseDifficulty.beginner,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          isFavorite: false,
        ),
        Exercise(
          id: '2',
          name: 'Press de Banca',
          description: 'Ejercicio de pecho',
          imageUrl: '',
          muscleGroups: [],
          tips: [],
          commonMistakes: [],
          category: ExerciseCategory.chest,
          difficulty: ExerciseDifficulty.intermediate,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          isFavorite: true,
        ),
        Exercise(
          id: '3',
          name: 'Dominadas',
          description: 'Ejercicio de espalda',
          imageUrl: '',
          muscleGroups: [],
          tips: [],
          commonMistakes: [],
          category: ExerciseCategory.back,
          difficulty: ExerciseDifficulty.advanced,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          isFavorite: false,
        ),
        Exercise(
          id: '4',
          name: 'Flexiones',
          description: 'Ejercicio de pecho',
          imageUrl: '',
          muscleGroups: [],
          tips: [],
          commonMistakes: [],
          category: ExerciseCategory.chest,
          difficulty: ExerciseDifficulty.beginner,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isFavorite: true,
        ),
      ];

      testRoutine = Routine(
        id: 'test-routine',
        name: 'Test Routine',
        description: 'Test routine description',
        days: [],
        sections: [
          RoutineSection(
            id: 'section1',
            routineId: 'test-routine',
            name: 'Pecho',
            muscleGroup: SectionMuscleGroup.chest,
            exercises: [
              RoutineExercise(id: 're1', routineSectionId: 'section1', exerciseId: '2', order: 0),
              RoutineExercise(id: 're2', routineSectionId: 'section1', exerciseId: '4', order: 1),
            ],
            isCollapsed: false,
            order: 0,
          ),
          RoutineSection(
            id: 'section2',
            routineId: 'test-routine',
            name: 'Piernas',
            muscleGroup: SectionMuscleGroup.quadriceps,
            exercises: [
              RoutineExercise(id: 're3', routineSectionId: 'section2', exerciseId: '1', order: 0),
              RoutineExercise(id: 're4', routineSectionId: 'section2', exerciseId: '3', order: 1),
            ],
            isCollapsed: false,
            order: 1,
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    test('should remove exercise from section correctly', () {
      // Obtener la sección de pecho
      final chestSection = testRoutine.sections.first;
      expect(chestSection.exercises.length, 2);

      // Crear una nueva sección sin el primer ejercicio
      final updatedExercises = chestSection.exercises.where((exercise) => exercise.id != 're1').toList();

      final updatedSection = chestSection.copyWith(exercises: updatedExercises);
      expect(updatedSection.exercises.length, 1);
      expect(updatedSection.exercises.first.id, 're2');
    });

    test('should handle removing non-existent exercise', () {
      // Intentar eliminar un ejercicio que no existe
      final chestSection = testRoutine.sections.first;
      final updatedExercises = chestSection.exercises.where((exercise) => exercise.id != 'non-existent').toList();

      // No debería cambiar nada
      expect(updatedExercises.length, 2);
      expect(updatedExercises, equals(chestSection.exercises));
    });

    test('should handle removing all exercises from section', () {
      // Eliminar todos los ejercicios de la sección
      final chestSection = testRoutine.sections.first;
      final updatedExercises = <RoutineExercise>[];

      final updatedSection = chestSection.copyWith(exercises: updatedExercises);
      expect(updatedSection.exercises.length, 0);
    });

    test('should maintain order after removing exercise', () {
      // Crear una sección con más ejercicios
      final sectionWithMoreExercises = RoutineSection(
        id: 'section3',
        routineId: 'test-routine',
        name: 'Espalda',
        muscleGroup: SectionMuscleGroup.back,
        exercises: [
          RoutineExercise(id: 're5', routineSectionId: 'section3', exerciseId: '1', order: 0),
          RoutineExercise(id: 're6', routineSectionId: 'section3', exerciseId: '2', order: 1),
          RoutineExercise(id: 're7', routineSectionId: 'section3', exerciseId: '3', order: 2),
          RoutineExercise(id: 're8', routineSectionId: 'section3', exerciseId: '4', order: 3),
        ],
        isCollapsed: false,
        order: 2,
      );

      // Eliminar el segundo ejercicio (re6)
      final updatedExercises = sectionWithMoreExercises.exercises.where((exercise) => exercise.id != 're6').toList();

      final updatedSection = sectionWithMoreExercises.copyWith(exercises: updatedExercises);

      // Verificar que se mantiene el orden
      expect(updatedSection.exercises.length, 3);
      expect(updatedSection.exercises[0].id, 're5');
      expect(updatedSection.exercises[1].id, 're7');
      expect(updatedSection.exercises[2].id, 're8');
    });

    test('should handle removing exercise from empty section', () {
      // Crear una sección vacía
      final emptySection = RoutineSection(
        id: 'empty-section',
        routineId: 'test-routine',
        name: 'Vacia',
        muscleGroup: SectionMuscleGroup.chest,
        exercises: [],
        isCollapsed: false,
        order: 3,
      );

      // Intentar eliminar de una sección vacía
      final updatedExercises = emptySection.exercises.where((exercise) => exercise.id != 'any-id').toList();

      expect(updatedExercises.length, 0);
    });

    test('should maintain favorites first ordering after removal', () {
      // Simular que tenemos ejercicios ordenados con favoritos primero
      final sortedExercises =
          testExercises.where((exercise) => exercise.isFavoriteValue).toList()
            ..addAll(testExercises.where((exercise) => !exercise.isFavoriteValue));

      // Verificar que los favoritos están primero
      expect(sortedExercises[0].isFavoriteValue, isTrue);
      expect(sortedExercises[1].isFavoriteValue, isTrue);
      expect(sortedExercises[2].isFavoriteValue, isFalse);
      expect(sortedExercises[3].isFavoriteValue, isFalse);

      // Simular eliminación de un ejercicio favorito
      final afterRemoval =
          sortedExercises
              .where((exercise) => exercise.id != '2') // Eliminar 'Press de Banca'
              .toList();

      // Verificar que los favoritos restantes siguen estando primero
      expect(afterRemoval[0].isFavorite, isTrue); // 'Flexiones'
      expect(afterRemoval[1].isFavorite, isFalse); // 'Sentadillas'
      expect(afterRemoval[2].isFavorite, isFalse); // 'Dominadas'
    });
  });
}
