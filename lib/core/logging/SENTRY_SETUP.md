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

1. Copia los archivos de ejemplo según tu entorno:
   ```bash
   # Para desarrollo
   cp env.development.example .env.development
   
   # Para staging
   cp env.staging.example .env.staging
   
   # Para producción
   cp env.production.example .env.production
   ```

2. Abre el archivo `.env.{environment}` apropiado y reemplaza `YOUR_SENTRY_DSN_HERE` con tu DSN real:
   ```env
   SENTRY_DSN=https://abc123def456@o123456.ingest.sentry.io/123456
   ```

3. Asegúrate de que los archivos `.env*` estén en tu `.gitignore` para no exponer tu DSN

### 5. Configurar variables de entorno adicionales

Puedes configurar otras opciones en los archivos `.env.{environment}`:

```env
# Configuración de entorno
ENVIRONMENT=development  # development, staging, production

# Configuración de logging
DEBUG_LOGGING=true  # true para logging detallado, false para mínimo

# Configuración de monitoreo
ENABLE_METRICS_MONITORING=true  # true para habilitar métricas, false para deshabilitar

# Configuración de alertas
ENABLE_ALERTS=true  # true para habilitar alertas, false para deshabilitar

# Configuración específica de Sentry
ENABLE_SCREENSHOTS=true  # true para capturar pantallas en errores
ENABLE_VIEW_HIERARCHY=true  # true para capturar jerarquía de vistas
TRACES_SAMPLE_RATE=1.0  # Nivel de muestreo para transacciones (0.0 a 1.0)
PROFILES_SAMPLE_RATE=1.0  # Nivel de muestreo para perfiles (0.0 a 1.0)
```

### 6. Configurar entorno automáticamente

El sistema detecta automáticamente el entorno basándose en:

- **Variable de entorno del sistema**: `FLUTTER_ENV` (tiene prioridad)
- **Modo de Flutter**: 
  - `kDebugMode` → `development`
  - `kProfileMode` → `staging`
  - `kReleaseMode` → `production`

Para forzar un entorno específico, puedes usar:
```bash
# En desarrollo
export FLUTTER_ENV=development

# En staging
export FLUTTER_ENV=staging

# En producción
export FLUTTER_ENV=production
```

### 7. Verificar configuración

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

### Variables de entorno

El sistema utiliza variables de entorno para una configuración flexible y segura:

| Variable | Descripción | Valores posibles | Valor por defecto |
|----------|-------------|------------------|-------------------|
| `SENTRY_DSN` | DSN de Sentry | URL válida de Sentry | `YOUR_SENTRY_DSN_HERE` |
| `ENVIRONMENT` | Entorno de la aplicación | `development`, `staging`, `production` | `development` |
| `DEBUG_LOGGING` | Habilitar logging detallado | `true`, `false` | `true` |
| `ENABLE_METRICS_MONITORING` | Habilitar monitoreo de métricas | `true`, `false` | `true` |
| `ENABLE_ALERTS` | Habilitar alertas automáticas | `true`, `false` | `true` |
| `ENABLE_SCREENSHOTS` | Habilitar captura de pantallas | `true`, `false` | `true` |
| `ENABLE_VIEW_HIERARCHY` | Habilitar captura de jerarquía de vistas | `true`, `false` | `true` |
| `TRACES_SAMPLE_RATE` | Nivel de muestreo para transacciones | `0.0` a `1.0` | `1.0` |
| `PROFILES_SAMPLE_RATE` | Nivel de muestreo para perfiles | `0.0` a `1.0` | `1.0` |

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
