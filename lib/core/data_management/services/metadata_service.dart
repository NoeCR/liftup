import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/export_config.dart';

/// Servicio para obtener metadatos reales de la aplicación y dispositivo
class MetadataService {
  static MetadataService? _instance;
  static MetadataService get instance => _instance ??= MetadataService._();

  MetadataService._();

  PackageInfo? _packageInfo;

  /// Inicializa el servicio
  Future<void> initialize() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  /// Crea metadatos de exportación con datos reales
  Future<ExportMetadata> createExportMetadata({Map<String, dynamic>? customData}) async {
    if (_packageInfo == null) {
      await initialize();
    }

    final deviceId = await _getDeviceId();

    return ExportMetadata(
      version: '1.0', // Versión del formato de exportación
      exportDate: DateTime.now(),
      appVersion: _packageInfo?.version ?? '1.0.0',
      deviceId: deviceId,
      customData: customData,
    );
  }

  /// Obtiene un ID único del dispositivo
  Future<String> _getDeviceId() async {
    try {
      // Por ahora, generar un ID basado en la plataforma y timestamp
      final platform = Platform.operatingSystem;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return '$platform-$timestamp';
    } catch (e) {
      // Fallback a un ID generado basado en timestamp
      return 'device-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Obtiene información del paquete
  PackageInfo? get packageInfo => _packageInfo;
}
