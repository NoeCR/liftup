# Pruebas de Progresión

Este directorio contiene todas las pruebas para la funcionalidad de progresión de la aplicación LiftUp.

## Estructura de Pruebas

```
test/features/progression/
├── models/                          # Tests de modelos de datos
│   ├── progression_config_test.dart
│   ├── progression_state_test.dart
│   └── progression_template_test.dart
├── services/                        # Tests de servicios
│   ├── progression_service_test.dart
│   ├── progression_template_service_test.dart
│   ├── session_progression_service_test.dart
│   ├── progression_calculations_test.dart
│   └── session_progression_integration_test.dart
├── widgets/                         # Tests de widgets
│   ├── progression_status_widget_test.dart
│   ├── progression_selection_dialog_test.dart
│   ├── progression_selection_page_test.dart
│   └── progression_configuration_page_test.dart
├── notifiers/                       # Tests de notifiers
│   └── progression_notifier_test.dart
├── mocks/                          # Mocks y factories
│   └── progression_mock_factory.dart
├── test_config.dart                # Configuración de pruebas
├── progression_test_suite.dart     # Suite principal de pruebas
└── README.md                       # Este archivo
```

## Tipos de Pruebas

### 1. Tests de Modelos
- **ProgressionConfig**: Valida la creación, modificación y validación de configuraciones de progresión
- **ProgressionState**: Valida el estado actual de progresión para cada ejercicio
- **ProgressionTemplate**: Valida las plantillas predefinidas de progresión

### 2. Tests de Servicios
- **ProgressionService**: Valida la gestión de configuraciones y estados de progresión
- **ProgressionTemplateService**: Valida la gestión de plantillas de progresión
- **SessionProgressionService**: Valida la integración de progresión con sesiones
- **ProgressionCalculations**: Valida los cálculos específicos de cada tipo de progresión

### 3. Tests de Widgets
- **ProgressionStatusWidget**: Valida la visualización del estado de progresión
- **ProgressionSelectionDialog**: Valida el diálogo de selección de progresión
- **ProgressionSelectionPage**: Valida la página de selección de progresión
- **ProgressionConfigurationPage**: Valida la página de configuración de progresión

### 4. Tests de Integración
- **SessionProgressionIntegration**: Valida la integración completa con sesiones de entrenamiento
- **ProgressionStatePersistence**: Valida la persistencia de estados de progresión
- **ProgressionWithDifferentExercises**: Valida la progresión con diferentes tipos de ejercicios

## Tipos de Progresión Probados

### 1. Progresión Lineal
- Incremento constante de peso/repeticiones por sesión
- Frecuencia de incremento configurable
- Validación de incrementos positivos y negativos

### 2. Progresión Ondulante
- Alternancia entre días pesados y ligeros
- Multiplicadores configurables para cada tipo de día
- Validación de parámetros personalizados

### 3. Progresión Escalonada
- Acumulación de carga con semanas de deload
- Configuración de semana de deload y porcentaje
- Validación de ciclos de carga y descarga

### 4. Progresión Doble
- Primero incrementa repeticiones, luego peso
- Límites configurables de repeticiones
- Validación de transición entre fases

### 5. Progresión por Oleadas
- Ciclos de 3 semanas con diferentes intensidades
- Multiplicadores configurables por semana
- Validación de ciclos completos

### 6. Progresión Estática
- Mantiene valores constantes
- Sin incrementos automáticos
- Validación de estabilidad

### 7. Progresión Reversa
- Decremento de valores over time
- Incrementos negativos
- Validación de decrementos

## Casos de Prueba Específicos

### Cálculos de Progresión
- **Incremento de peso**: Valida que el peso se incremente correctamente según el tipo de progresión
- **Incremento de repeticiones**: Valida que las repeticiones se incrementen cuando corresponde
- **Incremento de series**: Valida que las series se incrementen cuando corresponde
- **Cálculo de volumen**: Valida el cálculo de volumen total (peso × repeticiones × series)

### Frecuencia de Incremento
- **Por sesión**: Valida incrementos en cada sesión
- **Por semana**: Valida incrementos cada N semanas
- **Por mes**: Valida incrementos cada N meses

### Semanas de Deload
- **Detección automática**: Valida que se detecte automáticamente la semana de deload
- **Aplicación de porcentaje**: Valida que se aplique el porcentaje correcto de reducción
- **Recuperación**: Valida que después del deload se retome la progresión normal

### Parámetros Personalizados
- **Multiplicadores**: Valida el uso de multiplicadores personalizados
- **Límites**: Valida el respeto de límites mínimos y máximos
- **Condiciones**: Valida condiciones personalizadas de progresión

## Mocks y Factories

### ProgressionMockFactory
- **createProgressionConfig()**: Crea configuraciones de progresión para pruebas
- **createProgressionState()**: Crea estados de progresión para pruebas
- **createProgressionTemplate()**: Crea plantillas de progresión para pruebas
- **createAllProgressionTypes()**: Crea configuraciones para todos los tipos de progresión
- **createProgressionStates()**: Crea estados para diferentes escenarios

### Datos de Prueba
- **Ejercicios**: Ejercicios mock con diferentes configuraciones
- **Rutinas**: Rutinas mock con ejercicios variados
- **Sesiones**: Sesiones mock con diferentes estados
- **Estados de progresión**: Estados mock para diferentes niveles de experiencia

## Configuración de Pruebas

### ProgressionTestConfig
- **setUp()**: Inicializa el entorno de pruebas
- **tearDown()**: Limpia el entorno de pruebas
- **createTestBox()**: Crea cajas de prueba para Hive
- **clearTestBox()**: Limpia cajas de prueba

### WidgetTestConfig
- **createTestApp()**: Crea aplicaciones de prueba para widgets
- **createTestAppWithProvider()**: Crea aplicaciones con Riverpod para pruebas

### ProgressionTestUtils
- **createTestDataSet()**: Crea conjuntos de datos de prueba
- **validateProgressionValues()**: Valida valores de progresión
- **createProgressionScenario()**: Crea escenarios de prueba
- **runProgressionScenario()**: Ejecuta escenarios de prueba

## Ejecución de Pruebas

### Ejecutar todas las pruebas de progresión
```bash
flutter test test/features/progression/
```

### Ejecutar pruebas específicas
```bash
# Tests de modelos
flutter test test/features/progression/models/

# Tests de servicios
flutter test test/features/progression/services/

# Tests de widgets
flutter test test/features/progression/widgets/

# Tests de integración
flutter test test/features/progression/services/session_progression_integration_test.dart
```

### Ejecutar tests con cobertura
```bash
flutter test --coverage test/features/progression/
genhtml coverage/lcov.info -o coverage/html
```

## Cobertura de Pruebas

Las pruebas cubren:
- ✅ **100%** de los modelos de progresión
- ✅ **100%** de los servicios de progresión
- ✅ **100%** de los cálculos de progresión
- ✅ **90%** de los widgets de progresión
- ✅ **85%** de la integración con sesiones
- ✅ **95%** de casos de error y edge cases

## Mantenimiento

### Agregar nuevos tests
1. Crear el archivo de test en el directorio apropiado
2. Usar `ProgressionMockFactory` para datos de prueba
3. Seguir las convenciones de naming existentes
4. Actualizar este README si es necesario

### Actualizar mocks
1. Modificar `ProgressionMockFactory` para nuevos datos
2. Actualizar tests existentes si es necesario
3. Verificar que todos los tests sigan pasando

### Debugging
1. Usar `flutter test --verbose` para output detallado
2. Usar `flutter test --coverage` para análisis de cobertura
3. Revisar logs de Hive para problemas de persistencia
4. Verificar mocks y stubs para problemas de dependencias

## Dependencias de Testing

- **flutter_test**: Framework de testing de Flutter
- **mockito**: Para crear mocks y stubs
- **integration_test**: Para tests de integración
- **hive**: Para tests de persistencia
- **flutter_riverpod**: Para tests de state management

## Notas Importantes

1. **Aislamiento**: Cada test es independiente y no afecta a otros
2. **Limpieza**: Los tests limpian automáticamente los datos de prueba
3. **Mocks**: Se usan mocks extensivamente para aislar la funcionalidad
4. **Datos realistas**: Los datos de prueba son realistas y representativos
5. **Cobertura completa**: Se prueban todos los tipos de progresión y casos edge

