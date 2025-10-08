import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/change_history.dart';

/// Servicio para gestionar el historial de cambios
class ChangeHistoryService {
  static const String _boxName = 'change_history';

  Box<ChangeRecord>? _box;

  /// Inicializa el servicio
  Future<void> initialize() async {
    _box ??= await Hive.openBox<ChangeRecord>(_boxName);
  }

  /// Registra un cambio
  Future<void> recordChange(ChangeRecord change) async {
    if (_box == null) await initialize();

    await _box!.put(change.id, change);
  }

  /// Registra un cambio usando el builder
  Future<void> recordChangeWithBuilder(ChangeRecordBuilder builder) async {
    final change = builder.build();
    await recordChange(change);
  }

  /// Obtiene el historial de cambios para una entidad
  Future<List<ChangeRecord>> getEntityHistory(
    EntityType entityType,
    String entityId, {
    int? limit,
  }) async {
    if (_box == null) await initialize();

    final allChanges = _box!.values.toList();
    final entityChanges =
        allChanges
            .where(
              (change) =>
                  change.entityType == entityType &&
                  change.entityId == entityId,
            )
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null && entityChanges.length > limit) {
      return entityChanges.take(limit).toList();
    }

    return entityChanges;
  }

  /// Obtiene el historial de cambios para un usuario
  Future<List<ChangeRecord>> getUserHistory(
    String userId, {
    int? limit,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    if (_box == null) await initialize();

    final allChanges = _box!.values.toList();
    var userChanges =
        allChanges.where((change) => change.userId == userId).toList();

    // Filtrar por rango de fechas si se especifica
    if (fromDate != null) {
      userChanges =
          userChanges
              .where((change) => change.timestamp.isAfter(fromDate))
              .toList();
    }

    if (toDate != null) {
      userChanges =
          userChanges
              .where((change) => change.timestamp.isBefore(toDate))
              .toList();
    }

    userChanges.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null && userChanges.length > limit) {
      return userChanges.take(limit).toList();
    }

    return userChanges;
  }

  /// Obtiene el historial de cambios por tipo
  Future<List<ChangeRecord>> getChangesByType(
    ChangeType changeType, {
    int? limit,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    if (_box == null) await initialize();

    final allChanges = _box!.values.toList();
    var typeChanges =
        allChanges.where((change) => change.changeType == changeType).toList();

    // Filtrar por rango de fechas si se especifica
    if (fromDate != null) {
      typeChanges =
          typeChanges
              .where((change) => change.timestamp.isAfter(fromDate))
              .toList();
    }

    if (toDate != null) {
      typeChanges =
          typeChanges
              .where((change) => change.timestamp.isBefore(toDate))
              .toList();
    }

    typeChanges.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null && typeChanges.length > limit) {
      return typeChanges.take(limit).toList();
    }

    return typeChanges;
  }

  /// Obtiene estadísticas del historial
  Future<Map<String, dynamic>> getHistoryStats({
    String? userId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    if (_box == null) await initialize();

    final allChanges = _box!.values.toList();
    var filteredChanges = allChanges;

    // Filtrar por usuario si se especifica
    if (userId != null) {
      filteredChanges =
          filteredChanges.where((change) => change.userId == userId).toList();
    }

    // Filtrar por rango de fechas si se especifica
    if (fromDate != null) {
      filteredChanges =
          filteredChanges
              .where((change) => change.timestamp.isAfter(fromDate))
              .toList();
    }

    if (toDate != null) {
      filteredChanges =
          filteredChanges
              .where((change) => change.timestamp.isBefore(toDate))
              .toList();
    }

    // Calcular estadísticas
    final stats = <String, dynamic>{
      'totalChanges': filteredChanges.length,
      'changesByType': <String, int>{},
      'changesByEntity': <String, int>{},
      'changesByUser': <String, int>{},
      'recentChanges': <String, dynamic>{},
    };

    // Contar por tipo de cambio
    for (final changeType in ChangeType.values) {
      final count =
          filteredChanges
              .where((change) => change.changeType == changeType)
              .length;
      stats['changesByType'][changeType.name] = count;
    }

    // Contar por tipo de entidad
    for (final entityType in EntityType.values) {
      final count =
          filteredChanges
              .where((change) => change.entityType == entityType)
              .length;
      stats['changesByEntity'][entityType.name] = count;
    }

    // Contar por usuario
    final userCounts = <String, int>{};
    for (final change in filteredChanges) {
      userCounts[change.userId] = (userCounts[change.userId] ?? 0) + 1;
    }
    stats['changesByUser'] = userCounts;

    // Cambios recientes (últimos 7 días)
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentChanges =
        filteredChanges
            .where((change) => change.timestamp.isAfter(sevenDaysAgo))
            .length;
    stats['recentChanges'] = {'count': recentChanges, 'period': '7 days'};

    return stats;
  }

  /// Limpia el historial antiguo
  Future<void> cleanupOldHistory({int daysToKeep = 90}) async {
    if (_box == null) await initialize();

    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    final allChanges = _box!.values.toList();

    final oldChanges =
        allChanges
            .where((change) => change.timestamp.isBefore(cutoffDate))
            .toList();

    for (final change in oldChanges) {
      await _box!.delete(change.id);
    }
  }

  /// Exporta el historial a JSON
  Future<String> exportHistory({
    String? userId,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
  }) async {
    if (_box == null) await initialize();

    final changes = await getUserHistory(
      userId ?? '',
      fromDate: fromDate,
      toDate: toDate,
      limit: limit,
    );

    final exportData = {
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0',
      'totalRecords': changes.length,
      'changes': changes.map((change) => change.toJson()).toList(),
    };

    return jsonEncode(exportData);
  }

  /// Restaura una entidad desde el historial
  Future<Map<String, dynamic>?> restoreEntity(
    String entityId,
    EntityType entityType,
    DateTime restoreToDate,
  ) async {
    if (_box == null) await initialize();

    final entityHistory = await getEntityHistory(entityType, entityId);

    // Encontrar el estado más reciente antes de la fecha de restauración
    final relevantChanges =
        entityHistory
            .where((change) => change.timestamp.isBefore(restoreToDate))
            .toList();

    if (relevantChanges.isEmpty) return null;

    // Buscar el último estado válido
    for (final change in relevantChanges) {
      if (change.changeType == ChangeType.create ||
          change.changeType == ChangeType.update) {
        return change.newData;
      }
    }

    return null;
  }

  /// Obtiene el último cambio para una entidad
  Future<ChangeRecord?> getLastChange(
    String entityId,
    EntityType entityType,
  ) async {
    if (_box == null) await initialize();

    final entityHistory = await getEntityHistory(entityType, entityId);
    return entityHistory.isNotEmpty ? entityHistory.first : null;
  }

  /// Verifica si una entidad ha sido modificada recientemente
  Future<bool> hasRecentChanges(
    String entityId,
    EntityType entityType, {
    Duration? within = const Duration(hours: 24),
  }) async {
    if (_box == null) await initialize();

    final cutoffTime = DateTime.now().subtract(
      within ?? const Duration(hours: 24),
    );
    final entityHistory = await getEntityHistory(entityType, entityId);

    return entityHistory.any((change) => change.timestamp.isAfter(cutoffTime));
  }
}
