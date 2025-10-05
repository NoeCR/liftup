import 'package:hive/hive.dart';
import '../../features/progression/models/progression_config.dart';
import '../../features/progression/models/progression_state.dart';
import '../../features/progression/models/progression_template.dart';

/// Interfaz para el servicio de base de datos
/// Permite inyección de dependencias y testing con mocks
abstract class IDatabaseService {
  // Boxes para progresión
  Box<ProgressionConfig> get progressionConfigsBox;
  Box<ProgressionState> get progressionStatesBox;
  Box<ProgressionTemplate> get progressionTemplatesBox;

  // Métodos de inicialización
  Future<void> initialize();
  bool get isInitialized;

  // Métodos de limpieza
  Future<void> close();
}
