import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/common/enums/muscle_group_enum.dart';

void main() {
  test('Exercise.exerciseType se persiste y copyWith lo mantiene/actualiza', () {
    final base = Exercise(
      id: 'e1',
      name: 'Press banca',
      description: 'Empuje horizontal',
      imageUrl: 'assets/images/default_exercise.png',
      muscleGroups: [MuscleGroup.pectoralMajor, MuscleGroup.tricepsLongHead],
      tips: const [],
      commonMistakes: const [],
      category: ExerciseCategory.chest,
      difficulty: ExerciseDifficulty.beginner,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      exerciseType: ExerciseType.multiJoint,
    );

    expect(base.exerciseType, ExerciseType.multiJoint);

    final updated = base.copyWith(exerciseType: ExerciseType.isolation);
    expect(updated.exerciseType, ExerciseType.isolation);

    final unchanged = updated.copyWith();
    expect(unchanged.exerciseType, ExerciseType.isolation);
  });
}
