import 'package:equatable/equatable.dart';

/// Estado del backup en la nube
enum BackupStatus { pending, uploading, completed, failed, expired }

/// Configuración de backup automático
class BackupConfig extends Equatable {
  final bool enabled;
  final int intervalHours; // Intervalo en horas
  final int maxBackups; // Máximo número de backups a mantener
  final bool backupOnWifiOnly;
  final bool compressBackups;
  final List<String> includeDataTypes; // Tipos de datos a incluir

  const BackupConfig({
    this.enabled = false,
    this.intervalHours = 24,
    this.maxBackups = 10,
    this.backupOnWifiOnly = true,
    this.compressBackups = true,
    this.includeDataTypes = const ['sessions', 'routines', 'exercises'],
  });

  @override
  List<Object?> get props => [enabled, intervalHours, maxBackups, backupOnWifiOnly, compressBackups, includeDataTypes];

  BackupConfig copyWith({
    bool? enabled,
    int? intervalHours,
    int? maxBackups,
    bool? backupOnWifiOnly,
    bool? compressBackups,
    List<String>? includeDataTypes,
  }) {
    return BackupConfig(
      enabled: enabled ?? this.enabled,
      intervalHours: intervalHours ?? this.intervalHours,
      maxBackups: maxBackups ?? this.maxBackups,
      backupOnWifiOnly: backupOnWifiOnly ?? this.backupOnWifiOnly,
      compressBackups: compressBackups ?? this.compressBackups,
      includeDataTypes: includeDataTypes ?? this.includeDataTypes,
    );
  }
}

/// Información de un backup en la nube
class CloudBackup extends Equatable {
  final String id;
  final String userId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final BackupStatus status;
  final int sizeBytes;
  final String? downloadUrl;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  const CloudBackup({
    required this.id,
    required this.userId,
    required this.createdAt,
    this.completedAt,
    required this.status,
    required this.sizeBytes,
    this.downloadUrl,
    this.errorMessage,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    createdAt,
    completedAt,
    status,
    sizeBytes,
    downloadUrl,
    errorMessage,
    metadata,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status.name,
      'sizeBytes': sizeBytes,
      'downloadUrl': downloadUrl,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  factory CloudBackup.fromJson(Map<String, dynamic> json) {
    return CloudBackup(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      status: BackupStatus.values.firstWhere((e) => e.name == json['status']),
      sizeBytes: json['sizeBytes'] as int,
      downloadUrl: json['downloadUrl'] as String?,
      errorMessage: json['errorMessage'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  CloudBackup copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    DateTime? completedAt,
    BackupStatus? status,
    int? sizeBytes,
    String? downloadUrl,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return CloudBackup(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Resultado de una operación de backup
class BackupResult extends Equatable {
  final bool success;
  final String? backupId;
  final String? errorMessage;
  final int? sizeBytes;
  final DateTime? completedAt;

  const BackupResult({required this.success, this.backupId, this.errorMessage, this.sizeBytes, this.completedAt});

  @override
  List<Object?> get props => [success, backupId, errorMessage, sizeBytes, completedAt];

  factory BackupResult.success({required String backupId, required int sizeBytes, DateTime? completedAt}) {
    return BackupResult(
      success: true,
      backupId: backupId,
      sizeBytes: sizeBytes,
      completedAt: completedAt ?? DateTime.now(),
    );
  }

  factory BackupResult.failure(String errorMessage) {
    return BackupResult(success: false, errorMessage: errorMessage);
  }
}
