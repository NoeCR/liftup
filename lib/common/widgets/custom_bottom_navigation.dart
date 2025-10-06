import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/navigation/app_router.dart';
import '../themes/app_theme.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigation({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: AppTheme.elevationXL,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'home.title'.tr(),
                index: 0,
                route: AppRouter.home,
              ),
              _buildNavItem(
                context,
                icon: Icons.fitness_center_outlined,
                activeIcon: Icons.fitness_center,
                label: 'exercises.title'.tr(),
                index: 1,
                route: AppRouter.exerciseList,
              ),
              _buildNavItem(
                context,
                icon: Icons.play_circle_outline,
                activeIcon: Icons.play_circle,
                label: 'session.train'.tr(),
                index: 2,
                route: AppRouter.session,
              ),
              _buildNavItem(
                context,
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart,
                label: 'statistics.title'.tr(),
                index: 3,
                route: AppRouter.statistics,
              ),
              _buildNavItem(
                context,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'home.settings'.tr(),
                index: 4,
                route: AppRouter.settings,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required String route,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isActive ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
