import 'package:equatable/equatable.dart';
import 'export_type.dart';

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
  final ExportType? preferredType;
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
    this.preferredType,
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
        preferredType,
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
    ExportType? preferredType,
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
      preferredType: preferredType ?? this.preferredType,
      compressData: compressData ?? this.compressData,
      includeMetadata: includeMetadata ?? this.includeMetadata,
    );
  }

  /// Verifica si se incluye algún tipo de dato
  bool get hasAnyData {
    return includeSessions || 
           includeExercises || 
           includeRoutines || 
           includeProgressData || 
           includeUserSettings;
  }

  /// Verifica si se incluyen todos los tipos de datos
  bool get hasAllData {
    return includeSessions && 
           includeExercises && 
           includeRoutines && 
           includeProgressData;
  }

  /// Obtiene una descripción de los datos incluidos
  String get includedDataDescription {
    final included = <String>[];
    if (includeSessions) included.add('Sesiones');
    if (includeExercises) included.add('Ejercicios');
    if (includeRoutines) included.add('Rutinas');
    if (includeProgressData) included.add('Progreso');
    if (includeUserSettings) included.add('Configuración');
    
    return included.isEmpty ? 'Ningún dato' : included.join(', ');
  }

  /// Crea una configuración para exportación completa
  static ExportConfig fullExport() {
    return const ExportConfig(
      includeSessions: true,
      includeExercises: true,
      includeRoutines: true,
      includeProgressData: true,
      includeUserSettings: true,
      compressData: true,
      includeMetadata: true,
    );
  }

  /// Crea una configuración para exportación rápida (solo datos esenciales)
  static ExportConfig quickExport() {
    return const ExportConfig(
      includeSessions: true,
      includeExercises: true,
      includeRoutines: true,
      includeProgressData: false,
      includeUserSettings: false,
      compressData: false,
      includeMetadata: false,
    );
  }

  /// Crea una configuración para exportación de respaldo
  static ExportConfig backupExport() {
    return const ExportConfig(
      includeSessions: true,
      includeExercises: true,
      includeRoutines: true,
      includeProgressData: true,
      includeUserSettings: true,
      compressData: true,
      includeMetadata: true,
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
