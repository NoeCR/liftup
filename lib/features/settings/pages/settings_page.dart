import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/custom_bottom_navigation.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: colorScheme.surface,
      ),
      body: const Center(child: Text('Configuración - En desarrollo')),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 4),
    );
  }
}
