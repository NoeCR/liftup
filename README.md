# Liftly

A Flutter application for planning routines, applying training progression, tracking sessions, and visualizing statistics. The app uses Riverpod, Hive, build_runner code generation, robust logging, and GitHub Actions CI.

## Table of Contents
- Overview
- Features
- Tech Stack
- Requirements
- Quickstart
- Configuration (.env)
- Assets & App Icon
- Code Generation
- Run, Test, Lint
- Git Hooks
- CI/CD
- Architecture
- State Management
- Persistence & Data
- Logging & Monitoring (Sentry)
- Theming
- Project Structure
- Useful Commands
- Troubleshooting

## Overview
Liftly helps users manage workout routines and sessions while applying configurable progression templates (e.g., linear, undulating, stepped, double, wave). It includes detailed logging and optional Sentry monitoring.

### Rebranding
Formerly known as LiftUp. App name, icons, splash and theming updated to Liftly across Android, iOS and Web.

## Features
- Configurable progression types: linear, undulating, stepped, double, wave, static, reverse, autoregulated, overload, double factor
- Routine and session management with local persistence (Hive)
- Statistics and charts
- Riverpod 2.x app architecture
- Logger + Sentry integration
- Code generation with build_runner
- Git hooks and CI pipeline (GitHub Actions)

## Tech Stack
- Flutter 3.35.5 (stable)
- Dart 3.7.x (bundled with Flutter)
- Riverpod 2.x, go_router, easy_localization
- Hive (local storage)
- json_serializable, build_runner
- logger, sentry_flutter

## Requirements
- Flutter SDK 3.35.5 (stable)
- Android SDK and/or Xcode tooling for platform builds

## Quickstart
```bash
# Clone
git clone https://github.com/NoeCR/liftup.git
cd liftup

# Install dependencies
flutter pub get

# Generate code (providers, json, Hive adapters)
flutter pub run build_runner build --delete-conflicting-outputs

# Run (choose device)
flutter run
```

## Configuration (.env)
Environment files are required locally, but not committed to git. Expected files at repo root:
- .env
- .env.development
- .env.staging
- .env.production

Minimal example:
```bash
SENTRY_DSN=
API_BASE_URL=
FEATURE_FLAGS=
```
In CI, empty placeholders are created automatically before analyze/tests.

## Assets & App Icon
Declared in `pubspec.yaml`:
- `assets/images/`
- `assets/icons/`
- `assets/locales/`
- `.env*` entries (created as placeholders in CI)

App icon is generated from `assets/icons/app_icon.png` with flutter_launcher_icons:
```bash
dart run flutter_launcher_icons
```

Splash screen is generated with `flutter_native_splash`, using a padded variant `assets/icons/app_icon_splash.png` to avoid cropping on Android 12.

## Code Generation
```bash
# One time build
flutter pub run build_runner build --delete-conflicting-outputs
# Watch mode
flutter pub run build_runner watch --delete-conflicting-outputs
```
If analyzer errors mention missing `*.g.dart`, run the build step.

## Run, Test, Lint
```bash
# Format
dart format -l 120 .

# Analyze (non-fatal warnings in CI)
flutter analyze --no-preamble

# Tests
flutter test
```

## Git Hooks
Custom hooks live in `.githooks/` and are configured to format and analyze code on commit, and run tests + analyze on push. Analyzer infos/warnings are not fatal in CI.

## CI/CD
Workflow: `.github/workflows/flutter-ci.yml`
- Setup Flutter 3.35.5 (stable)
- Cache pub deps
- Create `.env*` placeholders
- Run `build_runner`
- Analyze (non-fatal warnings)
- Run tests

## Architecture
- UI: Flutter + go_router, easy_localization
- State: Riverpod `ProviderScope` with services/notifiers
- Domain: progression logic & templates
- Data: Hive local storage, adapters generated
- Observability: `LoggingService` to console and Sentry

## State Management
Riverpod 2.x providers. Deprecated `*Ref` types replaced by `Ref`.

## Persistence & Data
Hive is initialized at startup; adapters registered centrally (`HiveAdapters`). Keep generated code updated via build_runner.

## Logging & Monitoring (Sentry)
`LoggingService` provides leveled logs to console and forwards errors/fatals to Sentry with context/tags/user. Metrics/alerts configured via environment flags.

## Theming
`AppTheme` defines light/dark themes. Use `CardThemeData` with Flutter 3.35.x (avoid deprecated variants).

## Project Structure
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

## Useful Commands
```bash
# Clean + restore
flutter clean && flutter pub get

# Codegen (build/watch)
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run build_runner watch --delete-conflicting-outputs

# Icons
dart run flutter_launcher_icons
```

## Troubleshooting
- Missing `*.g.dart`: run build_runner.
- CI fails on `.env` assets: placeholders are created by workflow; ensure step exists.
- Version solving: use Flutter 3.35.5.
- CardTheme type mismatch: use `CardThemeData` for Flutter 3.35.x.

---
For Spanish documentation, see `README.es.md`.
