import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:liftly/features/home/notifiers/routine_exercise_notifier.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/common/enums/muscle_group_enum.dart';

void main() {
  group('RoutineExerciseNotifier', () {
    test(
      'addExercisesToSection agrega ejercicios en la sección seleccionada',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(
          routineExerciseNotifierProvider.notifier,
        );

        final sectionIdA = 'section-A';
        final sectionIdB = 'section-B';

        final now = DateTime.now();

        final exercise1 = Exercise(
          id: 'ex-1',
          name: 'Press banca',
          description: 'Pecho',
          imageUrl: 'bench.png',
          muscleGroups: const [MuscleGroup.pectoralMajor],
          tips: const [],
          commonMistakes: const [],
          category: ExerciseCategory.chest,
          difficulty: ExerciseDifficulty.beginner,
          createdAt: now,
          updatedAt: now,
        );

        final exercise2 = Exercise(
          id: 'ex-2',
          name: 'Dominadas',
          description: 'Espalda',
          imageUrl: 'pullups.png',
          muscleGroups: const [MuscleGroup.latissimusDorsi],
          tips: const [],
          commonMistakes: const [],
          category: ExerciseCategory.back,
          difficulty: ExerciseDifficulty.beginner,
          createdAt: now,
          updatedAt: now,
        );

        // Añadir a sección A
        notifier.addExercisesToSection(sectionIdA, [exercise1]);

        // Añadir a sección B
        notifier.addExercisesToSection(sectionIdB, [exercise2]);

        final state = container.read(routineExerciseNotifierProvider);

        expect(state.containsKey(sectionIdA), isTrue);
        expect(state.containsKey(sectionIdB), isTrue);

        final listA = state[sectionIdA]!;
        final listB = state[sectionIdB]!;

        expect(listA.length, 1);
        expect(listB.length, 1);

        expect(listA.first.exerciseId, 'ex-1');
        expect(listA.first.routineSectionId, sectionIdA);

        expect(listB.first.exerciseId, 'ex-2');
        expect(listB.first.routineSectionId, sectionIdB);

        // Verifica que al añadir otro a A mantiene sección correcta y orden incremental
        notifier.addExercisesToSection(sectionIdA, [exercise2]);
        final updatedA =
            container.read(routineExerciseNotifierProvider)[sectionIdA]!;
        expect(updatedA.length, 2);
        expect(updatedA[1].exerciseId, 'ex-2');
        expect(updatedA[1].routineSectionId, sectionIdA);
        expect(updatedA[1].order, 1);
      },
    );
  });
}
