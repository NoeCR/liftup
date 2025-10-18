import 'package:hive/hive.dart';

/// Configuración específica de progresión para un ejercicio
/// Actúa como puente entre Exercise y ProgressionConfig
@HiveType(typeId: 25)
class ExerciseProgressionConfig {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String exerciseId;

  @HiveField(2)
  final String progressionConfigId;

  /// Incremento personalizado de peso (opcional)
  /// Si es null, usa AdaptiveIncrementConfig
  @HiveField(3)
  final double? customIncrement;

  /// Repeticiones mínimas personalizadas (opcional)
  @HiveField(4)
  final int? customMinReps;

  /// Repeticiones máximas personalizadas (opcional)
  @HiveField(5)
  final int? customMaxReps;

  /// Series base personalizadas (opcional)
  @HiveField(6)
  final int? customBaseSets;

  /// Nivel de experiencia para este ejercicio específico (opcional)
  /// Si es null, usa el nivel del preset o intermedio por defecto
  @HiveField(7)
  final ExperienceLevel? experienceLevel;

  /// Metadatos
  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  const ExerciseProgressionConfig({
    required this.id,
    required this.exerciseId,
    required this.progressionConfigId,
    this.customIncrement,
    this.customMinReps,
    this.customMaxReps,
    this.customBaseSets,
    this.experienceLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una copia con campos modificados
  ExerciseProgressionConfig copyWith({
    String? id,
    String? exerciseId,
    String? progressionConfigId,
    double? customIncrement,
    int? customMinReps,
    int? customMaxReps,
    int? customBaseSets,
    ExperienceLevel? experienceLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExerciseProgressionConfig(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      progressionConfigId: progressionConfigId ?? this.progressionConfigId,
      customIncrement: customIncrement ?? this.customIncrement,
      customMinReps: customMinReps ?? this.customMinReps,
      customMaxReps: customMaxReps ?? this.customMaxReps,
      customBaseSets: customBaseSets ?? this.customBaseSets,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica si tiene configuración personalizada
  bool get hasCustomConfig =>
      customIncrement != null ||
      customMinReps != null ||
      customMaxReps != null ||
      customBaseSets != null ||
      experienceLevel != null;

  /// Verifica si tiene incremento personalizado
  bool get hasCustomIncrement => customIncrement != null && customIncrement! > 0;

  /// Verifica si tiene configuración de repeticiones personalizada
  bool get hasCustomReps => customMinReps != null || customMaxReps != null;

  /// Verifica si tiene series personalizadas
  bool get hasCustomSets => customBaseSets != null && customBaseSets! > 0;

  /// Verifica si tiene máximo de repeticiones personalizado
  bool get hasCustomMaxReps => customMaxReps != null && customMaxReps! > 0;

  /// Verifica si tiene mínimo de repeticiones personalizado
  bool get hasCustomMinReps => customMinReps != null && customMinReps! > 0;

  bool get hasCustomBaseSets => customBaseSets != null && customBaseSets! > 0;

  /// Convierte a Map para serialización manual
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'progressionConfigId': progressionConfigId,
      'customIncrement': customIncrement,
      'customMinReps': customMinReps,
      'customMaxReps': customMaxReps,
      'customBaseSets': customBaseSets,
      'experienceLevel': experienceLevel?.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Crea desde Map para deserialización manual
  factory ExerciseProgressionConfig.fromMap(Map<String, dynamic> map) {
    return ExerciseProgressionConfig(
      id: map['id'] as String,
      exerciseId: map['exerciseId'] as String,
      progressionConfigId: map['progressionConfigId'] as String,
      customIncrement: map['customIncrement'] as double?,
      customMinReps: map['customMinReps'] as int?,
      customMaxReps: map['customMaxReps'] as int?,
      customBaseSets: map['customBaseSets'] as int?,
      experienceLevel:
          map['experienceLevel'] != null
              ? ExperienceLevel.values.firstWhere(
                (e) => e.name == map['experienceLevel'],
                orElse: () => ExperienceLevel.intermediate,
              )
              : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'ExerciseProgressionConfig(id: $id, exerciseId: $exerciseId, '
        'progressionConfigId: $progressionConfigId, '
        'customIncrement: $customIncrement, '
        'customMinReps: $customMinReps, '
        'customMaxReps: $customMaxReps, '
        'customBaseSets: $customBaseSets, '
        'experienceLevel: $experienceLevel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExerciseProgressionConfig &&
        other.id == id &&
        other.exerciseId == exerciseId &&
        other.progressionConfigId == progressionConfigId &&
        other.customIncrement == customIncrement &&
        other.customMinReps == customMinReps &&
        other.customMaxReps == customMaxReps &&
        other.customBaseSets == customBaseSets &&
        other.experienceLevel == experienceLevel;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      exerciseId,
      progressionConfigId,
      customIncrement,
      customMinReps,
      customMaxReps,
      customBaseSets,
      experienceLevel,
    );
  }
}

/// Nivel de experiencia para progresión
/// Lógica: initiated (grandes incrementos) → advanced (pequeños incrementos)
@HiveType(typeId: 26)
enum ExperienceLevel {
  @HiveField(0)
  initiated('Iniciado', 'Puedes progresar rápidamente'),

  @HiveField(1)
  intermediate('Intermedio', 'Progresión moderada'),

  @HiveField(2)
  advanced('Avanzado', 'Progresión lenta, cerca del límite');

  const ExperienceLevel(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Obtiene el factor de incremento (1.0 = normal, >1.0 = más rápido, <1.0 = más lento)
  double get incrementFactor {
    switch (this) {
      case ExperienceLevel.initiated:
        return 1.5; // 50% más rápido
      case ExperienceLevel.intermediate:
        return 1.0; // Normal
      case ExperienceLevel.advanced:
        return 0.5; // 50% más lento
    }
  }
}
