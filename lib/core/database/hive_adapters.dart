import 'package:hive/hive.dart';

import '../../common/enums/muscle_group_enum.dart';
import '../../common/enums/progression_type_enum.dart';
import '../../common/enums/section_muscle_group_enum.dart';
import '../../common/enums/week_day_enum.dart';
import '../../features/exercise/models/exercise.dart';
import '../../features/exercise/models/exercise_set.dart';
import '../../features/home/models/routine.dart';
import '../../features/home/models/routine_section_template.dart';
import '../../features/progression/models/progression_config.dart';
import '../../features/progression/models/progression_state.dart';
import '../../features/sessions/models/workout_session.dart';
import '../../features/statistics/models/progress_data.dart';

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
      _registerAdapterSafely<ExerciseType>(ExerciseTypeAdapter());

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
      _registerAdapterSafely<RoutineSectionTemplate>(RoutineSectionTemplateAdapter());

      // Section Muscle Group adapters
      _registerAdapterSafely<SectionMuscleGroup>(SectionMuscleGroupAdapter());

      // Progression adapters
      _registerAdapterSafely<ProgressionConfig>(ProgressionConfigAdapter());
      _registerAdapterSafely<ProgressionState>(ProgressionStateAdapter());
      // _registerAdapterSafely<ProgressionTemplate>(ProgressionTemplateAdapter());
      _registerAdapterSafely<ProgressionType>(ProgressionTypeAdapter());
      _registerAdapterSafely<ProgressionUnit>(ProgressionUnitAdapter());
      _registerAdapterSafely<ProgressionTarget>(ProgressionTargetAdapter());

      _adaptersRegistered = true;
    } catch (e) {
      rethrow;
    }
  }

  static void _registerAdapterSafely<T>(TypeAdapter<T> adapter) {
    // Avoid duplicate registration by checking typeId first
    // Note: Hive throws different messages depending on platform; be proactive.
    try {
      // @ignore: cast ok for accessing typeId
      final dynamic dynAdapter = adapter;
      final int? typeId = (dynAdapter is TypeAdapter) ? dynAdapter.typeId : null;
      if (typeId != null) {
        final bool already = Hive.isAdapterRegistered(typeId);
        if (already) {
          return;
        }
      }

      Hive.registerAdapter<T>(adapter);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('already registered') || msg.contains('there is already a typeadapter')) {
        return; // ignore duplicate registration errors
      }
      rethrow;
    }
  }

  static void resetRegistration() {
    _adaptersRegistered = false;
  }
}
