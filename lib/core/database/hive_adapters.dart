import 'package:hive/hive.dart';
import '../../features/exercise/models/exercise.dart';
import '../../features/exercise/models/exercise_set.dart';
import '../../features/sessions/models/workout_session.dart';
import '../../features/home/models/routine.dart';
import '../../features/statistics/models/progress_data.dart';
import '../../common/enums/week_day_enum.dart';
import '../../common/enums/muscle_group_enum.dart';

class HiveAdapters {
  static void registerAdapters() {
    // Exercise adapters
    Hive.registerAdapter(ExerciseAdapter());
    Hive.registerAdapter(ExerciseCategoryAdapter());
    Hive.registerAdapter(ExerciseDifficultyAdapter());

    // Exercise Set adapters
    Hive.registerAdapter(ExerciseSetAdapter());

    // Workout Session adapters
    Hive.registerAdapter(WorkoutSessionAdapter());
    Hive.registerAdapter(SessionStatusAdapter());

    // Routine adapters
    Hive.registerAdapter(RoutineAdapter());
    Hive.registerAdapter(RoutineDayAdapter());
    Hive.registerAdapter(RoutineSectionAdapter());
    Hive.registerAdapter(RoutineExerciseAdapter());
    Hive.registerAdapter(WeekDayAdapter());

    // Progress Data adapters
    Hive.registerAdapter(ProgressDataAdapter());
    Hive.registerAdapter(WorkoutStatisticsAdapter());

    // Enum adapters
    Hive.registerAdapter(MuscleGroupAdapter());
  }
}
