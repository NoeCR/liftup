import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static const String _exercisesBox = 'exercises';
  static const String _routinesBox = 'routines';
  static const String _sessionsBox = 'sessions';
  static const String _progressBox = 'progress';
  static const String _settingsBox = 'settings';
  static const String _routineSectionTemplatesBox = 'routine_section_templates';

  bool _isInitialized = false;

  // Private constructor to prevent instantiation
  DatabaseService._();

  // Static method to get the singleton instance
  static DatabaseService getInstance() {
    if (_instance == null) {
      _instance = DatabaseService._();
    }
    return _instance!;
  }

  // Initialize the database service
  Future<void> initialize() async {
    if (!_isInitialized) {
      await _initializeHive();
      _isInitialized = true;
    }
  }

  Future<void> _initializeHive() async {
    try {
      // Open all boxes (Hive and adapters already initialized in main.dart)
      await Future.wait([
        Hive.openBox(_exercisesBox),
        Hive.openBox(_routinesBox),
        Hive.openBox(_sessionsBox),
        Hive.openBox(_progressBox),
        Hive.openBox(_settingsBox),
        Hive.openBox(_routineSectionTemplatesBox),
      ]);

      // Verify all boxes are open and accessible
      print('DatabaseService: All boxes initialized successfully');
    } catch (e) {
      print('Error opening boxes: $e');
      // If there's an error, clear all data and try again
      await _clearAllBoxes();
      await Future.wait([
        Hive.openBox(_exercisesBox),
        Hive.openBox(_routinesBox),
        Hive.openBox(_sessionsBox),
        Hive.openBox(_progressBox),
        Hive.openBox(_settingsBox),
        Hive.openBox(_routineSectionTemplatesBox),
      ]);
    }
  }

  Future<void> _clearAllBoxes() async {
    try {
      // Try to clear each box if it exists
      final boxes = [
        _exercisesBox,
        _routinesBox,
        _sessionsBox,
        _progressBox,
        _settingsBox,
        _routineSectionTemplatesBox,
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
    } catch (e) {
      print('Error clearing boxes: $e');
    }
  }

  Box get exercisesBox {
    if (!_isInitialized) {
      throw Exception('DatabaseService not initialized');
    }
    return Hive.box(_exercisesBox);
  }

  Box get routinesBox {
    if (!_isInitialized) {
      throw Exception('DatabaseService not initialized');
    }
    return Hive.box(_routinesBox);
  }

  Box get sessionsBox {
    if (!_isInitialized) {
      throw Exception('DatabaseService not initialized');
    }
    return Hive.box(_sessionsBox);
  }

  Box get progressBox {
    if (!_isInitialized) {
      throw Exception('DatabaseService not initialized');
    }
    return Hive.box(_progressBox);
  }

  Box get settingsBox {
    if (!_isInitialized) {
      throw Exception('DatabaseService not initialized');
    }
    return Hive.box(_settingsBox);
  }

  Box get routineSectionTemplatesBox {
    if (!_isInitialized) {
      throw Exception('DatabaseService not initialized');
    }
    return Hive.box(_routineSectionTemplatesBox);
  }

  Future<void> clearAllData() async {
    await Future.wait([
      exercisesBox.clear(),
      routinesBox.clear(),
      sessionsBox.clear(),
      progressBox.clear(),
      settingsBox.clear(),
      routineSectionTemplatesBox.clear(),
    ]);
  }

  Future<void> forceResetDatabase() async {
    try {
      // Close all boxes if they exist
      try {
        await Hive.close();
      } catch (e) {
        print('Error closing Hive: $e');
      }

      // Note: Adapters are registered once in main.dart, no need to reset

      // Delete all box files directly from disk
      final boxes = [
        _exercisesBox,
        _routinesBox,
        _sessionsBox,
        _progressBox,
        _settingsBox,
        _routineSectionTemplatesBox,
      ];

      final directory = await getApplicationDocumentsDirectory();

      for (final boxName in boxes) {
        try {
          final boxFile = File('${directory.path}/$boxName.hive');
          final lockFile = File('${directory.path}/$boxName.lock');

          if (await boxFile.exists()) {
            await boxFile.delete();
          }
          if (await lockFile.exists()) {
            await lockFile.delete();
          }
        } catch (e) {
          // Continue with other boxes if one fails
        }
      }

      // Reinitialize Hive
      await _initializeHive();
      print('Database reset and initialized successfully');
    } catch (e) {
      print('Error resetting database: $e');
      // Try to initialize normally as fallback
      try {
        await _initializeHive();
        print('Fallback initialization successful');
      } catch (fallbackError) {
        print('Fallback initialization failed: $fallbackError');
        rethrow;
      }
    }
  }

  Future<void> close() async {
    await Hive.close();
  }
}
