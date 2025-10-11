import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../common/enums/progression_type_enum.dart';

part 'progression_template.g.dart';

@JsonSerializable()
class ProgressionTemplate extends Equatable {
  final String id;
  final String name;
  final String description;
  final ProgressionType progressionType;
  final String category; // 'beginner', 'intermediate', 'advanced', 'specialized'
  final String goal; // 'strength', 'hypertrophy', 'endurance', 'power', 'general'

  // Configuración básica
  final ProgressionUnit unit;
  final ProgressionTarget primaryTarget;
  final ProgressionTarget? secondaryTarget;

  // Parámetros de progresión
  final double incrementValue;
  final int incrementFrequency;
  final int cycleLength;
  final int deloadWeek;
  final double deloadPercentage;

  // Parámetros específicos de la estrategia
  final Map<String, dynamic> customParameters;

  // Información adicional
  final String detailedDescription;
  final String whenToUse;
  final String deloadExplanation;
  final String progressionExplanation;
  final List<String> benefits;
  final List<String> considerations;

  // Metadatos
  final int estimatedDuration; // semanas
  final String difficulty; // 'easy', 'moderate', 'hard'
  final List<String> targetAudience; // ['beginner', 'intermediate', 'advanced']

  const ProgressionTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.progressionType,
    required this.category,
    required this.goal,
    required this.unit,
    required this.primaryTarget,
    this.secondaryTarget,
    required this.incrementValue,
    required this.incrementFrequency,
    required this.cycleLength,
    required this.deloadWeek,
    required this.deloadPercentage,
    required this.customParameters,
    required this.detailedDescription,
    required this.whenToUse,
    required this.deloadExplanation,
    required this.progressionExplanation,
    required this.benefits,
    required this.considerations,
    required this.estimatedDuration,
    required this.difficulty,
    required this.targetAudience,
  });

  factory ProgressionTemplate.fromJson(Map<String, dynamic> json) => _$ProgressionTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$ProgressionTemplateToJson(this);

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    progressionType,
    category,
    goal,
    unit,
    primaryTarget,
    secondaryTarget,
    incrementValue,
    incrementFrequency,
    cycleLength,
    deloadWeek,
    deloadPercentage,
    customParameters,
    detailedDescription,
    whenToUse,
    deloadExplanation,
    progressionExplanation,
    benefits,
    considerations,
    estimatedDuration,
    difficulty,
    targetAudience,
  ];
}

/// Categorías de plantillas
enum TemplateCategory {
  beginner('Principiante'),
  intermediate('Intermedio'),
  advanced('Avanzado'),
  specialized('Especializado');

  const TemplateCategory(this.displayName);
  final String displayName;
}

/// Objetivos de entrenamiento
enum TrainingGoal {
  strength('Fuerza'),
  hypertrophy('Hipertrofia'),
  endurance('Resistencia'),
  power('Potencia'),
  general('General');

  const TrainingGoal(this.displayName);
  final String displayName;
}

/// Niveles de dificultad
enum TemplateDifficulty {
  easy('Fácil'),
  moderate('Moderado'),
  hard('Difícil');

  const TemplateDifficulty(this.displayName);
  final String displayName;
}
