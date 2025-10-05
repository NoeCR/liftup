import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
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
        // Import options
        _buildImportOptions(),

        const SizedBox(height: 16),

        // Import actions
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _importFromFile(context),
                icon: const Icon(Icons.upload_file),
                label: Text(context.tr('dataManagement.importFile')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showImportHelp(context),
                icon: const Icon(Icons.help),
                label: Text(context.tr('dataManagement.help')),
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
          title: context.tr('dataManagement.mergeData'),
          subtitle: context.tr('dataManagement.mergeDataDescription'),
          value: _mergeData,
          onChanged: (value) => setState(() => _mergeData = value!),
        ),
        _buildCheckboxOption(
          title: context.tr('dataManagement.overwriteExisting'),
          subtitle: context.tr('dataManagement.overwriteExistingDescription'),
          value: _overwriteExisting,
          onChanged: (value) => setState(() => _overwriteExisting = value!),
        ),
        _buildCheckboxOption(
          title: context.tr('dataManagement.validateData'),
          subtitle: context.tr('dataManagement.validateDataDescription'),
          value: _validateData,
          onChanged: (value) => setState(() => _validateData = value!),
        ),
        _buildCheckboxOption(
          title: context.tr('dataManagement.createBackup'),
          subtitle: context.tr('dataManagement.createBackupDescription'),
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
                Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _importFromFile(BuildContext context) async {
    try {
      // Resolve supported extensions dynamically
      final supportedExtensions = ImportFactory.getSupportedExtensions();

      // Show file picker with validation
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: supportedExtensions.map((ext) => ext.replaceAll('.', '')).toList(),
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return; // User cancelled
      }

      final file = result.files.first;
      if (file.path == null) {
        throw Exception('Unable to access the selected file');
      }

      // Additional file validations
      await _validateFile(file);

      if (!context.mounted) return;
      // Show progress indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: Row(children: [CircularProgressIndicator(), SizedBox(width: 16), Text('Importando datos...')]),
            ),
      );

      // Build import configuration
      final importConfig = ImportConfig(
        mergeData: _mergeData,
        overwriteExisting: _overwriteExisting,
        validateData: _validateData,
        createBackup: _createBackup,
        allowedTypes: const [ExportType.json, ExportType.csv],
        maxFileSize: 10 * 1024 * 1024, // 10MB
      );

      // Perform import using the service
      final importResult = await ImportService.instance.importFromFile(filePath: file.path!, config: importConfig);

      // Close progress indicator
      if (!context.mounted) return;
      Navigator.of(context).pop();

      // Show result
      if (!context.mounted) return;
      if (importResult.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Import successful: ${importResult.importedCount} items imported'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Import error: ${importResult.errorMessage}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // Close progress indicator if open
      if (!mounted) return;
      Navigator.of(context).pop();

      if (!mounted) return;
      // Show error with details
      _showImportError(context, e.toString());
    }
  }
}

void _showImportHelp(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Import Help'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Supported Formats:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• JSON: Full backup files'),
                Text('• CSV: Tabular data for analysis'),
                SizedBox(height: 16),
                Text('Recommendations:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• Always create a backup before importing'),
                Text('• Validate data to avoid errors'),
                Text('• Use "Merge data" to keep existing information'),
                SizedBox(height: 16),
                Text('Maximum Size:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• 10MB per file'),
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
        ),
  );
}

/// Shows a detailed error dialog for import problems
void _showImportError(BuildContext context, String errorMessage) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Row(children: [Icon(Icons.error, color: Colors.red), SizedBox(width: 8), Text('Import Error')]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Could not import the file. Error details:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(errorMessage, style: TextStyle(color: Colors.red.shade800, fontFamily: 'monospace')),
              ),
              const SizedBox(height: 12),
              const Text('Suggestions:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('• Verify that the file is not corrupted'),
              const Text('• Make sure the format is correct'),
              const Text('• Ensure the file is under 10MB'),
              const Text('• Try with a different backup file'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showImportHelp(context);
              },
              child: const Text('View Help'),
            ),
          ],
        ),
  );
}

/// Valida un archivo antes de la importación
Future<void> _validateFile(PlatformFile file) async {
  // 1. Validar que el archivo existe y es accesible
  if (file.path == null) {
    throw Exception('No se pudo acceder al archivo seleccionado');
  }

  final fileObj = File(file.path!);
  if (!await fileObj.exists()) {
    throw Exception('El archivo seleccionado no existe');
  }

  // 2. Validar extensión del archivo
  final fileExtension = ImportFactory.getFileExtension(file.path!);
  if (!ImportFactory.isSupportedExtension(fileExtension)) {
    final supportedExtensions = ImportFactory.getSupportedExtensions().join(', ');
    throw Exception(
      'Tipo de archivo no soportado: $fileExtension\n'
      'Extensiones soportadas: $supportedExtensions',
    );
  }

  // 3. Validar tamaño del archivo
  const maxFileSize = 10 * 1024 * 1024; // 10MB
  final fileSize = await fileObj.length();
  if (fileSize > maxFileSize) {
    final sizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);
    final maxSizeMB = (maxFileSize / (1024 * 1024)).toStringAsFixed(0);
    throw Exception(
      'El archivo es demasiado grande: ${sizeMB}MB\n'
      'Maximum allowed size: ${maxSizeMB}MB',
    );
  }

  // 4. Validar que el archivo no esté vacío
  if (fileSize == 0) {
    throw Exception('Selected file is empty');
  }

  // 5. Validación básica de contenido según el tipo
  await _validateFileContent(fileObj, fileExtension);
}

/// Valida el contenido básico del archivo según su tipo
Future<void> _validateFileContent(File file, String extension) async {
  try {
    final content = await file.readAsString();

    if (content.trim().isEmpty) {
      throw Exception('File is empty or contains only whitespace');
    }

    switch (extension.toLowerCase()) {
      case '.json':
        // Validar que es JSON válido
        try {
          // Intentar parsear el JSON para verificar que es válido
          final jsonData = jsonDecode(content);
          if (jsonData is! Map<String, dynamic>) {
            throw Exception('JSON file must contain an object at the root');
          }
        } catch (e) {
          throw Exception('File does not contain valid JSON: ${e.toString()}');
        }
        break;

      case '.csv':
        // Validar que tiene al menos una línea con contenido
        final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
        if (lines.isEmpty) {
          throw Exception('CSV file does not contain valid data');
        }
        // Verificar que tiene al menos una coma (indicador básico de CSV)
        if (!lines.first.contains(',')) {
          throw Exception('File does not appear to be a valid CSV (no column separators found)');
        }
        break;

      default:
        throw Exception('File type not supported for content validation');
    }
  } catch (e) {
    if (e is Exception) {
      rethrow;
    }
    throw Exception('Error al leer el archivo: ${e.toString()}');
  }
}
