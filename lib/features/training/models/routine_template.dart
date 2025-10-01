import '../../exercise/models/exercise.dart';

/// Modelo simple de plantilla de rutina para un MVP.
class RoutineTemplate {
  final String id;
  final String name;
  final String description;
  final List<TemplateBlock> blocks;

  const RoutineTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.blocks,
  });
}

/// Bloque de la plantilla (por ejemplo, Día A, Día B, Full Body).
class TemplateBlock {
  final String title;
  final List<TemplateExercise> exercises;

  const TemplateBlock({
    required this.title,
    required this.exercises,
  });
}

/// Ejercicio dentro de una plantilla con esquema de series/reps.
class TemplateExercise {
  final Exercise exercise;
  final int sets;
  final int reps;
  final double? weightSuggestion;

  const TemplateExercise({
    required this.exercise,
    required this.sets,
    required this.reps,
    this.weightSuggestion,
  });
}


