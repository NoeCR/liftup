# Configuración de Sentry para LiftUp

Este documento explica cómo configurar Sentry para el monitoreo de errores y rendimiento en la aplicación LiftUp.

## Pasos para configurar Sentry

### 1. Crear cuenta en Sentry

1. Ve a [https://sentry.io](https://sentry.io)
2. Crea una cuenta gratuita
3. Verifica tu email

### 2. Crear proyecto

1. En el dashboard de Sentry, haz clic en "Create Project"
2. Selecciona "Flutter" como plataforma
3. Asigna un nombre al proyecto (ej: "liftup-app")
4. Selecciona tu organización
5. Haz clic en "Create Project"

### 3. Obtener DSN

1. En la página del proyecto, ve a "Settings" > "Projects" > "Client Keys (DSN)"
2. Copia el DSN (Data Source Name)
3. El DSN tiene el formato: `https://[key]@[organization].ingest.sentry.io/[project_id]`

### 4. Configurar DSN en la aplicación

1. Abre el archivo `lib/core/logging/sentry_dsn_config.dart`
2. Reemplaza `YOUR_SENTRY_DSN_HERE` con tu DSN real:

```dart
static const String _dnsKey = 'https://abc123def456@o123456.ingest.sentry.io/123456';
```

### 5. Verificar configuración

1. Reinicia la aplicación
2. Los logs deberían mostrar que Sentry se inicializó correctamente
3. Ve a tu proyecto en Sentry para ver los eventos

## Características implementadas

### Logging
- **Debug**: Información detallada para desarrollo
- **Info**: Información general de la aplicación
- **Warning**: Advertencias que no afectan la funcionalidad
- **Error**: Errores que afectan la funcionalidad
- **Fatal**: Errores críticos que pueden causar crashes

### Monitoreo de rendimiento
- Tiempo de inicio de la aplicación
- Operaciones de base de datos
- Importación/exportación de datos
- Sesiones de entrenamiento
- Uso de memoria

### Alertas automáticas
- Errores críticos de base de datos
- Problemas de rendimiento
- Errores de importación/exportación
- Problemas de experiencia de usuario
- Errores de configuración
- Uso excesivo de memoria

### Métricas en tiempo real
- Monitoreo de métricas cada 30 segundos
- Monitoreo de memoria cada 10 segundos
- Verificación de salud cada 60 segundos

## Configuración avanzada

### Filtros de datos sensibles

El sistema incluye filtros automáticos para:
- Contraseñas
- Tokens de autenticación
- Datos personales sensibles
- Información de tarjetas de crédito

### Contexto de usuario

Se incluye automáticamente:
- ID de usuario
- Información del dispositivo
- Versión de la aplicación
- Plataforma (Android/iOS)

### Breadcrumbs

Se registran automáticamente:
- Navegación entre pantallas
- Acciones del usuario
- Operaciones de base de datos
- Errores y excepciones

## Troubleshooting

### Sentry no se inicializa

1. Verifica que el DSN esté configurado correctamente
2. Asegúrate de que la aplicación tenga conexión a internet
3. Revisa los logs de la aplicación para errores de inicialización

### No se ven eventos en Sentry

1. Verifica que el DSN esté configurado correctamente
2. Asegúrate de que la aplicación esté enviando eventos
3. Revisa la configuración de filtros en Sentry

### Errores de red

1. Verifica la conexión a internet
2. Revisa si hay firewalls bloqueando Sentry
3. Verifica que el DSN sea válido

## Configuración de producción

Para producción, considera:

1. **Rate limiting**: Configura límites de eventos por minuto
2. **Sampling**: Configura muestreo de transacciones
3. **Filtros**: Configura filtros adicionales para datos sensibles
4. **Alertas**: Configura alertas por email/Slack para errores críticos

## Monitoreo de métricas

### Métricas disponibles

- **Rendimiento**: Tiempo de operaciones, operaciones lentas
- **Uso**: Sesiones, ejercicios, rutinas
- **Errores**: Tasa de errores, tipos de errores
- **Sistema**: Uso de memoria, estado de la aplicación

### Alertas configuradas

- **Críticas**: Errores de base de datos, crashes
- **Altas**: Problemas de rendimiento, errores de importación
- **Medias**: Problemas de UX, uso de memoria
- **Bajas**: Advertencias generales

## Soporte

Para problemas con la configuración de Sentry:

1. Revisa la [documentación oficial de Sentry](https://docs.sentry.io/platforms/flutter/)
2. Consulta los logs de la aplicación
3. Verifica la configuración del proyecto en Sentry
4. Contacta al equipo de desarrollo

## Seguridad

- El DSN es público y seguro de incluir en el código
- Los datos sensibles se filtran automáticamente
- Se recomienda usar variables de entorno en producción
- Mantén actualizada la versión de Sentry Flutter
