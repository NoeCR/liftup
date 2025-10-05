/// Tipos de exportación soportados
enum ExportType {
  json('json', 'JSON', 'application/json'),
  csv('csv', 'CSV', 'text/csv'),
  pdf('pdf', 'PDF', 'application/pdf');

  const ExportType(this.extension, this.displayName, this.mimeType);

  /// Extensión del archivo
  final String extension;

  /// Nombre para mostrar en la UI
  final String displayName;

  /// Tipo MIME del archivo
  final String mimeType;

  /// Obtiene el tipo de exportación desde la extensión del archivo
  static ExportType? fromExtension(String extension) {
    final cleanExtension = extension.toLowerCase().replaceAll('.', '');
    for (final type in ExportType.values) {
      if (type.extension == cleanExtension) {
        return type;
      }
    }
    return null;
  }

  /// Obtiene el tipo de exportación desde el tipo MIME
  static ExportType? fromMimeType(String mimeType) {
    for (final type in ExportType.values) {
      if (type.mimeType == mimeType) {
        return type;
      }
    }
    return null;
  }

  /// Lista de todas las extensiones soportadas
  static List<String> get supportedExtensions => ExportType.values.map((e) => e.extension).toList();

  /// Lista de todos los tipos MIME soportados
  static List<String> get supportedMimeTypes => ExportType.values.map((e) => e.mimeType).toList();

  /// Lista de todos los nombres para mostrar
  static List<String> get displayNames => ExportType.values.map((e) => e.displayName).toList();
}
