import '../models/import_config.dart';
import '../../../features/sessions/models/workout_session.dart';
import '../../../features/exercise/models/exercise.dart';
import '../../../features/home/models/routine.dart';
import '../../../features/statistics/models/progress_data.dart';

/// Resultado de una importación
class ImportResult {
  final bool success;
  final int importedCount;
  final int skippedCount;
  final int errorCount;
  final String? errorMessage;
  final List<WorkoutSession> importedSessions;
  final List<Exercise> importedExercises;
  final List<Routine> importedRoutines;
  final List<ProgressData> importedProgressData;
  final List<String> errors;
  final List<String> warnings;

  const ImportResult({
    required this.success,
    required this.importedCount,
    required this.skippedCount,
    required this.errorCount,
    this.errorMessage,
    required this.importedSessions,
    required this.importedExercises,
    required this.importedRoutines,
    required this.importedProgressData,
    required this.errors,
    required this.warnings,
  });

  factory ImportResult.success({
    required List<WorkoutSession> sessions,
    required List<Exercise> exercises,
    required List<Routine> routines,
    required List<ProgressData> progressData,
    List<String> warnings = const [],
  }) {
    final totalCount = sessions.length + exercises.length + routines.length + progressData.length;
    return ImportResult(
      success: true,
      importedCount: totalCount,
      skippedCount: 0,
      errorCount: 0,
      importedSessions: sessions,
      importedExercises: exercises,
      importedRoutines: routines,
      importedProgressData: progressData,
      errors: const [],
      warnings: warnings,
    );
  }

  factory ImportResult.failure({
    required String errorMessage,
    List<String> errors = const [],
    List<String> warnings = const [],
  }) {
    return ImportResult(
      success: false,
      importedCount: 0,
      skippedCount: 0,
      errorCount: errors.length,
      errorMessage: errorMessage,
      importedSessions: const [],
      importedExercises: const [],
      importedRoutines: const [],
      importedProgressData: const [],
      errors: errors,
      warnings: warnings,
    );
  }
}

/// Clase abstracta base para todos los importadores
abstract class ImportBuilder {
  final ImportConfig config;
  final List<WorkoutSession> existingSessions;
  final List<Exercise> existingExercises;
  final List<Routine> existingRoutines;
  final List<ProgressData> existingProgressData;

  ImportBuilder({
    required this.config,
    required this.existingSessions,
    required this.existingExercises,
    required this.existingRoutines,
    required this.existingProgressData,
  });

  /// Método principal de importación que debe ser implementado por cada clase específica
  Future<ImportResult> import(String filePath);

  /// Valida los datos antes de importar
  Future<List<String>> validateData(Map<String, dynamic> data) async {
    final errors = <String>[];

    if (!config.validateData) {
      return errors;
    }

    // Validar estructura básica
    if (!data.containsKey('sessions') && 
        !data.containsKey('exercises') && 
        !data.containsKey('routines')) {
      errors.add('El archivo no contiene datos válidos');
    }

    // Validar versiones compatibles
    if (data.containsKey('metadata')) {
      final metadata = data['metadata'] as Map<String, dynamic>;
      final version = metadata['version'] as String?;
      if (version != null && !_isVersionCompatible(version)) {
        errors.add('Versión de archivo no compatible: $version');
      }
    }

    return errors;
  }

  /// Verifica si la versión es compatible
  bool _isVersionCompatible(String version) {
    // Implementar lógica de compatibilidad de versiones
    return version.startsWith('1.');
  }

  /// Determina si una sesión debe ser importada
  bool shouldImportSession(WorkoutSession session) {
    if (config.mergeData) {
      // Verificar si ya existe
      final exists = existingSessions.any((s) => s.id == session.id);
      if (exists && !config.overwriteExisting) {
        return false;
      }
    }
    return true;
  }

  /// Determina si un ejercicio debe ser importado
  bool shouldImportExercise(Exercise exercise) {
    if (config.mergeData) {
      // Verificar si ya existe
      final exists = existingExercises.any((e) => e.id == exercise.id);
      if (exists && !config.overwriteExisting) {
        return false;
      }
    }
    return true;
  }

  /// Determina si una rutina debe ser importada
  bool shouldImportRoutine(Routine routine) {
    if (config.mergeData) {
      // Verificar si ya existe
      final exists = existingRoutines.any((r) => r.id == routine.id);
      if (exists && !config.overwriteExisting) {
        return false;
      }
    }
    return true;
  }

  /// Determina si los datos de progreso deben ser importados
  bool shouldImportProgressData(ProgressData progress) {
    if (config.mergeData) {
      // Verificar si ya existe
      final exists = existingProgressData.any((p) => 
        p.exerciseId == progress.exerciseId && 
        p.date == progress.date);
      if (exists && !config.overwriteExisting) {
        return false;
      }
    }
    return true;
  }
}
