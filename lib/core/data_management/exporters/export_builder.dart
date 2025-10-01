import '../models/export_config.dart';
import '../../../features/sessions/models/workout_session.dart';
import '../../../features/exercise/models/exercise.dart';
import '../../../features/home/models/routine.dart';
import '../../../features/statistics/models/progress_data.dart';

/// Clase abstracta base para todos los exportadores
abstract class ExportBuilder {
  final ExportConfig config;
  final List<WorkoutSession> sessions;
  final List<Exercise> exercises;
  final List<Routine> routines;
  final List<ProgressData> progressData;
  final Map<String, dynamic> userSettings;
  final ExportMetadata metadata;

  ExportBuilder({
    required this.config,
    required this.sessions,
    required this.exercises,
    required this.routines,
    required this.progressData,
    required this.userSettings,
    required this.metadata,
  });

  /// Método principal de exportación que debe ser implementado por cada clase específica
  Future<String> export();

  /// Método para compartir el archivo exportado
  Future<void> share(String filePath);

  /// Obtiene estadísticas de la exportación
  Map<String, dynamic> getStats() {
    return {
      'sessions': sessions.length,
      'exercises': exercises.length,
      'routines': routines.length,
      'progressData': progressData.length,
      'totalSize': _calculateEstimatedSize(),
    };
  }

  /// Calcula el tamaño estimado de la exportación
  int _calculateEstimatedSize() {
    int size = 0;
    
    if (config.includeSessions) {
      size += sessions.length * 200; // Estimación por sesión
    }
    
    if (config.includeExercises) {
      size += exercises.length * 150; // Estimación por ejercicio
    }
    
    if (config.includeRoutines) {
      size += routines.length * 300; // Estimación por rutina
    }
    
    if (config.includeProgressData) {
      size += progressData.length * 100; // Estimación por progreso
    }
    
    return size;
  }

  /// Filtra las sesiones según la configuración
  List<WorkoutSession> get filteredSessions {
    if (!config.includeSessions) return [];
    
    return sessions.where((session) {
      if (config.fromDate != null && session.startTime.isBefore(config.fromDate!)) {
        return false;
      }
      if (config.toDate != null && session.startTime.isAfter(config.toDate!)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Filtra los ejercicios según la configuración
  List<Exercise> get filteredExercises {
    if (!config.includeExercises) return [];
    
    if (config.exerciseIds != null && config.exerciseIds!.isNotEmpty) {
      return exercises.where((exercise) => config.exerciseIds!.contains(exercise.id)).toList();
    }
    
    return exercises;
  }

  /// Filtra las rutinas según la configuración
  List<Routine> get filteredRoutines {
    if (!config.includeRoutines) return [];
    
    if (config.routineIds != null && config.routineIds!.isNotEmpty) {
      return routines.where((routine) => config.routineIds!.contains(routine.id)).toList();
    }
    
    return routines;
  }

  /// Filtra los datos de progreso según la configuración
  List<ProgressData> get filteredProgressData {
    if (!config.includeProgressData) return [];
    
    return progressData.where((progress) {
      if (config.fromDate != null && progress.date.isBefore(config.fromDate!)) {
        return false;
      }
      if (config.toDate != null && progress.date.isAfter(config.toDate!)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Obtiene la configuración de usuario si está habilitada
  Map<String, dynamic> get filteredUserSettings {
    return config.includeUserSettings ? userSettings : {};
  }
}
