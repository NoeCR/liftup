import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../logging/logging.dart';
import 'i_database_service.dart';
import '../../features/progression/models/progression_config.dart';
import '../../features/progression/models/progression_state.dart';
import '../../features/progression/models/progression_template.dart';

class DatabaseService implements IDatabaseService {
  static DatabaseService? _instance;
  static const String _exercisesBox = 'exercises';
  static const String _routinesBox = 'routines';
  static const String _sessionsBox = 'sessions';
  static const String _progressBox = 'progress';
  static const String _settingsBox = 'settings';
  static const String _routineSectionTemplatesBox = 'routine_section_templates';
  static const String _progressionConfigsBox = 'progression_configs';
  static const String _progressionStatesBox = 'progression_states';
  static const String _progressionTemplatesBox = 'progression_templates';

  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  // Private constructor to prevent instantiation
  DatabaseService._();

  // Static method to get the singleton instance
  static DatabaseService getInstance() {
    return _instance ??= DatabaseService._();
  }

  // Initialize the database service
  @override
  Future<void> initialize() async {
    if (!_isInitialized) {
      return await PerformanceMonitor.instance.monitorAsync('database_initialize', () async {
        LoggingService.instance.info('Initializing DatabaseService');
        await _initializeHive();
        _isInitialized = true;
        LoggingService.instance.info('DatabaseService initialized successfully');

        // Record successful initialization metric
        SentryMetricsConfig.trackDatabaseOperation(
          operation: 'initialize',
          durationMs: 0, // Will be computed automatically by PerformanceMonitor
          success: true,
        );
      }, context: {'component': 'database_service'});
    }
  }

  Future<void> _initializeHive() async {
    try {
      LoggingService.instance.debug('Opening Hive boxes', {
        'boxes': [
          _exercisesBox,
          _routinesBox,
          _sessionsBox,
          _progressBox,
          _settingsBox,
          _routineSectionTemplatesBox,
          _progressionConfigsBox,
          _progressionStatesBox,
          _progressionTemplatesBox,
        ],
      });

      // List of all box names
      final boxNames = [
        _exercisesBox,
        _routinesBox,
        _sessionsBox,
        _progressBox,
        _settingsBox,
        _routineSectionTemplatesBox,
        _progressionConfigsBox,
        _progressionStatesBox,
        _progressionTemplatesBox,
      ];

      // Open boxes that are not already open with correct types
      final openPromises = <Future>[];
      for (final boxName in boxNames) {
        if (!Hive.isBoxOpen(boxName)) {
          Future<Box> openPromise;
          switch (boxName) {
            case _progressionConfigsBox:
              openPromise = Hive.openBox<ProgressionConfig>(boxName);
              break;
            case _progressionStatesBox:
              openPromise = Hive.openBox<ProgressionState>(boxName);
              break;
            case _progressionTemplatesBox:
              openPromise = Hive.openBox<ProgressionTemplate>(boxName);
              break;
            default:
              openPromise = Hive.openBox(boxName);
              break;
          }
          openPromises.add(openPromise);
          LoggingService.instance.debug('Opening box: $boxName');
        } else {
          LoggingService.instance.debug('Box already open: $boxName');
        }
      }

      // Wait for all boxes to be opened
      if (openPromises.isNotEmpty) {
        await Future.wait(openPromises);
      }

      // Verify all boxes are open and accessible
      LoggingService.instance.info('All Hive boxes initialized successfully');
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error opening Hive boxes', e, stackTrace, {'component': 'hive_initialization'});

      // If there's an error, clear all data and try again
      LoggingService.instance.warning('Attempting to clear and reinitialize boxes');
      await _clearAllBoxes();

      try {
        // List of all box names
        final boxNames = [
          _exercisesBox,
          _routinesBox,
          _sessionsBox,
          _progressBox,
          _settingsBox,
          _routineSectionTemplatesBox,
          _progressionConfigsBox,
          _progressionStatesBox,
          _progressionTemplatesBox,
        ];

        // Open boxes that are not already open with correct types
        final openPromises = <Future>[];
        for (final boxName in boxNames) {
          if (!Hive.isBoxOpen(boxName)) {
            Future<Box> openPromise;
            switch (boxName) {
              case _progressionConfigsBox:
                openPromise = Hive.openBox<ProgressionConfig>(boxName);
                break;
              case _progressionStatesBox:
                openPromise = Hive.openBox<ProgressionState>(boxName);
                break;
              case _progressionTemplatesBox:
                openPromise = Hive.openBox<ProgressionTemplate>(boxName);
                break;
              default:
                openPromise = Hive.openBox(boxName);
                break;
            }
            openPromises.add(openPromise);
            LoggingService.instance.debug('Retry opening box: $boxName');
          } else {
            LoggingService.instance.debug('Box already open during retry: $boxName');
          }
        }

        // Wait for all boxes to be opened
        if (openPromises.isNotEmpty) {
          await Future.wait(openPromises);
        }
        LoggingService.instance.info('Hive boxes reinitialized successfully after clear');
      } catch (retryError, retryStackTrace) {
        LoggingService.instance.fatal('Failed to reinitialize Hive boxes after clear', retryError, retryStackTrace, {
          'component': 'hive_retry_initialization',
        });
        rethrow;
      }
    }
  }

  Future<void> _clearAllBoxes() async {
    try {
      LoggingService.instance.debug('Clearing all Hive boxes');

      // Try to clear each box if it exists
      final boxes = [
        _exercisesBox,
        _routinesBox,
        _sessionsBox,
        _progressBox,
        _settingsBox,
        _routineSectionTemplatesBox,
        _progressionConfigsBox,
        _progressionStatesBox,
        _progressionTemplatesBox,
      ];

      for (final boxName in boxes) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            await Hive.box(boxName).clear();
            LoggingService.instance.debug('Cleared box: $boxName');
          }
        } catch (e) {
          LoggingService.instance.warning('Failed to clear box: $boxName', {'error': e.toString()});
          // Box might not exist, continue with others
        }
      }

      LoggingService.instance.info('All boxes cleared successfully');
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error clearing boxes', e, stackTrace, {'component': 'clear_boxes'});
    }
  }

  Box get exercisesBox {
    if (!_isInitialized) {
      LoggingService.instance.error('DatabaseService not initialized when accessing exercisesBox');
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

  @override
  Box<ProgressionConfig> get progressionConfigsBox {
    if (!_isInitialized) {
      throw Exception('DatabaseService not initialized');
    }
    try {
      return Hive.box<ProgressionConfig>(_progressionConfigsBox);
    } catch (e) {
      LoggingService.instance.warning('Box type conflict detected, attempting to resolve', {
        'boxName': _progressionConfigsBox,
        'error': e.toString(),
      });
      // Force close and reopen the box with correct type
      if (Hive.isBoxOpen(_progressionConfigsBox)) {
        Hive.box(_progressionConfigsBox).close();
      }
      return Hive.box<ProgressionConfig>(_progressionConfigsBox);
    }
  }

  @override
  Box<ProgressionState> get progressionStatesBox {
    if (!_isInitialized) {
      throw Exception('DatabaseService not initialized');
    }
    try {
      return Hive.box<ProgressionState>(_progressionStatesBox);
    } catch (e) {
      LoggingService.instance.warning('Box type conflict detected, attempting to resolve', {
        'boxName': _progressionStatesBox,
        'error': e.toString(),
      });
      // Force close and reopen the box with correct type
      if (Hive.isBoxOpen(_progressionStatesBox)) {
        Hive.box(_progressionStatesBox).close();
      }
      return Hive.box<ProgressionState>(_progressionStatesBox);
    }
  }

  @override
  Box<ProgressionTemplate> get progressionTemplatesBox {
    if (!_isInitialized) {
      throw Exception('DatabaseService not initialized');
    }
    try {
      return Hive.box<ProgressionTemplate>(_progressionTemplatesBox);
    } catch (e) {
      LoggingService.instance.warning('Box type conflict detected, attempting to resolve', {
        'boxName': _progressionTemplatesBox,
        'error': e.toString(),
      });
      // Force close and reopen the box with correct type
      if (Hive.isBoxOpen(_progressionTemplatesBox)) {
        Hive.box(_progressionTemplatesBox).close();
      }
      return Hive.box<ProgressionTemplate>(_progressionTemplatesBox);
    }
  }

  Future<void> clearAllData() async {
    try {
      LoggingService.instance.info('Clearing all application data');

      await Future.wait([
        exercisesBox.clear(),
        routinesBox.clear(),
        sessionsBox.clear(),
        progressBox.clear(),
        settingsBox.clear(),
        routineSectionTemplatesBox.clear(),
        progressionConfigsBox.clear(),
        progressionStatesBox.clear(),
        progressionTemplatesBox.clear(),
      ]);

      LoggingService.instance.info('All application data cleared successfully');
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error clearing all data', e, stackTrace, {'component': 'clear_all_data'});
      rethrow;
    }
  }

  Future<void> forceResetDatabase() async {
    try {
      LoggingService.instance.warning('Force resetting database - this will delete all data');

      // Close all boxes if they exist
      try {
        await Hive.close();
        LoggingService.instance.debug('Hive closed successfully');
      } catch (e) {
        LoggingService.instance.warning('Error closing Hive: $e');
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
        _progressionConfigsBox,
        _progressionStatesBox,
        _progressionTemplatesBox,
      ];

      final directory = await getApplicationDocumentsDirectory();
      LoggingService.instance.debug('Deleting database files from: ${directory.path}');

      for (final boxName in boxes) {
        try {
          final boxFile = File('${directory.path}/$boxName.hive');
          final lockFile = File('${directory.path}/$boxName.lock');

          if (await boxFile.exists()) {
            await boxFile.delete();
            LoggingService.instance.debug('Deleted file: ${boxFile.path}');
          }
          if (await lockFile.exists()) {
            await lockFile.delete();
            LoggingService.instance.debug('Deleted file: ${lockFile.path}');
          }
        } catch (e) {
          LoggingService.instance.warning('Failed to delete files for box: $boxName', {'error': e.toString()});
          // Continue with other boxes if one fails
        }
      }

      // Reinitialize Hive
      await _initializeHive();
      LoggingService.instance.info('Database reset and initialized successfully');
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error resetting database', e, stackTrace, {'component': 'force_reset_database'});

      // Try to initialize normally as fallback
      try {
        await _initializeHive();
        LoggingService.instance.info('Fallback initialization successful');
      } catch (fallbackError, fallbackStackTrace) {
        LoggingService.instance.fatal('Fallback initialization failed', fallbackError, fallbackStackTrace, {
          'component': 'fallback_initialization',
        });
        rethrow;
      }
    }
  }

  @override
  Future<void> close() async {
    try {
      LoggingService.instance.info('Closing DatabaseService');
      await Hive.close();
      LoggingService.instance.info('DatabaseService closed successfully');
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error closing DatabaseService', e, stackTrace, {'component': 'close_database'});
      rethrow;
    }
  }
}
