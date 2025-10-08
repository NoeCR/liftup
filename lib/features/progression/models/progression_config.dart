import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../common/enums/progression_type_enum.dart';

part 'progression_config.g.dart';

@HiveType(typeId: 23)
@JsonSerializable()
class ProgressionConfig extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final bool isGlobal;

  @HiveField(2)
  final ProgressionType type;

  @HiveField(3)
  final ProgressionUnit unit;

  @HiveField(4)
  final ProgressionTarget primaryTarget;

  @HiveField(5)
  final ProgressionTarget? secondaryTarget;

  @HiveField(6)
  final double incrementValue;

  @HiveField(7)
  final int incrementFrequency;

  @HiveField(8)
  final int cycleLength;

  @HiveField(9)
  final int deloadWeek;

  @HiveField(10)
  final double deloadPercentage;

  @HiveField(11)
  final Map<String, dynamic> customParameters;

  @HiveField(12)
  final DateTime startDate;

  @HiveField(13)
  final DateTime? endDate;

  @HiveField(14)
  final bool isActive;

  @HiveField(15)
  final DateTime createdAt;

  @HiveField(16)
  final DateTime updatedAt;

  const ProgressionConfig({
    required this.id,
    required this.isGlobal,
    required this.type,
    required this.unit,
    required this.primaryTarget,
    this.secondaryTarget,
    required this.incrementValue,
    required this.incrementFrequency,
    required this.cycleLength,
    required this.deloadWeek,
    required this.deloadPercentage,
    required this.customParameters,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProgressionConfig.fromJson(Map<String, dynamic> json) =>
      _$ProgressionConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ProgressionConfigToJson(this);

  ProgressionConfig copyWith({
    String? id,
    bool? isGlobal,
    ProgressionType? type,
    ProgressionUnit? unit,
    ProgressionTarget? primaryTarget,
    ProgressionTarget? secondaryTarget,
    double? incrementValue,
    int? incrementFrequency,
    int? cycleLength,
    int? deloadWeek,
    double? deloadPercentage,
    Map<String, dynamic>? customParameters,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProgressionConfig(
      id: id ?? this.id,
      isGlobal: isGlobal ?? this.isGlobal,
      type: type ?? this.type,
      unit: unit ?? this.unit,
      primaryTarget: primaryTarget ?? this.primaryTarget,
      secondaryTarget: secondaryTarget ?? this.secondaryTarget,
      incrementValue: incrementValue ?? this.incrementValue,
      incrementFrequency: incrementFrequency ?? this.incrementFrequency,
      cycleLength: cycleLength ?? this.cycleLength,
      deloadWeek: deloadWeek ?? this.deloadWeek,
      deloadPercentage: deloadPercentage ?? this.deloadPercentage,
      customParameters: customParameters ?? this.customParameters,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    isGlobal,
    type,
    unit,
    primaryTarget,
    secondaryTarget,
    incrementValue,
    incrementFrequency,
    cycleLength,
    deloadWeek,
    deloadPercentage,
    customParameters,
    startDate,
    endDate,
    isActive,
    createdAt,
    updatedAt,
  ];
}
