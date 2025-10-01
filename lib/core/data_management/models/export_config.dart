import 'package:equatable/equatable.dart';

/// Configuración para la exportación de datos
class ExportConfig extends Equatable {
  final bool includeSessions;
  final bool includeExercises;
  final bool includeRoutines;
  final bool includeProgressData;
  final bool includeUserSettings;
  final DateTime? fromDate;
  final DateTime? toDate;
  final List<String>? routineIds;
  final List<String>? exerciseIds;
  final bool compressData;
  final bool includeMetadata;

  const ExportConfig({
    this.includeSessions = true,
    this.includeExercises = true,
    this.includeRoutines = true,
    this.includeProgressData = true,
    this.includeUserSettings = false,
    this.fromDate,
    this.toDate,
    this.routineIds,
    this.exerciseIds,
    this.compressData = false,
    this.includeMetadata = true,
  });

  @override
  List<Object?> get props => [
        includeSessions,
        includeExercises,
        includeRoutines,
        includeProgressData,
        includeUserSettings,
        fromDate,
        toDate,
        routineIds,
        exerciseIds,
        compressData,
        includeMetadata,
      ];

  ExportConfig copyWith({
    bool? includeSessions,
    bool? includeExercises,
    bool? includeRoutines,
    bool? includeProgressData,
    bool? includeUserSettings,
    DateTime? fromDate,
    DateTime? toDate,
    List<String>? routineIds,
    List<String>? exerciseIds,
    bool? compressData,
    bool? includeMetadata,
  }) {
    return ExportConfig(
      includeSessions: includeSessions ?? this.includeSessions,
      includeExercises: includeExercises ?? this.includeExercises,
      includeRoutines: includeRoutines ?? this.includeRoutines,
      includeProgressData: includeProgressData ?? this.includeProgressData,
      includeUserSettings: includeUserSettings ?? this.includeUserSettings,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      routineIds: routineIds ?? this.routineIds,
      exerciseIds: exerciseIds ?? this.exerciseIds,
      compressData: compressData ?? this.compressData,
      includeMetadata: includeMetadata ?? this.includeMetadata,
    );
  }
}

/// Configuración para la importación de datos
class ImportConfig extends Equatable {
  final bool mergeData;
  final bool overwriteExisting;
  final bool validateData;
  final bool createBackup;
  final List<String>? allowedFormats;
  final int? maxFileSize; // en bytes

  const ImportConfig({
    this.mergeData = true,
    this.overwriteExisting = false,
    this.validateData = true,
    this.createBackup = true,
    this.allowedFormats,
    this.maxFileSize,
  });

  @override
  List<Object?> get props => [
        mergeData,
        overwriteExisting,
        validateData,
        createBackup,
        allowedFormats,
        maxFileSize,
      ];

  ImportConfig copyWith({
    bool? mergeData,
    bool? overwriteExisting,
    bool? validateData,
    bool? createBackup,
    List<String>? allowedFormats,
    int? maxFileSize,
  }) {
    return ImportConfig(
      mergeData: mergeData ?? this.mergeData,
      overwriteExisting: overwriteExisting ?? this.overwriteExisting,
      validateData: validateData ?? this.validateData,
      createBackup: createBackup ?? this.createBackup,
      allowedFormats: allowedFormats ?? this.allowedFormats,
      maxFileSize: maxFileSize ?? this.maxFileSize,
    );
  }
}

/// Metadatos de exportación
class ExportMetadata extends Equatable {
  final String version;
  final DateTime exportDate;
  final String appVersion;
  final String deviceId;
  final Map<String, dynamic>? customData;

  const ExportMetadata({
    required this.version,
    required this.exportDate,
    required this.appVersion,
    required this.deviceId,
    this.customData,
  });

  @override
  List<Object?> get props => [version, exportDate, appVersion, deviceId, customData];

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'exportDate': exportDate.toIso8601String(),
      'appVersion': appVersion,
      'deviceId': deviceId,
      'customData': customData,
    };
  }

  factory ExportMetadata.fromJson(Map<String, dynamic> json) {
    return ExportMetadata(
      version: json['version'] as String,
      exportDate: DateTime.parse(json['exportDate'] as String),
      appVersion: json['appVersion'] as String,
      deviceId: json['deviceId'] as String,
      customData: json['customData'] as Map<String, dynamic>?,
    );
  }
}
