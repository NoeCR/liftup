import 'package:hive_flutter/hive_flutter.dart';
import '../importers/import_factory.dart';
import '../importers/import_builder.dart';
import '../models/export_config.dart';
import '../../../features/sessions/models/workout_session.dart';
import '../../../features/exercise/models/exercise.dart';
import '../../../features/home/models/routine.dart';
import '../../../features/statistics/models/progress_data.dart';

/// Servicio para manejar la importación de datos a la base de datos Hive
class ImportService {
  static ImportService? _instance;
  static ImportService get instance => _instance ??= ImportService._();
  
  ImportService._();

  /// Importa datos desde un archivo y los guarda en Hive
  Future<ImportResult> importFromFile({
    required String filePath,
    required ImportConfig config,
  }) async {
    try {
      // Obtener datos existentes de Hive
      final existingData = await _getExistingData();
      
      // Crear importador apropiado
      final fileExtension = ImportFactory.getFileExtension(filePath);
      final importer = ImportFactory.createImporter(
        fileExtension: fileExtension,
        config: config,
        existingSessions: existingData['sessions'] as List<WorkoutSession>,
        existingExercises: existingData['exercises'] as List<Exercise>,
        existingRoutines: existingData['routines'] as List<Routine>,
        existingProgressData: existingData['progressData'] as List<ProgressData>,
      );

      // Realizar importación
      final result = await importer.import(filePath);

      // Si la importación fue exitosa, guardar en Hive
      if (result.success && result.importedCount > 0) {
        await _saveToHive(result);
      }

      return result;
    } catch (e) {
      return ImportResult.failure(
        errorMessage: 'Error durante la importación: $e',
        errors: ['Error del servicio: $e'],
      );
    }
  }

  /// Obtiene los datos existentes de Hive
  Future<Map<String, List<dynamic>>> _getExistingData() async {
    final sessionsBox = Hive.box<WorkoutSession>('sessions');
    final exercisesBox = Hive.box<Exercise>('exercises');
    final routinesBox = Hive.box<Routine>('routines');
    final progressBox = Hive.box<ProgressData>('progress');

    return {
      'sessions': sessionsBox.values.toList().cast<WorkoutSession>(),
      'exercises': exercisesBox.values.toList().cast<Exercise>(),
      'routines': routinesBox.values.toList().cast<Routine>(),
      'progressData': progressBox.values.toList().cast<ProgressData>(),
    };
  }

  /// Guarda los datos importados en Hive
  Future<void> _saveToHive(ImportResult result) async {
    // Guardar sesiones
    if (result.importedSessions.isNotEmpty) {
      final sessionsBox = Hive.box<WorkoutSession>('sessions');
      for (final session in result.importedSessions) {
        await sessionsBox.put(session.id, session);
      }
    }

    // Guardar ejercicios
    if (result.importedExercises.isNotEmpty) {
      final exercisesBox = Hive.box<Exercise>('exercises');
      for (final exercise in result.importedExercises) {
        await exercisesBox.put(exercise.id, exercise);
      }
    }

    // Guardar rutinas
    if (result.importedRoutines.isNotEmpty) {
      final routinesBox = Hive.box<Routine>('routines');
      for (final routine in result.importedRoutines) {
        await routinesBox.put(routine.id, routine);
      }
    }

    // Guardar datos de progreso
    if (result.importedProgressData.isNotEmpty) {
      final progressBox = Hive.box<ProgressData>('progress');
      for (final progress in result.importedProgressData) {
        // Usar una clave compuesta para datos de progreso
        final key = '${progress.exerciseId}_${progress.date.millisecondsSinceEpoch}';
        await progressBox.put(key, progress);
      }
    }
  }

  /// Crea un respaldo antes de importar
  Future<String?> createBackup() async {
    try {
      // TODO: Implementar creación de respaldo
      // Por ahora, solo retornamos null para indicar que no se creó respaldo
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Restaura desde un respaldo
  Future<bool> restoreFromBackup(String backupPath) async {
    try {
      // TODO: Implementar restauración desde respaldo
      return false;
    } catch (e) {
      return false;
    }
  }
}
