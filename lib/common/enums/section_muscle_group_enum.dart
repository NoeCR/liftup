import 'package:hive/hive.dart';

part 'section_muscle_group_enum.g.dart';

@HiveType(typeId: 15)
enum SectionMuscleGroup {
  @HiveField(0)
  chest,
  @HiveField(1)
  back,
  @HiveField(2)
  shoulders,
  @HiveField(3)
  trapezius,
  @HiveField(4)
  quadriceps,
  @HiveField(5)
  biceps,
  @HiveField(6)
  triceps,
  @HiveField(7)
  calves,
  @HiveField(8)
  hamstrings,
  @HiveField(9)
  core,
  @HiveField(10)
  cardio,
  @HiveField(11)
  warmup,
  @HiveField(12)
  cooldown,
}

extension SectionMuscleGroupExtension on SectionMuscleGroup {
  String get displayName {
    switch (this) {
      case SectionMuscleGroup.chest:
        return 'Pecho';
      case SectionMuscleGroup.back:
        return 'Espalda';
      case SectionMuscleGroup.shoulders:
        return 'Hombros';
      case SectionMuscleGroup.trapezius:
        return 'Trapecio';
      case SectionMuscleGroup.quadriceps:
        return 'Cuádriceps';
      case SectionMuscleGroup.biceps:
        return 'Bíceps';
      case SectionMuscleGroup.triceps:
        return 'Tríceps';
      case SectionMuscleGroup.calves:
        return 'Gemelos';
      case SectionMuscleGroup.hamstrings:
        return 'Isquiotibiales';
      case SectionMuscleGroup.core:
        return 'Core';
      case SectionMuscleGroup.cardio:
        return 'Cardio';
      case SectionMuscleGroup.warmup:
        return 'Calentamiento';
      case SectionMuscleGroup.cooldown:
        return 'Enfriamiento';
    }
  }

  String get iconName {
    switch (this) {
      case SectionMuscleGroup.chest:
        return 'fitness_center';
      case SectionMuscleGroup.back:
        return 'sports_gymnastics';
      case SectionMuscleGroup.shoulders:
        return 'sports_martial_arts';
      case SectionMuscleGroup.trapezius:
        return 'sports_tennis';
      case SectionMuscleGroup.quadriceps:
        return 'directions_run';
      case SectionMuscleGroup.biceps:
        return 'sports_basketball';
      case SectionMuscleGroup.triceps:
        return 'sports_volleyball';
      case SectionMuscleGroup.calves:
        return 'sports_soccer';
      case SectionMuscleGroup.hamstrings:
        return 'sports_handball';
      case SectionMuscleGroup.core:
        return 'self_improvement';
      case SectionMuscleGroup.cardio:
        return 'pool';
      case SectionMuscleGroup.warmup:
        return 'warm_up';
      case SectionMuscleGroup.cooldown:
        return 'self_improvement';
    }
  }

  String get description {
    switch (this) {
      case SectionMuscleGroup.chest:
        return 'Ejercicios para el desarrollo del pecho';
      case SectionMuscleGroup.back:
        return 'Ejercicios para fortalecer la espalda';
      case SectionMuscleGroup.shoulders:
        return 'Ejercicios para los hombros';
      case SectionMuscleGroup.trapezius:
        return 'Ejercicios para el trapecio';
      case SectionMuscleGroup.quadriceps:
        return 'Ejercicios para los cuádriceps';
      case SectionMuscleGroup.biceps:
        return 'Ejercicios para los bíceps';
      case SectionMuscleGroup.triceps:
        return 'Ejercicios para los tríceps';
      case SectionMuscleGroup.calves:
        return 'Ejercicios para los gemelos';
      case SectionMuscleGroup.hamstrings:
        return 'Ejercicios para los isquiotibiales';
      case SectionMuscleGroup.core:
        return 'Ejercicios para el core y abdominales';
      case SectionMuscleGroup.cardio:
        return 'Ejercicios cardiovasculares';
      case SectionMuscleGroup.warmup:
        return 'Ejercicios de calentamiento y activación';
      case SectionMuscleGroup.cooldown:
        return 'Ejercicios de enfriamiento y estiramiento';
    }
  }

  static List<SectionMuscleGroup> get allGroups => SectionMuscleGroup.values;

  static List<SectionMuscleGroup> get muscleGroups => [
    SectionMuscleGroup.chest,
    SectionMuscleGroup.back,
    SectionMuscleGroup.shoulders,
    SectionMuscleGroup.trapezius,
    SectionMuscleGroup.quadriceps,
    SectionMuscleGroup.biceps,
    SectionMuscleGroup.triceps,
    SectionMuscleGroup.calves,
    SectionMuscleGroup.hamstrings,
    SectionMuscleGroup.core,
    SectionMuscleGroup.cardio,
  ];

  static List<SectionMuscleGroup> get specialGroups => [SectionMuscleGroup.warmup, SectionMuscleGroup.cooldown];
}
