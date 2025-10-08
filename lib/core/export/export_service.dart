import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../features/sessions/models/workout_session.dart';
import '../../features/exercise/models/exercise.dart';
import '../../features/home/models/routine.dart';
import '../../features/statistics/models/progress_data.dart';

abstract class ExportService {
  Future<String> exportData({
    required List<WorkoutSession> sessions,
    required List<Exercise> exercises,
    required List<Routine> routines,
    required List<ProgressData> progressData,
  });
}

class CSVExportService extends ExportService {
  @override
  Future<String> exportData({
    required List<WorkoutSession> sessions,
    required List<Exercise> exercises,
    required List<Routine> routines,
    required List<ProgressData> progressData,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/liftly_data_${DateTime.now().millisecondsSinceEpoch}.csv',
    );

    final csvContent = StringBuffer();

    // Headers
    csvContent.writeln('Tipo,Datos');

    // Sessions
    csvContent.writeln('Sesiones,${sessions.length}');
    for (final session in sessions) {
      csvContent.writeln(
        'Sesión,${session.name},${session.startTime},${session.endTime},${session.totalWeight},${session.totalReps}',
      );
    }

    // Exercises
    csvContent.writeln('Ejercicios,${exercises.length}');
    for (final exercise in exercises) {
      csvContent.writeln(
        'Ejercicio,${exercise.name},${exercise.category},${exercise.difficulty}',
      );
    }

    // Routines
    csvContent.writeln('Rutinas,${routines.length}');
    for (final routine in routines) {
      csvContent.writeln('Rutina,${routine.name},${routine.days.length}');
    }

    // Progress Data
    csvContent.writeln('Progreso,${progressData.length}');
    for (final progress in progressData) {
      csvContent.writeln(
        'Progreso,${progress.exerciseId},${progress.date},${progress.maxWeight},${progress.totalReps}',
      );
    }

    await file.writeAsString(csvContent.toString());
    return file.path;
  }
}

class PDFExportService extends ExportService {
  @override
  Future<String> exportData({
    required List<WorkoutSession> sessions,
    required List<Exercise> exercises,
    required List<Routine> routines,
    required List<ProgressData> progressData,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Reporte de Progreso - Liftly',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary
            pw.Text(
              'Resumen General',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Total de sesiones: ${sessions.length}'),
            pw.Text('Total de ejercicios: ${exercises.length}'),
            pw.Text('Total de rutinas: ${routines.length}'),
            pw.Text('Registros de progreso: ${progressData.length}'),
            pw.SizedBox(height: 20),

            // Sessions
            pw.Text(
              'Sesiones de Entrenamiento',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            ...sessions.map(
              (session) => pw.Text(
                '${session.name} - ${session.startTime.toString().split(' ')[0]} - Peso total: ${session.totalWeight ?? 0}kg',
              ),
            ),
            pw.SizedBox(height: 20),

            // Exercises
            pw.Text(
              'Ejercicios',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            ...exercises.map(
              (exercise) => pw.Text(
                '${exercise.name} - ${exercise.category.name} - ${exercise.difficulty.name}',
              ),
            ),
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/liftly_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }
}

class JSONExportService extends ExportService {
  @override
  Future<String> exportData({
    required List<WorkoutSession> sessions,
    required List<Exercise> exercises,
    required List<Routine> routines,
    required List<ProgressData> progressData,
  }) async {
    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0',
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'routines': routines.map((r) => r.toJson()).toList(),
      'progressData': progressData.map((p) => p.toJson()).toList(),
    };

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/liftly_backup_${DateTime.now().millisecondsSinceEpoch}.json',
    );
    await file.writeAsString(jsonEncode(data));

    return file.path;
  }
}

class ExportManager {
  static Future<void> exportAndShare({
    required ExportService exportService,
    required List<WorkoutSession> sessions,
    required List<Exercise> exercises,
    required List<Routine> routines,
    required List<ProgressData> progressData,
  }) async {
    try {
      final filePath = await exportService.exportData(
        sessions: sessions,
        exercises: exercises,
        routines: routines,
        progressData: progressData,
      );

      await Share.shareXFiles([XFile(filePath)]);
    } catch (e) {
      throw Exception('Error al exportar datos: $e');
    }
  }
}
