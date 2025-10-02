import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'es';
  
  static LocalizationService? _instance;
  static LocalizationService get instance => _instance ??= LocalizationService._();
  
  LocalizationService._();
  
  Map<String, dynamic> _localizedStrings = {};
  String _currentLanguage = _defaultLanguage;
  
  String get currentLanguage => _currentLanguage;
  
  // Stream para notificar cambios de idioma
  final ValueNotifier<String> _languageNotifier = ValueNotifier(_defaultLanguage);
  ValueNotifier<String> get languageNotifier => _languageNotifier;
  
  /// Inicializa el servicio de localización
  Future<void> initialize() async {
    await _loadLanguage();
    await _loadLocalizedStrings();
  }
  
  /// Carga el idioma guardado en preferencias
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? _defaultLanguage;
    _languageNotifier.value = _currentLanguage;
  }
  
  /// Carga las cadenas localizadas desde el archivo JSON
  Future<void> _loadLocalizedStrings() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/locales/$_currentLanguage.json',
      );
      _localizedStrings = json.decode(jsonString);
    } catch (e) {
      // Si falla, intentar cargar el idioma por defecto
      if (_currentLanguage != _defaultLanguage) {
        _currentLanguage = _defaultLanguage;
        final String jsonString = await rootBundle.loadString(
          'assets/locales/$_defaultLanguage.json',
        );
        _localizedStrings = json.decode(jsonString);
      } else {
        throw Exception('No se pudo cargar el archivo de localización');
      }
    }
  }
  
  /// Cambia el idioma de la aplicación
  Future<void> changeLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;
    
    _currentLanguage = languageCode;
    _languageNotifier.value = languageCode;
    
    // Guardar en preferencias
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    
    // Recargar las cadenas localizadas
    await _loadLocalizedStrings();
  }
  
  /// Obtiene una cadena localizada
  String getString(String key) {
    final keys = key.split('.');
    dynamic value = _localizedStrings;
    
    for (final k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return key; // Retorna la clave si no se encuentra
      }
    }
    
    return value?.toString() ?? key;
  }
  
  /// Obtiene una cadena localizada con parámetros
  String getStringWithParams(String key, Map<String, dynamic> params) {
    String text = getString(key);
    
    params.forEach((paramKey, paramValue) {
      text = text.replaceAll('{$paramKey}', paramValue.toString());
    });
    
    return text;
  }
  
  /// Lista de idiomas disponibles
  static const List<Map<String, String>> availableLanguages = [
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
  ];
  
  /// Obtiene el nombre del idioma actual
  String getCurrentLanguageName() {
    final language = availableLanguages.firstWhere(
      (lang) => lang['code'] == _currentLanguage,
      orElse: () => availableLanguages.first,
    );
    return language['name'] ?? 'Español';
  }
  
  /// Obtiene la bandera del idioma actual
  String getCurrentLanguageFlag() {
    final language = availableLanguages.firstWhere(
      (lang) => lang['code'] == _currentLanguage,
      orElse: () => availableLanguages.first,
    );
    return language['flag'] ?? '🇪🇸';
  }
}
