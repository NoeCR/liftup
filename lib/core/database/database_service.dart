import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'hive_adapters.dart';

part 'database_service.g.dart';

@riverpod
class DatabaseService extends _$DatabaseService {
  static const String _exercisesBox = 'exercises';
  static const String _routinesBox = 'routines';
  static const String _sessionsBox = 'sessions';
  static const String _progressBox = 'progress';
  static const String _settingsBox = 'settings';
  static const String _routineSectionTemplatesBox = 'routine_section_templates';

  @override
  Future<void> build() async {
    await _initializeHive();
  }

  Future<void> _initializeHive() async {
    await Hive.initFlutter();
    HiveAdapters.registerAdapters();

    try {
      // Open all boxes
      await Future.wait([
        Hive.openBox(_exercisesBox),
        Hive.openBox(_routinesBox),
        Hive.openBox(_sessionsBox),
        Hive.openBox(_progressBox),
        Hive.openBox(_settingsBox),
        Hive.openBox(_routineSectionTemplatesBox),
      ]);
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
          print('Error clearing box $boxName: $e');
        }
      }
    } catch (e) {
      print('Error clearing boxes: $e');
    }
  }

  Box get exercisesBox => Hive.box(_exercisesBox);
  Box get routinesBox => Hive.box(_routinesBox);
  Box get sessionsBox => Hive.box(_sessionsBox);
  Box get progressBox => Hive.box(_progressBox);
  Box get settingsBox => Hive.box(_settingsBox);
  Box get routineSectionTemplatesBox => Hive.box(_routineSectionTemplatesBox);

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
      // Close all boxes
      await Hive.close();
      
      // Delete all box files
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
          final boxFile = await Hive.openBox(boxName);
          await boxFile.deleteFromDisk();
        } catch (e) {
          print('Error deleting box $boxName: $e');
        }
      }
      
      // Reinitialize
      await _initializeHive();
    } catch (e) {
      print('Error resetting database: $e');
    }
  }

  Future<void> close() async {
    await Hive.close();
  }
}
