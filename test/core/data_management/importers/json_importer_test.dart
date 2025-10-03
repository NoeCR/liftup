import 'package:flutter_test/flutter_test.dart';
import 'package:liftup/core/data_management/importers/json_importer.dart';
import 'package:liftup/core/data_management/models/import_config.dart';
import 'package:liftup/core/data_management/models/export_type.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  group('JsonImporter Tests', () {
    late JsonImporter jsonImporter;

    setUp(() {
      final config = ImportConfig(
        mergeData: true,
        overwriteExisting: true,
        validateData: true,
        createBackup: true,
        allowedTypes: [ExportType.json],
        maxFileSize: 10 * 1024 * 1024,
      );

      jsonImporter = JsonImporter(
        config: config,
        existingSessions: const [],
        existingExercises: const [],
        existingRoutines: const [],
        existingProgressData: const [],
      );
    });

    group('Initialization', () {
      test('should initialize JSON importer correctly', () {
        expect(jsonImporter, isNotNull);
      });
    });

    group('JSON Import', () {
      test('should import JSON data successfully', () async {
        // Create test JSON data
        final testData = {
          'sessions': [
            {
              'id': 'session_1',
              'routineId': 'routine_1',
              'startTime': DateTime.now().toIso8601String(),
              'endTime': DateTime.now().toIso8601String(),
              'exercises': [],
              'notes': 'Test session',
            },
          ],
          'exercises': [
            {
              'id': 'exercise_1',
              'name': 'Push-ups',
              'description': 'Bodyweight exercise',
              'muscleGroups': ['chest', 'triceps'],
              'category': 'calisthenics',
              'difficulty': 'beginner',
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
          ],
          'routines': [
            {
              'id': 'routine_1',
              'name': 'Full Body',
              'description': 'Full body workout',
              'days': ['monday', 'wednesday', 'friday'],
              'sections': [],
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
          ],
          'progressData': [
            {
              'id': 'progress_1',
              'exerciseId': 'exercise_1',
              'date': DateTime.now().toIso8601String(),
              'weight': 0,
              'reps': 10,
              'sets': 3,
              'notes': 'Test progress',
            },
          ],
        };

        // Create temporary file with valid JSON
        final tempFile = File('test_import.json');
        await tempFile.writeAsString(jsonEncode(testData));

        final config = ImportConfig(
          mergeData: true,
          overwriteExisting: true,
          validateData: true,
          createBackup: true,
          allowedTypes: [ExportType.json],
          maxFileSize: 10 * 1024 * 1024,
        );

        try {
          final result = await jsonImporter.import(tempFile.path);

          expect(result.success, equals(true));
          expect(result.importedSessions.length, equals(1));
          expect(result.importedExercises.length, equals(1));
          expect(result.importedRoutines.length, equals(1));
          expect(result.importedProgressData.length, equals(1));
        } finally {
          // Clean up
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        }
      });

      test('should handle invalid JSON format', () async {
        final invalidJsonData = '{"invalid_json": "data"';
        final tempFile = File('invalid_import.json');
        await tempFile.writeAsString(invalidJsonData);

        final config = ImportConfig(
          allowedTypes: [ExportType.json],
          mergeData: true,
          overwriteExisting: true,
        );

        try {
          final result = await jsonImporter.import(tempFile.path);

          expect(result.success, equals(false));
          expect(result.errorMessage, isNotNull);
        } finally {
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        }
      });

      test('should handle empty JSON file', () async {
        final emptyFile = File('empty_import.json');
        await emptyFile.writeAsString('');

        final config = ImportConfig(
          allowedTypes: [ExportType.json],
          mergeData: true,
          overwriteExisting: true,
        );

        try {
          final result = await jsonImporter.import(emptyFile.path);

          expect(result.success, equals(false));
          expect(result.errorMessage, isNotNull);
        } finally {
          if (await emptyFile.exists()) {
            await emptyFile.delete();
          }
        }
      });

      test('should handle JSON with missing required fields', () async {
        final testData = {
          'exercises': [
            {
              'id': 'exercise_1',
              // Missing name field
              'description': 'Description',
              'muscleGroups': ['chest'],
              'category': 'strength',
              'difficulty': 'beginner',
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
          ],
        };

        final tempFile = File('missing_fields_import.json');
        await tempFile.writeAsString(jsonEncode(testData));

        final config = ImportConfig(
          allowedTypes: [ExportType.json],
          mergeData: true,
          overwriteExisting: true,
          validateData: true,
        );

        try {
          final result = await jsonImporter.import(tempFile.path);

          expect(result.success, equals(false));
          expect(result.errorMessage, isNotNull);
          expect(result.errors, isNotEmpty);
        } finally {
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        }
      });
    });

    group('Data Validation', () {
      test('should validate exercise data', () async {
        final testData = {
          'exercises': [
            {
              'id': 'exercise_1',
              'name': 'Valid Exercise',
              'description': 'Description',
              'muscleGroups': ['chest'],
              'category': 'strength',
              'difficulty': 'intermediate',
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
            {
              'id': 'exercise_2',
              'name': null, // Invalid name
              'description': 'Description',
              'muscleGroups': ['back'],
              'category': 'strength',
              'difficulty': 'beginner',
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
          ],
        };

        final tempFile = File('exercise_validation_test.json');
        await tempFile.writeAsString(jsonEncode(testData));

        final config = ImportConfig(
          allowedTypes: [ExportType.json],
          mergeData: true,
          overwriteExisting: true,
          validateData: true,
        );

        try {
          final result = await jsonImporter.import(tempFile.path);

          expect(result.success, equals(false));
          expect(result.errorMessage, isNotNull);
          expect(result.errors, isNotEmpty);
        } finally {
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        }
      });

      test('should validate routine data', () async {
        final testData = {
          'routines': [
            {
              'id': 'routine_1',
              'name': 'Valid Routine',
              'description': 'Description',
              'days': ['monday'],
              'sections': [],
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
            {
              'id': 'routine_2',
              'name': 'Invalid Routine',
              'description': null, // Invalid description
              'days': ['tuesday'],
              'sections': [],
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
          ],
        };

        final tempFile = File('routine_validation_test.json');
        await tempFile.writeAsString(jsonEncode(testData));

        final config = ImportConfig(
          allowedTypes: [ExportType.json],
          mergeData: true,
          overwriteExisting: true,
          validateData: true,
        );

        try {
          final result = await jsonImporter.import(tempFile.path);

          expect(result.success, equals(false));
          expect(result.errorMessage, isNotNull);
          expect(result.errors, isNotEmpty);
        } finally {
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        }
      });

      test('should validate session data', () async {
        final testData = {
          'sessions': [
            {
              'id': 'session_1',
              'routineId': 'routine_1',
              'startTime': DateTime.now().toIso8601String(),
              'endTime': DateTime.now().toIso8601String(),
              'exercises': [],
              'notes': 'Valid session',
            },
            {
              'id': 'session_2',
              'routineId': null, // Invalid routine ID
              'startTime': DateTime.now().toIso8601String(),
              'endTime': DateTime.now().toIso8601String(),
              'exercises': [],
              'notes': 'Invalid session',
            },
          ],
        };

        final tempFile = File('session_validation_test.json');
        await tempFile.writeAsString(testData.toString());

        final config = ImportConfig(
          allowedTypes: [ExportType.json],
          mergeData: true,
          overwriteExisting: true,
          validateData: true,
        );

        try {
          final result = await jsonImporter.import(tempFile.path);

          expect(result.success, equals(false));
          expect(result.errorMessage, isNotNull);
          expect(result.errors, isNotEmpty);
        } finally {
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        }
      });
    });

    group('File Handling', () {
      test('should handle non-existent file', () async {
        final config = ImportConfig(
          allowedTypes: [ExportType.json],
          mergeData: true,
          overwriteExisting: true,
        );

        final result = await jsonImporter.import('non_existent_file.json');

        expect(result.success, equals(false));
        expect(result.errorMessage, isNotNull);
      });

      test('should handle file size limits', () async {
        // Create a large JSON file
        final largeJsonData = {
          'exercises': List.generate(
            10000,
            (i) => {
              'id': 'exercise_$i',
              'name': 'Exercise $i',
              'description': 'Description $i',
              'muscleGroups': ['chest'],
              'category': 'strength',
              'difficulty': 'beginner',
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
          ),
        };

        final tempFile = File('large_import.json');
        await tempFile.writeAsString(jsonEncode(largeJsonData));

        final config = ImportConfig(
          allowedTypes: [ExportType.json],
          mergeData: true,
          overwriteExisting: true,
          maxFileSize: 1024, // 1KB limit
        );

        try {
          final result = await jsonImporter.import(tempFile.path);

          expect(result.success, equals(false));
          expect(result.errorMessage, isNotNull);
        } finally {
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        }
      });
    });

    group('Import Statistics', () {
      test('should track import statistics correctly', () async {
        final testData = {
          'sessions': List.generate(
            3,
            (i) => {
              'id': 'session_$i',
              'routineId': 'routine_1',
              'startTime': DateTime.now().toIso8601String(),
              'endTime': DateTime.now().toIso8601String(),
              'exercises': [],
            },
          ),
          'exercises': List.generate(
            5,
            (i) => {
              'id': 'exercise_$i',
              'name': 'Exercise $i',
              'description': 'Description $i',
              'muscleGroups': ['pectoralMajor'],
              'category': 'chest',
              'difficulty': 'beginner',
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
          ),
          'routines': List.generate(
            2,
            (i) => {
              'id': 'routine_$i',
              'name': 'Routine $i',
              'description': 'Description $i',
              'days': ['monday'],
              'sections': [],
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
          ),
        };

        final tempFile = File('statistics_test.json');
        await tempFile.writeAsString(jsonEncode(testData));

        final config = ImportConfig(
          allowedTypes: [ExportType.json],
          mergeData: true,
          overwriteExisting: true,
        );

        try {
          final result = await jsonImporter.import(tempFile.path);

          expect(result.success, equals(true));
          expect(result.importedSessions.length, equals(3));
          expect(result.importedExercises.length, equals(5));
          expect(result.importedRoutines.length, equals(2));
          expect(result.importedCount, equals(10));
          expect(result.skippedCount, equals(0));
          expect(result.errorCount, equals(0));
        } finally {
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        }
      });
    });

    group('Error Handling', () {
      test('should handle file read errors', () async {
        final config = ImportConfig(
          allowedTypes: [ExportType.json],
          mergeData: true,
          overwriteExisting: true,
        );

        // Try to read a directory instead of a file
        final result = await jsonImporter.import('.');

        expect(result.success, equals(false));
        expect(result.errorMessage, isNotNull);
      });

      test('should handle unsupported file type', () async {
        final config = ImportConfig(
          allowedTypes: [ExportType.csv], // Only CSV allowed
          mergeData: true,
          overwriteExisting: true,
        );

        final jsonData = '{"test": "data"}';
        final tempFile = File('unsupported_type.json');
        await tempFile.writeAsString(jsonData);

        try {
          final result = await jsonImporter.import(tempFile.path);

          expect(result.success, equals(false));
          expect(result.errorMessage, isNotNull);
        } finally {
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        }
      });
    });
  });
}
