import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/navigation/app_router.dart';
import 'common/themes/app_theme.dart';
import 'core/database/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database normally
  final container = ProviderContainer();
  try {
    await container.read(databaseServiceProvider.future);
    print('Database initialized successfully');
  } catch (e) {
    print('Error initializing database: $e');
    // If initialization fails, show error but don't auto-reset
    print(
      'Database initialization failed. User can manually reset from settings if needed.',
    );
  }

  runApp(
    UncontrolledProviderScope(container: container, child: const LiftUpApp()),
  );
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
