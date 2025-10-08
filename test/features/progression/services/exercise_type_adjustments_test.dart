import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/progression/services/session_progression_service.dart';
import 'package:liftly/features/exercise/models/exercise.dart';

void main() {
  group('_adjustByExerciseType', () {
    test('multiJoint clamps increment and reps to configured range', () {
      final res = debugAdjustByExerciseType(
        exerciseType: ExerciseType.multiJoint,
        currentWeight: 100,
        proposedWeight: 107, // +7
        proposedReps: 25,
        custom: const {
          'multi_increment_min': 2.5,
          'multi_increment_max': 5.0,
          'multi_reps_min': 15,
          'multi_reps_max': 20,
        },
        incrementApplied: true,
      );
      expect(res['weight'], 105); // clamped to +5
      expect(res['reps'], 20); // clamped to max
    });

    test('isolation clamps to iso range', () {
      final res = debugAdjustByExerciseType(
        exerciseType: ExerciseType.isolation,
        currentWeight: 50,
        proposedWeight: 51.5,
        proposedReps: 5,
        custom: const {
          'iso_increment_min': 1.25,
          'iso_increment_max': 2.5,
          'iso_reps_min': 8,
          'iso_reps_max': 12,
        },
        incrementApplied: true,
      );
      expect(res['weight'], closeTo(51.25, 0.0001));
      expect(res['reps'], 8);
    });
  });
}
