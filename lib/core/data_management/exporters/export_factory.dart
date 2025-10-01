import 'export_builder.dart';
import 'json_exporter.dart';
import 'csv_exporter.dart';
import 'pdf_exporter.dart';
import '../models/export_config.dart';
import '../../../features/sessions/models/workout_session.dart';
import '../../../features/exercise/models/exercise.dart';
import '../../../features/home/models/routine.dart';
import '../../../features/statistics/models/progress_data.dart';

/// Factory para crear exportadores específicos
class ExportFactory {
  /// Crea un exportador basado en el tipo especificado
  static ExportBuilder createExporter({
    required String type,
    required ExportConfig config,
    required List<WorkoutSession> sessions,
    required List<Exercise> exercises,
    required List<Routine> routines,
    required List<ProgressData> progressData,
    required Map<String, dynamic> userSettings,
    required ExportMetadata metadata,
  }) {
    switch (type.toLowerCase()) {
      case 'json':
        return JsonExporter(
          config: config,
          sessions: sessions,
          exercises: exercises,
          routines: routines,
          progressData: progressData,
          userSettings: userSettings,
          metadata: metadata,
        );
      
      case 'csv':
        return CsvExporter(
          config: config,
          sessions: sessions,
          exercises: exercises,
          routines: routines,
          progressData: progressData,
          userSettings: userSettings,
          metadata: metadata,
        );
      
      case 'pdf':
        return PdfExporter(
          config: config,
          sessions: sessions,
          exercises: exercises,
          routines: routines,
          progressData: progressData,
          userSettings: userSettings,
          metadata: metadata,
        );
      
      default:
        throw ArgumentError('Tipo de exportador no soportado: $type');
    }
  }

  /// Obtiene la lista de tipos de exportación soportados
  static List<String> getSupportedTypes() {
    return ['json', 'csv', 'pdf'];
  }

  /// Obtiene la descripción de cada tipo de exportación
  static Map<String, String> getTypeDescriptions() {
    return {
      'json': 'Formato JSON completo con metadatos para respaldos',
      'csv': 'Formato CSV tabular para análisis de datos',
      'pdf': 'Reporte PDF visual con gráficos y estadísticas',
    };
  }

  /// Obtiene la extensión de archivo para cada tipo
  static Map<String, String> getFileExtensions() {
    return {
      'json': '.json',
      'csv': '.csv',
      'pdf': '.pdf',
    };
  }
}
