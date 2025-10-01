import 'dart:async';

/// MVP: Servicio mínimo para modo offline
/// - Marca operaciones pendientes (cola en memoria)
/// - Expone método para intento de sincronización manual
class OfflineSyncService {
  static OfflineSyncService? _instance;
  static OfflineSyncService get instance => _instance ??= OfflineSyncService._();

  final List<PendingOperation> _queue = [];

  OfflineSyncService._();

  void enqueue(PendingOperation op) {
    _queue.add(op);
  }

  List<PendingOperation> get pending => List.unmodifiable(_queue);

  Future<int> syncNow() async {
    // MVP: simular que se sube todo correctamente y limpiar cola
    final count = _queue.length;
    _queue.clear();
    return count;
  }
}

class PendingOperation {
  final String id;
  final String type; // e.g., 'create_session', 'update_routine'
  final Map<String, dynamic> payload;

  const PendingOperation({
    required this.id,
    required this.type,
    required this.payload,
  });
}


