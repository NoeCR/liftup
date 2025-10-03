import 'package:hive_flutter/hive_flutter.dart';
import 'package:liftup/core/database/database_service.dart';
import 'dart:io';

/// TestDatabaseService que proporciona una implementación real pero aislada
/// para tests, usando directorios temporales
class TestDatabaseService {
  static TestDatabaseService? _instance;
  static Directory? _tempDir;
  bool _isInitialized = false;

  TestDatabaseService._();

  static TestDatabaseService getInstance() {
    _instance ??= TestDatabaseService._();
    return _instance!;
  }

  Future<void> initialize() async {
    if (!_isInitialized) {
      // Crear directorio temporal para este test
      _tempDir = Directory.systemTemp.createTempSync(
        'liftup_test_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Inicializar Hive en el directorio temporal
      Hive.init(_tempDir!.path);

      // Abrir todas las cajas
      await _initializeHive();
      _isInitialized = true;
    }
  }

  Future<void> _initializeHive() async {
    try {
      // Open all boxes
      await Future.wait([
        Hive.openBox('exercises'),
        Hive.openBox('routines'),
        Hive.openBox('sessions'),
        Hive.openBox('progress'),
        Hive.openBox('settings'),
        Hive.openBox('routine_section_templates'),
      ]);
    } catch (e) {
      // Si hay error, limpiar y reintentar
      await _clearAllBoxes();
      await Future.wait([
        Hive.openBox('exercises'),
        Hive.openBox('routines'),
        Hive.openBox('sessions'),
        Hive.openBox('progress'),
        Hive.openBox('settings'),
        Hive.openBox('routine_section_templates'),
      ]);
    }
  }

  Future<void> _clearAllBoxes() async {
    final boxes = [
      'exercises',
      'routines',
      'sessions',
      'progress',
      'settings',
      'routine_section_templates',
    ];

    for (final boxName in boxes) {
      try {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).clear();
        }
      } catch (e) {
        // Box might not exist, continue with others
      }
    }
  }

  Future<void> close() async {
    if (_isInitialized) {
      await Hive.close();
      _isInitialized = false;
    }
  }

  Future<void> clearAllData() async {
    if (_isInitialized) {
      await _clearAllBoxes();
    }
  }

  // Getters para acceder a las cajas
  Box get exercisesBox {
    if (!_isInitialized) {
      throw Exception('TestDatabaseService not initialized');
    }
    return Hive.box('exercises');
  }

  Box get routinesBox {
    if (!_isInitialized) {
      throw Exception('TestDatabaseService not initialized');
    }
    return Hive.box('routines');
  }

  Box get sessionsBox {
    if (!_isInitialized) {
      throw Exception('TestDatabaseService not initialized');
    }
    return Hive.box('sessions');
  }

  Box get progressBox {
    if (!_isInitialized) {
      throw Exception('TestDatabaseService not initialized');
    }
    return Hive.box('progress');
  }

  Box get settingsBox {
    if (!_isInitialized) {
      throw Exception('TestDatabaseService not initialized');
    }
    return Hive.box('settings');
  }

  Box get routineSectionTemplatesBox {
    if (!_isInitialized) {
      throw Exception('TestDatabaseService not initialized');
    }
    return Hive.box('routine_section_templates');
  }

  /// Limpiar el directorio temporal
  static void cleanup() {
    if (_tempDir != null && _tempDir!.existsSync()) {
      try {
        _tempDir!.deleteSync(recursive: true);
      } catch (e) {
        // Ignorar errores de limpieza
      }
      _tempDir = null;
    }
    _instance = null;
  }
}
