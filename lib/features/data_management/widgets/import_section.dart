import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/data_management/data_management.dart';

class ImportSection extends ConsumerStatefulWidget {
  const ImportSection({super.key});

  @override
  ConsumerState<ImportSection> createState() => _ImportSectionState();
}

class _ImportSectionState extends ConsumerState<ImportSection> {
  bool _mergeData = true;
  bool _overwriteExisting = false;
  bool _validateData = true;
  bool _createBackup = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Opciones de importación
        _buildImportOptions(),

        const SizedBox(height: 16),

        // Botones de importación
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _importFromFile(context),
                icon: const Icon(Icons.upload_file),
                label: const Text('Importar Archivo'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showImportHelp(context),
                icon: const Icon(Icons.help),
                label: const Text('Ayuda'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImportOptions() {
    return Column(
      children: [
        _buildCheckboxOption(
          title: 'Fusionar datos',
          subtitle: 'Mantener datos existentes y agregar nuevos',
          value: _mergeData,
          onChanged: (value) => setState(() => _mergeData = value!),
        ),
        _buildCheckboxOption(
          title: 'Sobrescribir existentes',
          subtitle: 'Reemplazar datos duplicados',
          value: _overwriteExisting,
          onChanged: (value) => setState(() => _overwriteExisting = value!),
        ),
        _buildCheckboxOption(
          title: 'Validar datos',
          subtitle: 'Verificar integridad antes de importar',
          value: _validateData,
          onChanged: (value) => setState(() => _validateData = value!),
        ),
        _buildCheckboxOption(
          title: 'Crear respaldo',
          subtitle: 'Hacer backup antes de importar',
          value: _createBackup,
          onChanged: (value) => setState(() => _createBackup = value!),
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

  Future<void> _importFromFile(BuildContext context) async {
    try {
      // Mostrar diálogo de selección de archivo
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return; // Usuario canceló
      }

      final file = result.files.first;
      if (file.path == null) {
        throw Exception('No se pudo acceder al archivo');
      }

      // Mostrar indicador de progreso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Importando datos...'),
                ],
              ),
            ),
      );

      // Configurar importación
      final importConfig = ImportConfig(
        mergeData: _mergeData,
        overwriteExisting: _overwriteExisting,
        validateData: _validateData,
        createBackup: _createBackup,
        allowedFormats: const ['json', 'csv'],
        maxFileSize: 10 * 1024 * 1024, // 10MB
      );

      // Realizar importación usando el servicio
      final importResult = await ImportService.instance.importFromFile(
        filePath: file.path!,
        config: importConfig,
      );

      // Cerrar indicador de progreso
      if (mounted) Navigator.of(context).pop();

      // Mostrar resultado
      if (mounted) {
        if (importResult.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Importación exitosa: ${importResult.importedCount} elementos importados',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '❌ Error en la importación: ${importResult.errorMessage}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Cerrar indicador de progreso si está abierto
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al importar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImportHelp(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ayuda de Importación'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Formatos Soportados:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• JSON: Archivos de respaldo completos'),
                  Text('• CSV: Datos tabulares para análisis'),
                  SizedBox(height: 16),
                  Text(
                    'Recomendaciones:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Siempre crea un respaldo antes de importar'),
                  Text('• Valida los datos para evitar errores'),
                  Text(
                    '• Usa "Fusionar datos" para mantener información existente',
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tamaño Máximo:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• 10MB por archivo'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendido'),
              ),
            ],
          ),
    );
  }
}
