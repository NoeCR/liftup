import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSelector extends ConsumerStatefulWidget {
  const LanguageSelector({super.key});

  @override
  ConsumerState<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends ConsumerState<LanguageSelector> {
  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;
    final languageName = _getLanguageName(currentLocale);
    final flag = _getLanguageFlag(currentLocale);

    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(context.tr('settings.language')),
      subtitle: Text(context.tr('settings.languageDescription')),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(languageName, style: Theme.of(context).textTheme.bodyMedium),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
      onTap: () => _showLanguageDialog(context),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final supportedLocales = context.supportedLocales;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.tr('settings.language')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  supportedLocales.map((locale) {
                    final isSelected = locale == context.locale;
                    final languageName = _getLanguageName(locale);
                    final flag = _getLanguageFlag(locale);

                    return ListTile(
                      leading: Text(flag, style: const TextStyle(fontSize: 24)),
                      title: Text(languageName),
                      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                      onTap: () {
                        Navigator.of(context).pop();
                        _changeLanguage(context, locale);
                      },
                    );
                  }).toList(),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.tr('common.cancel'))),
            ],
          ),
    );
  }

  void _changeLanguage(BuildContext context, Locale locale) {
    context.setLocale(locale);

    // Safely show success message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.mounted) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('settings.languageChanged', namedArgs: {'language': _getLanguageName(locale)})),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } catch (e) {
          // Si no hay Scaffold disponible, no mostrar el SnackBar
          // The language change was already applied correctly
        }
      }
    });
  }

  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'es':
        return context.tr('settings.spanish');
      case 'en':
        return context.tr('settings.english');
      default:
        return context.tr('settings.spanish');
    }
  }

  String _getLanguageFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'es':
        return '🇪🇸';
      case 'en':
        return '🇺🇸';
      default:
        return '🇪🇸';
    }
  }
}
