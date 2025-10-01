import 'dart:io';
import 'dart:convert';
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
      // Obtener extensiones soportadas dinámicamente
      final supportedExtensions = ImportFactory.getSupportedExtensions();

      // Mostrar diálogo de selección de archivo con validación
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions:
            supportedExtensions.map((ext) => ext.replaceAll('.', '')).toList(),
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return; // Usuario canceló
      }

      final file = result.files.first;
      if (file.path == null) {
        throw Exception('No se pudo acceder al archivo');
      }

      // Validaciones adicionales del archivo
      await _validateFile(file);

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
        allowedTypes: const [ExportType.json, ExportType.csv],
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
        // Mostrar error específico con más detalles
        _showImportError(context, e.toString());
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

  /// Muestra un diálogo de error detallado para problemas de importación
  void _showImportError(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('Error de Importación'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No se pudo importar el archivo. Detalles del error:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sugerencias:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('• Verifica que el archivo no esté corrupto'),
                const Text('• Asegúrate de que el formato sea correcto'),
                const Text('• Comprueba que el archivo no exceda 10MB'),
                const Text('• Intenta con un archivo de respaldo diferente'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendido'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showImportHelp(context);
                },
                child: const Text('Ver Ayuda'),
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
      final supportedExtensions = ImportFactory.getSupportedExtensions().join(
        ', ',
      );
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
        'Tamaño máximo permitido: ${maxSizeMB}MB',
      );
    }

    // 4. Validar que el archivo no esté vacío
    if (fileSize == 0) {
      throw Exception('El archivo seleccionado está vacío');
    }

    // 5. Validación básica de contenido según el tipo
    await _validateFileContent(fileObj, fileExtension);
  }

  /// Valida el contenido básico del archivo según su tipo
  Future<void> _validateFileContent(File file, String extension) async {
    try {
      final content = await file.readAsString();

      if (content.trim().isEmpty) {
        throw Exception(
          'El archivo está vacío o contiene solo espacios en blanco',
        );
      }

      switch (extension.toLowerCase()) {
        case '.json':
          // Validar que es JSON válido
          try {
            // Intentar parsear el JSON para verificar que es válido
            final jsonData = jsonDecode(content);
            if (jsonData is! Map<String, dynamic>) {
              throw Exception(
                'El archivo JSON debe contener un objeto en la raíz',
              );
            }
          } catch (e) {
            throw Exception(
              'El archivo no contiene JSON válido: ${e.toString()}',
            );
          }
          break;

        case '.csv':
          // Validar que tiene al menos una línea con contenido
          final lines =
              content
                  .split('\n')
                  .where((line) => line.trim().isNotEmpty)
                  .toList();
          if (lines.isEmpty) {
            throw Exception('El archivo CSV no contiene datos válidos');
          }
          // Verificar que tiene al menos una coma (indicador básico de CSV)
          if (!lines.first.contains(',')) {
            throw Exception(
              'El archivo no parece ser un CSV válido (no contiene separadores de columna)',
            );
          }
          break;

        default:
          throw Exception(
            'Tipo de archivo no soportado para validación de contenido',
          );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error al leer el archivo: ${e.toString()}');
    }
  }
}
