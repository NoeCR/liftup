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

/// Cloud backup service
abstract class CloudBackupService {
  /// Uploads a backup to the cloud
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

  /// Downloads a backup from the cloud
  Future<Map<String, dynamic>?> downloadBackup(String backupId);

  /// Lists user's backups
  Future<List<CloudBackup>> listBackups(String userId);

  /// Deletes a backup
  Future<bool> deleteBackup(String backupId);

  /// Gets backup information
  Future<CloudBackup?> getBackupInfo(String backupId);
}

/// Simulated implementation of the cloud backup service
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
      // Configure export
      final exportConfig = ExportConfig(
        includeSessions: config?.includeDataTypes.contains('sessions') ?? true,
        includeExercises:
            config?.includeDataTypes.contains('exercises') ?? true,
        includeRoutines: config?.includeDataTypes.contains('routines') ?? true,
        includeProgressData:
            config?.includeDataTypes.contains('progressData') ?? true,
        includeUserSettings:
            config?.includeDataTypes.contains('settings') ?? false,
        compressData: config?.compressBackups ?? true,
        includeMetadata: true,
      );

      // Use ExportFactory to create the JSON exporter
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

      // Simulate cloud upload
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

      // Clean up temp file
      await file.delete();

      return BackupResult.success(
        backupId: backupId,
        sizeBytes: sizeBytes,
        completedAt: DateTime.now(),
      );
    } catch (e) {
      return BackupResult.failure('Error uploading backup: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> downloadBackup(String backupId) async {
    try {
      // Simulate cloud download
      await Future.delayed(const Duration(seconds: 1));

      return _backupData[backupId];
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<CloudBackup>> listBackups(String userId) async {
    try {
      // Simulate cloud query
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
      // Simulate cloud deletion
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
      // Simulate cloud query
      await Future.delayed(const Duration(milliseconds: 300));

      return _backups[backupId];
    } catch (e) {
      return null;
    }
  }

  /// Loads backup data from file
  Future<Map<String, dynamic>> _loadBackupData(String filePath) async {
    final file = File(filePath);
    final jsonString = await file.readAsString();
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
}

/// Automatic backup service
class AutoBackupService {
  final CloudBackupService _cloudService;
  final BackupConfig _config;
  DateTime? _lastBackupTime;

  AutoBackupService({
    required CloudBackupService cloudService,
    required BackupConfig config,
  }) : _cloudService = cloudService,
       _config = config;

  /// Checks whether a backup is needed
  bool shouldBackup() {
    if (!_config.enabled) return false;

    if (_lastBackupTime == null) return true;

    final timeSinceLastBackup = DateTime.now().difference(_lastBackupTime!);
    return timeSinceLastBackup.inHours >= _config.intervalHours;
  }

  /// Runs an automatic backup if needed
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

    // Check WiFi connection if required
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

  /// Checks if there is WiFi connection (simulated)
  Future<bool> _isWifiConnected() async {
    // In a real implementation, you'd check the network connection
    await Future.delayed(const Duration(milliseconds: 100));
    return true; // Simulate WiFi connection
  }

  /// Updates backup configuration
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

  /// Cleans up old backups
  Future<void> cleanupOldBackups(String userId) async {
    final backups = await _cloudService.listBackups(userId);

    if (backups.length > _config.maxBackups) {
      // Sort by creation date (oldest first)
      backups.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // Delete the oldest ones
      final toDelete = backups.take(backups.length - _config.maxBackups);
      for (final backup in toDelete) {
        await _cloudService.deleteBackup(backup.id);
      }
    }
  }
}
