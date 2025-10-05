import 'dart:io';
import 'dart:convert';
import 'import_builder.dart';
import '../../../features/sessions/models/workout_session.dart';
import '../../../features/exercise/models/exercise.dart';
import '../../../features/home/models/routine.dart';
import '../../../features/statistics/models/progress_data.dart';

/// JSON-specific importer
class JsonImporter extends ImportBuilder {
  JsonImporter({
    required super.config,
    required super.existingSessions,
    required super.existingExercises,
    required super.existingRoutines,
    required super.existingProgressData,
  });

  @override
  Future<ImportResult> import(String filePath) async {
    try {
      final file = File(filePath);

      // Validate file size
      if (await file.length() > config.maxFileSize) {
        return ImportResult.failure(errorMessage: 'File is too large', errors: ['File exceeds maximum allowed size']);
      }

      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validar datos
      final validationErrors = await validateData(data);
      if (validationErrors.isNotEmpty) {
        return ImportResult.failure(errorMessage: 'Invalid data', errors: validationErrors);
      }

      return await _processData(data);
    } catch (e) {
      return ImportResult.failure(errorMessage: 'Error al leer el archivo JSON: $e', errors: ['Error de formato: $e']);
    }
  }

  /// Processes JSON and converts it into domain objects
  Future<ImportResult> _processData(Map<String, dynamic> data) async {
    final importedSessions = <WorkoutSession>[];
    final importedExercises = <Exercise>[];
    final importedRoutines = <Routine>[];
    final importedProgressData = <ProgressData>[];
    final errors = <String>[];
    final warnings = <String>[];

    int importedCount = 0;
    int skippedCount = 0;

    // Import sessions
    if (data.containsKey('sessions')) {
      final sessionsData = data['sessions'] as List;
      for (final sessionData in sessionsData) {
        try {
          final session = WorkoutSession.fromJson(sessionData as Map<String, dynamic>);

          if (shouldImportSession(session)) {
            importedSessions.add(session);
            importedCount++;
          } else {
            skippedCount++;
          }
        } catch (e) {
          errors.add('Error importing session: $e');
        }
      }
    }

    // Import exercises
    if (data.containsKey('exercises')) {
      final exercisesData = data['exercises'] as List;
      for (final exerciseData in exercisesData) {
        try {
          final exercise = Exercise.fromJson(exerciseData as Map<String, dynamic>);

          if (shouldImportExercise(exercise)) {
            importedExercises.add(exercise);
            importedCount++;
          } else {
            skippedCount++;
          }
        } catch (e) {
          errors.add('Error al importar ejercicio: $e');
        }
      }
    }

    // Import routines
    if (data.containsKey('routines')) {
      final routinesData = data['routines'] as List;
      for (final routineData in routinesData) {
        try {
          final routine = Routine.fromJson(routineData as Map<String, dynamic>);

          if (shouldImportRoutine(routine)) {
            importedRoutines.add(routine);
            importedCount++;
          } else {
            skippedCount++;
          }
        } catch (e) {
          errors.add('Error al importar rutina: $e');
        }
      }
    }

    // Import progress data
    if (data.containsKey('progressData')) {
      final progressData = data['progressData'] as List;
      for (final progressItem in progressData) {
        try {
          final progress = ProgressData.fromJson(progressItem as Map<String, dynamic>);

          if (shouldImportProgressData(progress)) {
            importedProgressData.add(progress);
            importedCount++;
          } else {
            skippedCount++;
          }
        } catch (e) {
          errors.add('Error al importar datos de progreso: $e');
        }
      }
    }

    // Add warnings if there were duplicates
    if (skippedCount > 0) {
      warnings.add('$skippedCount items were skipped because they already exist');
    }

    return ImportResult(
      success: errors.isEmpty,
      importedCount: importedCount,
      skippedCount: skippedCount,
      errorCount: errors.length,
      errorMessage: errors.isNotEmpty ? 'Errors found during import' : null,
      importedSessions: importedSessions,
      importedExercises: importedExercises,
      importedRoutines: importedRoutines,
      importedProgressData: importedProgressData,
      errors: errors,
      warnings: warnings,
    );
  }
}
