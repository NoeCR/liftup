import 'import_builder.dart';
import 'json_importer.dart';
import 'csv_importer.dart';
import '../models/export_config.dart';
import '../../../features/sessions/models/workout_session.dart';
import '../../../features/exercise/models/exercise.dart';
import '../../../features/home/models/routine.dart';
import '../../../features/statistics/models/progress_data.dart';

/// Factory para crear importadores específicos
class ImportFactory {
  /// Crea un importador basado en el tipo de archivo
  static ImportBuilder createImporter({
    required String fileExtension,
    required ImportConfig config,
    required List<WorkoutSession> existingSessions,
    required List<Exercise> existingExercises,
    required List<Routine> existingRoutines,
    required List<ProgressData> existingProgressData,
  }) {
    switch (fileExtension.toLowerCase()) {
      case '.json':
        return JsonImporter(
          config: config,
          existingSessions: existingSessions,
          existingExercises: existingExercises,
          existingRoutines: existingRoutines,
          existingProgressData: existingProgressData,
        );
      
      case '.csv':
        return CsvImporter(
          config: config,
          existingSessions: existingSessions,
          existingExercises: existingExercises,
          existingRoutines: existingRoutines,
          existingProgressData: existingProgressData,
        );
      
      default:
        throw ArgumentError('Tipo de archivo no soportado: $fileExtension');
    }
  }

  /// Obtiene la extensión de archivo desde la ruta
  static String getFileExtension(String filePath) {
    final lastDot = filePath.lastIndexOf('.');
    if (lastDot == -1) {
      throw ArgumentError('El archivo no tiene extensión: $filePath');
    }
    return filePath.substring(lastDot);
  }

  /// Obtiene la lista de extensiones soportadas
  static List<String> getSupportedExtensions() {
    return ['.json', '.csv'];
  }

  /// Obtiene la descripción de cada tipo de importación
  static Map<String, String> getTypeDescriptions() {
    return {
      '.json': 'Archivos JSON de respaldo completo',
      '.csv': 'Archivos CSV con datos tabulares',
    };
  }

  /// Valida si una extensión es soportada
  static bool isSupportedExtension(String extension) {
    return getSupportedExtensions().contains(extension.toLowerCase());
  }
}
