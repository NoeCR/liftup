import 'dart:io';
import 'dart:convert';
import '../models/cloud_backup.dart';
import '../models/export_config.dart';
import '../models/export_type.dart';
import '../exporters/export_factory.dart';
import '../services/metadata_service.dart';
import '../../../features/sessions/models/workout_session.dart';
import '../../../features/exercise/models/exercise.dart';
import '../../../features/home/models/routine.dart';
import '../../../features/statistics/models/progress_data.dart';

/// Servicio para backup en la nube
abstract class CloudBackupService {
  /// Sube un backup a la nube
  Future<BackupResult> uploadBackup({
    required String userId,
    required List<WorkoutSession> sessions,
    required List<Exercise> exercises,
    required List<Routine> routines,
    required List<ProgressData> progressData,
    required Map<String, dynamic> userSettings,
    required ExportMetadata metadata,
    BackupConfig? config,
  });

  /// Descarga un backup desde la nube
  Future<Map<String, dynamic>?> downloadBackup(String backupId);

  /// Lista los backups del usuario
  Future<List<CloudBackup>> listBackups(String userId);

  /// Elimina un backup
  Future<bool> deleteBackup(String backupId);

  /// Obtiene información de un backup
  Future<CloudBackup?> getBackupInfo(String backupId);
}

/// Implementación simulada del servicio de backup en la nube
class MockCloudBackupService implements CloudBackupService {
  final Map<String, CloudBackup> _backups = {};
  final Map<String, Map<String, dynamic>> _backupData = {};

  @override
  Future<BackupResult> uploadBackup({
    required String userId,
    required List<WorkoutSession> sessions,
    required List<Exercise> exercises,
    required List<Routine> routines,
    required List<ProgressData> progressData,
    required Map<String, dynamic> userSettings,
    required ExportMetadata metadata,
    BackupConfig? config,
  }) async {
    try {
      // Configurar exportación
      final exportConfig = ExportConfig(
        includeSessions: config?.includeDataTypes.contains('sessions') ?? true,
        includeExercises: config?.includeDataTypes.contains('exercises') ?? true,
        includeRoutines: config?.includeDataTypes.contains('routines') ?? true,
        includeProgressData: config?.includeDataTypes.contains('progressData') ?? true,
        includeUserSettings: config?.includeDataTypes.contains('settings') ?? false,
        compressData: config?.compressBackups ?? true,
        includeMetadata: true,
      );

      // Usar ExportFactory para crear el exportador JSON
      final exporter = ExportFactory.createExporter(
        type: ExportType.json,
        config: exportConfig,
        routines: routines,
        exercises: exercises,
        sessions: sessions,
        progressData: progressData,
        userSettings: {},
        metadata: await MetadataService.instance.createExportMetadata(),
      );

      final filePath = await exporter.export();
      final file = File(filePath);
      final sizeBytes = await file.length();

      // Simular subida a la nube
      await Future.delayed(const Duration(seconds: 2));

      final backupId = 'backup_${DateTime.now().millisecondsSinceEpoch}';
      final backup = CloudBackup(
        id: backupId,
        userId: userId,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        status: BackupStatus.completed,
        sizeBytes: sizeBytes,
        downloadUrl: 'https://mock-cloud.com/backups/$backupId',
        metadata: {
          'sessions': sessions.length,
          'exercises': exercises.length,
          'routines': routines.length,
          'progressData': progressData.length,
        },
      );

      _backups[backupId] = backup;
      _backupData[backupId] = await _loadBackupData(filePath);

      // Limpiar archivo temporal
      await file.delete();

      return BackupResult.success(backupId: backupId, sizeBytes: sizeBytes, completedAt: DateTime.now());
    } catch (e) {
      return BackupResult.failure('Error al subir backup: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> downloadBackup(String backupId) async {
    try {
      // Simular descarga desde la nube
      await Future.delayed(const Duration(seconds: 1));

      return _backupData[backupId];
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<CloudBackup>> listBackups(String userId) async {
    try {
      // Simular consulta a la nube
      await Future.delayed(const Duration(milliseconds: 500));

      return _backups.values.where((backup) => backup.userId == userId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> deleteBackup(String backupId) async {
    try {
      // Simular eliminación en la nube
      await Future.delayed(const Duration(milliseconds: 500));

      _backups.remove(backupId);
      _backupData.remove(backupId);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<CloudBackup?> getBackupInfo(String backupId) async {
    try {
      // Simular consulta a la nube
      await Future.delayed(const Duration(milliseconds: 300));

      return _backups[backupId];
    } catch (e) {
      return null;
    }
  }

  /// Carga los datos del backup desde el archivo
  Future<Map<String, dynamic>> _loadBackupData(String filePath) async {
    final file = File(filePath);
    final jsonString = await file.readAsString();
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
}

/// Servicio de backup automático
class AutoBackupService {
  final CloudBackupService _cloudService;
  final BackupConfig _config;
  DateTime? _lastBackupTime;

  AutoBackupService({required CloudBackupService cloudService, required BackupConfig config})
    : _cloudService = cloudService,
      _config = config;

  /// Verifica si es necesario hacer un backup
  bool shouldBackup() {
    if (!_config.enabled) return false;

    if (_lastBackupTime == null) return true;

    final timeSinceLastBackup = DateTime.now().difference(_lastBackupTime!);
    return timeSinceLastBackup.inHours >= _config.intervalHours;
  }

  /// Ejecuta un backup automático si es necesario
  Future<BackupResult?> executeAutoBackup({
    required String userId,
    required List<WorkoutSession> sessions,
    required List<Exercise> exercises,
    required List<Routine> routines,
    required List<ProgressData> progressData,
    required Map<String, dynamic> userSettings,
    required ExportMetadata metadata,
  }) async {
    if (!shouldBackup()) return null;

    // Verificar conexión WiFi si es requerido
    if (_config.backupOnWifiOnly && !await _isWifiConnected()) {
      return BackupResult.failure('Backup requires WiFi connection');
    }

    final result = await _cloudService.uploadBackup(
      userId: userId,
      sessions: sessions,
      exercises: exercises,
      routines: routines,
      progressData: progressData,
      userSettings: userSettings,
      metadata: metadata,
      config: _config,
    );

    if (result.success) {
      _lastBackupTime = DateTime.now();
    }

    return result;
  }

  /// Verifica si hay conexión WiFi (simulado)
  Future<bool> _isWifiConnected() async {
    // En una implementación real, verificarías la conexión de red
    await Future.delayed(const Duration(milliseconds: 100));
    return true; // Simular conexión WiFi
  }

  /// Actualiza la configuración de backup
  void updateConfig(BackupConfig newConfig) {
    _config.copyWith(
      enabled: newConfig.enabled,
      intervalHours: newConfig.intervalHours,
      maxBackups: newConfig.maxBackups,
      backupOnWifiOnly: newConfig.backupOnWifiOnly,
      compressBackups: newConfig.compressBackups,
      includeDataTypes: newConfig.includeDataTypes,
    );
  }

  /// Limpia backups antiguos
  Future<void> cleanupOldBackups(String userId) async {
    final backups = await _cloudService.listBackups(userId);

    if (backups.length > _config.maxBackups) {
      // Ordenar por fecha de creación (más antiguos primero)
      backups.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // Eliminar los más antiguos
      final toDelete = backups.take(backups.length - _config.maxBackups);
      for (final backup in toDelete) {
        await _cloudService.deleteBackup(backup.id);
      }
    }
  }
}
