import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Configuración para las pruebas de progresión
class ProgressionTestConfig {
  static late String testDir;
  static late Box<dynamic> testBox;

  /// Inicializa el entorno de pruebas
  static Future<void> setUp() async {
    // Inicializar el binding de Flutter para tests
    TestWidgetsFlutterBinding.ensureInitialized();

    // Crear directorio temporal para las pruebas usando el directorio temporal del sistema
    final tempDir = Directory.systemTemp;
    testDir = '${tempDir.path}/progression_tests_${DateTime.now().millisecondsSinceEpoch}';

    // Crear directorio si no existe
    final dir = Directory(testDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Inicializar Hive para pruebas
    Hive.init(testDir);

    // Registrar adaptadores de prueba
    _registerTestAdapters();
  }

  /// Limpia el entorno de pruebas
  static Future<void> tearDown() async {
    try {
      // Cerrar todas las cajas
      await Hive.close();

      // Eliminar directorio temporal solo si se inicializó
      if (testDir.isNotEmpty) {
        final dir = Directory(testDir);
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      }
    } catch (e) {
      // Ignorar errores durante la limpieza
      print('Warning: Error during test cleanup: $e');
    }
  }

  /// Registra los adaptadores necesarios para las pruebas
  static void _registerTestAdapters() {
    // Aquí se registrarían los adaptadores de Hive para los modelos de progresión
    // Por ahora, usamos adaptadores genéricos para las pruebas
  }

  /// Crea una caja de prueba
  static Future<Box<T>> createTestBox<T>(String name) async {
    return await Hive.openBox<T>(name);
  }

  /// Limpia una caja de prueba
  static Future<void> clearTestBox<T>(Box<T> box) async {
    await box.clear();
  }

  /// Cierra una caja de prueba
  static Future<void> closeTestBox<T>(Box<T> box) async {
    await box.close();
  }
}

/// Configuración específica para pruebas de widgets
class WidgetTestConfig {
  /// Configuración básica para pruebas de widgets
  static Widget createTestApp({
    required Widget child,
    List<Locale> supportedLocales = const [Locale('es', ''), Locale('en', '')],
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        // Using easy_localization instead of custom AppLocalizations
      ],
      supportedLocales: supportedLocales,
      home: Scaffold(body: child),
    );
  }

  /// Configuración para pruebas con Riverpod
  static Widget createTestAppWithProvider({required Widget child, List<Override> overrides = const []}) {
    return ProviderScope(overrides: overrides, child: createTestApp(child: child));
  }
}

/// Utilidades para pruebas de progresión
class ProgressionTestUtils {
  /// Crea un conjunto de datos de prueba
  static Map<String, dynamic> createTestDataSet() {
    return {
      'exercises': [
        {
          'id': 'test-exercise-1',
          'name': 'Test Exercise 1',
          'description': 'Test exercise description',
          'weight': 100.0,
          'reps': 10,
          'sets': 3,
        },
        {
          'id': 'test-exercise-2',
          'name': 'Test Exercise 2',
          'description': 'Test exercise description',
          'weight': 80.0,
          'reps': 12,
          'sets': 3,
        },
      ],
      'routines': [
        {
          'id': 'test-routine-1',
          'name': 'Test Routine',
          'description': 'Test routine description',
          'exercises': [
            {'id': 'test-routine-exercise-1', 'exerciseId': 'test-exercise-1', 'weight': 100.0, 'reps': 10, 'sets': 3},
            {'id': 'test-routine-exercise-2', 'exerciseId': 'test-exercise-2', 'weight': 80.0, 'reps': 12, 'sets': 3},
          ],
        },
      ],
      'progressionConfigs': [
        {
          'id': 'test-config-1',
          'type': 'linear',
          'incrementValue': 2.5,
          'incrementFrequency': 1,
          'isActive': true,
          'isGlobal': true,
        },
        {
          'id': 'test-config-2',
          'type': 'undulating',
          'incrementValue': 5.0,
          'incrementFrequency': 2,
          'isActive': false,
          'isGlobal': true,
        },
      ],
      'progressionStates': [
        {
          'id': 'test-state-1',
          'progressionConfigId': 'test-config-1',
          'exerciseId': 'test-exercise-1',
          'currentWeight': 100.0,
          'currentReps': 10,
          'currentSets': 3,
          'currentWeek': 1,
          'currentSession': 1,
        },
        {
          'id': 'test-state-2',
          'progressionConfigId': 'test-config-1',
          'exerciseId': 'test-exercise-2',
          'currentWeight': 80.0,
          'currentReps': 12,
          'currentSets': 3,
          'currentWeek': 1,
          'currentSession': 1,
        },
      ],
    };
  }

  /// Valida que los valores de progresión sean correctos
  static void validateProgressionValues({
    required double expectedWeight,
    required double actualWeight,
    required int expectedReps,
    required int actualReps,
    required int expectedSets,
    required int actualSets,
    String? reason,
  }) {
    expect(actualWeight, expectedWeight, reason: 'Weight mismatch: $reason');
    expect(actualReps, expectedReps, reason: 'Reps mismatch: $reason');
    expect(actualSets, expectedSets, reason: 'Sets mismatch: $reason');
  }

  /// Crea un escenario de prueba para un tipo de progresión específico
  static Map<String, dynamic> createProgressionScenario({
    required String type,
    required Map<String, dynamic> parameters,
    required Map<String, dynamic> initialState,
    required Map<String, dynamic> expectedState,
  }) {
    return {
      'type': type,
      'parameters': parameters,
      'initialState': initialState,
      'expectedState': expectedState,
      'description': 'Test scenario for $type progression',
    };
  }

  /// Ejecuta un escenario de prueba
  static void runProgressionScenario(Map<String, dynamic> scenario) {
    final type = scenario['type'] as String;
    final parameters = scenario['parameters'] as Map<String, dynamic>;
    final initialState = scenario['initialState'] as Map<String, dynamic>;
    final expectedState = scenario['expectedState'] as Map<String, dynamic>;
    final description = scenario['description'] as String;

    // Aquí se ejecutaría la lógica de prueba específica
    // Por ahora, solo validamos que los datos estén presentes
    expect(type, isNotEmpty, reason: 'Progression type should not be empty');
    expect(parameters, isNotEmpty, reason: 'Parameters should not be empty');
    expect(initialState, isNotEmpty, reason: 'Initial state should not be empty');
    expect(expectedState, isNotEmpty, reason: 'Expected state should not be empty');
    expect(description, isNotEmpty, reason: 'Description should not be empty');
  }
}

/// Configuración para pruebas de integración
class IntegrationTestConfig {
  /// Configuración para pruebas de integración de progresión
  static Future<void> setUpIntegrationTests() async {
    await ProgressionTestConfig.setUp();
  }

  /// Limpieza para pruebas de integración
  static Future<void> tearDownIntegrationTests() async {
    await ProgressionTestConfig.tearDown();
  }

  /// Crea un entorno de prueba completo
  static Future<Map<String, dynamic>> createTestEnvironment() async {
    await setUpIntegrationTests();
    return ProgressionTestUtils.createTestDataSet();
  }

  /// Limpia el entorno de prueba completo
  static Future<void> cleanupTestEnvironment() async {
    await tearDownIntegrationTests();
  }
}
