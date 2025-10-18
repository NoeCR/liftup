import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../common/enums/progression_type_enum.dart';

part 'progression_template.g.dart';

@HiveType(typeId: 22)
@JsonSerializable()
class ProgressionTemplate extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final ProgressionType type;

  @HiveField(4)
  final ProgressionUnit defaultUnit;

  @HiveField(5)
  final ProgressionTarget defaultPrimaryTarget;

  @HiveField(6)
  final ProgressionTarget? defaultSecondaryTarget;

  @HiveField(7)
  final double defaultIncrementValue;

  @HiveField(8)
  final int defaultIncrementFrequency;

  @HiveField(9)
  final int defaultCycleLength;

  @HiveField(10)
  final int defaultDeloadWeek;

  @HiveField(11)
  final double defaultDeloadPercentage;

  @HiveField(12)
  final Map<String, dynamic> defaultParameters;

  @HiveField(13)
  final List<String> recommendedFor;

  @HiveField(14)
  final String difficulty;

  @HiveField(15)
  final String example;

  @HiveField(16)
  final bool isBuiltIn;

  @HiveField(17)
  final DateTime createdAt;

  const ProgressionTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.defaultUnit,
    required this.defaultPrimaryTarget,
    this.defaultSecondaryTarget,
    required this.defaultIncrementValue,
    required this.defaultIncrementFrequency,
    required this.defaultCycleLength,
    required this.defaultDeloadWeek,
    required this.defaultDeloadPercentage,
    required this.defaultParameters,
    required this.recommendedFor,
    required this.difficulty,
    required this.example,
    required this.isBuiltIn,
    required this.createdAt,
  });

  factory ProgressionTemplate.fromJson(Map<String, dynamic> json) => _$ProgressionTemplateFromJson(json);
  Map<String, dynamic> toJson() => _$ProgressionTemplateToJson(this);

  ProgressionTemplate copyWith({
    String? id,
    String? name,
    String? description,
    ProgressionType? type,
    ProgressionUnit? defaultUnit,
    ProgressionTarget? defaultPrimaryTarget,
    ProgressionTarget? defaultSecondaryTarget,
    double? defaultIncrementValue,
    int? defaultIncrementFrequency,
    int? defaultCycleLength,
    int? defaultDeloadWeek,
    double? defaultDeloadPercentage,
    Map<String, dynamic>? defaultParameters,
    List<String>? recommendedFor,
    String? difficulty,
    String? example,
    bool? isBuiltIn,
    DateTime? createdAt,
  }) {
    return ProgressionTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      defaultUnit: defaultUnit ?? this.defaultUnit,
      defaultPrimaryTarget: defaultPrimaryTarget ?? this.defaultPrimaryTarget,
      defaultSecondaryTarget: defaultSecondaryTarget ?? this.defaultSecondaryTarget,
      defaultIncrementValue: defaultIncrementValue ?? this.defaultIncrementValue,
      defaultIncrementFrequency: defaultIncrementFrequency ?? this.defaultIncrementFrequency,
      defaultCycleLength: defaultCycleLength ?? this.defaultCycleLength,
      defaultDeloadWeek: defaultDeloadWeek ?? this.defaultDeloadWeek,
      defaultDeloadPercentage: defaultDeloadPercentage ?? this.defaultDeloadPercentage,
      defaultParameters: defaultParameters ?? this.defaultParameters,
      recommendedFor: recommendedFor ?? this.recommendedFor,
      difficulty: difficulty ?? this.difficulty,
      example: example ?? this.example,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    type,
    defaultUnit,
    defaultPrimaryTarget,
    defaultSecondaryTarget,
    defaultIncrementValue,
    defaultIncrementFrequency,
    defaultCycleLength,
    defaultDeloadWeek,
    defaultDeloadPercentage,
    defaultParameters,
    recommendedFor,
    difficulty,
    example,
    isBuiltIn,
    createdAt,
  ];
}
