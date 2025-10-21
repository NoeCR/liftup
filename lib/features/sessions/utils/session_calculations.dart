import '../../exercise/models/exercise_set.dart';

/// Utility class for session-related calculations
class SessionCalculations {
  /// Calculates the maximum weight used in the exercise
  /// Formula: max(weight) for each set
  static double calculateTotalWeight(List<ExerciseSet> sets) {
    if (sets.isEmpty) return 0.0;
    return sets.map((set) => set.weight).reduce((a, b) => a > b ? a : b);
  }

  /// Calculates total repetitions performed in a session
  /// Formula: sum(reps) for each set
  static int calculateTotalReps(List<ExerciseSet> sets) {
    return sets.fold(0, (sum, set) => sum + set.reps);
  }

  /// Calculates total sets performed in a session
  /// Formula: count of sets
  static int calculateTotalSets(List<ExerciseSet> sets) {
    return sets.length;
  }

  /// Calculates average weight per repetition
  /// Formula: sum(weight * reps) / totalReps
  static double calculateAverageWeightPerRep(List<ExerciseSet> sets) {
    final totalWeightLifted = sets.fold(0.0, (sum, set) => sum + (set.weight * set.reps));
    final totalReps = calculateTotalReps(sets);
    return totalReps > 0 ? totalWeightLifted / totalReps : 0.0;
  }

  /// Calculates average repetitions per set
  /// Formula: totalReps / totalSets
  static double calculateAverageRepsPerSet(List<ExerciseSet> sets) {
    final totalReps = calculateTotalReps(sets);
    final totalSets = calculateTotalSets(sets);
    return totalSets > 0 ? totalReps / totalSets : 0.0;
  }

  /// Calculates average weight per set
  /// Formula: sum(weight * reps) / totalSets
  static double calculateAverageWeightPerSet(List<ExerciseSet> sets) {
    final totalWeightLifted = sets.fold(0.0, (sum, set) => sum + (set.weight * set.reps));
    final totalSets = calculateTotalSets(sets);
    return totalSets > 0 ? totalWeightLifted / totalSets : 0.0;
  }

  /// Groups sets by exercise ID and calculates totals for each exercise
  static Map<String, ExerciseTotals> calculateExerciseTotals(List<ExerciseSet> sets) {
    final Map<String, List<ExerciseSet>> groupedSets = {};

    for (final set in sets) {
      groupedSets.putIfAbsent(set.exerciseId, () => []).add(set);
    }

    final Map<String, ExerciseTotals> exerciseTotals = {};
    for (final entry in groupedSets.entries) {
      final exerciseId = entry.key;
      final exerciseSets = entry.value;

      exerciseTotals[exerciseId] = ExerciseTotals(
        totalWeight: calculateTotalWeight(exerciseSets),
        totalReps: calculateTotalReps(exerciseSets),
        totalSets: calculateTotalSets(exerciseSets),
        averageWeightPerRep: calculateAverageWeightPerRep(exerciseSets),
        averageRepsPerSet: calculateAverageRepsPerSet(exerciseSets),
        averageWeightPerSet: calculateAverageWeightPerSet(exerciseSets),
      );
    }

    return exerciseTotals;
  }
}

/// Data class for exercise totals
class ExerciseTotals {
  final double totalWeight; // Maximum weight used in the exercise
  final int totalReps;
  final int totalSets;
  final double averageWeightPerRep;
  final double averageRepsPerSet;
  final double averageWeightPerSet;

  const ExerciseTotals({
    required this.totalWeight,
    required this.totalReps,
    required this.totalSets,
    required this.averageWeightPerRep,
    required this.averageRepsPerSet,
    required this.averageWeightPerSet,
  });

  @override
  String toString() {
    return 'ExerciseTotals('
        'totalWeight: $totalWeight, '
        'totalReps: $totalReps, '
        'totalSets: $totalSets, '
        'avgWeightPerRep: ${averageWeightPerRep.toStringAsFixed(2)}, '
        'avgRepsPerSet: ${averageRepsPerSet.toStringAsFixed(2)}, '
        'avgWeightPerSet: ${averageWeightPerSet.toStringAsFixed(2)}'
        ')';
  }
}
