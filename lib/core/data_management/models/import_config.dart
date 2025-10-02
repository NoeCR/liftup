import 'package:equatable/equatable.dart';
import 'export_type.dart';

/// Configuración para la importación de datos
class ImportConfig extends Equatable {
  final bool mergeData;
  final bool overwriteExisting;
  final bool validateData;
  final bool createBackup;
  final List<ExportType> allowedTypes;
  final int maxFileSize; // en bytes

  const ImportConfig({
    this.mergeData = true,
    this.overwriteExisting = false,
    this.validateData = true,
    this.createBackup = true,
    this.allowedTypes = const [ExportType.json, ExportType.csv],
    this.maxFileSize = 10 * 1024 * 1024, // 10MB por defecto
  });

  @override
  List<Object?> get props => [
    mergeData,
    overwriteExisting,
    validateData,
    createBackup,
    allowedTypes,
    maxFileSize,
  ];

  ImportConfig copyWith({
    bool? mergeData,
    bool? overwriteExisting,
    bool? validateData,
    bool? createBackup,
    List<ExportType>? allowedTypes,
    int? maxFileSize,
  }) {
    return ImportConfig(
      mergeData: mergeData ?? this.mergeData,
      overwriteExisting: overwriteExisting ?? this.overwriteExisting,
      validateData: validateData ?? this.validateData,
      createBackup: createBackup ?? this.createBackup,
      allowedTypes: allowedTypes ?? this.allowedTypes,
      maxFileSize: maxFileSize ?? this.maxFileSize,
    );
  }

  /// Valida si un tipo de archivo está permitido
  bool isTypeAllowed(ExportType type) {
    return allowedTypes.contains(type);
  }

  /// Valida si una extensión de archivo está permitida
  bool isExtensionAllowed(String extension) {
    final type = ExportType.fromExtension(extension);
    return type != null && isTypeAllowed(type);
  }

  /// Valida si el tamaño del archivo está dentro del límite
  bool isFileSizeValid(int fileSize) {
    return fileSize <= maxFileSize;
  }

  /// Obtiene las extensiones permitidas como strings
  List<String> getAllowedExtensions() {
    return allowedTypes.map((type) => '.${type.extension}').toList();
  }

  /// Obtiene los tipos MIME permitidos
  List<String> getAllowedMimeTypes() {
    return allowedTypes.map((type) => type.mimeType).toList();
  }

  /// Crea una configuración para importación completa (todos los tipos)
  static ImportConfig fullImport() {
    return const ImportConfig(
      mergeData: true,
      overwriteExisting: false,
      validateData: true,
      createBackup: true,
      allowedTypes: [ExportType.json, ExportType.csv],
      maxFileSize: 50 * 1024 * 1024, // 50MB para importación completa
    );
  }

  /// Crea una configuración para importación rápida (solo JSON)
  static ImportConfig quickImport() {
    return const ImportConfig(
      mergeData: true,
      overwriteExisting: true,
      validateData: false,
      createBackup: false,
      allowedTypes: [ExportType.json],
      maxFileSize: 5 * 1024 * 1024, // 5MB para importación rápida
    );
  }

  /// Crea una configuración para importación segura (con validaciones)
  static ImportConfig safeImport() {
    return const ImportConfig(
      mergeData: false,
      overwriteExisting: false,
      validateData: true,
      createBackup: true,
      allowedTypes: [ExportType.json, ExportType.csv],
      maxFileSize: 10 * 1024 * 1024, // 10MB para importación segura
    );
  }

  /// Valida la configuración completa
  List<String> validate() {
    final errors = <String>[];

    if (maxFileSize <= 0) {
      errors.add('Maximum file size must be greater than 0');
    }

    if (allowedTypes.isEmpty) {
      errors.add('Must allow at least one file type');
    }

    if (mergeData && overwriteExisting) {
      errors.add('Cannot merge and overwrite at the same time');
    }

    return errors;
  }

  /// Verifica si la configuración es válida
  bool get isValid => validate().isEmpty;

  /// Obtiene una descripción legible de la configuración
  String get description {
    final buffer = StringBuffer();
    buffer.write('Import: ');

    if (mergeData) {
      buffer.write('Fusionar datos');
    } else if (overwriteExisting) {
      buffer.write('Sobrescribir existentes');
    } else {
      buffer.write('Solo nuevos');
    }

    buffer.write(' | Validate: ${validateData ? 'Yes' : 'No'}');
    buffer.write(' | Backup: ${createBackup ? 'Yes' : 'No'}');
    buffer.write(
      ' | Tipos: ${allowedTypes.map((t) => t.displayName).join(', ')}',
    );
    buffer.write(
      ' | Max: ${(maxFileSize / (1024 * 1024)).toStringAsFixed(1)}MB',
    );

    return buffer.toString();
  }
}
