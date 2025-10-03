import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:faker/faker.dart';
import 'package:hive/hive.dart';
import 'dart:io';

import '../mocks/database_service_mock.dart';
import '../mocks/test_database_service.dart';
import '../mocks/logging_service_mock.dart';
import '../mocks/routine_service_mock.dart';
import '../../lib/features/home/services/routine_service.dart';
import '../../lib/core/database/database_service.dart';

/// Configuración central para todos los tests
/// Proporciona mocks y configuración común
class TestSetup {
  static late MockDatabaseService _mockDatabaseService;
  static late TestDatabaseService _testDatabaseService;
  static late MockLoggingService _mockLoggingService;
  static late MockPerformanceMonitor _mockPerformanceMonitor;
  static late MockRoutineService _mockRoutineService;
  static late Faker _faker;

  /// Inicializar todos los mocks y configuración de testing
  static void initialize() {
    _faker = Faker();
    _mockDatabaseService = MockDatabaseService.getInstance();
    _testDatabaseService = TestDatabaseService.getInstance();
    _mockLoggingService = MockLoggingService.getInstance();
    _mockPerformanceMonitor = MockPerformanceMonitor.getInstance();
    _mockRoutineService = MockRoutineService();

    // Configurar comportamiento por defecto de los mocks
    _mockDatabaseService.setupMockBehavior();
    _mockLoggingService.setupMockBehavior();
    _mockPerformanceMonitor.setupMockBehavior();
    _mockRoutineService.setupMockBehavior();

    // Configurar fallback values para mocktail
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(Exception('Test exception'));
  }

  /// Limpiar todos los mocks y datos de prueba
  static void cleanup() {
    _mockDatabaseService.clearMockData();
    _mockLoggingService.clearCapturedLogs();
    _mockPerformanceMonitor.clearCapturedMetrics();
    _mockRoutineService.clearMockData();
    // Clear test database data but don't close it
    try {
      _testDatabaseService.clearAllData();
    } catch (_) {}
  }

  /// Limpiar completamente el TestDatabaseService
  static void cleanupTestDatabase() {
    try {
      _testDatabaseService.close();
      TestDatabaseService.cleanup();
    } catch (_) {}
  }

  /// Obtener instancia del mock de DatabaseService
  static MockDatabaseService get mockDatabaseService => _mockDatabaseService;

  /// Obtener instancia del TestDatabaseService
  static TestDatabaseService get testDatabaseService => _testDatabaseService;

  /// Obtener instancia del mock de LoggingService
  static MockLoggingService get mockLoggingService => _mockLoggingService;

  /// Obtener instancia del mock de PerformanceMonitor
  static MockPerformanceMonitor get mockPerformanceMonitor =>
      _mockPerformanceMonitor;

  /// Obtener instancia del mock de RoutineService
  static MockRoutineService get mockRoutineService => _mockRoutineService;

  /// Obtener instancia de Faker para generar datos de prueba
  static Faker get faker => _faker;

  /// Inicializar el TestDatabaseService para tests que requieren base de datos real
  static Future<void> initializeTestDatabase() async {
    await _testDatabaseService.initialize();
  }

  /// Crear un ProviderContainer con overrides para testing
  static ProviderContainer createTestContainer({
    List<Override> overrides = const [],
  }) {
    return ProviderContainer(
      overrides: [
        // Aquí se pueden añadir overrides específicos para cada test
        ...overrides,
      ],
    );
  }

  /// Configurar datos de prueba para DatabaseService
  static void setupTestData({
    Map<String, dynamic>? exercises,
    Map<String, dynamic>? routines,
    Map<String, dynamic>? sessions,
    Map<String, dynamic>? progress,
    Map<String, dynamic>? settings,
  }) {
    if (exercises != null) {
      _mockDatabaseService.setupMockData('exercises', exercises);
    }
    if (routines != null) {
      _mockDatabaseService.setupMockData('routines', routines);
    }
    if (sessions != null) {
      _mockDatabaseService.setupMockData('sessions', sessions);
    }
    if (progress != null) {
      _mockDatabaseService.setupMockData('progress', progress);
    }
    if (settings != null) {
      _mockDatabaseService.setupMockData('settings', settings);
    }
  }

  /// Verificar que se realizaron operaciones específicas en la base de datos
  static void verifyDatabaseOperations({
    String? boxName,
    String? operation,
    dynamic key,
    dynamic value,
  }) {
    if (boxName != null && operation != null) {
      _mockDatabaseService.verifyBoxInteraction(
        boxName,
        operation,
        key: key,
        value: value,
      );
    }
  }

  /// Verificar que se registraron logs específicos
  static void verifyLogging({required String message, LogLevel? level}) {
    if (level != null) {
      _mockLoggingService.verifyLogCall(level, message);
    } else {
      expect(_mockLoggingService.hasLogWithMessage(message), isTrue);
    }
  }

  /// Verificar que se registraron métricas de rendimiento
  static void verifyPerformanceMetrics({required String operation}) {
    final metrics = _mockPerformanceMonitor.getCapturedMetrics();
    expect(metrics.any((m) => m.operation == operation), isTrue);
  }
}

/// Mixin para tests que necesitan configuración automática
mixin TestSetupMixin {
  void setUpTest() {
    TestSetup.initialize();
  }

  void tearDownTest() {
    TestSetup.cleanup();
  }
}

/// Extensión para facilitar la creación de datos de prueba
extension TestDataExtension on TestSetup {
  /// Crear datos de prueba para un ejercicio
  static Map<String, dynamic> createTestExercise({
    String? id,
    String? name,
    String? description,
    String? category,
    String? imagePath,
  }) {
    return {
      'id': id ?? TestSetup.faker.guid.guid(),
      'name': name ?? TestSetup.faker.lorem.word(),
      'description': description ?? TestSetup.faker.lorem.sentence(),
      'category': category ?? TestSetup.faker.lorem.word(),
      'imagePath': imagePath ?? TestSetup.faker.image.image(),
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Crear datos de prueba para una rutina
  static Map<String, dynamic> createTestRoutine({
    String? id,
    String? name,
    String? description,
    List<Map<String, dynamic>>? exercises,
  }) {
    return {
      'id': id ?? TestSetup.faker.guid.guid(),
      'name': name ?? TestSetup.faker.lorem.word(),
      'description': description ?? TestSetup.faker.lorem.sentence(),
      'exercises': exercises ?? [],
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Crear datos de prueba para una sesión
  static Map<String, dynamic> createTestSession({
    String? id,
    String? routineId,
    String? status,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return {
      'id': id ?? TestSetup.faker.guid.guid(),
      'routineId': routineId ?? TestSetup.faker.guid.guid(),
      'status': status ?? 'active',
      'startTime': (startTime ?? DateTime.now()).toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalWeight': TestSetup.faker.randomGenerator.integer(1000),
      'totalReps': TestSetup.faker.randomGenerator.integer(500),
      'exerciseSets': [],
      'notes': TestSetup.faker.lorem.sentence(),
    };
  }
}
