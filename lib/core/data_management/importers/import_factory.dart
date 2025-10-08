import 'import_builder.dart';
import 'json_importer.dart';
import 'csv_importer.dart';
import '../models/import_config.dart';
import '../models/export_type.dart';
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
    final exportType = ExportType.fromExtension(fileExtension);
    if (exportType == null) {
      throw ArgumentError('Tipo de archivo no soportado: $fileExtension');
    }

    switch (exportType) {
      case ExportType.json:
        return JsonImporter(
          config: config,
          existingSessions: existingSessions,
          existingExercises: existingExercises,
          existingRoutines: existingRoutines,
          existingProgressData: existingProgressData,
        );

      case ExportType.csv:
        return CsvImporter(
          config: config,
          existingSessions: existingSessions,
          existingExercises: existingExercises,
          existingRoutines: existingRoutines,
          existingProgressData: existingProgressData,
        );

      case ExportType.pdf:
        throw ArgumentError('La importación desde PDF no está soportada');
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

  /// Obtiene la lista de extensiones soportadas para importación
  static List<String> getSupportedExtensions() {
    return ['.json', '.csv']; // Solo JSON y CSV para importación
  }

  /// Obtiene la lista de tipos soportados para importación
  static List<ExportType> getSupportedTypes() {
    return [ExportType.json, ExportType.csv]; // Solo JSON y CSV para importación
  }

  /// Obtiene la descripción de cada tipo de importación
  static Map<ExportType, String> getTypeDescriptions() {
    return {ExportType.json: 'Archivos JSON de respaldo completo', ExportType.csv: 'Archivos CSV con datos tabulares'};
  }

  /// Valida si una extensión es soportada para importación
  static bool isSupportedExtension(String extension) {
    final exportType = ExportType.fromExtension(extension);
    return exportType != null && getSupportedTypes().contains(exportType);
  }
}
