import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../common/enums/muscle_group_enum.dart';
import '../models/exercise.dart';
import '../services/exercise_service.dart';

part 'exercise_notifier.g.dart';

@riverpod
class ExerciseNotifier extends _$ExerciseNotifier {
  @override
  Future<List<Exercise>> build() async {
    // Load initial data if empty
    final exerciseService = ref.read(exerciseServiceProvider);
    final exercises = await exerciseService.getAllExercises();
    if (exercises.isEmpty) {
      await _loadInitialExercises();
      return await exerciseService.getAllExercises();
    }

    return exercises;
  }

  Future<Exercise> addExercise(Exercise exercise) async {
    final exerciseService = ref.read(exerciseServiceProvider);
    final uuid = const Uuid();

    final newExercise = exercise.copyWith(id: uuid.v4(), createdAt: DateTime.now(), updatedAt: DateTime.now());

    await exerciseService.saveExercise(newExercise);

    // Force refresh the state
    ref.invalidateSelf();
    state = AsyncValue.data(await exerciseService.getAllExercises());

    return newExercise;
  }

  Future<void> updateExercise(Exercise exercise) async {
    final exerciseService = ref.read(exerciseServiceProvider);
    final updatedExercise = exercise.copyWith(updatedAt: DateTime.now());

    await exerciseService.saveExercise(updatedExercise);

    // Force refresh the state
    ref.invalidateSelf();
    state = AsyncValue.data(await exerciseService.getAllExercises());
  }

  Future<void> deleteExercise(String exerciseId) async {
    final exerciseService = ref.read(exerciseServiceProvider);
    await exerciseService.deleteExercise(exerciseId);

    // Force refresh the state
    ref.invalidateSelf();
    state = AsyncValue.data(await exerciseService.getAllExercises());
  }

  Future<Exercise?> getExerciseById(String id) async {
    final exerciseService = ref.read(exerciseServiceProvider);
    return await exerciseService.getExerciseById(id);
  }

  Future<List<Exercise>> getExercisesByCategory(ExerciseCategory category) async {
    final exerciseService = ref.read(exerciseServiceProvider);
    return await exerciseService.getExercisesByCategory(category);
  }

  Future<List<Exercise>> searchExercises(String query) async {
    final exerciseService = ref.read(exerciseServiceProvider);
    return await exerciseService.searchExercises(query);
  }

  /// Alterna el estado de favorito de un ejercicio
  Future<void> toggleFavorite(String exerciseId) async {
    final exerciseService = ref.read(exerciseServiceProvider);
    final exercise = await exerciseService.getExerciseById(exerciseId);

    if (exercise == null) return;

    final updatedExercise = exercise.copyWith(isFavorite: !exercise.isFavorite, updatedAt: DateTime.now());

    await exerciseService.saveExercise(updatedExercise);

    // Actualizar el estado
    ref.invalidateSelf();
    state = AsyncValue.data(await exerciseService.getAllExercises());
  }

  /// Reordena la lista de ejercicios según el orden proporcionado
  Future<void> reorderExercises(List<Exercise> reorderedExercises) async {
    final exerciseService = ref.read(exerciseServiceProvider);

    // Actualizar el orden de cada ejercicio
    for (int i = 0; i < reorderedExercises.length; i++) {
      final exercise = reorderedExercises[i];
      final updatedExercise = exercise.copyWith(
        updatedAt: DateTime.now(),
        // Aquí podrías agregar un campo de orden si lo necesitas
        // order: i,
      );
      await exerciseService.saveExercise(updatedExercise);
    }

    // Actualizar el estado con la nueva lista ordenada
    state = AsyncValue.data(reorderedExercises);
  }

  /// Obtiene los ejercicios ordenados con favoritos primero
  Future<List<Exercise>> getExercisesWithFavoritesFirst() async {
    final exerciseService = ref.read(exerciseServiceProvider);
    final exercises = await exerciseService.getAllExercises();

    // Ordenar con favoritos primero, luego por nombre
    exercises.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;
      return a.name.compareTo(b.name);
    });

    return exercises;
  }

  Future<void> _loadInitialExercises() async {
    final exerciseService = ref.read(exerciseServiceProvider);
    final uuid = const Uuid();

    final initialExercises = [
      Exercise(
        id: uuid.v4(),
        name: 'Press de Banca',
        description: 'Ejercicio fundamental para el desarrollo del pecho, hombros y tríceps.',
        imageUrl: 'assets/images/bench_press.png',
        videoUrl: 'https://example.com/bench_press.mp4',
        muscleGroups: [MuscleGroup.pectoralMajor, MuscleGroup.anteriorDeltoid, MuscleGroup.tricepsLateralHead],
        tips: [
          'Mantén los pies firmes en el suelo',
          'Contrae el core durante todo el movimiento',
          'Baja la barra de forma controlada hasta el pecho',
        ],
        commonMistakes: [
          'Rebotar la barra en el pecho',
          'Arquear excesivamente la espalda',
          'No mantener los hombros estables',
        ],
        category: ExerciseCategory.chest,
        difficulty: ExerciseDifficulty.intermediate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        exerciseType: ExerciseType.multiJoint,
        loadType: LoadType.barbell,
      ),
      Exercise(
        id: uuid.v4(),
        name: 'Sentadillas',
        description: 'Ejercicio compuesto que trabaja principalmente las piernas y glúteos.',
        imageUrl: 'assets/images/squats.png',
        videoUrl: 'https://example.com/squats.mp4',
        muscleGroups: [MuscleGroup.rectusFemoris, MuscleGroup.gluteusMaximus, MuscleGroup.bicepsFemoris],
        tips: [
          'Mantén el pecho erguido',
          'Baja hasta que los muslos estén paralelos al suelo',
          'Empuja con los talones al subir',
        ],
        commonMistakes: [
          'Doblar las rodillas hacia adentro',
          'No bajar lo suficiente',
          'Inclinar el torso demasiado hacia adelante',
        ],
        category: ExerciseCategory.quadriceps,
        difficulty: ExerciseDifficulty.beginner,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        exerciseType: ExerciseType.multiJoint,
        loadType: LoadType.bodyweight,
      ),
      Exercise(
        id: uuid.v4(),
        name: 'Dominadas',
        description: 'Ejercicio de tracción que desarrolla la espalda y bíceps.',
        imageUrl: 'assets/images/pull_ups.png',
        videoUrl: 'https://example.com/pull_ups.mp4',
        muscleGroups: [MuscleGroup.latissimusDorsi, MuscleGroup.bicepsLongHead, MuscleGroup.rhomboids],
        tips: ['Mantén el core activado', 'Tira con los codos hacia abajo', 'Completa el rango de movimiento'],
        commonMistakes: [
          'Balancearse excesivamente',
          'No subir hasta que el mentón pase la barra',
          'Usar solo los brazos sin activar la espalda',
        ],
        category: ExerciseCategory.back,
        difficulty: ExerciseDifficulty.advanced,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        exerciseType: ExerciseType.multiJoint,
        loadType: LoadType.bodyweight,
      ),
    ];

    for (final exercise in initialExercises) {
      await exerciseService.saveExercise(exercise);
    }
  }
}
