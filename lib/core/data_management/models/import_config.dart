import 'package:equatable/equatable.dart';
import 'export_type.dart';

/// Configuration for data import
class ImportConfig extends Equatable {
  final bool mergeData;
  final bool overwriteExisting;
  final bool validateData;
  final bool createBackup;
  final List<ExportType> allowedTypes;
  final int maxFileSize; // in bytes

  const ImportConfig({
    this.mergeData = true,
    this.overwriteExisting = false,
    this.validateData = true,
    this.createBackup = true,
    this.allowedTypes = const [ExportType.json, ExportType.csv],
    this.maxFileSize = 10 * 1024 * 1024, // 10MB default
  });

  @override
  List<Object?> get props => [mergeData, overwriteExisting, validateData, createBackup, allowedTypes, maxFileSize];

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

  /// Validates whether a file type is allowed
  bool isTypeAllowed(ExportType type) {
    return allowedTypes.contains(type);
  }

  /// Validates whether a file extension is allowed
  bool isExtensionAllowed(String extension) {
    final type = ExportType.fromExtension(extension);
    return type != null && isTypeAllowed(type);
  }

  /// Validates whether the file size is within the limit
  bool isFileSizeValid(int fileSize) {
    return fileSize <= maxFileSize;
  }

  /// Returns allowed extensions as strings
  List<String> getAllowedExtensions() {
    return allowedTypes.map((type) => '.${type.extension}').toList();
  }

  /// Returns allowed MIME types
  List<String> getAllowedMimeTypes() {
    return allowedTypes.map((type) => type.mimeType).toList();
  }

  /// Creates a configuration for full import (all types)
  static ImportConfig fullImport() {
    return const ImportConfig(
      mergeData: true,
      overwriteExisting: false,
      validateData: true,
      createBackup: true,
      allowedTypes: [ExportType.json, ExportType.csv],
      maxFileSize: 50 * 1024 * 1024, // 50MB for full import
    );
  }

  /// Creates a configuration for quick import (JSON only)
  static ImportConfig quickImport() {
    return const ImportConfig(
      mergeData: true,
      overwriteExisting: true,
      validateData: false,
      createBackup: false,
      allowedTypes: [ExportType.json],
      maxFileSize: 5 * 1024 * 1024, // 5MB for quick import
    );
  }

  /// Creates a configuration for safe import (with validations)
  static ImportConfig safeImport() {
    return const ImportConfig(
      mergeData: false,
      overwriteExisting: false,
      validateData: true,
      createBackup: true,
      allowedTypes: [ExportType.json, ExportType.csv],
      maxFileSize: 10 * 1024 * 1024, // 10MB for safe import
    );
  }

  /// Validates full configuration
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

  /// Checks whether the configuration is valid
  bool get isValid => validate().isEmpty;

  /// Returns a human-readable description of the configuration
  String get description {
    final buffer = StringBuffer();
    buffer.write('Import: ');

    if (mergeData) {
      buffer.write('Merge data');
    } else if (overwriteExisting) {
      buffer.write('Overwrite existing');
    } else {
      buffer.write('Only new');
    }

    buffer.write(' | Validate: ${validateData ? 'Yes' : 'No'}');
    buffer.write(' | Backup: ${createBackup ? 'Yes' : 'No'}');
    buffer.write(' | Types: ${allowedTypes.map((t) => t.displayName).join(', ')}');
    buffer.write(' | Max: ${(maxFileSize / (1024 * 1024)).toStringAsFixed(1)}MB');

    return buffer.toString();
  }
}
