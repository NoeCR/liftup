import 'package:equatable/equatable.dart';

/// Estado de una rutina compartida
enum SharedRoutineStatus { active, expired, deleted, private }

/// Visibilidad de una rutina compartida
enum RoutineVisibility {
  public,
  unlisted, // Solo accesible con link
  private,
}

/// Información de una rutina compartida
class SharedRoutine extends Equatable {
  final String id;
  final String routineId;
  final String ownerId;
  final String title;
  final String? description;
  final RoutineVisibility visibility;
  final SharedRoutineStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int viewCount;
  final int downloadCount;
  final List<String> tags;
  final String? thumbnailUrl;
  final Map<String, dynamic>? metadata;

  const SharedRoutine({
    required this.id,
    required this.routineId,
    required this.ownerId,
    required this.title,
    this.description,
    this.visibility = RoutineVisibility.public,
    this.status = SharedRoutineStatus.active,
    required this.createdAt,
    this.expiresAt,
    this.viewCount = 0,
    this.downloadCount = 0,
    this.tags = const [],
    this.thumbnailUrl,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    routineId,
    ownerId,
    title,
    description,
    visibility,
    status,
    createdAt,
    expiresAt,
    viewCount,
    downloadCount,
    tags,
    thumbnailUrl,
    metadata,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routineId': routineId,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'visibility': visibility.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'viewCount': viewCount,
      'downloadCount': downloadCount,
      'tags': tags,
      'thumbnailUrl': thumbnailUrl,
      'metadata': metadata,
    };
  }

  factory SharedRoutine.fromJson(Map<String, dynamic> json) {
    return SharedRoutine(
      id: json['id'] as String,
      routineId: json['routineId'] as String,
      ownerId: json['ownerId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      visibility: RoutineVisibility.values.firstWhere((e) => e.name == json['visibility']),
      status: SharedRoutineStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt'] as String) : null,
      viewCount: json['viewCount'] as int,
      downloadCount: json['downloadCount'] as int,
      tags: List<String>.from(json['tags'] as List),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  SharedRoutine copyWith({
    String? id,
    String? routineId,
    String? ownerId,
    String? title,
    String? description,
    RoutineVisibility? visibility,
    SharedRoutineStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? viewCount,
    int? downloadCount,
    List<String>? tags,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
  }) {
    return SharedRoutine(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      visibility: visibility ?? this.visibility,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewCount: viewCount ?? this.viewCount,
      downloadCount: downloadCount ?? this.downloadCount,
      tags: tags ?? this.tags,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Resultado de compartir una rutina
class ShareResult extends Equatable {
  final bool success;
  final String? shareId;
  final String? shareUrl;
  final String? errorMessage;

  const ShareResult({required this.success, this.shareId, this.shareUrl, this.errorMessage});

  @override
  List<Object?> get props => [success, shareId, shareUrl, errorMessage];

  factory ShareResult.success({required String shareId, required String shareUrl}) {
    return ShareResult(success: true, shareId: shareId, shareUrl: shareUrl);
  }

  factory ShareResult.failure(String errorMessage) {
    return ShareResult(success: false, errorMessage: errorMessage);
  }
}

/// Configuración para compartir una rutina
class ShareConfig extends Equatable {
  final String title;
  final String? description;
  final RoutineVisibility visibility;
  final DateTime? expiresAt;
  final List<String> tags;
  final bool allowDownload;
  final bool allowComments;

  const ShareConfig({
    required this.title,
    this.description,
    this.visibility = RoutineVisibility.public,
    this.expiresAt,
    this.tags = const [],
    this.allowDownload = true,
    this.allowComments = true,
  });

  @override
  List<Object?> get props => [title, description, visibility, expiresAt, tags, allowDownload, allowComments];

  ShareConfig copyWith({
    String? title,
    String? description,
    RoutineVisibility? visibility,
    DateTime? expiresAt,
    List<String>? tags,
    bool? allowDownload,
    bool? allowComments,
  }) {
    return ShareConfig(
      title: title ?? this.title,
      description: description ?? this.description,
      visibility: visibility ?? this.visibility,
      expiresAt: expiresAt ?? this.expiresAt,
      tags: tags ?? this.tags,
      allowDownload: allowDownload ?? this.allowDownload,
      allowComments: allowComments ?? this.allowComments,
    );
  }
}
