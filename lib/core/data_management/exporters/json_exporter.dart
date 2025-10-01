import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../builders/export_builder.dart';

/// Exportador específico para formato JSON
class JsonExporter extends ExportBuilder {
  JsonExporter({
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
        'liftup_export_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${directory.path}/$fileName');

    final data = <String, dynamic>{};

    // Agregar metadatos si está habilitado
    if (config.includeMetadata) {
      data['metadata'] = metadata.toJson();
    }

    // Agregar sesiones filtradas
    if (config.includeSessions) {
      data['sessions'] = filteredSessions.map((s) => s.toJson()).toList();
    }

    // Agregar ejercicios filtrados
    if (config.includeExercises) {
      data['exercises'] = filteredExercises.map((e) => e.toJson()).toList();
    }

    // Agregar rutinas filtradas
    if (config.includeRoutines) {
      data['routines'] = filteredRoutines.map((r) => r.toJson()).toList();
    }

    // Agregar datos de progreso filtrados
    if (config.includeProgressData) {
      data['progressData'] =
          filteredProgressData.map((p) => p.toJson()).toList();
    }

    // Agregar configuración de usuario si está habilitada
    if (config.includeUserSettings) {
      data['userSettings'] = filteredUserSettings;
    }

    // Convertir a JSON con formato legible
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    // Comprimir si está habilitado
    final finalContent =
        config.compressData ? _compressJson(jsonString) : jsonString;

    await file.writeAsString(finalContent);
    return file.path;
  }

  @override
  Future<void> share(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
  }

  /// Comprime el JSON eliminando espacios y saltos de línea
  String _compressJson(String jsonString) {
    // En una implementación real, podrías usar gzip o similar
    // Por ahora, simplemente eliminamos espacios innecesarios
    return jsonString
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\s*{\s*'), '{')
        .replaceAll(RegExp(r'\s*}\s*'), '}')
        .replaceAll(RegExp(r'\s*\[\s*'), '[')
        .replaceAll(RegExp(r'\s*\]\s*'), ']')
        .replaceAll(RegExp(r'\s*,\s*'), ',')
        .replaceAll(RegExp(r'\s*:\s*'), ':')
        .trim();
  }
}
