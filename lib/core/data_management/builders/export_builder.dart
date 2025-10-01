import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/export_config.dart';
import '../../../features/sessions/models/workout_session.dart';
import '../../../features/exercise/models/exercise.dart';
import '../../../features/home/models/routine.dart';
import '../../../features/statistics/models/progress_data.dart';

/// Builder para crear exportaciones de datos
class ExportBuilder {
  final ExportConfig _config;
  final List<WorkoutSession> _sessions;
  final List<Exercise> _exercises;
  final List<Routine> _routines;
  final List<ProgressData> _progressData;
  final Map<String, dynamic> _userSettings;
  final ExportMetadata _metadata;

  ExportBuilder._({
    required ExportConfig config,
    required List<WorkoutSession> sessions,
    required List<Exercise> exercises,
    required List<Routine> routines,
    required List<ProgressData> progressData,
    required Map<String, dynamic> userSettings,
    required ExportMetadata metadata,
  })  : _config = config,
        _sessions = sessions,
        _exercises = exercises,
        _routines = routines,
        _progressData = progressData,
        _userSettings = userSettings,
        _metadata = metadata;

  /// Crea un nuevo ExportBuilder
  static ExportBuilder create({
    required List<WorkoutSession> sessions,
    required List<Exercise> exercises,
    required List<Routine> routines,
    required List<ProgressData> progressData,
    required Map<String, dynamic> userSettings,
    required ExportMetadata metadata,
  }) {
    return ExportBuilder._(
      config: const ExportConfig(),
      sessions: sessions,
      exercises: exercises,
      routines: routines,
      progressData: progressData,
      userSettings: userSettings,
      metadata: metadata,
    );
  }

  /// Configura qué datos incluir en la exportación
  ExportBuilder withConfig(ExportConfig config) {
    return ExportBuilder._(
      config: config,
      sessions: _sessions,
      exercises: _exercises,
      routines: _routines,
      progressData: _progressData,
      userSettings: _userSettings,
      metadata: _metadata,
    );
  }

  /// Filtra las sesiones por rango de fechas
  ExportBuilder filterSessionsByDateRange(DateTime? from, DateTime? to) {
    final filteredSessions = _sessions.where((session) {
      if (from != null && session.startTime.isBefore(from)) return false;
      if (to != null && session.startTime.isAfter(to)) return false;
      return true;
    }).toList();

    return ExportBuilder._(
      config: _config,
      sessions: filteredSessions,
      exercises: _exercises,
      routines: _routines,
      progressData: _progressData,
      userSettings: _userSettings,
      metadata: _metadata,
    );
  }

  /// Filtra las rutinas por IDs específicos
  ExportBuilder filterRoutinesByIds(List<String> routineIds) {
    final filteredRoutines = _routines
        .where((routine) => routineIds.contains(routine.id))
        .toList();

    return ExportBuilder._(
      config: _config,
      sessions: _sessions,
      exercises: _exercises,
      routines: filteredRoutines,
      progressData: _progressData,
      userSettings: _userSettings,
      metadata: _metadata,
    );
  }

  /// Filtra los ejercicios por IDs específicos
  ExportBuilder filterExercisesByIds(List<String> exerciseIds) {
    final filteredExercises = _exercises
        .where((exercise) => exerciseIds.contains(exercise.id))
        .toList();

    return ExportBuilder._(
      config: _config,
      sessions: _sessions,
      exercises: filteredExercises,
      routines: _routines,
      progressData: _progressData,
      userSettings: _userSettings,
      metadata: _metadata,
    );
  }

  /// Exporta a formato CSV
  Future<String> toCSV() async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'liftup_export_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('${directory.path}/$fileName');

    final csvContent = StringBuffer();
    
    // Headers con metadatos
    if (_config.includeMetadata) {
      csvContent.writeln('# LiftUp Export');
      csvContent.writeln('# Version: ${_metadata.version}');
      csvContent.writeln('# Export Date: ${_metadata.exportDate.toIso8601String()}');
      csvContent.writeln('# App Version: ${_metadata.appVersion}');
      csvContent.writeln('');
    }

    // Sessions
    if (_config.includeSessions) {
      csvContent.writeln('Sessions,${_sessions.length}');
      csvContent.writeln('ID,Name,StartTime,EndTime,TotalWeight,TotalReps,Status');
      for (final session in _sessions) {
        csvContent.writeln(
          '${session.id},${session.name},${session.startTime.toIso8601String()},'
          '${session.endTime?.toIso8601String() ?? ''},${session.totalWeight ?? 0},'
          '${session.totalReps ?? 0},${session.status.name}',
        );
      }
      csvContent.writeln('');
    }

    // Exercises
    if (_config.includeExercises) {
      csvContent.writeln('Exercises,${_exercises.length}');
      csvContent.writeln('ID,Name,Category,Difficulty,MuscleGroups');
      for (final exercise in _exercises) {
        csvContent.writeln(
          '${exercise.id},${exercise.name},${exercise.category.name},'
          '${exercise.difficulty.name},"${exercise.muscleGroups.join(', ')}"',
        );
      }
      csvContent.writeln('');
    }

    // Routines
    if (_config.includeRoutines) {
      csvContent.writeln('Routines,${_routines.length}');
      csvContent.writeln('ID,Name,Description,Order,CreatedAt');
      for (final routine in _routines) {
        csvContent.writeln(
          '${routine.id},${routine.name},${routine.description},'
          '${routine.order ?? 0},${routine.createdAt.toIso8601String()}',
        );
      }
      csvContent.writeln('');
    }

    // Progress Data
    if (_config.includeProgressData) {
      csvContent.writeln('ProgressData,${_progressData.length}');
      csvContent.writeln('ExerciseId,Date,MaxWeight,TotalReps');
      for (final progress in _progressData) {
        csvContent.writeln(
          '${progress.exerciseId},${progress.date.toIso8601String()},'
          '${progress.maxWeight},${progress.totalReps}',
        );
      }
    }

    await file.writeAsString(csvContent.toString());
    return file.path;
  }

  /// Exporta a formato JSON
  Future<String> toJSON() async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'liftup_export_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${directory.path}/$fileName');

    final data = <String, dynamic>{};

    if (_config.includeMetadata) {
      data['metadata'] = _metadata.toJson();
    }

    if (_config.includeSessions) {
      data['sessions'] = _sessions.map((s) => s.toJson()).toList();
    }

    if (_config.includeExercises) {
      data['exercises'] = _exercises.map((e) => e.toJson()).toList();
    }

    if (_config.includeRoutines) {
      data['routines'] = _routines.map((r) => r.toJson()).toList();
    }

    if (_config.includeProgressData) {
      data['progressData'] = _progressData.map((p) => p.toJson()).toList();
    }

    if (_config.includeUserSettings) {
      data['userSettings'] = _userSettings;
    }

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    await file.writeAsString(jsonString);

    return file.path;
  }

  /// Exporta a formato PDF
  Future<String> toPDF() async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'liftup_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${directory.path}/$fileName');

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                'Reporte de Progreso - LiftUp',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Metadata
            if (_config.includeMetadata) ...[
              pw.Text(
                'Información del Export',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Versión: ${_metadata.version}'),
              pw.Text('Fecha de exportación: ${_metadata.exportDate.toString()}'),
              pw.Text('Versión de la app: ${_metadata.appVersion}'),
              pw.SizedBox(height: 20),
            ],

            // Summary
            pw.Text(
              'Resumen General',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            if (_config.includeSessions)
              pw.Text('Total de sesiones: ${_sessions.length}'),
            if (_config.includeExercises)
              pw.Text('Total de ejercicios: ${_exercises.length}'),
            if (_config.includeRoutines)
              pw.Text('Total de rutinas: ${_routines.length}'),
            if (_config.includeProgressData)
              pw.Text('Registros de progreso: ${_progressData.length}'),
            pw.SizedBox(height: 20),

            // Sessions
            if (_config.includeSessions && _sessions.isNotEmpty) ...[
              pw.Text(
                'Sesiones de Entrenamiento',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              ..._sessions.take(10).map(
                (session) => pw.Text(
                  '${session.name} - ${session.startTime.toString().split(' ')[0]} - '
                  'Peso total: ${session.totalWeight ?? 0}kg',
                ),
              ),
              if (_sessions.length > 10)
                pw.Text('... y ${_sessions.length - 10} sesiones más'),
              pw.SizedBox(height: 20),
            ],

            // Exercises
            if (_config.includeExercises && _exercises.isNotEmpty) ...[
              pw.Text(
                'Ejercicios',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              ..._exercises.take(10).map(
                (exercise) => pw.Text(
                  '${exercise.name} - ${exercise.category.name} - ${exercise.difficulty.name}',
                ),
              ),
              if (_exercises.length > 10)
                pw.Text('... y ${_exercises.length - 10} ejercicios más'),
            ],
          ];
        },
      ),
    );

    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  /// Comparte el archivo exportado
  Future<void> share(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
  }

  /// Obtiene estadísticas de la exportación
  Map<String, dynamic> getStats() {
    return {
      'sessions': _sessions.length,
      'exercises': _exercises.length,
      'routines': _routines.length,
      'progressData': _progressData.length,
      'totalSize': _calculateEstimatedSize(),
    };
  }

  /// Calcula el tamaño estimado de la exportación
  int _calculateEstimatedSize() {
    int size = 0;
    
    if (_config.includeSessions) {
      size += _sessions.length * 200; // Estimación por sesión
    }
    
    if (_config.includeExercises) {
      size += _exercises.length * 150; // Estimación por ejercicio
    }
    
    if (_config.includeRoutines) {
      size += _routines.length * 300; // Estimación por rutina
    }
    
    if (_config.includeProgressData) {
      size += _progressData.length * 100; // Estimación por progreso
    }
    
    return size;
  }
}
