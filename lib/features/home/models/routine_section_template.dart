import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../common/enums/section_muscle_group_enum.dart';

part 'routine_section_template.g.dart';

@HiveType(typeId: 14)
@JsonSerializable()
class RoutineSectionTemplate extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String iconName;

  @HiveField(4)
  final int order;

  @HiveField(5)
  final bool isDefault;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  @HiveField(8)
  final SectionMuscleGroup? muscleGroup;

  const RoutineSectionTemplate({
    required this.id,
    required this.name,
    this.description,
    required this.iconName,
    required this.order,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
    this.muscleGroup,
  });

  factory RoutineSectionTemplate.fromJson(Map<String, dynamic> json) => _$RoutineSectionTemplateFromJson(json);
  Map<String, dynamic> toJson() => _$RoutineSectionTemplateToJson(this);

  RoutineSectionTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    int? order,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    SectionMuscleGroup? muscleGroup,
  }) {
    return RoutineSectionTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      order: order ?? this.order,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      muscleGroup: muscleGroup ?? this.muscleGroup,
    );
  }

  @override
  List<Object?> get props => [id, name, description, iconName, order, isDefault, createdAt, updatedAt, muscleGroup];
}

// Secciones predefinidas por defecto
class DefaultSectionTemplates {
  static List<RoutineSectionTemplate> get templates => [
    RoutineSectionTemplate(
      id: 'warmup',
      name: 'Calentamiento',
      description: 'Ejercicios de preparación y activación',
      iconName: 'warm_up',
      order: 0,
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      muscleGroup: SectionMuscleGroup.warmup,
    ),
    RoutineSectionTemplate(
      id: 'chest',
      name: 'Pecho',
      description: 'Ejercicios para el desarrollo del pecho',
      iconName: 'fitness_center',
      order: 1,
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      muscleGroup: SectionMuscleGroup.chest,
    ),
    RoutineSectionTemplate(
      id: 'back',
      name: 'Espalda',
      description: 'Ejercicios para fortalecer la espalda',
      iconName: 'sports_gymnastics',
      order: 2,
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      muscleGroup: SectionMuscleGroup.back,
    ),
    RoutineSectionTemplate(
      id: 'shoulders',
      name: 'Hombros',
      description: 'Ejercicios para los hombros',
      iconName: 'sports_martial_arts',
      order: 3,
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      muscleGroup: SectionMuscleGroup.shoulders,
    ),
    RoutineSectionTemplate(
      id: 'arms',
      name: 'Brazos',
      description: 'Ejercicios para bíceps y tríceps',
      iconName: 'sports_basketball',
      order: 4,
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      muscleGroup: SectionMuscleGroup.biceps,
    ),
    RoutineSectionTemplate(
      id: 'legs',
      name: 'Piernas',
      description: 'Ejercicios para cuádriceps e isquiotibiales',
      iconName: 'directions_run',
      order: 5,
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      muscleGroup: SectionMuscleGroup.quadriceps,
    ),
    RoutineSectionTemplate(
      id: 'core',
      name: 'Core',
      description: 'Ejercicios para el core y abdominales',
      iconName: 'self_improvement',
      order: 6,
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      muscleGroup: SectionMuscleGroup.core,
    ),
    RoutineSectionTemplate(
      id: 'cooldown',
      name: 'Enfriamiento',
      description: 'Ejercicios de relajación y estiramiento',
      iconName: 'self_improvement',
      order: 7,
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      muscleGroup: SectionMuscleGroup.cooldown,
    ),
    RoutineSectionTemplate(
      id: 'trapezius',
      name: 'Trapecio',
      description: 'Ejercicios para el trapecio',
      iconName: 'sports_handball',
      order: 8,
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      muscleGroup: SectionMuscleGroup.trapezius,
    ),
    RoutineSectionTemplate(
      id: 'triceps',
      name: 'Tríceps',
      description: 'Ejercicios específicos para tríceps',
      iconName: 'sports_basketball',
      order: 9,
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      muscleGroup: SectionMuscleGroup.triceps,
    ),
    RoutineSectionTemplate(
      id: 'calves',
      name: 'Gemelos',
      description: 'Ejercicios para los gemelos',
      iconName: 'sports_soccer',
      order: 10,
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      muscleGroup: SectionMuscleGroup.calves,
    ),
    RoutineSectionTemplate(
      id: 'hamstrings',
      name: 'Isquiotibiales',
      description: 'Ejercicios para isquiotibiales',
      iconName: 'directions_run',
      order: 11,
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      muscleGroup: SectionMuscleGroup.hamstrings,
    ),
    RoutineSectionTemplate(
      id: 'cardio',
      name: 'Cardio',
      description: 'Ejercicios cardiovasculares',
      iconName: 'pool',
      order: 12,
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      muscleGroup: SectionMuscleGroup.cardio,
    ),
  ];

  static const List<String> availableIcons = [
    // Calentamiento y Enfriamiento
    'warm_up',
    'self_improvement',
    'spa',
    'air',
    'thermostat',

    // Pecho y Torso
    'fitness_center',
    'sports_gymnastics',
    'sports_martial_arts',
    'sports_tennis',
    'sports_volleyball',
    'sports_handball',
    'sports_kabaddi',
    'sports_mma',
    'sports_rugby',
    'sports_cricket',
    'sports_golf',
    'sports_hockey',
    'sports_baseball',
    'sports_football',
    'sports_esports',
    'sports',
    'sports_score',
    'sports_bar',
    'sports_cafe',

    // Brazos (Bíceps y Tríceps)
    'sports_basketball',

    // Piernas (Cuádriceps, Isquiotibiales, Gemelos)
    'directions_run',
    'sports_soccer',

    // Cardio
    'pool',
  ];
}
