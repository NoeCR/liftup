import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/navigation/app_router.dart';
import 'common/themes/app_theme.dart';
import 'core/database/database_service.dart';
import 'core/database/hive_adapters.dart';
import 'common/widgets/auto_routine_initializer.dart';
import 'core/logging/logging.dart';

void main() async {
  // Inicializar Sentry y manejo global de errores
  await SentryConfig.initialize();
  
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar servicio de logging
  LoggingService.instance.initialize();
  
  // Inicializar servicio de contexto de usuario
  await UserContextService.instance.initialize();

  // Configurar alertas y métricas de Sentry
  SentryAlertsConfig.configureAlerts();
  await SentryMetricsConfig.initialize();

  // Iniciar monitoreo de métricas y salud
  MetricsMonitor.instance.startMonitoring();
  HealthMonitor.instance.startMonitoring();
  
  // Configurar manejo global de errores
  _setupGlobalErrorHandling();

  // Initialize Hive and register adapters once
  await Hive.initFlutter();
  HiveAdapters.registerAdapters();

  // Initialize database singleton before running the app
  try {
    await DatabaseService.getInstance().initialize();
    LoggingService.instance.info('Database initialized successfully');
  } catch (e, stackTrace) {
    LoggingService.instance.error(
      'Error initializing database',
      e,
      stackTrace,
      {'component': 'database_initialization'},
    );
    // If initialization fails, show error but don't auto-reset
    LoggingService.instance.warning(
      'Database initialization failed. User can manually reset from settings if needed.',
    );
  }

  runApp(
    const ProviderScope(child: AutoRoutineInitializer(child: LiftUpApp())),
  );
}

/// Configura el manejo global de errores
void _setupGlobalErrorHandling() {
  // Capturar errores de Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    LoggingService.instance.error(
      'Flutter Error: ${details.exception}',
      details.exception,
      details.stack,
      {
        'component': 'flutter_error',
        'library': details.library,
        'context': details.context?.toString(),
      },
    );
  };

  // Capturar errores de plataforma
  PlatformDispatcher.instance.onError = (error, stack) {
    LoggingService.instance.error(
      'Platform Error: $error',
      error,
      stack,
      {'component': 'platform_error'},
    );
    return true;
  };
}

class LiftUpApp extends StatelessWidget {
  const LiftUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LiftUp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Spanish
        Locale('en', 'US'), // English
      ],
      routerConfig: AppRouter.router,
    );
  }
}
