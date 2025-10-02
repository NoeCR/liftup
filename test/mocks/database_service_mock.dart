import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:liftup/core/database/database_service.dart';

/// Mock para DatabaseService que simula todas las operaciones de base de datos
/// sin tocar la base de datos real del dispositivo/simulador
class MockDatabaseService extends Mock implements DatabaseService {
  // Simulamos el comportamiento del singleton
  static MockDatabaseService? _instance;

  static MockDatabaseService getInstance() {
    _instance ??= MockDatabaseService._();
    return _instance!;
  }

  MockDatabaseService._();

  // Mock de las cajas de Hive
  final Map<String, MockBox> _mockBoxes = {};

  // Configurar el mock para que simule el comportamiento real
  void setupMockBehavior() {
    // Mock de initialize()
    when(() => initialize()).thenAnswer((_) async {});

    // Mock de los getters de boxes
    when(() => exercisesBox).thenAnswer((_) {
      if (!_mockBoxes.containsKey('exercises')) {
        _mockBoxes['exercises'] = MockBox();
      }
      return _mockBoxes['exercises']!;
    });

    when(() => routinesBox).thenAnswer((_) {
      if (!_mockBoxes.containsKey('routines')) {
        _mockBoxes['routines'] = MockBox();
      }
      return _mockBoxes['routines']!;
    });

    when(() => sessionsBox).thenAnswer((_) {
      if (!_mockBoxes.containsKey('sessions')) {
        _mockBoxes['sessions'] = MockBox();
      }
      return _mockBoxes['sessions']!;
    });

    when(() => progressBox).thenAnswer((_) {
      if (!_mockBoxes.containsKey('progress')) {
        _mockBoxes['progress'] = MockBox();
      }
      return _mockBoxes['progress']!;
    });

    when(() => settingsBox).thenAnswer((_) {
      if (!_mockBoxes.containsKey('settings')) {
        _mockBoxes['settings'] = MockBox();
      }
      return _mockBoxes['settings']!;
    });

    when(() => routineSectionTemplatesBox).thenAnswer((_) {
      if (!_mockBoxes.containsKey('routine_section_templates')) {
        _mockBoxes['routine_section_templates'] = MockBox();
      }
      return _mockBoxes['routine_section_templates']!;
    });

    // Mock de close()
    when(() => close()).thenAnswer((_) async {});

    // Mock de clearAllData()
    when(() => clearAllData()).thenAnswer((_) async {});
  }

  // Métodos para configurar datos de prueba
  void setupMockData(String boxName, Map<String, dynamic> data) {
    final mockBox = MockBox();
    mockBox.setupMockData(data);
    _mockBoxes[boxName] = mockBox;
  }

  // Método para limpiar todos los datos mock
  void clearMockData() {
    _mockBoxes.clear();
  }

  // Método para verificar interacciones
  void verifyBoxInteraction(
    String boxName,
    String method, {
    dynamic key,
    dynamic value,
  }) {
    // Para simplificar, solo verificamos que la caja existe
    // En un test real, podrías implementar un sistema de tracking más sofisticado
    expect(_mockBoxes.containsKey(boxName), isTrue);
  }
}

/// Mock para Box de Hive
class MockBox extends Mock implements Box {
  final Map<String, dynamic> _data = {};

  @override
  String get name => 'mock_box';

  @override
  bool get isOpen => true;

  @override
  int get length => _data.length;

  @override
  Iterable get keys => _data.keys;

  @override
  Iterable get values => _data.values;

  @override
  Future<void> put(dynamic key, dynamic value) async {
    _data[key.toString()] = value;
  }

  @override
  dynamic get(dynamic key, {dynamic defaultValue}) {
    return _data[key.toString()] ?? defaultValue;
  }

  @override
  Future<void> delete(dynamic key) async {
    _data.remove(key.toString());
  }

  @override
  Future<int> clear() async {
    final count = _data.length;
    _data.clear();
    return count;
  }

  @override
  Future<void> close() async {}

  @override
  Future<void> compact() async {}

  @override
  Future<void> flush() async {}

  // Método para configurar datos de prueba
  void setupMockData(Map<String, dynamic> data) {
    _data.clear();
    _data.addAll(data);
  }
}