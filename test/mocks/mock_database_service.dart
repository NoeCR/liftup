import 'package:hive/hive.dart';
import 'package:liftup/core/database/i_database_service.dart';
import 'package:liftup/features/progression/models/progression_config.dart';
import 'package:liftup/features/progression/models/progression_state.dart';
import 'package:liftup/features/progression/models/progression_template.dart';

/// Mock implementation of IDatabaseService for testing
class MockDatabaseService implements IDatabaseService {
  final Map<String, ProgressionConfig> _configs = {};
  final Map<String, ProgressionState> _states = {};
  final Map<String, ProgressionTemplate> _templates = {};

  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Box<ProgressionConfig> get progressionConfigsBox => _MockBox<ProgressionConfig>(_configs);

  @override
  Box<ProgressionState> get progressionStatesBox => _MockBox<ProgressionState>(_states);

  @override
  Box<ProgressionTemplate> get progressionTemplatesBox => _MockBox<ProgressionTemplate>(_templates);

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<void> close() async {
    _isInitialized = false;
    _configs.clear();
    _states.clear();
    _templates.clear();
  }

  // Helper methods for testing
  void addConfig(ProgressionConfig config) {
    _configs[config.id] = config;
  }

  void addState(ProgressionState state) {
    _states[state.id] = state;
  }

  void addTemplate(ProgressionTemplate template) {
    _templates[template.id] = template;
  }

  List<ProgressionConfig> get allConfigs => _configs.values.toList();
  List<ProgressionState> get allStates => _states.values.toList();
  List<ProgressionTemplate> get allTemplates => _templates.values.toList();
}

/// Mock implementation of Hive Box for testing
class _MockBox<T> implements Box<T> {
  final Map<String, T> _data;

  _MockBox(this._data);

  @override
  T? get(dynamic key, {T? defaultValue}) {
    return _data[key.toString()] ?? defaultValue;
  }

  @override
  Future<void> put(dynamic key, T value) async {
    _data[key.toString()] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    _data.remove(key.toString());
  }

  @override
  bool containsKey(dynamic key) => _data.containsKey(key.toString());

  @override
  Iterable<T> get values => _data.values;

  @override
  Iterable<String> get keys => _data.keys;

  @override
  int get length => _data.length;

  @override
  bool get isEmpty => _data.isEmpty;

  @override
  bool get isNotEmpty => _data.isNotEmpty;

  // Implement other required methods with default behavior
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
