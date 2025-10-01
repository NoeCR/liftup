import 'export_builder.dart';
import 'json_exporter.dart';
import 'csv_exporter.dart';
import 'pdf_exporter.dart';
import '../models/export_config.dart';
import '../models/export_type.dart';
import '../../../features/sessions/models/workout_session.dart';
import '../../../features/exercise/models/exercise.dart';
import '../../../features/home/models/routine.dart';
import '../../../features/statistics/models/progress_data.dart';

/// Factory para crear exportadores específicos
class ExportFactory {
  /// Crea un exportador basado en el tipo especificado
  static ExportBuilder createExporter({
    required ExportType type,
    required ExportConfig config,
    required List<WorkoutSession> sessions,
    required List<Exercise> exercises,
    required List<Routine> routines,
    required List<ProgressData> progressData,
    required Map<String, dynamic> userSettings,
    required ExportMetadata metadata,
  }) {
    switch (type) {
      case ExportType.json:
        return JsonExporter(
          config: config,
          sessions: sessions,
          exercises: exercises,
          routines: routines,
          progressData: progressData,
          userSettings: userSettings,
          metadata: metadata,
        );
      
      case ExportType.csv:
        return CsvExporter(
          config: config,
          sessions: sessions,
          exercises: exercises,
          routines: routines,
          progressData: progressData,
          userSettings: userSettings,
          metadata: metadata,
        );
      
      case ExportType.pdf:
        return PdfExporter(
          config: config,
          sessions: sessions,
          exercises: exercises,
          routines: routines,
          progressData: progressData,
          userSettings: userSettings,
          metadata: metadata,
        );
    }
  }

  /// Obtiene la lista de tipos de exportación soportados
  static List<ExportType> getSupportedTypes() {
    return ExportType.values;
  }

  /// Obtiene la lista de extensiones soportadas
  static List<String> getSupportedExtensions() {
    return ExportType.supportedExtensions;
  }

  /// Obtiene la descripción de cada tipo de exportación
  static Map<ExportType, String> getTypeDescriptions() {
    return {
      ExportType.json: 'Formato JSON completo con metadatos para respaldos',
      ExportType.csv: 'Formato CSV tabular para análisis de datos',
      ExportType.pdf: 'Reporte PDF visual con gráficos y estadísticas',
    };
  }

  /// Obtiene la extensión de archivo para cada tipo
  static Map<ExportType, String> getFileExtensions() {
    return {
      ExportType.json: '.json',
      ExportType.csv: '.csv',
      ExportType.pdf: '.pdf',
    };
  }

  /// Obtiene el tipo de exportación desde una extensión de archivo
  static ExportType? getTypeFromExtension(String extension) {
    return ExportType.fromExtension(extension);
  }
}
