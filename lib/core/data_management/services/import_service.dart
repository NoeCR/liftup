import '../importers/import_factory.dart';
import '../importers/import_builder.dart';
import '../models/import_config.dart';
import '../../../features/sessions/models/workout_session.dart';
import '../../../features/exercise/models/exercise.dart';
import '../../../features/home/models/routine.dart';
import '../../../features/statistics/models/progress_data.dart';
import '../../../core/database/database_service.dart';
import '../../logging/logging.dart';

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
    return await PerformanceMonitor.instance.monitorAsync(
      'import_from_file',
      () async {
        try {
          LoggingService.instance.info('Starting import from file', {
            'file_path': filePath,
            'merge_data': config.mergeData,
            'overwrite_existing': config.overwriteExisting,
            'validate_data': config.validateData,
            'create_backup': config.createBackup,
            'max_file_size': config.maxFileSize,
            'component': 'import_service',
          });

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
            existingProgressData:
                existingData['progressData'] as List<ProgressData>,
          );

          LoggingService.instance.debug('Created importer', {
            'file_extension': fileExtension,
            'importer_type': importer.runtimeType.toString(),
          });

          // Realizar importación
          final result = await importer.import(filePath);

            LoggingService.instance.info('Import completed', {
              'success': result.success,
              'imported_count': result.importedCount,
              'errors_count': result.errors.length,
            });

            // Registrar métrica de importación
            SentryMetricsConfig.trackImportExportOperation(
              operation: 'import',
              fileType: fileExtension,
              durationMs: 0, // Se calculará automáticamente por PerformanceMonitor
              success: result.success,
              dataSize: result.importedCount,
              error: result.success ? null : result.errorMessage,
            );

          // Si la importación fue exitosa, guardar en Hive
          if (result.success && result.importedCount > 0) {
            await _saveToHive(result);
            LoggingService.instance.info('Data saved to Hive successfully');
          }

          return result;
        } catch (e, stackTrace) {
          LoggingService.instance.error('Error during import', e, stackTrace, {
            'file_path': filePath,
            'merge_data': config.mergeData,
            'overwrite_existing': config.overwriteExisting,
            'validate_data': config.validateData,
            'create_backup': config.createBackup,
            'max_file_size': config.maxFileSize,
            'component': 'import_service',
          });

          return ImportResult.failure(
            errorMessage: 'Error durante la importación: $e',
            errors: ['Error del servicio: $e'],
          );
        }
      },
      context: {
        'file_path': filePath,
        'config_type': config.runtimeType.toString(),
      },
    );
  }

  /// Obtiene los datos existentes de Hive
  Future<Map<String, List<dynamic>>> _getExistingData() async {
    final databaseService = DatabaseService.getInstance();

    return {
      'sessions':
          databaseService.sessionsBox.values.cast<WorkoutSession>().toList(),
      'exercises':
          databaseService.exercisesBox.values.cast<Exercise>().toList(),
      'routines': databaseService.routinesBox.values.cast<Routine>().toList(),
      'progressData':
          databaseService.progressBox.values.cast<ProgressData>().toList(),
    };
  }

  /// Guarda los datos importados en Hive
  Future<void> _saveToHive(ImportResult result) async {
    final databaseService = DatabaseService.getInstance();

    // Guardar sesiones
    if (result.importedSessions.isNotEmpty) {
      for (final session in result.importedSessions) {
        await databaseService.sessionsBox.put(session.id, session);
      }
    }

    // Guardar ejercicios
    if (result.importedExercises.isNotEmpty) {
      for (final exercise in result.importedExercises) {
        await databaseService.exercisesBox.put(exercise.id, exercise);
      }
    }

    // Guardar rutinas
    if (result.importedRoutines.isNotEmpty) {
      for (final routine in result.importedRoutines) {
        await databaseService.routinesBox.put(routine.id, routine);
      }
    }

    // Guardar datos de progreso
    if (result.importedProgressData.isNotEmpty) {
      for (final progress in result.importedProgressData) {
        // Usar una clave compuesta para datos de progreso
        final key =
            '${progress.exerciseId}_${progress.date.millisecondsSinceEpoch}';
        await databaseService.progressBox.put(key, progress);
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
