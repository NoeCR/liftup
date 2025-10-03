import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:liftup/features/sessions/notifiers/session_notifier.dart';
import 'package:liftup/features/sessions/models/workout_session.dart';
import 'package:liftup/features/home/notifiers/routine_notifier.dart';
import 'package:liftup/features/home/models/routine.dart';
import 'package:liftup/features/exercise/notifiers/exercise_notifier.dart';
import 'package:liftup/features/exercise/models/exercise.dart';

class FakeSessionNotifier extends SessionNotifier {
  @override
  Future<List<WorkoutSession>> build() async {
    return <WorkoutSession>[];
  }
}

class FakeRoutineNotifier extends RoutineNotifier {
  @override
  Future<List<Routine>> build() async {
    return <Routine>[];
  }
}

class FakeExerciseNotifier extends ExerciseNotifier {
  @override
  Future<List<Exercise>> build() async {
    return <Exercise>[];
  }
}

