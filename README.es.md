# LiftUp

Aplicación Flutter para planificar rutinas, aplicar progresiones de entrenamiento, registrar sesiones y visualizar estadísticas. Usa Riverpod, Hive, generación de código con build_runner, logging robusto y CI con GitHub Actions.

## Índice
- Descripción
- Características
- Tecnologías
- Requisitos
- Inicio Rápido
- Configuración (.env)
- Assets e Icono de App
- Generación de Código
- Ejecutar, Testear, Analizar
- Git Hooks
- CI/CD
- Arquitectura
- Gestión de Estado
- Persistencia y Datos
- Logging y Monitorización (Sentry)
- Temas (Theming)
- Estructura del Proyecto
- Comandos Útiles
- Problemas Comunes

## Descripción
LiftUp ayuda a gestionar rutinas y sesiones aplicando plantillas de progresión configurables (lineal, ondulante, escalonada, doble, wave, etc.). Incluye logging detallado y monitorización opcional con Sentry.

## Características
- Tipos de progresión: lineal, ondulante, escalonada, doble, wave, estática, inversa, autoregulada, sobrecarga, doble factor
- Gestión de rutinas y sesiones con persistencia local (Hive)
- Estadísticas y gráficos
- Arquitectura con Riverpod 2.x
- Integración de Logger + Sentry
- Generación de código con build_runner
- Git hooks y pipeline de CI (GitHub Actions)

## Tecnologías
- Flutter 3.35.5 (stable)
- Dart 3.7.x (incluido en Flutter)
- Riverpod 2.x, go_router, easy_localization
- Hive (almacenamiento local)
- json_serializable, build_runner
- logger, sentry_flutter

## Requisitos
- Flutter SDK 3.35.5 (stable)
- Android SDK y/o Xcode para builds de plataforma

## Inicio Rápido
```bash
# Clonar
git clone https://github.com/NoeCR/liftup.git
cd liftup

# Instalar dependencias
flutter pub get

# Generar código (providers, json, adaptadores de Hive)
flutter pub run build_runner build --delete-conflicting-outputs

# Ejecutar (selecciona dispositivo)
flutter run
```

## Configuración (.env)
Los archivos de entorno son necesarios localmente, pero no se suben al repositorio. Se esperan en la raíz:
- .env
- .env.development
- .env.staging
- .env.production

Ejemplo mínimo:
```bash
SENTRY_DSN=
API_BASE_URL=
FEATURE_FLAGS=
```
En CI se crean placeholders vacíos automáticamente antes de analizar y testear.

## Assets e Icono de App
Declarado en `pubspec.yaml`:
- `assets/images/`
- `assets/icons/`
- `assets/locales/`
- entradas `.env*` (placeholders creados en CI)

El icono se genera desde `assets/icons/app_icon.png` con flutter_launcher_icons:
```bash
dart run flutter_launcher_icons
```

## Generación de Código
```bash
# Build único
flutter pub run build_runner build --delete-conflicting-outputs
# Watch
flutter pub run build_runner watch --delete-conflicting-outputs
```
Si el analizador reporta `*.g.dart` faltantes, ejecuta el paso de build.

## Ejecutar, Testear, Analizar
```bash
# Formato
dart format -l 120 .

# Analizar (en CI los warnings no fallan)
flutter analyze --no-preamble

# Tests
flutter test
```

## Git Hooks
Los hooks en `.githooks/` formatean y analizan en commit, y ejecutan tests + analyze en push. En CI, infos/warnings no son fatales.

## CI/CD
Workflow: `.github/workflows/flutter-ci.yml`
- Configura Flutter 3.35.5 (stable)
- Cache de dependencias pub
- Crea placeholders `.env*`
- Ejecuta `build_runner`
- Analiza (warnings no fatales)
- Ejecuta tests

## Arquitectura
- UI: Flutter + go_router, easy_localization
- Estado: Riverpod `ProviderScope` con servicios/notifiers
- Dominio: lógica de progresión y plantillas
- Datos: Hive con adaptadores generados
- Observabilidad: `LoggingService` a consola y Sentry

## Gestión de Estado
Providers de Riverpod 2.x. Tipos `*Ref` deprecados reemplazados por `Ref`.

## Persistencia y Datos
Hive se inicializa al arranque; adaptadores registrados en `HiveAdapters`. Mantén el código generado actualizado.

## Logging y Monitorización (Sentry)
`LoggingService` ofrece logs por niveles y envía errores/fatales a Sentry con contexto/tags/usuario. Métricas/alertas mediante banderas de entorno.

## Temas (Theming)
`AppTheme` define temas claro/oscuro. En Flutter 3.35.x usa `CardThemeData`.

## Estructura del Proyecto
```
lib/
  common/
  core/
    logging/
    database/
    data_management/
  features/
    progression/
    sessions/
    exercise/
    statistics/
    home/
  main.dart
assets/
  icons/
  images/
  locales/
.githooks/
.github/workflows/
```

## Comandos Útiles
```bash
# Limpiar y restaurar
flutter clean && flutter pub get

# Codegen
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run build_runner watch --delete-conflicting-outputs

# Iconos
dart run flutter_launcher_icons
```

## Problemas Comunes
- `*.g.dart` faltantes: ejecutar build_runner.
- Fallos por `.env` en CI: los placeholders los crea el workflow.
- Conflictos de versiones: usar Flutter 3.35.5.
- Error de `CardTheme`: usar `CardThemeData`.

---
Para documentación en inglés, ver `README.md`.
