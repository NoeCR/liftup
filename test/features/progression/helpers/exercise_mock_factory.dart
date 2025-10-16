import 'package:liftly/common/enums/muscle_group_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';

/// Factory for creating mock Exercise objects for testing
class ExerciseMockFactory {
  /// Creates a basic Exercise mock with default values
  static Exercise createExercise({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? videoUrl,
    List<MuscleGroup>? muscleGroups,
    List<String>? tips,
    List<String>? commonMistakes,
    ExerciseCategory? category,
    ExerciseDifficulty? difficulty,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? defaultWeight,
    int? defaultSets,
    int? defaultReps,
    int? restTimeSeconds,
    DateTime? lastPerformedAt,
    bool? isProgressionLocked,
    ExerciseType? exerciseType,
    LoadType? loadType,
  }) {
    final now = DateTime.now();
    return Exercise(
      id: id ?? 'exercise-1',
      name: name ?? 'Test Exercise',
      description: description ?? 'Test exercise description',
      imageUrl: imageUrl ?? 'https://example.com/image.jpg',
      videoUrl: videoUrl,
      muscleGroups: muscleGroups ?? [MuscleGroup.pectoralMajor],
      tips: tips ?? ['Test tip'],
      commonMistakes: commonMistakes ?? ['Test mistake'],
      category: category ?? ExerciseCategory.chest,
      difficulty: difficulty ?? ExerciseDifficulty.beginner,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      defaultWeight: defaultWeight ?? 100.0,
      defaultSets: defaultSets ?? 3,
      defaultReps: defaultReps ?? 10,
      restTimeSeconds: restTimeSeconds ?? 60,
      lastPerformedAt: lastPerformedAt,
      isProgressionLocked: isProgressionLocked ?? false,
      exerciseType: exerciseType ?? ExerciseType.multiJoint,
      loadType: loadType ?? LoadType.barbell,
    );
  }

  /// Creates a simple Exercise mock for basic testing
  static Exercise createSimpleExercise({
    String? id,
    String? name,
    double? defaultWeight,
    int? defaultSets,
    int? defaultReps,
    bool? isProgressionLocked,
  }) {
    return createExercise(
      id: id,
      name: name,
      defaultWeight: defaultWeight,
      defaultSets: defaultSets,
      defaultReps: defaultReps,
      isProgressionLocked: isProgressionLocked,
    );
  }

  /// Creates an Exercise mock for strength training
  static Exercise createStrengthExercise({
    String? id,
    String? name,
    double? defaultWeight,
    int? defaultSets,
    int? defaultReps,
  }) {
    return createExercise(
      id: id,
      name: name ?? 'Bench Press',
      muscleGroups: [
        MuscleGroup.pectoralMajor,
        MuscleGroup.anteriorDeltoid,
        MuscleGroup.tricepsLateralHead,
      ],
      category: ExerciseCategory.chest,
      difficulty: ExerciseDifficulty.intermediate,
      defaultWeight: defaultWeight ?? 135.0,
      defaultSets: defaultSets ?? 3,
      defaultReps: defaultReps ?? 8,
      exerciseType: ExerciseType.multiJoint,
      loadType: LoadType.barbell,
    );
  }

  /// Creates an Exercise mock for endurance training
  static Exercise createEnduranceExercise({
    String? id,
    String? name,
    double? defaultWeight,
    int? defaultSets,
    int? defaultReps,
  }) {
    return createExercise(
      id: id,
      name: name ?? 'Push-ups',
      muscleGroups: [
        MuscleGroup.pectoralMajor,
        MuscleGroup.anteriorDeltoid,
        MuscleGroup.tricepsLateralHead,
      ],
      category: ExerciseCategory.chest,
      difficulty: ExerciseDifficulty.beginner,
      defaultWeight: defaultWeight ?? 0.0,
      defaultSets: defaultSets ?? 3,
      defaultReps: defaultReps ?? 15,
      exerciseType: ExerciseType.multiJoint,
      loadType: LoadType.bodyweight,
    );
  }

  /// Creates an Exercise mock for deload testing
  static Exercise createDeloadExercise({
    String? id,
    String? name,
    double? defaultWeight,
    int? defaultSets,
    int? defaultReps,
  }) {
    return createExercise(
      id: id,
      name: name ?? 'Squat',
      muscleGroups: [MuscleGroup.rectusFemoris, MuscleGroup.gluteusMaximus],
      category: ExerciseCategory.quadriceps,
      difficulty: ExerciseDifficulty.intermediate,
      defaultWeight: defaultWeight ?? 200.0,
      defaultSets: defaultSets ?? 5,
      defaultReps: defaultReps ?? 5,
      exerciseType: ExerciseType.multiJoint,
      loadType: LoadType.barbell,
    );
  }
}
