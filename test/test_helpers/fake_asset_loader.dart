import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';

import 'package:easy_localization/easy_localization.dart';

/// Fake asset loader for tests that reads JSON files directly from assets/locales.
class FakeAssetLoader extends AssetLoader {
  const FakeAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final filePath = '$path/${locale.languageCode}.json';
    final file = File(filePath);
    if (await file.exists()) {
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    }
    return <String, dynamic>{};
  }
}
