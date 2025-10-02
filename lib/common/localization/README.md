# 🌍 Sistema de Internacionalización con Easy Localization

Este proyecto utiliza **easy_localization** para manejar la internacionalización de manera eficiente y flexible.

## 🚀 Ventajas de Easy Localization

- ✅ **Sintaxis simple**: `'hello'.tr()` en lugar de widgets complejos
- ✅ **Soporte para parámetros**: `'hello_user'.tr(namedArgs: {'name': 'Juan'})`
- ✅ **Cambio de idioma en tiempo real** sin recargar la app
- ✅ **Soporte para pluralización** automática
- ✅ **Carga dinámica** de idiomas
- ✅ **Mejor rendimiento** que implementaciones manuales
- ✅ **Funciona en cualquier widget** (Text, AppBar, Dialog, etc.)

## 📁 Estructura de Archivos

```
assets/locales/
├── es.json          # Traducciones en español
└── en.json          # Traducciones en inglés
```

## 🔧 Configuración

### 1. Dependencia en pubspec.yaml
```yaml
dependencies:
  easy_localization: ^3.0.7
```

### 2. Configuración en main.dart
```dart
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],
      path: 'assets/locales',
      fallbackLocale: const Locale('es', 'ES'),
      child: MyApp(),
    ),
  );
}
```

### 3. Configuración en MaterialApp
```dart
MaterialApp(
  localizationsDelegates: [
    ...context.localizationDelegates,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: context.supportedLocales,
  locale: context.locale,
  // ... resto de configuración
)
```

## 📝 Uso Básico

### Texto Simple
```dart
Text('app.title'.tr())
```

### Con Parámetros Nombrados
```dart
Text('settings.languageChanged'.tr(namedArgs: {'language': 'Español'}))
```

### Con Parámetros Posicionales
```dart
Text('common.series'.tr(args: ['3']))
```

### Pluralización
```dart
Text('common.series'.plural(3))  // "3 series"
Text('common.series'.plural(1))  // "1 serie"
```

## 🎯 Ejemplos por Contexto

### AppBar
```dart
AppBar(
  title: Text('settings.title'.tr()),
)
```

### Dialog
```dart
AlertDialog(
  title: Text('routine.deleteRoutine'.tr()),
  content: Text('routine.deleteRoutineDescription'.tr()),
  actions: [
    TextButton(
      onPressed: () {},
      child: Text('common.cancel'.tr()),
    ),
  ],
)
```

### SnackBar
```dart
SnackBar(
  content: Text('routine.routineDeletedSuccess'.tr()),
  backgroundColor: Colors.green,
)
```

### ListTile
```dart
ListTile(
  title: Text('settings.language'.tr()),
  subtitle: Text('settings.languageDescription'.tr()),
)
```

### Tooltip
```dart
Tooltip(
  message: 'home.manageRoutines'.tr(),
  child: Icon(Icons.settings),
)
```

## 🔄 Cambio de Idioma

### Programático
```dart
// Cambiar a inglés
context.setLocale(Locale('en', 'US'));

// Cambiar a español
context.setLocale(Locale('es', 'ES'));
```

### Obtener Idioma Actual
```dart
String currentLanguage = context.locale.languageCode;
```

## 📋 Estructura de Archivos JSON

### es.json
```json
{
  "app": {
    "title": "LiftUp",
    "welcome": "¡Bienvenido a LiftUp!"
  },
  "settings": {
    "title": "Configuración",
    "languageChanged": "Idioma cambiado a {language}"
  },
  "common": {
    "cancel": "Cancelar",
    "delete": "Eliminar",
    "series": "{count} series"
  }
}
```

### en.json
```json
{
  "app": {
    "title": "LiftUp",
    "welcome": "Welcome to LiftUp!"
  },
  "settings": {
    "title": "Settings",
    "languageChanged": "Language changed to {language}"
  },
  "common": {
    "cancel": "Cancel",
    "delete": "Delete",
    "series": "{count} sets"
  }
}
```

## 🎨 Características Avanzadas

### Pluralización Automática
```dart
// En el JSON
{
  "items": {
    "zero": "No items",
    "one": "One item",
    "other": "{count} items"
  }
}

// En el código
Text('items'.plural(0))  // "No items"
Text('items'.plural(1))  // "One item"
Text('items'.plural(5))  // "5 items"
```

### Validación de Formularios
```dart
String? validateField(String? value) {
  if (value == null || value.isEmpty) {
    return 'common.error'.tr();
  }
  return null;
}
```

### RichText
```dart
RichText(
  text: TextSpan(
    children: [
      TextSpan(text: 'app.welcome'.tr()),
      TextSpan(
        text: 'app.title'.tr(),
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  ),
)
```

## 🚀 Migración desde Implementación Manual

### Antes (Implementación Manual)
```dart
LocalizedText('app.title')
LocalizedText('settings.languageChanged', params: {'language': 'Español'})
```

### Después (Easy Localization)
```dart
Text('app.title'.tr())
Text('settings.languageChanged'.tr(namedArgs: {'language': 'Español'}))
```

## 📱 Idiomas Soportados

- 🇪🇸 **Español** (es_ES) - Idioma por defecto
- 🇺🇸 **English** (en_US)

## 🔧 Agregar Nuevos Idiomas

1. Crear archivo `assets/locales/[codigo].json`
2. Añadir el Locale en `supportedLocales`
3. Las traducciones se cargarán automáticamente

## 🎯 Mejores Prácticas

1. **Usar claves descriptivas**: `'settings.language'` en lugar de `'lang'`
2. **Agrupar por funcionalidad**: `app.*`, `settings.*`, `common.*`
3. **Usar parámetros nombrados** para mayor claridad
4. **Mantener consistencia** entre idiomas
5. **Probar todos los idiomas** antes de publicar

## 🐛 Solución de Problemas

### Error: "No localization found"
- Verificar que el archivo JSON existe en `assets/locales/`
- Verificar que la clave existe en el archivo JSON
- Verificar que `fallbackLocale` está configurado

### Error: "Context not found"
- Asegurarse de que el widget está dentro de `EasyLocalization`
- Usar `context.tr()` en lugar de `'text'.tr()` si es necesario

### Cambio de idioma no funciona
- Verificar que `context.setLocale()` se llama correctamente
- Verificar que el Locale está en `supportedLocales`

