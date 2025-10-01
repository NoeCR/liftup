import 'dart:io';
import 'dart:convert';
import '../models/export_config.dart';
import '../../../features/sessions/models/workout_session.dart';
import '../../../features/exercise/models/exercise.dart';
import '../../../features/home/models/routine.dart';
import '../../../features/statistics/models/progress_data.dart';

/// Resultado de una importación
class ImportResult extends ImportResultBase {
  final List<WorkoutSession> importedSessions;
  final List<Exercise> importedExercises;
  final List<Routine> importedRoutines;
  final List<ProgressData> importedProgressData;
  final List<String> errors;
  final List<String> warnings;

  const ImportResult({
    required super.success,
    required super.importedCount,
    required super.skippedCount,
    required super.errorCount,
    super.errorMessage,
    required this.importedSessions,
    required this.importedExercises,
    required this.importedRoutines,
    required this.importedProgressData,
    required this.errors,
    required this.warnings,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        importedSessions,
        importedExercises,
        importedRoutines,
        importedProgressData,
        errors,
        warnings,
      ];
}

/// Clase base para resultados de importación
abstract class ImportResultBase {
  final bool success;
  final int importedCount;
  final int skippedCount;
  final int errorCount;
  final String? errorMessage;

  const ImportResultBase({
    required this.success,
    required this.importedCount,
    required this.skippedCount,
    required this.errorCount,
    this.errorMessage,
  });

  List<Object?> get props => [success, importedCount, skippedCount, errorCount, errorMessage];
}

/// Builder para importar datos
class ImportBuilder {
  final ImportConfig _config;
  final List<WorkoutSession> _existingSessions;
  final List<Exercise> _existingExercises;
  final List<Routine> _existingRoutines;
  final List<ProgressData> _existingProgressData;

  ImportBuilder._({
    required ImportConfig config,
    required List<WorkoutSession> existingSessions,
    required List<Exercise> existingExercises,
    required List<Routine> existingRoutines,
    required List<ProgressData> existingProgressData,
  })  : _config = config,
        _existingSessions = existingSessions,
        _existingExercises = existingExercises,
        _existingRoutines = existingRoutines,
        _existingProgressData = existingProgressData;

  /// Crea un nuevo ImportBuilder
  static ImportBuilder create({
    required List<WorkoutSession> existingSessions,
    required List<Exercise> existingExercises,
    required List<Routine> existingRoutines,
    required List<ProgressData> existingProgressData,
  }) {
    return ImportBuilder._(
      config: const ImportConfig(),
      existingSessions: existingSessions,
      existingExercises: existingExercises,
      existingRoutines: existingRoutines,
      existingProgressData: existingProgressData,
    );
  }

  /// Configura las opciones de importación
  ImportBuilder withConfig(ImportConfig config) {
    return ImportBuilder._(
      config: config,
      existingSessions: _existingSessions,
      existingExercises: _existingExercises,
      existingRoutines: _existingRoutines,
      existingProgressData: _existingProgressData,
    );
  }

  /// Importa desde un archivo JSON
  Future<ImportResult> fromJSON(String filePath) async {
    try {
      final file = File(filePath);
      
      // Validar tamaño del archivo
      if (_config.maxFileSize != null && 
          await file.length() > _config.maxFileSize!) {
        return ImportResult(
          success: false,
          importedCount: 0,
          skippedCount: 0,
          errorCount: 1,
          errorMessage: 'El archivo es demasiado grande',
          importedSessions: [],
          importedExercises: [],
          importedRoutines: [],
          importedProgressData: [],
          errors: ['Archivo excede el tamaño máximo permitido'],
          warnings: [],
        );
      }

      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      return await _processJSONData(data);
    } catch (e) {
      return ImportResult(
        success: false,
        importedCount: 0,
        skippedCount: 0,
        errorCount: 1,
        errorMessage: 'Error al leer el archivo JSON: $e',
        importedSessions: [],
        importedExercises: [],
        importedRoutines: [],
        importedProgressData: [],
        errors: ['Error de formato: $e'],
        warnings: [],
      );
    }
  }

  /// Importa desde un archivo CSV
  Future<ImportResult> fromCSV(String filePath) async {
    try {
      final file = File(filePath);
      final csvContent = await file.readAsString();
      
      return await _processCSVData(csvContent);
    } catch (e) {
      return ImportResult(
        success: false,
        importedCount: 0,
        skippedCount: 0,
        errorCount: 1,
        errorMessage: 'Error al leer el archivo CSV: $e',
        importedSessions: [],
        importedExercises: [],
        importedRoutines: [],
        importedProgressData: [],
        errors: ['Error de formato: $e'],
        warnings: [],
      );
    }
  }

  /// Procesa datos JSON
  Future<ImportResult> _processJSONData(Map<String, dynamic> data) async {
    final importedSessions = <WorkoutSession>[];
    final importedExercises = <Exercise>[];
    final importedRoutines = <Routine>[];
    final importedProgressData = <ProgressData>[];
    final errors = <String>[];
    final warnings = <String>[];

    int importedCount = 0;
    int skippedCount = 0;
    int errorCount = 0;

    // Importar sesiones
    if (data.containsKey('sessions')) {
      final sessionsData = data['sessions'] as List;
      for (final sessionData in sessionsData) {
        try {
          final session = WorkoutSession.fromJson(sessionData as Map<String, dynamic>);
          
          if (_shouldImportSession(session)) {
            importedSessions.add(session);
            importedCount++;
          } else {
            skippedCount++;
          }
        } catch (e) {
          errors.add('Error al importar sesión: $e');
          errorCount++;
        }
      }
    }

    // Importar ejercicios
    if (data.containsKey('exercises')) {
      final exercisesData = data['exercises'] as List;
      for (final exerciseData in exercisesData) {
        try {
          final exercise = Exercise.fromJson(exerciseData as Map<String, dynamic>);
          
          if (_shouldImportExercise(exercise)) {
            importedExercises.add(exercise);
            importedCount++;
          } else {
            skippedCount++;
          }
        } catch (e) {
          errors.add('Error al importar ejercicio: $e');
          errorCount++;
        }
      }
    }

    // Importar rutinas
    if (data.containsKey('routines')) {
      final routinesData = data['routines'] as List;
      for (final routineData in routinesData) {
        try {
          final routine = Routine.fromJson(routineData as Map<String, dynamic>);
          
          if (_shouldImportRoutine(routine)) {
            importedRoutines.add(routine);
            importedCount++;
          } else {
            skippedCount++;
          }
        } catch (e) {
          errors.add('Error al importar rutina: $e');
          errorCount++;
        }
      }
    }

    // Importar datos de progreso
    if (data.containsKey('progressData')) {
      final progressData = data['progressData'] as List;
      for (final progressItem in progressData) {
        try {
          final progress = ProgressData.fromJson(progressItem as Map<String, dynamic>);
          
          if (_shouldImportProgressData(progress)) {
            importedProgressData.add(progress);
            importedCount++;
          } else {
            skippedCount++;
          }
        } catch (e) {
          errors.add('Error al importar datos de progreso: $e');
          errorCount++;
        }
      }
    }

    return ImportResult(
      success: errorCount == 0,
      importedCount: importedCount,
      skippedCount: skippedCount,
      errorCount: errorCount,
      importedSessions: importedSessions,
      importedExercises: importedExercises,
      importedRoutines: importedRoutines,
      importedProgressData: importedProgressData,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Procesa datos CSV
  Future<ImportResult> _processCSVData(String csvContent) async {
    // Implementación básica de CSV parsing
    // En una implementación real, usarías una librería como csv
    final lines = csvContent.split('\n');
    final errors = <String>[];
    final warnings = <String>[];

    // Por ahora, solo validamos el formato básico
    if (lines.isEmpty) {
      return ImportResult(
        success: false,
        importedCount: 0,
        skippedCount: 0,
        errorCount: 1,
        errorMessage: 'El archivo CSV está vacío',
        importedSessions: [],
        importedExercises: [],
        importedRoutines: [],
        importedProgressData: [],
        errors: ['Archivo CSV vacío'],
        warnings: [],
      );
    }

    // TODO: Implementar parsing completo de CSV
    warnings.add('Importación de CSV aún no implementada completamente');

    return ImportResult(
      success: true,
      importedCount: 0,
      skippedCount: 0,
      errorCount: 0,
      importedSessions: [],
      importedExercises: [],
      importedRoutines: [],
      importedProgressData: [],
      errors: errors,
      warnings: warnings,
    );
  }

  /// Determina si una sesión debe ser importada
  bool _shouldImportSession(WorkoutSession session) {
    if (_config.mergeData) {
      // Verificar si ya existe
      final exists = _existingSessions.any((s) => s.id == session.id);
      if (exists && !_config.overwriteExisting) {
        return false;
      }
    }
    return true;
  }

  /// Determina si un ejercicio debe ser importado
  bool _shouldImportExercise(Exercise exercise) {
    if (_config.mergeData) {
      // Verificar si ya existe
      final exists = _existingExercises.any((e) => e.id == exercise.id);
      if (exists && !_config.overwriteExisting) {
        return false;
      }
    }
    return true;
  }

  /// Determina si una rutina debe ser importada
  bool _shouldImportRoutine(Routine routine) {
    if (_config.mergeData) {
      // Verificar si ya existe
      final exists = _existingRoutines.any((r) => r.id == routine.id);
      if (exists && !_config.overwriteExisting) {
        return false;
      }
    }
    return true;
  }

  /// Determina si los datos de progreso deben ser importados
  bool _shouldImportProgressData(ProgressData progress) {
    if (_config.mergeData) {
      // Verificar si ya existe
      final exists = _existingProgressData.any((p) => 
        p.exerciseId == progress.exerciseId && 
        p.date == progress.date);
      if (exists && !_config.overwriteExisting) {
        return false;
      }
    }
    return true;
  }

  /// Valida los datos antes de importar
  Future<List<String>> validateData(Map<String, dynamic> data) async {
    final errors = <String>[];

    if (!_config.validateData) {
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
}
