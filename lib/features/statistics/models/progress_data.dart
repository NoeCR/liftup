import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'progress_data.g.dart';

@HiveType(typeId: 11)
@JsonSerializable()
class ProgressData extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String exerciseId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final double maxWeight;

  @HiveField(4)
  final int totalReps;

  @HiveField(5)
  final int totalSets;

  @HiveField(6)
  final double totalVolume;

  @HiveField(7)
  final Duration? duration;

  const ProgressData({
    required this.id,
    required this.exerciseId,
    required this.date,
    required this.maxWeight,
    required this.totalReps,
    required this.totalSets,
    required this.totalVolume,
    this.duration,
  });

  factory ProgressData.fromJson(Map<String, dynamic> json) => _$ProgressDataFromJson(json);
  Map<String, dynamic> toJson() => _$ProgressDataToJson(this);

  ProgressData copyWith({
    String? id,
    String? exerciseId,
    DateTime? date,
    double? maxWeight,
    int? totalReps,
    int? totalSets,
    double? totalVolume,
    Duration? duration,
  }) {
    return ProgressData(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      date: date ?? this.date,
      maxWeight: maxWeight ?? this.maxWeight,
      totalReps: totalReps ?? this.totalReps,
      totalSets: totalSets ?? this.totalSets,
      totalVolume: totalVolume ?? this.totalVolume,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object?> get props => [id, exerciseId, date, maxWeight, totalReps, totalSets, totalVolume, duration];
}

@HiveType(typeId: 12)
@JsonSerializable()
class WorkoutStatistics extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int totalWorkouts;

  @HiveField(3)
  final Duration totalTime;

  @HiveField(4)
  final double totalWeight;

  @HiveField(5)
  final int totalReps;

  @HiveField(6)
  final int totalSets;

  @HiveField(7)
  final double totalVolume;

  @HiveField(8)
  final List<String> exercisesPerformed;

  const WorkoutStatistics({
    required this.id,
    required this.date,
    required this.totalWorkouts,
    required this.totalTime,
    required this.totalWeight,
    required this.totalReps,
    required this.totalSets,
    required this.totalVolume,
    required this.exercisesPerformed,
  });

  factory WorkoutStatistics.fromJson(Map<String, dynamic> json) => _$WorkoutStatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutStatisticsToJson(this);

  WorkoutStatistics copyWith({
    String? id,
    DateTime? date,
    int? totalWorkouts,
    Duration? totalTime,
    double? totalWeight,
    int? totalReps,
    int? totalSets,
    double? totalVolume,
    List<String>? exercisesPerformed,
  }) {
    return WorkoutStatistics(
      id: id ?? this.id,
      date: date ?? this.date,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalTime: totalTime ?? this.totalTime,
      totalWeight: totalWeight ?? this.totalWeight,
      totalReps: totalReps ?? this.totalReps,
      totalSets: totalSets ?? this.totalSets,
      totalVolume: totalVolume ?? this.totalVolume,
      exercisesPerformed: exercisesPerformed ?? this.exercisesPerformed,
    );
  }

  @override
  List<Object?> get props => [
    id,
    date,
    totalWorkouts,
    totalTime,
    totalWeight,
    totalReps,
    totalSets,
    totalVolume,
    exercisesPerformed,
  ];
}
