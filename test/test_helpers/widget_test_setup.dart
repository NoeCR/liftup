import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'fake_asset_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WidgetTestSetup {
  static Future<void> ensureLocalizationInitialized() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  }

  static Widget createTestWidget({
    required Widget child,
    List<Override> overrides = const [],
    Locale locale = const Locale('en'),
  }) {
    return ProviderScope(
      overrides: overrides,
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('es')],
        path: 'assets/locales',
        fallbackLocale: const Locale('en'),
        startLocale: locale,
        assetLoader: const FakeAssetLoader(),
        child: Builder(
          builder:
              (context) => MaterialApp(
                home: child,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
              ),
        ),
      ),
    );
  }
}
