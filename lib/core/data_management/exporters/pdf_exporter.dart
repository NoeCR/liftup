import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'export_builder.dart';

/// Exportador específico para formato PDF
class PdfExporter extends ExportBuilder {
  PdfExporter({
    required super.config,
    required super.sessions,
    required super.exercises,
    required super.routines,
    required super.progressData,
    required super.userSettings,
    required super.metadata,
  });

  @override
  Future<String> export() async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'liftly_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${directory.path}/$fileName');

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final widgets = <pw.Widget>[
            // Header
            _buildHeader(),

            pw.SizedBox(height: 20),
          ];

          // Metadata
          if (config.includeMetadata) {
            widgets.addAll(_buildMetadataSection());
          }

          // Summary
          widgets.addAll(_buildSummarySection());

          // Sessions
          if (config.includeSessions && filteredSessions.isNotEmpty) {
            widgets.addAll(_buildSessionsSection());
          }

          // Exercises
          if (config.includeExercises && filteredExercises.isNotEmpty) {
            widgets.addAll(_buildExercisesSection());
          }

          // Routines
          if (config.includeRoutines && filteredRoutines.isNotEmpty) {
            widgets.addAll(_buildRoutinesSection());
          }

          // Progress Data
          if (config.includeProgressData && filteredProgressData.isNotEmpty) {
            widgets.addAll(_buildProgressDataSection());
          }

          return widgets;
        },
      ),
    );

    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  @override
  Future<void> share(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
  }

  /// Construye el header del PDF
  pw.Widget _buildHeader() {
    return pw.Header(
      level: 0,
      child: pw.Text(
        'Reporte de Progreso - Liftly',
        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  /// Construye la sección de metadatos
  List<pw.Widget> _buildMetadataSection() {
    return [
      pw.Text(
        'Información del Export',
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 10),
      pw.Text('Versión: ${metadata.version}'),
      pw.Text('Fecha de exportación: ${metadata.exportDate.toString()}'),
      pw.Text('Versión de la app: ${metadata.appVersion}'),
      pw.Text('ID del dispositivo: ${metadata.deviceId}'),
      pw.SizedBox(height: 20),
    ];
  }

  /// Construye la sección de resumen
  List<pw.Widget> _buildSummarySection() {
    return [
      pw.Text(
        'Resumen General',
        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 10),
      if (config.includeSessions)
        pw.Text('Total de sesiones: ${filteredSessions.length}'),
      if (config.includeExercises)
        pw.Text('Total de ejercicios: ${filteredExercises.length}'),
      if (config.includeRoutines)
        pw.Text('Total de rutinas: ${filteredRoutines.length}'),
      if (config.includeProgressData)
        pw.Text('Registros de progreso: ${filteredProgressData.length}'),
      pw.SizedBox(height: 20),
    ];
  }

  /// Construye la sección de sesiones
  List<pw.Widget> _buildSessionsSection() {
    return [
      pw.Text(
        'Sesiones de Entrenamiento',
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 10),
      ...filteredSessions
          .take(10)
          .map(
            (session) => pw.Text(
              '${session.name} - ${session.startTime.toString().split(' ')[0]} - '
              'Peso total: ${session.totalWeight ?? 0}kg',
            ),
          ),
      if (filteredSessions.length > 10)
        pw.Text('... y ${filteredSessions.length - 10} sesiones más'),
      pw.SizedBox(height: 20),
    ];
  }

  /// Construye la sección de ejercicios
  List<pw.Widget> _buildExercisesSection() {
    return [
      pw.Text(
        'Ejercicios',
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 10),
      ...filteredExercises
          .take(10)
          .map(
            (exercise) => pw.Text(
              '${exercise.name} - ${exercise.category.name} - ${exercise.difficulty.name}',
            ),
          ),
      if (filteredExercises.length > 10)
        pw.Text('... y ${filteredExercises.length - 10} ejercicios más'),
      pw.SizedBox(height: 20),
    ];
  }

  /// Construye la sección de rutinas
  List<pw.Widget> _buildRoutinesSection() {
    return [
      pw.Text(
        'Rutinas',
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 10),
      ...filteredRoutines
          .take(10)
          .map(
            (routine) => pw.Text(
              '${routine.name} - ${routine.days.length} días - '
              'Creada: ${routine.createdAt.toString().split(' ')[0]}',
            ),
          ),
      if (filteredRoutines.length > 10)
        pw.Text('... y ${filteredRoutines.length - 10} rutinas más'),
      pw.SizedBox(height: 20),
    ];
  }

  /// Construye la sección de datos de progreso
  List<pw.Widget> _buildProgressDataSection() {
    return [
      pw.Text(
        'Datos de Progreso',
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 10),
      ...filteredProgressData
          .take(10)
          .map(
            (progress) => pw.Text(
              'Ejercicio: ${progress.exerciseId} - '
              'Fecha: ${progress.date.toString().split(' ')[0]} - '
              'Peso máximo: ${progress.maxWeight}kg',
            ),
          ),
      if (filteredProgressData.length > 10)
        pw.Text('... y ${filteredProgressData.length - 10} registros más'),
    ];
  }
}
