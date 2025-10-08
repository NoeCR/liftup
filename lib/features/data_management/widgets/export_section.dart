import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/data_management/data_management.dart';
import '../../../features/sessions/notifiers/session_notifier.dart';
import '../../../features/exercise/notifiers/exercise_notifier.dart';
import '../../../features/home/notifiers/routine_notifier.dart';
import '../../../features/statistics/notifiers/progress_notifier.dart';

class ExportSection extends ConsumerStatefulWidget {
  const ExportSection({super.key});

  @override
  ConsumerState<ExportSection> createState() => _ExportSectionState();
}

class _ExportSectionState extends ConsumerState<ExportSection> {
  bool _includeSessions = true;
  bool _includeExercises = true;
  bool _includeRoutines = true;
  bool _includeProgressData = true;
  bool _includeUserSettings = false;
  bool _compressData = false;
  bool _includeMetadata = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Export options
        _buildExportOptions(),

        const SizedBox(height: 16),

        // Export buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportToJSON(context),
                icon: const Icon(Icons.code),
                label: Text(context.tr('dataManagement.json')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportToCSV(context),
                icon: const Icon(Icons.table_chart),
                label: Text(context.tr('dataManagement.csv')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportToPDF(context),
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(context.tr('dataManagement.pdf')),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExportOptions() {
    return Column(
      children: [
        _buildCheckboxOption(
          title: context.tr('dataManagement.trainingSessions'),
          subtitle: context.tr('dataManagement.trainingSessionsDescription'),
          value: _includeSessions,
          onChanged: (value) => setState(() => _includeSessions = value!),
        ),
        _buildCheckboxOption(
          title: context.tr('dataManagement.exercises'),
          subtitle: context.tr('dataManagement.exercisesDescription'),
          value: _includeExercises,
          onChanged: (value) => setState(() => _includeExercises = value!),
        ),
        _buildCheckboxOption(
          title: context.tr('dataManagement.routines'),
          subtitle: context.tr('dataManagement.routinesDescription'),
          value: _includeRoutines,
          onChanged: (value) => setState(() => _includeRoutines = value!),
        ),
        _buildCheckboxOption(
          title: context.tr('dataManagement.progressData'),
          subtitle: context.tr('dataManagement.progressDataDescription'),
          value: _includeProgressData,
          onChanged: (value) => setState(() => _includeProgressData = value!),
        ),
        _buildCheckboxOption(
          title: context.tr('dataManagement.userSettings'),
          subtitle: context.tr('dataManagement.userSettingsDescription'),
          value: _includeUserSettings,
          onChanged: (value) => setState(() => _includeUserSettings = value!),
        ),
        _buildCheckboxOption(
          title: context.tr('dataManagement.compressData'),
          subtitle: context.tr('dataManagement.compressDataDescription'),
          value: _compressData,
          onChanged: (value) => setState(() => _compressData = value!),
        ),
        _buildCheckboxOption(
          title: context.tr('dataManagement.metadata'),
          subtitle: context.tr('dataManagement.metadataDescription'),
          value: _includeMetadata,
          onChanged: (value) => setState(() => _includeMetadata = value!),
        ),
      ],
    );
  }

  Widget _buildCheckboxOption({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Checkbox(value: value, onChanged: onChanged),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToJSON(BuildContext context) async {
    try {
      final exportConfig = ExportConfig(
        includeSessions: _includeSessions,
        includeExercises: _includeExercises,
        includeRoutines: _includeRoutines,
        includeProgressData: _includeProgressData,
        includeUserSettings: _includeUserSettings,
        compressData: _compressData,
        includeMetadata: _includeMetadata,
      );

      final sessions = await ref.read(sessionNotifierProvider.future);
      final exercises = await ref.read(exerciseNotifierProvider.future);
      final routines = await ref.read(routineNotifierProvider.future);

      final metadata = await MetadataService.instance.createExportMetadata();

      final exporter = ExportFactory.createExporter(
        type: ExportType.json,
        config: exportConfig,
        sessions: sessions,
        exercises: exercises,
        routines: routines,
        progressData: await ref.read(progressNotifierProvider.future),
        userSettings: {},
        metadata: metadata,
      );

      final filePath = await exporter.export();
      await exporter.share(filePath);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('dataManagement.dataExportedToJsonSuccessfully')),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('dataManagement.exportError', namedArgs: {'error': e.toString()})),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportToCSV(BuildContext context) async {
    try {
      final exportConfig = ExportConfig(
        includeSessions: _includeSessions,
        includeExercises: _includeExercises,
        includeRoutines: _includeRoutines,
        includeProgressData: _includeProgressData,
        includeUserSettings: _includeUserSettings,
        compressData: _compressData,
        includeMetadata: _includeMetadata,
      );

      final sessions = await ref.read(sessionNotifierProvider.future);
      final exercises = await ref.read(exerciseNotifierProvider.future);
      final routines = await ref.read(routineNotifierProvider.future);

      // Crear metadatos reales
      final metadata = await MetadataService.instance.createExportMetadata();

      // Crear exportador CSV
      final exporter = ExportFactory.createExporter(
        type: ExportType.csv,
        config: exportConfig,
        sessions: sessions,
        exercises: exercises,
        routines: routines,
        progressData: await ref.read(progressNotifierProvider.future),
        userSettings: {},
        metadata: metadata,
      );

      final filePath = await exporter.export();
      await exporter.share(filePath);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('dataManagement.dataExportedToCsvSuccessfully')),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('dataManagement.exportError', namedArgs: {'error': e.toString()})),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportToPDF(BuildContext context) async {
    try {
      final exportConfig = ExportConfig(
        includeSessions: _includeSessions,
        includeExercises: _includeExercises,
        includeRoutines: _includeRoutines,
        includeProgressData: _includeProgressData,
        includeUserSettings: _includeUserSettings,
        compressData: _compressData,
        includeMetadata: _includeMetadata,
      );

      final sessions = await ref.read(sessionNotifierProvider.future);
      final exercises = await ref.read(exerciseNotifierProvider.future);
      final routines = await ref.read(routineNotifierProvider.future);

      // Crear metadatos reales
      final metadata = await MetadataService.instance.createExportMetadata();

      // Crear exportador PDF
      final exporter = ExportFactory.createExporter(
        type: ExportType.pdf,
        config: exportConfig,
        sessions: sessions,
        exercises: exercises,
        routines: routines,
        progressData: await ref.read(progressNotifierProvider.future),
        userSettings: {},
        metadata: metadata,
      );

      final filePath = await exporter.export();
      await exporter.share(filePath);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('dataManagement.pdfReportGeneratedSuccessfully')),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error al generar PDF: $e'), backgroundColor: Colors.red));
    }
  }
}
