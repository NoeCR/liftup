import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Tipo de cambio realizado
enum ChangeType { create, update, delete, restore }

/// Entidad que fue modificada
enum EntityType { routine, exercise, session, progressData, userSettings }

/// Historial de cambios en las entidades
class ChangeRecord extends Equatable {
  final String id;
  final EntityType entityType;
  final String entityId;
  final ChangeType changeType;
  final DateTime timestamp;
  final String userId;
  final Map<String, dynamic>? previousData;
  final Map<String, dynamic>? newData;
  final String? description;
  final String? reason;

  const ChangeRecord({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.changeType,
    required this.timestamp,
    required this.userId,
    this.previousData,
    this.newData,
    this.description,
    this.reason,
  });

  @override
  List<Object?> get props => [
    id,
    entityType,
    entityId,
    changeType,
    timestamp,
    userId,
    previousData,
    newData,
    description,
    reason,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType.name,
      'entityId': entityId,
      'changeType': changeType.name,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'previousData': previousData,
      'newData': newData,
      'description': description,
      'reason': reason,
    };
  }

  factory ChangeRecord.fromJson(Map<String, dynamic> json) {
    return ChangeRecord(
      id: json['id'] as String,
      entityType: EntityType.values.firstWhere((e) => e.name == json['entityType']),
      entityId: json['entityId'] as String,
      changeType: ChangeType.values.firstWhere((e) => e.name == json['changeType']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String,
      previousData: json['previousData'] as Map<String, dynamic>?,
      newData: json['newData'] as Map<String, dynamic>?,
      description: json['description'] as String?,
      reason: json['reason'] as String?,
    );
  }

  ChangeRecord copyWith({
    String? id,
    EntityType? entityType,
    String? entityId,
    ChangeType? changeType,
    DateTime? timestamp,
    String? userId,
    Map<String, dynamic>? previousData,
    Map<String, dynamic>? newData,
    String? description,
    String? reason,
  }) {
    return ChangeRecord(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      changeType: changeType ?? this.changeType,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      previousData: previousData ?? this.previousData,
      newData: newData ?? this.newData,
      description: description ?? this.description,
      reason: reason ?? this.reason,
    );
  }
}

/// Builder para crear registros de cambio
class ChangeRecordBuilder {
  String? _id;
  EntityType? _entityType;
  String? _entityId;
  ChangeType? _changeType;
  DateTime? _timestamp;
  String? _userId;
  Map<String, dynamic>? _previousData;
  Map<String, dynamic>? _newData;
  String? _description;
  String? _reason;

  ChangeRecordBuilder();

  ChangeRecordBuilder setId(String id) {
    _id = id;
    return this;
  }

  ChangeRecordBuilder setEntityType(EntityType entityType) {
    _entityType = entityType;
    return this;
  }

  ChangeRecordBuilder setEntityId(String entityId) {
    _entityId = entityId;
    return this;
  }

  ChangeRecordBuilder setChangeType(ChangeType changeType) {
    _changeType = changeType;
    return this;
  }

  ChangeRecordBuilder setTimestamp(DateTime timestamp) {
    _timestamp = timestamp;
    return this;
  }

  ChangeRecordBuilder setUserId(String userId) {
    _userId = userId;
    return this;
  }

  ChangeRecordBuilder setPreviousData(Map<String, dynamic>? previousData) {
    _previousData = previousData;
    return this;
  }

  ChangeRecordBuilder setNewData(Map<String, dynamic>? newData) {
    _newData = newData;
    return this;
  }

  ChangeRecordBuilder setDescription(String? description) {
    _description = description;
    return this;
  }

  ChangeRecordBuilder setReason(String? reason) {
    _reason = reason;
    return this;
  }

  ChangeRecord build() {
    return ChangeRecord(
      id: _id ?? const Uuid().v4(),
      entityType: _entityType!,
      entityId: _entityId!,
      changeType: _changeType!,
      timestamp: _timestamp ?? DateTime.now(),
      userId: _userId!,
      previousData: _previousData,
      newData: _newData,
      description: _description,
      reason: _reason,
    );
  }
}
