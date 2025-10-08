/// Supported export types
enum ExportType {
  json('json', 'JSON', 'application/json'),
  csv('csv', 'CSV', 'text/csv'),
  pdf('pdf', 'PDF', 'application/pdf');

  const ExportType(this.extension, this.displayName, this.mimeType);

  /// File extension
  final String extension;

  /// UI display name
  final String displayName;

  /// File MIME type
  final String mimeType;

  /// Gets the export type from a file extension
  static ExportType? fromExtension(String extension) {
    final cleanExtension = extension.toLowerCase().replaceAll('.', '');
    for (final type in ExportType.values) {
      if (type.extension == cleanExtension) {
        return type;
      }
    }
    return null;
  }

  /// Gets the export type from a MIME type
  static ExportType? fromMimeType(String mimeType) {
    for (final type in ExportType.values) {
      if (type.mimeType == mimeType) {
        return type;
      }
    }
    return null;
  }

  /// List of all supported extensions
  static List<String> get supportedExtensions =>
      ExportType.values.map((e) => e.extension).toList();

  /// List of all supported MIME types
  static List<String> get supportedMimeTypes =>
      ExportType.values.map((e) => e.mimeType).toList();

  /// List of all display names
  static List<String> get displayNames =>
      ExportType.values.map((e) => e.displayName).toList();
}
