import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../common/enums/week_day_enum.dart';
import '../../../common/enums/section_muscle_group_enum.dart';

part 'routine.g.dart';

@HiveType(typeId: 6)
@JsonSerializable()
class Routine extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final List<RoutineDay> days;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  @HiveField(6)
  final bool isActive;

  @HiveField(7)
  final String? imageUrl;

  const Routine({
    required this.id,
    required this.name,
    required this.description,
    required this.days,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.imageUrl,
  });

  factory Routine.fromJson(Map<String, dynamic> json) =>
      _$RoutineFromJson(json);
  Map<String, dynamic> toJson() => _$RoutineToJson(this);

  Routine copyWith({
    String? id,
    String? name,
    String? description,
    List<RoutineDay>? days,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? imageUrl,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      days: days ?? this.days,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    days,
    createdAt,
    updatedAt,
    isActive,
    imageUrl,
  ];
}

@HiveType(typeId: 7)
@JsonSerializable()
class RoutineDay extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String routineId;

  @HiveField(2)
  final WeekDay dayOfWeek;

  @HiveField(3)
  final String name;

  @HiveField(4)
  final List<RoutineSection> sections;

  @HiveField(5)
  final bool isActive;

  const RoutineDay({
    required this.id,
    required this.routineId,
    required this.dayOfWeek,
    required this.name,
    required this.sections,
    required this.isActive,
  });

  factory RoutineDay.fromJson(Map<String, dynamic> json) =>
      _$RoutineDayFromJson(json);
  Map<String, dynamic> toJson() => _$RoutineDayToJson(this);

  RoutineDay copyWith({
    String? id,
    String? routineId,
    WeekDay? dayOfWeek,
    String? name,
    List<RoutineSection>? sections,
    bool? isActive,
  }) {
    return RoutineDay(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      name: name ?? this.name,
      sections: sections ?? this.sections,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    routineId,
    dayOfWeek,
    name,
    sections,
    isActive,
  ];
}

@HiveType(typeId: 8)
@JsonSerializable()
class RoutineSection extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String routineDayId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final List<RoutineExercise> exercises;

  @HiveField(4)
  final bool isCollapsed;

  @HiveField(5)
  final int order;

  @HiveField(6)
  final String? sectionTemplateId;

  @HiveField(7)
  final String? iconName;

  @HiveField(8)
  final SectionMuscleGroup? muscleGroup;

  const RoutineSection({
    required this.id,
    required this.routineDayId,
    required this.name,
    required this.exercises,
    required this.isCollapsed,
    required this.order,
    this.sectionTemplateId,
    this.iconName,
    this.muscleGroup,
  });

  factory RoutineSection.fromJson(Map<String, dynamic> json) =>
      _$RoutineSectionFromJson(json);
  Map<String, dynamic> toJson() => _$RoutineSectionToJson(this);

  RoutineSection copyWith({
    String? id,
    String? routineDayId,
    String? name,
    List<RoutineExercise>? exercises,
    bool? isCollapsed,
    int? order,
    String? sectionTemplateId,
    String? iconName,
    SectionMuscleGroup? muscleGroup,
  }) {
    return RoutineSection(
      id: id ?? this.id,
      routineDayId: routineDayId ?? this.routineDayId,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      isCollapsed: isCollapsed ?? this.isCollapsed,
      order: order ?? this.order,
      sectionTemplateId: sectionTemplateId ?? this.sectionTemplateId,
      iconName: iconName ?? this.iconName,
      muscleGroup: muscleGroup ?? this.muscleGroup,
    );
  }

  @override
  List<Object?> get props => [
    id,
    routineDayId,
    name,
    exercises,
    isCollapsed,
    order,
    sectionTemplateId,
    iconName,
    muscleGroup,
  ];
}

@HiveType(typeId: 9)
@JsonSerializable()
class RoutineExercise extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String routineSectionId;

  @HiveField(2)
  final String exerciseId;

  @HiveField(3)
  final int sets;

  @HiveField(4)
  final int reps;

  @HiveField(5)
  final double weight;

  @HiveField(6)
  final int? restTimeSeconds;

  @HiveField(7)
  final String? notes;

  @HiveField(8)
  final int order;

  const RoutineExercise({
    required this.id,
    required this.routineSectionId,
    required this.exerciseId,
    required this.sets,
    required this.reps,
    required this.weight,
    this.restTimeSeconds,
    this.notes,
    required this.order,
  });

  factory RoutineExercise.fromJson(Map<String, dynamic> json) =>
      _$RoutineExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$RoutineExerciseToJson(this);

  RoutineExercise copyWith({
    String? id,
    String? routineSectionId,
    String? exerciseId,
    int? sets,
    int? reps,
    double? weight,
    int? restTimeSeconds,
    String? notes,
    int? order,
  }) {
    return RoutineExercise(
      id: id ?? this.id,
      routineSectionId: routineSectionId ?? this.routineSectionId,
      exerciseId: exerciseId ?? this.exerciseId,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      restTimeSeconds: restTimeSeconds ?? this.restTimeSeconds,
      notes: notes ?? this.notes,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [
    id,
    routineSectionId,
    exerciseId,
    sets,
    reps,
    weight,
    restTimeSeconds,
    notes,
    order,
  ];
}

