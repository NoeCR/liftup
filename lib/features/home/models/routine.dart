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
  final List<WeekDay> days; // Solo los días de la semana, sin secciones

  @HiveField(4)
  final List<RoutineSection> sections; // Las secciones están en la rutina

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  @HiveField(7)
  final String? imageUrl;

  @HiveField(8)
  final int? order; // Orden manual para controlar la posición en la lista

  const Routine({
    required this.id,
    required this.name,
    required this.description,
    required this.days,
    required this.sections,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.order,
  });

  factory Routine.fromJson(Map<String, dynamic> json) => _$RoutineFromJson(json);
  Map<String, dynamic> toJson() => _$RoutineToJson(this);

  Routine copyWith({
    String? id,
    String? name,
    String? description,
    List<WeekDay>? days,
    List<RoutineSection>? sections,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    int? order,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      days: days ?? this.days,
      sections: sections ?? this.sections,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, name, description, days, sections, createdAt, updatedAt, imageUrl, order];
}

@HiveType(typeId: 7)
@JsonSerializable()
class RoutineSection extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String routineId;

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
    required this.routineId,
    required this.name,
    required this.exercises,
    required this.isCollapsed,
    required this.order,
    this.sectionTemplateId,
    this.iconName,
    this.muscleGroup,
  });

  factory RoutineSection.fromJson(Map<String, dynamic> json) => _$RoutineSectionFromJson(json);
  Map<String, dynamic> toJson() => _$RoutineSectionToJson(this);

  RoutineSection copyWith({
    String? id,
    String? routineId,
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
      routineId: routineId ?? this.routineId,
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
    routineId,
    name,
    exercises,
    isCollapsed,
    order,
    sectionTemplateId,
    iconName,
    muscleGroup,
  ];
}

@HiveType(typeId: 8)
@JsonSerializable()
class RoutineExercise extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String routineSectionId;

  @HiveField(2)
  final String exerciseId;

  @HiveField(3)
  final String? notes;

  @HiveField(4)
  final int order;

  const RoutineExercise({
    required this.id,
    required this.routineSectionId,
    required this.exerciseId,
    this.notes,
    required this.order,
  });

  factory RoutineExercise.fromJson(Map<String, dynamic> json) => _$RoutineExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$RoutineExerciseToJson(this);

  RoutineExercise copyWith({String? id, String? routineSectionId, String? exerciseId, String? notes, int? order}) {
    return RoutineExercise(
      id: id ?? this.id,
      routineSectionId: routineSectionId ?? this.routineSectionId,
      exerciseId: exerciseId ?? this.exerciseId,
      notes: notes ?? this.notes,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, routineSectionId, exerciseId, notes, order];
}
