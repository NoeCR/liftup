import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data_management/data_management.dart';
import '../../../features/sessions/notifiers/session_notifier.dart';
import '../../../features/exercise/notifiers/exercise_notifier.dart';
import '../../../features/home/notifiers/routine_notifier.dart';

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
        // Opciones de exportación
        _buildExportOptions(),
        
        const SizedBox(height: 16),
        
        // Botones de exportación
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportToJSON(context),
                icon: const Icon(Icons.code),
                label: const Text('JSON'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportToCSV(context),
                icon: const Icon(Icons.table_chart),
                label: const Text('CSV'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportToPDF(context),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('PDF'),
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
          title: 'Sesiones de entrenamiento',
          subtitle: 'Incluir todas las sesiones completadas',
          value: _includeSessions,
          onChanged: (value) => setState(() => _includeSessions = value!),
        ),
        _buildCheckboxOption(
          title: 'Ejercicios',
          subtitle: 'Incluir catálogo de ejercicios',
          value: _includeExercises,
          onChanged: (value) => setState(() => _includeExercises = value!),
        ),
        _buildCheckboxOption(
          title: 'Rutinas',
          subtitle: 'Incluir rutinas personalizadas',
          value: _includeRoutines,
          onChanged: (value) => setState(() => _includeRoutines = value!),
        ),
        _buildCheckboxOption(
          title: 'Datos de progreso',
          subtitle: 'Incluir estadísticas de progreso',
          value: _includeProgressData,
          onChanged: (value) => setState(() => _includeProgressData = value!),
        ),
        _buildCheckboxOption(
          title: 'Configuración de usuario',
          subtitle: 'Incluir preferencias y configuraciones',
          value: _includeUserSettings,
          onChanged: (value) => setState(() => _includeUserSettings = value!),
        ),
        _buildCheckboxOption(
          title: 'Comprimir datos',
          subtitle: 'Reducir tamaño del archivo',
          value: _compressData,
          onChanged: (value) => setState(() => _compressData = value!),
        ),
        _buildCheckboxOption(
          title: 'Metadatos',
          subtitle: 'Incluir información de exportación',
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
          Checkbox(
            value: value,
            onChanged: onChanged,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
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

      final exportBuilder = ExportBuilder.create(
        sessions: sessions,
        exercises: exercises,
        routines: routines,
        progressData: [], // TODO: Implementar ProgressData
        userSettings: {},
        metadata: ExportMetadata(
          version: '1.0',
          exportDate: DateTime.now(),
          appVersion: '1.0.0',
          deviceId: 'device-id',
        ),
      );

      final configuredBuilder = exportBuilder.withConfig(exportConfig);
      final filePath = await configuredBuilder.toJSON();
      await configuredBuilder.share(filePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Datos exportados a JSON exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

      final exportBuilder = ExportBuilder.create(
        sessions: sessions,
        exercises: exercises,
        routines: routines,
        progressData: [], // TODO: Implementar ProgressData
        userSettings: {},
        metadata: ExportMetadata(
          version: '1.0',
          exportDate: DateTime.now(),
          appVersion: '1.0.0',
          deviceId: 'device-id',
        ),
      );

      final configuredBuilder = exportBuilder.withConfig(exportConfig);
      final filePath = await configuredBuilder.toCSV();
      await configuredBuilder.share(filePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Datos exportados a CSV exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

      final exportBuilder = ExportBuilder.create(
        sessions: sessions,
        exercises: exercises,
        routines: routines,
        progressData: [], // TODO: Implementar ProgressData
        userSettings: {},
        metadata: ExportMetadata(
          version: '1.0',
          exportDate: DateTime.now(),
          appVersion: '1.0.0',
          deviceId: 'device-id',
        ),
      );

      final configuredBuilder = exportBuilder.withConfig(exportConfig);
      final filePath = await configuredBuilder.toPDF();
      await configuredBuilder.share(filePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reporte PDF generado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al generar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
