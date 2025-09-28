import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../notifiers/routine_section_template_notifier.dart';
import '../notifiers/routine_notifier.dart';
import '../models/routine_section_template.dart';
import '../../../common/enums/section_muscle_group_enum.dart';
import '../../../common/widgets/custom_bottom_navigation.dart';

class SectionSelectionPage extends ConsumerStatefulWidget {
  final String routineId;
  final String dayId;

  const SectionSelectionPage({
    super.key,
    required this.routineId,
    required this.dayId,
  });

  @override
  ConsumerState<SectionSelectionPage> createState() => _SectionSelectionPageState();
}

class _SectionSelectionPageState extends ConsumerState<SectionSelectionPage> {
  final Set<String> _selectedSectionIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final sectionTemplatesAsync = ref.watch(routineSectionTemplateNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Secciones'),
        backgroundColor: colorScheme.surface,
        actions: [
          if (_selectedSectionIds.isNotEmpty)
            TextButton(
              onPressed: _saveSections,
              child: Text(
                'Guardar (${_selectedSectionIds.length})',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: sectionTemplatesAsync.when(
        data: (sectionTemplates) {
          if (sectionTemplates.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              _buildInstructions(),
              Expanded(
                child: _buildSectionTemplatesList(sectionTemplates),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _buildErrorState(err),
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildInstructions() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Selecciona las secciones que quieres incluir en tu rutina. Podrás añadir ejercicios a cada sección después.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTemplatesList(List<RoutineSectionTemplate> sectionTemplates) {
    // Agrupar por categorías
    final groupedTemplates = <String, List<RoutineSectionTemplate>>{};
    
    for (final template in sectionTemplates) {
      final category = _getCategoryName(template.muscleGroup);
      groupedTemplates.putIfAbsent(category, () => []).add(template);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groupedTemplates.length,
      itemBuilder: (context, index) {
        final category = groupedTemplates.keys.elementAt(index);
        final templates = groupedTemplates[category]!;

        return _buildCategorySection(category, templates);
      },
    );
  }

  Widget _buildCategorySection(String category, List<RoutineSectionTemplate> templates) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            category,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...templates.map((template) => _buildSectionTemplateCard(template)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSectionTemplateCard(RoutineSectionTemplate template) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedSectionIds.contains(template.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              _selectedSectionIds.add(template.id);
            } else {
              _selectedSectionIds.remove(template.id);
            }
          });
        },
        title: Text(
          template.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: template.description != null
            ? Text(
                template.description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        secondary: Icon(
          _getIconData(template.iconName),
          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        activeColor: colorScheme.primary,
        checkColor: colorScheme.onPrimary,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings_suggest,
            size: 80,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay plantillas de secciones',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Ve a Configuración > Configurar Secciones para crear plantillas personalizadas.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              context.push('/section-templates');
            },
            icon: const Icon(Icons.settings),
            label: const Text('Configurar Secciones'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar secciones',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              ref.invalidate(routineSectionTemplateNotifierProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(SectionMuscleGroup? muscleGroup) {
    if (muscleGroup == null) return 'Otros';
    
    switch (muscleGroup) {
      case SectionMuscleGroup.warmup:
      case SectionMuscleGroup.cooldown:
        return 'Preparación y Recuperación';
      case SectionMuscleGroup.chest:
      case SectionMuscleGroup.back:
      case SectionMuscleGroup.shoulders:
      case SectionMuscleGroup.trapezius:
        return 'Torso Superior';
      case SectionMuscleGroup.biceps:
      case SectionMuscleGroup.triceps:
        return 'Brazos';
      case SectionMuscleGroup.quadriceps:
      case SectionMuscleGroup.hamstrings:
      case SectionMuscleGroup.calves:
        return 'Piernas';
      case SectionMuscleGroup.core:
        return 'Core';
      case SectionMuscleGroup.cardio:
        return 'Cardio';
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'warm_up':
        return Icons.whatshot;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'sports_gymnastics':
        return Icons.sports_gymnastics;
      case 'pool':
        return Icons.pool;
      case 'directions_run':
        return Icons.directions_run;
      case 'sports_martial_arts':
        return Icons.sports_martial_arts;
      case 'sports_tennis':
        return Icons.sports_tennis;
      case 'sports_basketball':
        return Icons.sports_basketball;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'sports_volleyball':
        return Icons.sports_volleyball;
      case 'sports_handball':
        return Icons.sports_handball;
      case 'sports_kabaddi':
        return Icons.sports_kabaddi;
      case 'sports_mma':
        return Icons.sports_mma;
      case 'sports_rugby':
        return Icons.sports_rugby;
      case 'sports_cricket':
        return Icons.sports_cricket;
      case 'sports_golf':
        return Icons.sports_golf;
      case 'sports_hockey':
        return Icons.sports_hockey;
      case 'sports_baseball':
        return Icons.sports_baseball;
      case 'sports_football':
        return Icons.sports_football;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'sports':
        return Icons.sports;
      case 'sports_score':
        return Icons.sports_score;
      case 'sports_bar':
        return Icons.sports_bar;
      case 'sports_cafe':
        return Icons.local_cafe;
      case 'spa':
        return Icons.spa;
      case 'air':
        return Icons.air;
      case 'thermostat':
        return Icons.thermostat;
      default:
        return Icons.fitness_center;
    }
  }

  void _saveSections() {
    if (_selectedSectionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos una sección'),
        ),
      );
      return;
    }

    // Guardar secciones seleccionadas
    ref.read(routineNotifierProvider.notifier).addSectionsToDay(
      widget.routineId,
      widget.dayId,
      _selectedSectionIds.toList(),
    );

    // Navegar de vuelta
    context.pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedSectionIds.length} secciones añadidas a la rutina'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
