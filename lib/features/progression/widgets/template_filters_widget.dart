import 'package:flutter/material.dart';
import 'package:liftly/features/progression/models/progression_template.dart';

class TemplateFiltersWidget extends StatefulWidget {
  final List<ProgressionTemplate> allTemplates;
  final Function(List<ProgressionTemplate>) onFiltersChanged;
  final bool showAdvancedFilters;

  const TemplateFiltersWidget({
    super.key,
    required this.allTemplates,
    required this.onFiltersChanged,
    this.showAdvancedFilters = true,
  });

  @override
  State<TemplateFiltersWidget> createState() => _TemplateFiltersWidgetState();
}

class _TemplateFiltersWidgetState extends State<TemplateFiltersWidget> {
  String _searchQuery = '';
  String? _selectedGoal;
  String? _selectedDifficulty;
  String? _selectedCategory;
  int? _selectedDuration;
  bool _showOnlyPhases = false;

  final List<String> _goals = [
    'hypertrophy',
    'strength',
    'powerlifting',
    'powerbuilding',
    'competition',
    'general',
  ];

  final List<String> _difficulties = ['easy', 'medium', 'hard'];

  final List<String> _categories = [
    'beginner',
    'intermediate',
    'advanced',
    'specialized',
  ];

  final List<int> _durations = [4, 6, 8, 9, 12, 16, 18, 20];

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  void _applyFilters() {
    List<ProgressionTemplate> filteredTemplates = widget.allTemplates;

    // Filtro de búsqueda
    if (_searchQuery.isNotEmpty) {
      filteredTemplates =
          filteredTemplates.where((template) {
            return template.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                template.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                template.detailedDescription.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();
    }

    // Filtro por objetivo
    if (_selectedGoal != null) {
      filteredTemplates =
          filteredTemplates.where((template) {
            return template.goal == _selectedGoal;
          }).toList();
    }

    // Filtro por dificultad
    if (_selectedDifficulty != null) {
      filteredTemplates =
          filteredTemplates.where((template) {
            return template.difficulty == _selectedDifficulty;
          }).toList();
    }

    // Filtro por categoría
    if (_selectedCategory != null) {
      filteredTemplates =
          filteredTemplates.where((template) {
            return template.category == _selectedCategory;
          }).toList();
    }

    // Filtro por duración
    if (_selectedDuration != null) {
      filteredTemplates =
          filteredTemplates.where((template) {
            return template.estimatedDuration == _selectedDuration;
          }).toList();
    }

    // Filtro por fases automáticas
    if (_showOnlyPhases) {
      filteredTemplates =
          filteredTemplates.where((template) {
            return template.customParameters['overload_type'] == 'phases';
          }).toList();
    }

    widget.onFiltersChanged(filteredTemplates);
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedGoal = null;
      _selectedDifficulty = null;
      _selectedCategory = null;
      _selectedDuration = null;
      _showOnlyPhases = false;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con botón de limpiar
            Row(
              children: [
                Icon(Icons.filter_list, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Filtros de Plantillas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Limpiar'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Barra de búsqueda
            TextField(
              decoration: InputDecoration(
                labelText: 'Buscar plantillas',
                hintText: 'Nombre, descripción...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                            _applyFilters();
                          },
                        )
                        : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _applyFilters();
              },
            ),
            const SizedBox(height: 16),

            // Filtros avanzados
            if (widget.showAdvancedFilters) ...[
              Text(
                'Filtros Avanzados',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Filtros en filas
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  // Filtro por objetivo
                  _buildFilterDropdown(
                    'Objetivo',
                    _selectedGoal,
                    _goals
                        .map(
                          (goal) => DropdownMenuItem(
                            value: goal,
                            child: Text(_getGoalDisplayName(goal)),
                          ),
                        )
                        .toList(),
                    (value) {
                      setState(() {
                        _selectedGoal = value;
                      });
                      _applyFilters();
                    },
                  ),

                  // Filtro por dificultad
                  _buildFilterDropdown(
                    'Dificultad',
                    _selectedDifficulty,
                    _difficulties
                        .map(
                          (difficulty) => DropdownMenuItem(
                            value: difficulty,
                            child: Text(_getDifficultyDisplayName(difficulty)),
                          ),
                        )
                        .toList(),
                    (value) {
                      setState(() {
                        _selectedDifficulty = value;
                      });
                      _applyFilters();
                    },
                  ),

                  // Filtro por categoría
                  _buildFilterDropdown(
                    'Categoría',
                    _selectedCategory,
                    _categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(_getCategoryDisplayName(category)),
                          ),
                        )
                        .toList(),
                    (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                      _applyFilters();
                    },
                  ),

                  // Filtro por duración
                  _buildFilterDropdown(
                    'Duración',
                    _selectedDuration?.toString(),
                    _durations
                        .map(
                          (duration) => DropdownMenuItem(
                            value: duration.toString(),
                            child: Text('$duration semanas'),
                          ),
                        )
                        .toList(),
                    (value) {
                      setState(() {
                        _selectedDuration =
                            value != null ? int.parse(value) : null;
                      });
                      _applyFilters();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Filtros especiales
              Row(
                children: [
                  Checkbox(
                    value: _showOnlyPhases,
                    onChanged: (value) {
                      setState(() {
                        _showOnlyPhases = value ?? false;
                      });
                      _applyFilters();
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Solo plantillas con fases automáticas',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],

            // Resumen de filtros activos
            if (_hasActiveFilters()) ...[
              const SizedBox(height: 16),
              _buildActiveFiltersSummary(theme, colorScheme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String? value,
    List<DropdownMenuItem<String>> items,
    Function(String?) onChanged,
  ) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: 'Todos',
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text(
                  'Todos',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              ...items,
            ],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersSummary(ThemeData theme, ColorScheme colorScheme) {
    final activeFilters = <String>[];

    if (_searchQuery.isNotEmpty) {
      activeFilters.add('Búsqueda: "$_searchQuery"');
    }
    if (_selectedGoal != null) {
      activeFilters.add('Objetivo: ${_getGoalDisplayName(_selectedGoal!)}');
    }
    if (_selectedDifficulty != null) {
      activeFilters.add(
        'Dificultad: ${_getDifficultyDisplayName(_selectedDifficulty!)}',
      );
    }
    if (_selectedCategory != null) {
      activeFilters.add(
        'Categoría: ${_getCategoryDisplayName(_selectedCategory!)}',
      );
    }
    if (_selectedDuration != null) {
      activeFilters.add('Duración: $_selectedDuration semanas');
    }
    if (_showOnlyPhases) {
      activeFilters.add('Solo fases automáticas');
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_alt, size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Filtros activos:',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children:
                activeFilters.map((filter) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      filter,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _searchQuery.isNotEmpty ||
        _selectedGoal != null ||
        _selectedDifficulty != null ||
        _selectedCategory != null ||
        _selectedDuration != null ||
        _showOnlyPhases;
  }

  String _getGoalDisplayName(String goal) {
    switch (goal) {
      case 'hypertrophy':
        return 'Hipertrofia';
      case 'strength':
        return 'Fuerza';
      case 'powerlifting':
        return 'Powerlifting';
      case 'powerbuilding':
        return 'Powerbuilding';
      case 'competition':
        return 'Competencia';
      case 'general':
        return 'General';
      default:
        return goal;
    }
  }

  String _getDifficultyDisplayName(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 'Fácil';
      case 'medium':
        return 'Intermedio';
      case 'hard':
        return 'Avanzado';
      default:
        return difficulty;
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'beginner':
        return 'Principiante';
      case 'intermediate':
        return 'Intermedio';
      case 'advanced':
        return 'Avanzado';
      case 'specialized':
        return 'Especializado';
      default:
        return category;
    }
  }
}
