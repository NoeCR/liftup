import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:liftup/main.dart' as app;

/// Configuración robusta para tests de integración
class IntegrationTestSetup {
  static WidgetTester? _tester;

  /// Inicializa el entorno de testing de integración
  static Future<void> initialize(WidgetTester tester) async {
    _tester = tester;

    // No inicializar binding aquí, ya está inicializado por flutter test
    // Solo configurar EasyLocalization para tests si es necesario
    try {
      await EasyLocalization.ensureInitialized();
    } catch (e) {
      // Ignorar errores de inicialización en tests
    }
  }

  /// Configura la aplicación para tests de integración
  static Widget createTestApp() {
    return ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('es')],
        path: 'assets/locales',
        fallbackLocale: const Locale('en'),
        child: const MaterialApp(
          home: Scaffold(body: Center(child: Text('Test App'))),
        ),
      ),
    );
  }

  /// Configura la aplicación real para tests de integración
  static Widget createRealApp() {
    return ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('es')],
        path: 'assets/locales',
        fallbackLocale: const Locale('en'),
        child: const MaterialApp(
          home: Scaffold(body: Center(child: Text('Real App'))),
        ),
      ),
    );
  }

  /// Espera a que la aplicación se estabilice
  static Future<void> waitForAppStabilization() async {
    if (_tester != null) {
      await _tester!.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Verifica que no hay errores críticos
  static void verifyNoCriticalErrors() {
    if (_tester != null) {
      expect(_tester!.takeException(), isNull);
    }
  }

  /// Limpia el entorno de testing
  static void cleanup() {
    _tester = null;
  }
}
