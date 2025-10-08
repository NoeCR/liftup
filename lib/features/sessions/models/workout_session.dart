import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../exercise/models/exercise_set.dart';

part 'workout_session.g.dart';

@HiveType(typeId: 4)
@JsonSerializable()
class WorkoutSession extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? routineId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final DateTime startTime;

  @HiveField(4)
  final DateTime? endTime;

  @HiveField(5)
  final List<ExerciseSet> exerciseSets;

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final SessionStatus status;

  @HiveField(8)
  final double? totalWeight;

  @HiveField(9)
  final int? totalReps;

  const WorkoutSession({
    required this.id,
    this.routineId,
    required this.name,
    required this.startTime,
    this.endTime,
    required this.exerciseSets,
    this.notes,
    required this.status,
    this.totalWeight,
    this.totalReps,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => _$WorkoutSessionFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutSessionToJson(this);

  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  bool get isActive => status == SessionStatus.active;
  bool get isCompleted => status == SessionStatus.completed;

  WorkoutSession copyWith({
    String? id,
    String? routineId,
    String? name,
    DateTime? startTime,
    DateTime? endTime,
    List<ExerciseSet>? exerciseSets,
    String? notes,
    SessionStatus? status,
    double? totalWeight,
    int? totalReps,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      exerciseSets: exerciseSets ?? this.exerciseSets,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      totalWeight: totalWeight ?? this.totalWeight,
      totalReps: totalReps ?? this.totalReps,
    );
  }

  @override
  List<Object?> get props => [
    id,
    routineId,
    name,
    startTime,
    endTime,
    exerciseSets,
    notes,
    status,
    totalWeight,
    totalReps,
  ];
}

@HiveType(typeId: 5)
enum SessionStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  completed,
  @HiveField(2)
  paused,
}
