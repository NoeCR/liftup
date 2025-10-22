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
import 'core/theme/theme_provider.dart';
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
  // Initialize logging service first (needed for error logging)
  LoggingService.instance.initialize();

  // Configure global error handling early
  _setupGlobalErrorHandling();

  // Initialize services in parallel where possible
  await _initializeServicesInParallel();

  // Initialize database and progression templates
  await _initializeDatabaseAndTemplates();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('es'), Locale('en')],
      path: 'assets/locales',
      fallbackLocale: const Locale('es'),
      child: const ProviderScope(child: LiftlyApp()),
    ),
  );
}

/// Initialize services that can run in parallel
Future<void> _initializeServicesInParallel() async {
  try {
    // Initialize Hive and user context in parallel
    await Future.wait([Hive.initFlutter(), UserContextService.instance.initialize()]);

    // Register Hive adapters after initialization
    HiveAdapters.registerAdapters();

    // Configure Sentry components in parallel
    final sentryTasks = <Future>[];

    if (SentryDsnConfig.isAlertsEnabled) {
      sentryTasks.add(Future(() => SentryAlertsConfig.configureAlerts()));
    }

    sentryTasks.add(SentryMetricsConfig.initialize());

    await Future.wait(sentryTasks);

    // Start monitoring services if enabled
    if (SentryDsnConfig.isMetricsMonitoringEnabled) {
      MetricsMonitor.instance.startMonitoring();
      HealthMonitor.instance.startMonitoring();
    }

    LoggingService.instance.info('Core services initialized successfully');
  } catch (e, stackTrace) {
    LoggingService.instance.error('Failed to initialize core services', e, stackTrace, {
      'component': 'core_services_initialization',
    });
    rethrow;
  }
}

/// Initialize database and progression templates
Future<void> _initializeDatabaseAndTemplates() async {
  try {
    final dbService = DatabaseService.getInstance();
    await dbService.initialize();

    // Initialize progression templates in background to not block UI
    _initializeProgressionTemplatesInBackground();

    LoggingService.instance.info('Database initialized successfully');
  } catch (e, stackTrace) {
    LoggingService.instance.error('Failed to initialize database', e, stackTrace, {
      'component': 'database_initialization',
    });
    rethrow;
  }
}

/// Initialize progression templates in background
void _initializeProgressionTemplatesInBackground() {
  Future(() async {
    try {
      final container = ProviderContainer();
      final templateService = container.read(progressionTemplateServiceProvider.notifier);
      await templateService.initializeBuiltInTemplates();
      container.dispose();
      LoggingService.instance.info('Progression templates initialized successfully');
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error initializing progression templates', e, stackTrace, {
        'component': 'progression_templates_initialization',
      });
    }
  });
}

/// Configures global error handling
void _setupGlobalErrorHandling() {
  // Capture Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    LoggingService.instance.error('Flutter Error: ${details.exception}', details.exception, details.stack, {
      'component': 'flutter_error',
      'library': details.library,
      'context': details.context?.toString(),
    });
  };

  // Capture platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    LoggingService.instance.error('Platform Error: $error', error, stack, {'component': 'platform_error'});
    return true;
  };
}

class LiftlyApp extends ConsumerWidget {
  const LiftlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp.router(
      title: 'Liftly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
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
