import 'package:hive/hive.dart';
import '../../features/exercise/models/exercise.dart';
import '../../features/exercise/models/exercise_set.dart';
import '../../features/sessions/models/workout_session.dart';
import '../../features/home/models/routine.dart';
import '../../features/home/models/routine_section_template.dart';
import '../../features/statistics/models/progress_data.dart';
import '../../common/enums/week_day_enum.dart';
import '../../common/enums/muscle_group_enum.dart';
import '../../common/enums/section_muscle_group_enum.dart';

class HiveAdapters {
  static bool _adaptersRegistered = false;

  static void registerAdapters() {
    if (_adaptersRegistered) {
      return;
    }

    try {
      // Exercise adapters
      _registerAdapterSafely<Exercise>(ExerciseAdapter());
      _registerAdapterSafely<ExerciseCategory>(ExerciseCategoryAdapter());
      _registerAdapterSafely<ExerciseDifficulty>(ExerciseDifficultyAdapter());

      // Exercise Set adapters
      _registerAdapterSafely<ExerciseSet>(ExerciseSetAdapter());

      // Workout Session adapters
      _registerAdapterSafely<WorkoutSession>(WorkoutSessionAdapter());
      _registerAdapterSafely<SessionStatus>(SessionStatusAdapter());

      // Routine adapters
      _registerAdapterSafely<Routine>(RoutineAdapter());
      _registerAdapterSafely<RoutineSection>(RoutineSectionAdapter());
      _registerAdapterSafely<RoutineExercise>(RoutineExerciseAdapter());
      _registerAdapterSafely<WeekDay>(WeekDayAdapter());

      // Progress Data adapters
      _registerAdapterSafely<ProgressData>(ProgressDataAdapter());
      _registerAdapterSafely<WorkoutStatistics>(WorkoutStatisticsAdapter());

      // Enum adapters
      _registerAdapterSafely<MuscleGroup>(MuscleGroupAdapter());

      // Routine Section Template adapters
      _registerAdapterSafely<RoutineSectionTemplate>(
        RoutineSectionTemplateAdapter(),
      );

      // Section Muscle Group adapters
      _registerAdapterSafely<SectionMuscleGroup>(SectionMuscleGroupAdapter());

      _adaptersRegistered = true;
    } catch (e) {
      rethrow;
    }
  }

  static void _registerAdapterSafely<T>(TypeAdapter<T> adapter) {
    try {
      Hive.registerAdapter<T>(adapter);
    } catch (e) {
      // If adapter is already registered, that's fine
      if (!e.toString().contains('already registered')) {
        rethrow;
      }
    }
  }

  static void resetRegistration() {
    _adaptersRegistered = false;
  }
}
