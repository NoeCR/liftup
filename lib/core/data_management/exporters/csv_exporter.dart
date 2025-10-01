import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'export_builder.dart';

/// Exportador específico para formato CSV
class CsvExporter extends ExportBuilder {
  CsvExporter({
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
        'liftup_export_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('${directory.path}/$fileName');

    final csvContent = StringBuffer();

    // Headers con metadatos
    if (config.includeMetadata) {
      csvContent.writeln('# LiftUp Export');
      csvContent.writeln('# Version: ${metadata.version}');
      csvContent.writeln(
        '# Export Date: ${metadata.exportDate.toIso8601String()}',
      );
      csvContent.writeln('# App Version: ${metadata.appVersion}');
      csvContent.writeln('# Device ID: ${metadata.deviceId}');
      csvContent.writeln('');
    }

    // Sessions
    if (config.includeSessions) {
      csvContent.writeln('Sessions,${filteredSessions.length}');
      csvContent.writeln(
        'ID,Name,StartTime,EndTime,TotalWeight,TotalReps,Status',
      );
      for (final session in filteredSessions) {
        csvContent.writeln(
          '${session.id},${_escapeCsvField(session.name)},'
          '${session.startTime.toIso8601String()},'
          '${session.endTime?.toIso8601String() ?? ''},'
          '${session.totalWeight ?? 0},'
          '${session.totalReps ?? 0},'
          '${session.status.name}',
        );
      }
      csvContent.writeln('');
    }

    // Exercises
    if (config.includeExercises) {
      csvContent.writeln('Exercises,${filteredExercises.length}');
      csvContent.writeln('ID,Name,Category,Difficulty,MuscleGroups');
      for (final exercise in filteredExercises) {
        csvContent.writeln(
          '${exercise.id},${_escapeCsvField(exercise.name)},'
          '${exercise.category.name},'
          '${exercise.difficulty.name},'
          '"${exercise.muscleGroups.join(', ')}"',
        );
      }
      csvContent.writeln('');
    }

    // Routines
    if (config.includeRoutines) {
      csvContent.writeln('Routines,${filteredRoutines.length}');
      csvContent.writeln('ID,Name,Description,Order,CreatedAt,UpdatedAt');
      for (final routine in filteredRoutines) {
        csvContent.writeln(
          '${routine.id},${_escapeCsvField(routine.name)},'
          '${_escapeCsvField(routine.description)},'
          '${routine.order ?? 0},'
          '${routine.createdAt.toIso8601String()},'
          '${routine.updatedAt.toIso8601String()}',
        );
      }
      csvContent.writeln('');
    }

    // Progress Data
    if (config.includeProgressData) {
      csvContent.writeln('ProgressData,${filteredProgressData.length}');
      csvContent.writeln('ExerciseId,Date,MaxWeight,TotalReps');
      for (final progress in filteredProgressData) {
        csvContent.writeln(
          '${progress.exerciseId},'
          '${progress.date.toIso8601String()},'
          '${progress.maxWeight},'
          '${progress.totalReps}',
        );
      }
    }

    // User Settings
    if (config.includeUserSettings && filteredUserSettings.isNotEmpty) {
      csvContent.writeln('UserSettings,${filteredUserSettings.length}');
      csvContent.writeln('Key,Value');
      for (final entry in filteredUserSettings.entries) {
        csvContent.writeln(
          '${_escapeCsvField(entry.key)},'
          '${_escapeCsvField(entry.value.toString())}',
        );
      }
    }

    await file.writeAsString(csvContent.toString());
    return file.path;
  }

  @override
  Future<void> share(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
  }

  /// Escapa campos CSV que contienen comas, comillas o saltos de línea
  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
