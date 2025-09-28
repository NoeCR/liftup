import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/custom_bottom_navigation.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        backgroundColor: colorScheme.surface,
      ),
      body: const Center(child: Text('Estadísticas - En desarrollo')),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 3),
    );
  }
}
