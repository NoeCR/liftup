import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/localization/localization_service.dart';
import '../../../common/localization/localized_text.dart';

class LanguageSelector extends ConsumerStatefulWidget {
  const LanguageSelector({super.key});

  @override
  ConsumerState<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends ConsumerState<LanguageSelector> {
  @override
  Widget build(BuildContext context) {
    final localizationService = LocalizationService.instance;
    
    return ListTile(
      leading: const Icon(Icons.language),
      title: const LocalizedText('settings.language'),
      subtitle: const LocalizedText('settings.languageDescription'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            localizationService.getCurrentLanguageFlag(),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Text(
            localizationService.getCurrentLanguageName(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
      onTap: () => _showLanguageDialog(context),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const LocalizedText('settings.language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LocalizationService.availableLanguages.map((language) {
            final isSelected = language['code'] == LocalizationService.instance.currentLanguage;
            
            return ListTile(
              leading: Text(
                language['flag']!,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(language['name']!),
              trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
              onTap: () async {
                Navigator.of(context).pop();
                await _changeLanguage(language['code']!);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const LocalizedText('common.cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeLanguage(String languageCode) async {
    try {
      await LocalizationService.instance.changeLanguage(languageCode);
      
      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: LocalizedText(
              'settings.languageChanged',
              params: {'language': LocalizationService.instance.getCurrentLanguageName()},
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // El LocalizationWrapper se encargará de reconstruir la app automáticamente
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar idioma: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}
