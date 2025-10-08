import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/export_config.dart';

/// Service to obtain real app and device metadata
class MetadataService {
  static MetadataService? _instance;
  static MetadataService get instance => _instance ??= MetadataService._();

  MetadataService._();

  PackageInfo? _packageInfo;

  /// Inicializa el servicio
  Future<void> initialize() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  /// Creates export metadata with real data
  Future<ExportMetadata> createExportMetadata({
    Map<String, dynamic>? customData,
  }) async {
    if (_packageInfo == null) {
      await initialize();
    }

    final deviceId = await _getDeviceId();

    return ExportMetadata(
      version: '1.0', // Export format version
      exportDate: DateTime.now(),
      appVersion: _packageInfo?.version ?? '1.0.0',
      deviceId: deviceId,
      customData: customData,
    );
  }

  /// Gets a unique device ID
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

  /// Gets package information
  PackageInfo? get packageInfo => _packageInfo;
}
