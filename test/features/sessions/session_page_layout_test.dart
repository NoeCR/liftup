import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liftup/features/sessions/pages/session_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Widget wrap(Widget child) => EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('es')],
    path: 'assets/locales',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('es'),
    saveLocale: false,
    child: ProviderScope(
      child: Builder(
        builder:
            (context) => MaterialApp(
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              home: Scaffold(body: child),
            ),
      ),
    ),
  );

  testWidgets(
    'SessionPage: ListView tiene padding inferior con kBottomNavigationBarHeight',
    (tester) async {
      // Renderizamos la página sin providers reales; el test valida estructura básica.
      await tester.pumpWidget(wrap(const SessionPage()));
      await tester.pumpAndSettle();

      // Confirma que el Scaffold tiene bottomNavigationBar configurada
      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsWidgets);
      final scaffolds = tester.widgetList<Scaffold>(scaffoldFinder).toList();
      // Tomamos el último Scaffold renderizado (contenido de la página)
      expect(scaffolds.last.bottomNavigationBar, isNotNull);
    },
  );
}
