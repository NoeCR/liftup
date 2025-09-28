import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise_set.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class ExerciseSet extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String exerciseId;

  @HiveField(2)
  final int reps;

  @HiveField(3)
  final double weight;

  @HiveField(4)
  final int? restTimeSeconds;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final DateTime completedAt;

  @HiveField(7)
  final bool isCompleted;

  const ExerciseSet({
    required this.id,
    required this.exerciseId,
    required this.reps,
    required this.weight,
    this.restTimeSeconds,
    this.notes,
    required this.completedAt,
    required this.isCompleted,
  });

  factory ExerciseSet.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSetFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseSetToJson(this);

  ExerciseSet copyWith({
    String? id,
    String? exerciseId,
    int? reps,
    double? weight,
    int? restTimeSeconds,
    String? notes,
    DateTime? completedAt,
    bool? isCompleted,
  }) {
    return ExerciseSet(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      restTimeSeconds: restTimeSeconds ?? this.restTimeSeconds,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
    id,
    exerciseId,
    reps,
    weight,
    restTimeSeconds,
    notes,
    completedAt,
    isCompleted,
  ];
}
