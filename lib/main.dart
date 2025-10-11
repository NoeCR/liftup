import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'common/themes/app_theme.dart';
import 'core/database/database_service.dart';
import 'core/database/hive_adapters.dart';
import 'core/logging/logging.dart';
import 'core/navigation/app_router.dart';
import 'features/progression/services/progression_template_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize easy_localization
  await EasyLocalization.ensureInitialized();

  // Initialize environment service
  await EnvironmentService.instance.initialize();

  // Initialize Sentry and run the application
  await SentryConfig.initialize(appRunner: _runApp);
}

/// Runs after Sentry has been initialized successfully
void _runApp() async {
  print('Starting _runApp()');

  // Initialize logging service
  print('Initializing LoggingService');
  LoggingService.instance.initialize();
  print('LoggingService initialized');

  // Initialize user context service
  print('Initializing UserContextService');
  await UserContextService.instance.initialize();
  print('UserContextService initialized');

  // Configure Sentry alerts and metrics
  print('Configuring Sentry');
  if (SentryDsnConfig.isAlertsEnabled) {
    SentryAlertsConfig.configureAlerts();
  }
  await SentryMetricsConfig.initialize();
  print('Sentry configured');

  // Start metrics and health monitoring when enabled
  if (SentryDsnConfig.isMetricsMonitoringEnabled) {
    MetricsMonitor.instance.startMonitoring();
    HealthMonitor.instance.startMonitoring();
  }

  // Configure global error handling
  _setupGlobalErrorHandling();

  // Initialize Hive and register adapters once
  print('Initializing Hive');
  await Hive.initFlutter();
  HiveAdapters.registerAdapters();
  print('Hive initialized');

  // Initialize database singleton before running the app
  try {
    print('About to initialize DatabaseService');
    print('DatabaseService instance created');
    final dbService = DatabaseService.getInstance();
    print('Calling initialize method');
    await dbService.initialize();
    print('Database initialized successfully');

    // Initialize progression templates
    try {
      ProgressionTemplateService.initializeTemplates();
      LoggingService.instance.info(
        'Progression templates initialized successfully',
      );
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error initializing progression templates',
        e,
        stackTrace,
        {'component': 'progression_templates_initialization'},
      );
    }
  } catch (e, stackTrace) {
    print('Error initializing database: $e');
    print('Stack trace: $stackTrace');
    // If initialization fails, show error but do not auto-reset
    print(
      'Database initialization failed. User can manually reset from settings if needed.',
    );
    rethrow; // Re-throw to prevent app from running with broken database
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('es'), Locale('en')],
      path: 'assets/locales',
      fallbackLocale: const Locale('es'),
      child: const ProviderScope(child: LiftlyApp()),
    ),
  );
}

/// Configures global error handling
void _setupGlobalErrorHandling() {
  // Capture Flutter errors
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

  // Capture platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    LoggingService.instance.error('Platform Error: $error', error, stack, {
      'component': 'platform_error',
    });
    return true;
  };
}

class LiftlyApp extends StatelessWidget {
  const LiftlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Liftly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: [
        ...context.localizationDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: AppRouter.router,
    );
  }
}
