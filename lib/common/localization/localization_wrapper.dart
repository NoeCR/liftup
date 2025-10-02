import 'package:flutter/material.dart';
import 'localization_service.dart';

/// Widget que envuelve la aplicación y escucha cambios de idioma
class LocalizationWrapper extends StatefulWidget {
  final Widget child;

  const LocalizationWrapper({
    super.key,
    required this.child,
  });

  @override
  State<LocalizationWrapper> createState() => _LocalizationWrapperState();
}

class _LocalizationWrapperState extends State<LocalizationWrapper> {
  @override
  void initState() {
    super.initState();
    // Escuchar cambios de idioma
    LocalizationService.instance.languageNotifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    // Remover el listener
    LocalizationService.instance.languageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    // Reconstruir el widget cuando cambie el idioma
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
