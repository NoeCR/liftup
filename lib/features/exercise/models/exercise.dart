import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../common/enums/muscle_group_enum.dart';

part 'exercise.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class Exercise extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String imageUrl;

  @HiveField(4)
  final String? videoUrl;

  @HiveField(5)
  final List<MuscleGroup> muscleGroups;

  @HiveField(6)
  final List<String> tips;

  @HiveField(7)
  final List<String> commonMistakes;

  @HiveField(8)
  final ExerciseCategory category;

  @HiveField(9)
  final ExerciseDifficulty difficulty;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  @HiveField(12)
  final double? defaultWeight;

  @HiveField(13)
  final int? defaultSets;

  @HiveField(14)
  final int? defaultReps;

  @HiveField(15)
  final int? restTimeSeconds;

  @HiveField(16)
  final DateTime? lastPerformedAt;

  @HiveField(17)
  final bool isProgressionLocked;

  @HiveField(18)
  final ExerciseType exerciseType;

  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.videoUrl,
    required this.muscleGroups,
    required this.tips,
    required this.commonMistakes,
    required this.category,
    required this.difficulty,
    required this.createdAt,
    required this.updatedAt,
    this.defaultWeight,
    this.defaultSets,
    this.defaultReps,
    this.restTimeSeconds,
    this.lastPerformedAt,
    this.isProgressionLocked = false,
    this.exerciseType = ExerciseType.multiJoint,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseToJson(this);

  Exercise copyWith({
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
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      tips: tips ?? this.tips,
      commonMistakes: commonMistakes ?? this.commonMistakes,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      defaultWeight: defaultWeight ?? this.defaultWeight,
      defaultSets: defaultSets ?? this.defaultSets,
      defaultReps: defaultReps ?? this.defaultReps,
      restTimeSeconds: restTimeSeconds ?? this.restTimeSeconds,
      lastPerformedAt: lastPerformedAt ?? this.lastPerformedAt,
      isProgressionLocked: isProgressionLocked ?? this.isProgressionLocked,
      exerciseType: exerciseType ?? this.exerciseType,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    imageUrl,
    videoUrl,
    muscleGroups,
    tips,
    commonMistakes,
    category,
    difficulty,
    createdAt,
    updatedAt,
    defaultWeight,
    defaultSets,
    defaultReps,
    restTimeSeconds,
    lastPerformedAt,
    isProgressionLocked,
    exerciseType,
  ];
}

@HiveType(typeId: 1)
enum ExerciseCategory {
  @HiveField(0)
  chest,
  @HiveField(1)
  back,
  @HiveField(2)
  shoulders,
  @HiveField(3)
  biceps,
  @HiveField(4)
  triceps,
  @HiveField(5)
  forearms,
  @HiveField(6)
  quadriceps,
  @HiveField(7)
  hamstrings,
  @HiveField(8)
  glutes,
  @HiveField(9)
  calves,
  @HiveField(10)
  core,
  @HiveField(11)
  cardio,
  @HiveField(12)
  fullBody,
}

extension ExerciseCategoryExtension on ExerciseCategory {
  String get displayName {
    switch (this) {
      case ExerciseCategory.chest:
        return 'Pecho';
      case ExerciseCategory.back:
        return 'Espalda';
      case ExerciseCategory.shoulders:
        return 'Hombros';
      case ExerciseCategory.biceps:
        return 'Bíceps';
      case ExerciseCategory.triceps:
        return 'Tríceps';
      case ExerciseCategory.forearms:
        return 'Antebrazos';
      case ExerciseCategory.quadriceps:
        return 'Cuádriceps';
      case ExerciseCategory.hamstrings:
        return 'Isquiotibiales';
      case ExerciseCategory.glutes:
        return 'Glúteos';
      case ExerciseCategory.calves:
        return 'Pantorrillas';
      case ExerciseCategory.core:
        return 'Core';
      case ExerciseCategory.cardio:
        return 'Cardio';
      case ExerciseCategory.fullBody:
        return 'Cuerpo Completo';
    }
  }
}

@HiveType(typeId: 2)
enum ExerciseDifficulty {
  @HiveField(0)
  beginner,
  @HiveField(1)
  intermediate,
  @HiveField(2)
  advanced,
}

@HiveType(typeId: 25)
enum ExerciseType {
  @HiveField(0)
  multiJoint('Multi-joint', 'Exercises involving multiple joints'),

  @HiveField(1)
  isolation('Isolation', 'Exercises focusing on a specific muscle group');

  const ExerciseType(this.displayName, this.description);

  final String displayName;
  final String description;
}
