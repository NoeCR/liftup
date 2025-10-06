import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/widgets/exercise_card.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/home/models/routine.dart';

void main() {
  Exercise buildExercise({
    String id = 'e1',
    String name = 'Press banca',
    int defaultSets = 3,
    int defaultReps = 10,
    double defaultWeight = 50,
  }) {
    return Exercise(
      id: id,
      name: name,
      description: 'desc',
      imageUrl: '',
      muscleGroups: const [],
      tips: const [],
      commonMistakes: const [],
      category: ExerciseCategory.chest,
      difficulty: ExerciseDifficulty.intermediate,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024, 2),
      defaultSets: defaultSets,
      defaultReps: defaultReps,
      defaultWeight: defaultWeight,
      restTimeSeconds: 60,
    );
  }

  RoutineExercise buildRoutineExercise() {
    return const RoutineExercise(
      id: 're1',
      routineSectionId: 'rs1',
      exerciseId: 'e1',
      order: 0,
    );
  }

  Widget wrap(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: child)));

  testWidgets('Home card: muestra chips, sin texto Series: x/y y sin botón -', (
    tester,
  ) async {
    final exercise = buildExercise();
    final routineExercise = buildRoutineExercise();

    await tester.pumpWidget(
      wrap(
        ExerciseCard(
          routineExercise: routineExercise,
          exercise: exercise,
          showSetsControls: false,
        ),
      ),
    );

    expect(find.textContaining('series'), findsOneWidget);
    expect(find.textContaining('reps'), findsOneWidget);
    expect(find.textContaining('kg'), findsOneWidget);

    // No texto redundante "Series: x/y"
    expect(find.textContaining('Series:'), findsNothing);

    // No botón de decrementar
    expect(find.byIcon(Icons.remove), findsNothing);
    // Tampoco debería existir el botón + en Home
    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets(
    'Sesión: botón + habilitado cuando no descansa y faltan series (48x48) y callback',
    (tester) async {
      final exercise = buildExercise(defaultSets: 3);
      final routineExercise = buildRoutineExercise();
      int? newSets;

      await tester.pumpWidget(
        wrap(
          ExerciseCard(
            routineExercise: routineExercise,
            exercise: exercise,
            showSetsControls: true,
            performedSets: 1,
            isResting: false,
            onRepsChanged: (v) => newSets = v,
          ),
        ),
      );

      final addIcon = find.byIcon(Icons.add);
      expect(addIcon, findsOneWidget);

      // Tamaño 48x48 (SizedBox ancestro del IconButton)
      final sizedBoxForAdd = find.ancestor(
        of: addIcon,
        matching: find.byType(SizedBox),
      );
      final addBox = tester.getSize(sizedBoxForAdd);
      expect(addBox.width, 48);
      expect(addBox.height, 48);

      // Tap incrementa (usar el IconButton ancestro)
      final addButton = find.ancestor(
        of: addIcon,
        matching: find.byType(IconButton),
      );
      await tester.tap(addButton);
      await tester.pump();
      expect(newSets, 2);
    },
  );

  testWidgets(
    'Sesión: botón + deshabilitado durante descanso o al completar series',
    (tester) async {
      final exercise = buildExercise(defaultSets: 3);
      final routineExercise = buildRoutineExercise();

      // Caso descanso
      await tester.pumpWidget(
        wrap(
          ExerciseCard(
            routineExercise: routineExercise,
            exercise: exercise,
            showSetsControls: true,
            performedSets: 1,
            isResting: true,
          ),
        ),
      );
      final addDuringRestBtn = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.add),
          matching: find.byType(IconButton),
        ),
      );
      expect(addDuringRestBtn.onPressed, isNull);

      // Caso completado
      await tester.pumpWidget(
        wrap(
          ExerciseCard(
            routineExercise: routineExercise,
            exercise: exercise,
            showSetsControls: true,
            performedSets: 3,
            isResting: false,
          ),
        ),
      );
      final addWhenCompletedBtn = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.add),
          matching: find.byType(IconButton),
        ),
      );
      expect(addWhenCompletedBtn.onPressed, isNull);
    },
  );
}
