# Sistema de Logging y Monitoreo - LiftUp

Este módulo proporciona un sistema completo de logging y monitoreo para la aplicación LiftUp, integrado con Sentry para el seguimiento de errores y métricas de rendimiento.

## 🚀 Características

- **Logging centralizado** con diferentes niveles (debug, info, warning, error, fatal)
- **Integración con Sentry** para seguimiento de errores en producción
- **Monitoreo de rendimiento** para operaciones críticas
- **Contexto de usuario** y metadata para mejor debugging
- **Manejo global de errores** para Flutter y plataforma
- **Breadcrumbs** para trazabilidad de eventos

## 📦 Componentes

### LoggingService
Servicio principal para logging con integración a Sentry.

```dart
// Logging básico
LoggingService.instance.info('Usuario inició sesión');
LoggingService.instance.error('Error al cargar datos', error, stackTrace);

// Logging con contexto
LoggingService.instance.warning('Datos inconsistentes', {
  'user_id': '123',
  'data_type': 'routine',
  'inconsistency': 'missing_exercises'
});
```

### PerformanceMonitor
Monitoreo de rendimiento para operaciones críticas.

```dart
// Monitoreo automático
final result = await PerformanceMonitor.instance.monitorAsync(
  'database_operation',
  () async => await databaseService.saveData(data),
  context: {'data_size': data.length},
);

// Monitoreo manual
final operationId = PerformanceMonitor.instance.startOperation('file_import');
// ... realizar operación ...
PerformanceMonitor.instance.endOperation(operationId);
```

### UserContextService
Configuración de contexto de usuario y metadata.

```dart
// Configurar usuario
UserContextService.instance.setUserContext(
  userId: 'user123',
  username: 'john_doe',
  userType: 'premium',
);

// Configurar contexto de rutina
UserContextService.instance.setRoutineContext(
  routineId: 'routine456',
  routineName: 'Push Day',
  routineType: 'strength',
);
```

## 🔧 Configuración

### 1. Configurar Sentry DSN

Edita `lib/core/logging/sentry_config.dart` y reemplaza `YOUR_SENTRY_DSN_HERE` con tu DSN real de Sentry.

```dart
static const String _dnsKey = 'https://your-dsn@sentry.io/project-id';
```

### 2. Inicialización

El sistema se inicializa automáticamente en `main.dart`:

```dart
void main() async {
  // Inicializar Sentry
  await SentryConfig.initialize();
  
  // Inicializar servicios de logging
  LoggingService.instance.initialize();
  await UserContextService.instance.initialize();
  
  // ... resto de la inicialización
}
```

## 📊 Niveles de Logging

- **Debug**: Información detallada para desarrollo
- **Info**: Información general de la aplicación
- **Warning**: Situaciones que requieren atención
- **Error**: Errores que no detienen la aplicación
- **Fatal**: Errores críticos que pueden detener la aplicación

## 🎯 Mejores Prácticas

### 1. Usar contexto relevante
```dart
// ✅ Bueno
LoggingService.instance.error('Failed to save routine', error, stackTrace, {
  'routine_id': routine.id,
  'routine_name': routine.name,
  'user_id': currentUser.id,
});

// ❌ Malo
LoggingService.instance.error('Error occurred', error, stackTrace);
```

### 2. Monitorear operaciones críticas
```dart
// ✅ Operaciones de base de datos
await PerformanceMonitor.instance.monitorAsync(
  'save_routine',
  () => databaseService.saveRoutine(routine),
);

// ✅ Operaciones de archivo
await PerformanceMonitor.instance.monitorAsync(
  'export_data',
  () => exportService.exportToFile(data),
);
```

### 3. Configurar contexto de usuario
```dart
// Al iniciar sesión
UserContextService.instance.setUserContext(
  userId: user.id,
  username: user.username,
  userType: user.subscriptionType,
);

// Al cambiar de rutina
UserContextService.instance.setRoutineContext(
  routineId: routine.id,
  routineName: routine.name,
);
```

## 🔍 Debugging en Sentry

### Filtros útiles
- `log_level:error` - Solo errores
- `component:database` - Errores de base de datos
- `user_id:123` - Errores de un usuario específico
- `routine_id:456` - Errores relacionados con una rutina

### Breadcrumbs
El sistema automáticamente añade breadcrumbs para:
- Navegación entre pantallas
- Operaciones de base de datos
- Cambios de contexto de usuario
- Operaciones de rendimiento

## 🧪 Testing

Para testing, el sistema de logging se puede configurar para no enviar datos a Sentry:

```dart
// En tests
LoggingService.instance.initialize(
  enableConsoleLogging: true,
  enableSentryLogging: false,
);
```

## 📈 Métricas de Rendimiento

El sistema automáticamente:
- Mide el tiempo de operaciones críticas
- Detecta operaciones lentas (>1 segundo)
- Envía métricas a Sentry
- Proporciona estadísticas locales

### Ver estadísticas
```dart
final stats = PerformanceMonitor.instance.getAllStats();
print('Operaciones monitoreadas: ${stats.keys}');
```

## 🚨 Alertas

Sentry puede configurarse para enviar alertas cuando:
- Se producen errores fatales
- El tiempo de respuesta excede umbrales
- Se detectan patrones de error específicos

## 🔒 Privacidad

El sistema filtra automáticamente información sensible:
- Contraseñas
- Tokens
- Claves de API
- Información personal

## 📝 Logs Locales

En modo debug, todos los logs se muestran en consola con formato colorizado y emojis para fácil identificación.
