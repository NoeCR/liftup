import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/themes/app_theme.dart';
import 'package:liftly/common/widgets/exercise_card.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/home/models/routine.dart';
import 'package:liftly/features/progression/providers/exercise_values_provider.dart';

void main() {
  group('ExerciseCard Widget Tests', () {
    late Exercise testExercise;
    late RoutineExercise testRoutineExercise;

    setUp(() {
      testExercise = Exercise(
        id: 'test-exercise',
        name: 'Test Exercise',
        description: 'Test exercise description',
        imageUrl: '',
        muscleGroups: [],
        tips: [],
        commonMistakes: [],
        category: ExerciseCategory.chest,
        difficulty: ExerciseDifficulty.beginner,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
      );

      testRoutineExercise = RoutineExercise(
        id: 'test-routine-exercise',
        routineSectionId: 'test-section',
        exerciseId: 'test-exercise',
        order: 0,
      );
    });

    testWidgets('should display exercise information correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ExerciseCard(
              routineExercise: testRoutineExercise,
              exercise: testExercise,
            ),
          ),
        ),
      );

      // Verificar que se muestra el nombre del ejercicio
      expect(find.text('Test Exercise'), findsOneWidget);

      // Verificar que se muestra la categoría en el chip
      expect(find.text('Pecho'), findsOneWidget);
    });

    testWidgets(
      'should display favorite button when onToggleFavorite is provided',
      (WidgetTester tester) async {
        bool favoriteToggled = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: ExerciseCard(
                routineExercise: testRoutineExercise,
                exercise: testExercise,
                onToggleFavorite: () {
                  favoriteToggled = true;
                },
              ),
            ),
          ),
        );

        // Verificar que el botón de favorito está presente
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);

        // Tocar el botón de favorito
        await tester.tap(find.byIcon(Icons.favorite_border));
        await tester.pump();

        // Verificar que se llamó la función
        expect(favoriteToggled, isTrue);
      },
    );

    testWidgets(
      'should display filled favorite icon when exercise is favorite',
      (WidgetTester tester) async {
        final favoriteExercise = testExercise.copyWith(isFavorite: true);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: ExerciseCard(
                routineExercise: testRoutineExercise,
                exercise: favoriteExercise,
                onToggleFavorite: () {},
              ),
            ),
          ),
        );

        // Verificar que se muestra el ícono de favorito lleno
        expect(find.byIcon(Icons.favorite), findsOneWidget);
        expect(find.byIcon(Icons.favorite_border), findsNothing);
      },
    );

    testWidgets('should display remove button when onRemove is provided', (
      WidgetTester tester,
    ) async {
      bool removeCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ExerciseCard(
              routineExercise: testRoutineExercise,
              exercise: testExercise,
              onRemove: () {
                removeCalled = true;
              },
            ),
          ),
        ),
      );

      // Verificar que el botón de eliminar está presente
      expect(find.text('Eliminar'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);

      // Tocar el botón de eliminar
      await tester.tap(find.text('Eliminar'));
      await tester.pump();

      // Verificar que se llamó la función
      expect(removeCalled, isTrue);
    });

    testWidgets('should not display remove button when onRemove is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ExerciseCard(
              routineExercise: testRoutineExercise,
              exercise: testExercise,
            ),
          ),
        ),
      );

      // Verificar que el botón de eliminar no está presente
      expect(find.text('Eliminar'), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets(
      'should display both favorite and remove buttons when both callbacks are provided',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: ExerciseCard(
                routineExercise: testRoutineExercise,
                exercise: testExercise,
                onToggleFavorite: () {},
                onRemove: () {},
              ),
            ),
          ),
        );

        // Verificar que ambos botones están presentes
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
        expect(find.text('Eliminar'), findsOneWidget);
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      },
    );

    testWidgets('should handle exercise with no image gracefully', (
      WidgetTester tester,
    ) async {
      final exerciseWithoutImage = testExercise.copyWith(imageUrl: '');

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ExerciseCard(
              routineExercise: testRoutineExercise,
              exercise: exerciseWithoutImage,
            ),
          ),
        ),
      );

      // Verificar que se muestra el ícono por defecto (puede haber múltiples)
      expect(find.byIcon(Icons.fitness_center), findsWidgets);
    });

    testWidgets('should display exercise with display values correctly', (
      WidgetTester tester,
    ) async {
      final displayValues = ExerciseDisplayValues(
        sets: 3,
        reps: 12,
        weight: 50.0,
        restTimeSeconds: 90,
        source: ExerciseValueSource.base,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ExerciseCard(
              routineExercise: testRoutineExercise,
              exercise: testExercise,
              displayValues: displayValues,
              showSetsControls: true,
            ),
          ),
        ),
      );

      // Verificar que se muestran los valores de display en los chips
      expect(find.text('3 series'), findsOneWidget); // Sets
      expect(find.text('12 reps'), findsOneWidget); // Reps
      expect(find.text('50.0 kg'), findsOneWidget); // Weight
    });

    testWidgets('should handle tap on card when onTap is provided', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ExerciseCard(
              routineExercise: testRoutineExercise,
              exercise: testExercise,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Tocar la tarjeta
      await tester.tap(find.byType(Card));
      await tester.pump();

      // Verificar que se llamó la función
      expect(tapped, isTrue);
    });

    testWidgets('should display lock button when exercise is locked', (
      WidgetTester tester,
    ) async {
      final lockedExercise = testExercise.copyWith(isProgressionLocked: true);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ExerciseCard(
              routineExercise: testRoutineExercise,
              exercise: lockedExercise,
              isLocked: true,
              onToggleLock: () {},
            ),
          ),
        ),
      );

      // Verificar que se muestra el ícono de candado
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('should display unlock button when exercise is not locked', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ExerciseCard(
              routineExercise: testRoutineExercise,
              exercise: testExercise,
              isLocked: false,
              onToggleLock: () {},
            ),
          ),
        ),
      );

      // Verificar que se muestra el ícono de candado abierto
      expect(find.byIcon(Icons.lock_open), findsOneWidget);
    });
  });
}
