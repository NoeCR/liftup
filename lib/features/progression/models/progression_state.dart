import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'progression_state.g.dart';

@HiveType(typeId: 19)
@JsonSerializable()
class ProgressionState extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String progressionConfigId;

  @HiveField(2)
  final String exerciseId;

  @HiveField(3)
  final String routineId;

  @HiveField(4)
  final int currentCycle;

  @HiveField(5)
  final int currentWeek;

  @HiveField(6)
  final int currentSession;

  @HiveField(7)
  final double currentWeight;

  @HiveField(8)
  final int currentReps;

  @HiveField(9)
  final int currentSets;

  @HiveField(10)
  final double baseWeight;

  @HiveField(11)
  final int baseReps;

  @HiveField(12)
  final int baseSets;

  @HiveField(13)
  final Map<String, dynamic> sessionHistory;

  @HiveField(14)
  final DateTime lastUpdated;

  @HiveField(15)
  final bool isDeloadWeek;

  @HiveField(16)
  final double? oneRepMax;

  @HiveField(17)
  final Map<String, dynamic> customData;

  const ProgressionState({
    required this.id,
    required this.progressionConfigId,
    required this.exerciseId,
    required this.routineId,
    required this.currentCycle,
    required this.currentWeek,
    required this.currentSession,
    required this.currentWeight,
    required this.currentReps,
    required this.currentSets,
    required this.baseWeight,
    required this.baseReps,
    required this.baseSets,
    required this.sessionHistory,
    required this.lastUpdated,
    required this.isDeloadWeek,
    this.oneRepMax,
    required this.customData,
  });

  factory ProgressionState.fromJson(Map<String, dynamic> json) => _$ProgressionStateFromJson(json);
  Map<String, dynamic> toJson() => _$ProgressionStateToJson(this);

  ProgressionState copyWith({
    String? id,
    String? progressionConfigId,
    String? exerciseId,
    String? routineId,
    int? currentCycle,
    int? currentWeek,
    int? currentSession,
    double? currentWeight,
    int? currentReps,
    int? currentSets,
    double? baseWeight,
    int? baseReps,
    int? baseSets,
    Map<String, dynamic>? sessionHistory,
    DateTime? lastUpdated,
    bool? isDeloadWeek,
    double? oneRepMax,
    Map<String, dynamic>? customData,
  }) {
    return ProgressionState(
      id: id ?? this.id,
      progressionConfigId: progressionConfigId ?? this.progressionConfigId,
      exerciseId: exerciseId ?? this.exerciseId,
      routineId: routineId ?? this.routineId,
      currentCycle: currentCycle ?? this.currentCycle,
      currentWeek: currentWeek ?? this.currentWeek,
      currentSession: currentSession ?? this.currentSession,
      currentWeight: currentWeight ?? this.currentWeight,
      currentReps: currentReps ?? this.currentReps,
      currentSets: currentSets ?? this.currentSets,
      baseWeight: baseWeight ?? this.baseWeight,
      baseReps: baseReps ?? this.baseReps,
      baseSets: baseSets ?? this.baseSets,
      sessionHistory: sessionHistory ?? this.sessionHistory,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isDeloadWeek: isDeloadWeek ?? this.isDeloadWeek,
      oneRepMax: oneRepMax ?? this.oneRepMax,
      customData: customData ?? this.customData,
    );
  }

  @override
  List<Object?> get props => [
    id,
    progressionConfigId,
    exerciseId,
    routineId,
    currentCycle,
    currentWeek,
    currentSession,
    currentWeight,
    currentReps,
    currentSets,
    baseWeight,
    baseReps,
    baseSets,
    sessionHistory,
    lastUpdated,
    isDeloadWeek,
    oneRepMax,
    customData,
  ];
}
