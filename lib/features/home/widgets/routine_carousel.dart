import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/themes/app_theme.dart';
import '../../sessions/models/workout_session.dart';
import '../../sessions/notifiers/session_notifier.dart';
import '../models/routine.dart';
import '../notifiers/auto_routine_selection_notifier.dart';
import '../notifiers/routine_notifier.dart';
import '../notifiers/selected_routine_provider.dart';
import '../services/background_image_service.dart';
import 'background_image_selector.dart';

/// Widget carousel para mostrar las rutinas con navegación por puntos
class RoutineCarousel extends ConsumerStatefulWidget {
  const RoutineCarousel({super.key});

  @override
  ConsumerState<RoutineCarousel> createState() => _RoutineCarouselState();
}

class _RoutineCarouselState extends ConsumerState<RoutineCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  String _selectedMenuOption = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer(
      builder: (context, ref, child) {
        final routineAsync = ref.watch(routineNotifierProvider);

        return routineAsync.when(
          data: (routines) {
            if (routines.isEmpty) {
              return _buildEmptyState();
            }

            // Auto-select routine based on day of week or first routine if none selected
            if (_selectedMenuOption.isEmpty || !routines.any((r) => r.name == _selectedMenuOption)) {
              if (routines.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // Get auto-selected routine or fallback to first
                  final autoSelectionInfo = ref.read(autoRoutineSelectionNotifierProvider);

                  Routine? routineToSelect;
                  if (autoSelectionInfo.hasSelection) {
                    routineToSelect = autoSelectionInfo.selectedRoutine;
                  } else {
                    routineToSelect = routines.first;
                  }

                  if (routineToSelect != null) {
                    final index = routines.indexWhere((r) => r.id == routineToSelect!.id);
                    if (index != -1) {
                      setState(() {
                        _selectedMenuOption = routineToSelect!.name;
                        _currentPage = index;
                      });
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      ref.read(selectedRoutineIdProvider.notifier).state = routineToSelect.id;
                    }
                  }
                });
              }
            }

            return Column(
              children: [
                // Carousel
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                        _selectedMenuOption = routines[index].name;
                      });
                      ref.read(selectedRoutineIdProvider.notifier).state = routines[index].id;
                    },
                    itemCount: routines.length,
                    itemBuilder: (context, index) {
                      final routine = routines[index];
                      return _buildCarouselItem(routine, colorScheme);
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                // Dot indicators
                _buildDotIndicators(routines.length, colorScheme),
              ],
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(),
        );
      },
    );
  }

  Widget _buildCarouselItem(Routine routine, ColorScheme colorScheme) {
    final hasActiveSession = ref
        .watch(sessionNotifierProvider)
        .maybeWhen(
          data:
              (sessions) => sessions.any(
                (s) => (s.status == SessionStatus.active || s.status == SessionStatus.paused) && s.endTime == null,
              ),
          orElse: () => false,
        );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        onTap:
            hasActiveSession
                ? null
                : () {
                  // La selección se maneja automáticamente en onPageChanged
                },
        onLongPress: () => _showBackgroundImageSelector(routine),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            boxShadow: [
              BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                _buildBackgroundImage(routine),
                // Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withValues(alpha: 0.3), Colors.black.withValues(alpha: 0.7)],
                    ),
                  ),
                ),
                // Content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        routine.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Text(
                        '${routine.sections.length} ${context.tr('home.sections')}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // Edit button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _showBackgroundImageSelector(routine),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(Routine routine) {
    return FutureBuilder<String?>(
      future: BackgroundImageService.getBackgroundImageForRoutine(routine.id),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final imagePath = snapshot.data!;
          if (imagePath.startsWith('assets/')) {
            return Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultBackground(routine);
              },
            );
          } else {
            return Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultBackground(routine);
              },
            );
          }
        }

        return _buildDefaultBackground(routine);
      },
    );
  }

  Widget _buildDefaultBackground(Routine routine) {
    return Container(
      decoration: BoxDecoration(gradient: BackgroundImageService.getRoutineGradient(routine.name)),
      child: const Icon(Icons.fitness_center, size: 80, color: Colors.white),
    );
  }

  Future<void> _showBackgroundImageSelector(Routine routine) async {
    final currentImage = await BackgroundImageService.getBackgroundImageForRoutine(routine.id);

    if (!mounted) return;

    await showDialog(
      context: context,
      builder:
          (context) => BackgroundImageSelector(
            routineId: routine.id,
            routineName: routine.name,
            currentImagePath: currentImage,
            onImageSelected: (imagePath) async {
              if (imagePath != null) {
                await BackgroundImageService.setBackgroundImageForRoutine(routine.id, imagePath);
              } else {
                // Remove current image
                await BackgroundImageService.setBackgroundImageForRoutine(routine.id, '');
              }
              if (mounted) {
                setState(() {});
              }
            },
          ),
    );
  }

  Widget _buildDotIndicators(int totalPages, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _currentPage == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center_outlined, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              context.tr('home.noRoutines'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              context.tr('home.errorLoadingRoutines'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }
}
