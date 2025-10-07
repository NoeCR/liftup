# 🏋️‍♂️ Liftly - Guía de Desarrollo

## 📋 Resumen del Proyecto

Liftly es una aplicación móvil desarrollada en Flutter para gestionar rutinas de ejercicios. La aplicación está diseñada con una arquitectura limpia, orientada a features, y utiliza tecnologías modernas como Riverpod para el manejo de estado, Hive para la persistencia local, y go_router para la navegación.

## 🏗️ Arquitectura del Proyecto

### Estructura de Carpetas

```
lib/
├── features/                    # Módulos por funcionalidad
│   ├── home/                   # Pantalla principal y rutinas
│   │   ├── models/            # Modelos de datos
│   │   ├── notifiers/         # StateNotifiers de Riverpod
│   │   ├── services/          # Servicios de datos
│   │   ├── pages/             # Pantallas/UI
│   │   └── routes/            # Rutas específicas
│   ├── exercise/              # Gestión de ejercicios
│   ├── sessions/              # Sesiones de entrenamiento
│   ├── statistics/            # Estadísticas y progreso
│   └── settings/              # Configuración
├── common/                     # Componentes compartidos
│   ├── widgets/               # Widgets reutilizables
│   ├── utils/                 # Utilidades
│   ├── themes/                # Temas y estilos
│   └── localization/          # Internacionalización
└── core/                      # Funcionalidades centrales
    ├── database/              # Configuración de Hive
    ├── export/                # Sistema de exportación
    └── navigation/            # Configuración de rutas
```

## 🛠️ Tecnologías Utilizadas

### Dependencias Principales

- **Flutter**: Framework de desarrollo móvil
- **Riverpod**: Gestión de estado reactiva
- **Hive**: Base de datos local NoSQL
- **go_router**: Navegación declarativa
- **Material You**: Sistema de diseño moderno

### Dependencias de UI

- **fl_chart**: Gráficos para estadísticas
- **lottie**: Animaciones
- **material_design_icons_flutter**: Iconos adicionales

### Dependencias de Exportación

- **pdf**: Generación de PDFs
- **csv**: Exportación a CSV
- **share_plus**: Compartir archivos
- **path_provider**: Acceso a directorios

## 🚀 Configuración del Entorno

### 1. Instalación de Dependencias

```bash
flutter pub get
```

### 2. Generación de Código

```bash
flutter packages pub run build_runner build
```

### 3. Ejecución

```bash
flutter run
```

## 📱 Funcionalidades Implementadas

### ✅ Completadas

1. **Arquitectura Base**
   - Estructura de carpetas orientada a features
   - Configuración de Riverpod
   - Configuración de Hive
   - Navegación con go_router

2. **Modelos de Datos**
   - Exercise (Ejercicios)
   - ExerciseSet (Series de ejercicios)
   - WorkoutSession (Sesiones de entrenamiento)
   - Routine (Rutinas)
   - ProgressData (Datos de progreso)

3. **Pantallas Principales**
   - Home (Pantalla principal con menú configurable)
   - ExerciseList (Lista de ejercicios con filtros)
   - ExerciseDetail (Detalle de ejercicio)
   - Session (Sesión de entrenamiento)
   - Statistics (Estadísticas)
   - Settings (Configuración)

4. **Widgets Reutilizables**
   - ExerciseCard (Tarjeta de ejercicio)
   - SectionHeader (Encabezado de sección)
   - CustomBottomNavigation (Navegación inferior)

5. **Sistema de Exportación**
   - Exportación a CSV
   - Exportación a PDF
   - Exportación a JSON
   - Compartir archivos

6. **Internacionalización**
   - Soporte para español e inglés
   - Sistema de localización configurado

### ✅ Sistema de Progresión Avanzado

1. **Estrategias de Progresión Implementadas**
   - **Linear**: Incremento constante de peso/repeticiones
   - **Double**: Primero reps, luego peso
   - **Undulating**: Alternancia entre días pesados y ligeros
   - **Stepped**: Acumulación con deload periódico
   - **Wave**: Ciclos de 3 semanas con diferentes intensidades
   - **Static**: Mantiene valores constantes
   - **Reverse**: Decremento progresivo
   - **Autoregulated**: Basada en RPE/RIR
   - **DoubleFactor**: Balance fitness-fatiga
   - **Overload**: Sobrecarga progresiva
   - **Default**: Sin cambios (fallback)

2. **Parámetros Personalizados**
   - Configuración individual por ejercicio
   - Diferenciación multi-joint vs isolation
   - Prioridad: per_exercise > global > defaults
   - Unidades de progresión (sesión/semana/ciclo)

3. **Lógica de Deload Unificada**
   - baseWeight * deloadPercentage
   - Aplicación consistente en todas las estrategias
   - Preservación del progreso base

### 🚧 En Desarrollo

1. **Funcionalidades de Entrenamiento**
   - Timer de sesión
   - Gestión de series y repeticiones
   - Progresión de peso

2. **Estadísticas Avanzadas**
   - Gráficos de progreso
   - Análisis de rendimiento
   - Comparativas históricas

3. **Configuración**
   - Temas personalizados
   - Configuración de notificaciones
   - Gestión de datos

## 🎨 Diseño y UX

### Material You

La aplicación utiliza el sistema de diseño Material You con:
- Colores adaptativos
- Tipografías modernas
- Bordes redondeados
- Animaciones suaves

### Tema Claro/Oscuro

- Soporte automático para tema claro y oscuro
- Colores que se adaptan al sistema
- Transiciones suaves entre temas

## 🗄️ Base de Datos

### Hive Boxes

- `exercises`: Almacena ejercicios
- `routines`: Almacena rutinas
- `sessions`: Almacena sesiones de entrenamiento
- `progress`: Almacena datos de progreso
- `settings`: Almacena configuraciones

### Modelos Principales

```dart
// Ejercicio
class Exercise {
  String id;
  String name;
  String description;
  String imageUrl;
  List<String> muscleGroups;
  ExerciseCategory category;
  ExerciseDifficulty difficulty;
  // ...
}

// Rutina
class Routine {
  String id;
  String name;
  List<RoutineDay> days;
  bool isActive;
  // ...
}

// Sesión de Entrenamiento
class WorkoutSession {
  String id;
  String name;
  DateTime startTime;
  DateTime? endTime;
  List<ExerciseSet> exerciseSets;
  SessionStatus status;
  // ...
}
```

## 🔄 Gestión de Estado

### Riverpod Providers

```dart
// Ejercicios
@riverpod
class ExerciseNotifier extends _$ExerciseNotifier {
  // Gestión de ejercicios
}

// Rutinas
@riverpod
class RoutineNotifier extends _$RoutineNotifier {
  // Gestión de rutinas
}

// Sesiones
@riverpod
class SessionNotifier extends _$SessionNotifier {
  // Gestión de sesiones
}
```

## 🏗️ Arquitectura de Servicios de Progresión

### Servicios Especializados

El sistema de progresión ha sido refactorizado en servicios especializados para mejorar la mantenibilidad y testabilidad:

#### 1. **ProgressionStateService**
```dart
class ProgressionStateService {
  // Gestión de estados de progresión
  Future<ProgressionState?> getProgressionStateByExercise(String configId, String exerciseId);
  Future<void> saveProgressionState(ProgressionState state);
  int detectStallWeeks(Map<String, dynamic> history);
  Future<void> cleanupInactiveProgressionStates();
}
```

#### 2. **ProgressionCalculationService**
```dart
class ProgressionCalculationService {
  // Cálculos de progresión
  ProgressionCalculationResult calculateProgression({
    required ProgressionConfig config,
    required ProgressionState state,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
  });
  (int session, int week) calculateNextSessionAndWeek(ProgressionConfig config, ProgressionState state);
  double calculateNextBaseWeight(ProgressionConfig config, ProgressionState state, ProgressionCalculationResult result);
}
```

#### 3. **ProgressionCoordinatorService**
```dart
class ProgressionCoordinatorService {
  // Orquestación del proceso de progresión
  Future<ProgressionCalculationResult> processProgression({
    required ProgressionConfig config,
    required String exerciseId,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
  });
}
```

#### 4. **ProgressionStrategyFactory**
```dart
class ProgressionStrategyFactory {
  // Factory pattern para estrategias
  static ProgressionStrategy fromType(ProgressionType type) {
    switch (type) {
      case ProgressionType.linear: return LinearProgressionStrategy();
      case ProgressionType.double: return DoubleProgressionStrategy();
      // ... otras estrategias
      default: return DefaultProgressionStrategy();
    }
  }
}
```

### Estrategias de Progresión

Cada estrategia implementa la interfaz `ProgressionStrategy`:

```dart
abstract class ProgressionStrategy {
  ProgressionCalculationResult calculate({
    required ProgressionConfig config,
    required ProgressionState state,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
  });
}
```

### Parámetros Personalizados

El sistema soporta parámetros personalizados con la siguiente prioridad:

1. **per_exercise**: Parámetros específicos por ejercicio
2. **global**: Parámetros globales de configuración
3. **defaults**: Valores por defecto del sistema

```dart
// Ejemplo de configuración personalizada
final customParams = {
  'per_exercise': {
    'exercise_123': {
      'multi_increment_min': 2.5,
      'multi_increment_max': 5.0,
      'multi_reps_min': 8,
      'multi_reps_max': 12,
    }
  }
};
```

## 📊 Sistema de Exportación

### Formatos Soportados

1. **CSV**: Para análisis en hojas de cálculo
2. **PDF**: Para reportes visuales
3. **JSON**: Para respaldo completo

### Uso

```dart
// Exportar a CSV
await ExportManager.exportAndShare(
  exportService: CSVExportService(),
  sessions: sessions,
  exercises: exercises,
  routines: routines,
  progressData: progressData,
);
```

## 🌍 Internacionalización

### Archivos de Localización

- `assets/locales/es.json`: Traducciones en español
- `assets/locales/en.json`: Traducciones en inglés

### Uso

```dart
final l10n = AppLocalizations.of(context);
Text(l10n.appTitle); // "Liftly"
```

## 🧪 Testing

### Estructura de Tests

```
test/
├── unit/                      # Tests unitarios
├── widget/                    # Tests de widgets
└── integration/               # Tests de integración
```

### Comandos de Testing

```bash
# Tests unitarios
flutter test

# Tests con cobertura
flutter test --coverage

# Tests de integración
flutter drive --target=test_driver/app.dart
```

## 📦 Build y Deploy

### Android

```bash
# Build de debug
flutter build apk --debug

# Build de release
flutter build apk --release

# Build de App Bundle
flutter build appbundle --release
```

### iOS

```bash
# Build de debug
flutter build ios --debug

# Build de release
flutter build ios --release
```

## 🔧 Comandos Útiles

### Desarrollo

```bash
# Limpiar proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Generar código
flutter packages pub run build_runner build

# Análisis de código
flutter analyze

# Formatear código
dart format .
```

### Debugging

```bash
# Ver logs
flutter logs

# Hot reload
r

# Hot restart
R

# Quit
q
```

## 📝 Próximos Pasos

### Funcionalidades Pendientes

1. **Implementar Timer de Sesión**
   - Contador de tiempo en tiempo real
   - Pausa y reanudación
   - Notificaciones de descanso

2. **Gestión de Progreso**
   - Tracking de peso y repeticiones
   - Gráficos de progresión
   - Metas y objetivos

3. **Funcionalidades Sociales**
   - Compartir rutinas
   - Comunidad de usuarios
   - Retos y logros

4. **Integración con Dispositivos**
   - Sincronización con wearables
   - Integración con Apple Health/Google Fit
   - Tracking de frecuencia cardíaca

### Mejoras Técnicas

1. **Performance**
   - Optimización de consultas a base de datos
   - Lazy loading de imágenes
   - Caché de datos

2. **Testing**
   - Aumentar cobertura de tests
   - Tests de integración
   - Tests de performance

3. **Accesibilidad**
   - Soporte para lectores de pantalla
   - Navegación por teclado
   - Contraste mejorado

## 🤝 Contribución

### Flujo de Trabajo

1. Fork del repositorio
2. Crear rama feature: `git checkout -b feature/nueva-funcionalidad`
3. Commit cambios: `git commit -m 'Agregar nueva funcionalidad'`
4. Push a la rama: `git push origin feature/nueva-funcionalidad`
5. Crear Pull Request

### Estándares de Código

- Seguir las convenciones de Dart/Flutter
- Documentar funciones públicas
- Escribir tests para nuevas funcionalidades
- Mantener cobertura de tests > 80%

## 📞 Soporte

Para dudas o problemas:
- Crear un issue en el repositorio
- Revisar la documentación de Flutter
- Consultar la comunidad de Flutter

---

**¡Happy Coding! 🚀**
