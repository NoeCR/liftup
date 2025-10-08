import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../models/progression_template.dart';
import '../../../common/enums/progression_type_enum.dart';
import '../../../core/database/database_service.dart';
import '../../../core/logging/logging.dart';

part 'progression_template_service.g.dart';

@riverpod
class ProgressionTemplateService extends _$ProgressionTemplateService {
  @override
  Future<List<ProgressionTemplate>> build() async {
    return await _getAllProgressionTemplates();
  }

  Box get _templatesBox =>
      DatabaseService.getInstance().progressionTemplatesBox;

  /// Inicializa las plantillas predefinidas de progresión
  Future<void> initializeBuiltInTemplates() async {
    try {
      LoggingService.instance.info(
        'Initializing built-in progression templates',
      );

      final templates = _getBuiltInTemplates();
      int initializedCount = 0;

      for (final template in templates) {
        // Solo inicializar si no existe ya
        final existingTemplate = _templatesBox.get(template.id);
        if (existingTemplate == null) {
          await _templatesBox.put(template.id, template);
          initializedCount++;
        }
      }

      LoggingService.instance
          .info('Built-in progression templates initialized successfully', {
            'total': templates.length,
            'initialized': initializedCount,
            'already_existed': templates.length - initializedCount,
          });
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error initializing built-in progression templates',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  List<ProgressionTemplate> _getBuiltInTemplates() {
    return [
      // Progresión Lineal
      ProgressionTemplate(
        id: 'linear_beginner',
        name: 'Progresión Lineal - Principiante',
        description:
            'Incremento constante de peso cada sesión. Ideal para principiantes que pueden progresar rápidamente.',
        type: ProgressionType.linear,
        defaultUnit: ProgressionUnit.session,
        defaultPrimaryTarget: ProgressionTarget.weight,
        defaultIncrementValue: 2.5,
        defaultIncrementFrequency: 1,
        defaultCycleLength: 4,
        defaultDeloadWeek: 4,
        defaultDeloadPercentage: 0.9,
        defaultParameters: {
          'max_weeks': 8,
          'reset_percentage': 0.85,
          'sessions_per_week': 3,
        },
        recommendedFor: ['Principiantes', 'Fuerza'],
        difficulty: 'Principiante',
        example:
            'Semana 1: 100kg x 5x5 → Semana 2: 102.5kg x 5x5 → Semana 3: 105kg x 5x5',
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),

      // Progresión Ondulante
      ProgressionTemplate(
        id: 'undulating_intermediate',
        name: 'Progresión Ondulante - Intermedio',
        description:
            'Alterna entre días pesados y ligeros para estimular diferentes adaptaciones.',
        type: ProgressionType.undulating,
        defaultUnit: ProgressionUnit.session,
        defaultPrimaryTarget: ProgressionTarget.weight,
        defaultSecondaryTarget: ProgressionTarget.reps,
        defaultIncrementValue: 2.5,
        defaultIncrementFrequency: 2,
        defaultCycleLength: 6,
        defaultDeloadWeek: 6,
        defaultDeloadPercentage: 0.85,
        defaultParameters: {
          'heavy_day_multiplier': 1.0,
          'light_day_multiplier': 0.8,
          'rep_variation': 0.2,
          'sessions_per_week': 3,
        },
        recommendedFor: ['Intermedios', 'Hipertrofia', 'Fuerza'],
        difficulty: 'Intermedio',
        example: 'Lunes (pesado): 100kg x 4x4 → Miércoles (ligero): 80kg x 4x8',
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),

      // Progresión Escalonada
      ProgressionTemplate(
        id: 'stepped_advanced',
        name: 'Progresión Escalonada - Avanzado',
        description:
            'Acumula carga durante varias semanas y luego reduce para recuperación.',
        type: ProgressionType.stepped,
        defaultUnit: ProgressionUnit.week,
        defaultPrimaryTarget: ProgressionTarget.weight,
        defaultIncrementValue: 2.5,
        defaultIncrementFrequency: 1,
        defaultCycleLength: 4,
        defaultDeloadWeek: 4,
        defaultDeloadPercentage: 0.8,
        defaultParameters: {
          'accumulation_weeks': 3,
          'deload_volume_reduction': 0.7,
          'sessions_per_week': 3,
        },
        recommendedFor: ['Avanzados', 'Powerlifting'],
        difficulty: 'Avanzado',
        example:
            'Semana 1-3: 100kg → 105kg → 107.5kg → Semana 4: 80kg (deload)',
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),

      // Progresión Doble
      ProgressionTemplate(
        id: 'double_hypertrophy',
        name: 'Progresión Doble - Hipertrofia',
        description:
            'Primero aumenta repeticiones hasta el máximo, luego incrementa peso.',
        type: ProgressionType.double,
        defaultUnit: ProgressionUnit.session,
        defaultPrimaryTarget: ProgressionTarget.reps,
        defaultSecondaryTarget: ProgressionTarget.weight,
        defaultIncrementValue: 2.5,
        defaultIncrementFrequency: 1,
        defaultCycleLength: 6,
        defaultDeloadWeek: 6,
        defaultDeloadPercentage: 0.9,
        defaultParameters: {
          'min_reps': 8,
          'max_reps': 12,
          'weight_increment': 2.5,
          'sessions_per_week': 3,
        },
        recommendedFor: ['Intermedios', 'Hipertrofia'],
        difficulty: 'Intermedio',
        example:
            'Semana 1: 80kg x 3x8 → Semana 2: 80kg x 3x9 → Semana 3: 80kg x 3x10',
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),

      // Progresión por Oleadas
      ProgressionTemplate(
        id: 'wave_advanced',
        name: 'Progresión por Oleadas - Avanzado',
        description:
            'Ciclos de 3 semanas: alta intensidad, alto volumen, descarga.',
        type: ProgressionType.wave,
        defaultUnit: ProgressionUnit.week,
        defaultPrimaryTarget: ProgressionTarget.weight,
        defaultSecondaryTarget: ProgressionTarget.volume,
        defaultIncrementValue: 5.0,
        defaultIncrementFrequency: 3,
        defaultCycleLength: 9,
        defaultDeloadWeek: 3,
        defaultDeloadPercentage: 0.7,
        defaultParameters: {
          'intensity_week_multiplier': 1.0,
          'volume_week_multiplier': 1.3,
          'deload_week_multiplier': 0.7,
          'sessions_per_week': 3,
        },
        recommendedFor: ['Avanzados', 'Competitivos'],
        difficulty: 'Avanzado',
        example:
            'Semana 1: 100kg x 3x5 (intensidad) → Semana 2: 80kg x 4x8 (volumen) → Semana 3: 70kg x 3x5 (descarga)',
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),

      // Progresión Estática
      ProgressionTemplate(
        id: 'static_technique',
        name: 'Progresión Estática - Técnica',
        description:
            'Mantiene carga constante para enfocarse en técnica y tolerancia.',
        type: ProgressionType.static,
        defaultUnit: ProgressionUnit.week,
        defaultPrimaryTarget: ProgressionTarget.volume,
        defaultIncrementValue: 0.0,
        defaultIncrementFrequency: 0,
        defaultCycleLength: 4,
        defaultDeloadWeek: 0,
        defaultDeloadPercentage: 1.0,
        defaultParameters: {
          'focus': 'technique',
          'rpe_target': 6,
          'sessions_per_week': 1,
        },
        recommendedFor: ['Principiantes', 'Técnica'],
        difficulty: 'Principiante',
        example: '4 semanas: 80kg x 3x8 (mantener carga constante)',
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),

      // Progresión Inversa
      ProgressionTemplate(
        id: 'reverse_peaking',
        name: 'Progresión Inversa - Pico',
        description:
            'Inicia con alta intensidad y reduce progresivamente para llegar al pico.',
        type: ProgressionType.reverse,
        defaultUnit: ProgressionUnit.week,
        defaultPrimaryTarget: ProgressionTarget.weight,
        defaultSecondaryTarget: ProgressionTarget.reps,
        defaultIncrementValue: -2.5,
        defaultIncrementFrequency: 1,
        defaultCycleLength: 6,
        defaultDeloadWeek: 0,
        defaultDeloadPercentage: 1.0,
        defaultParameters: {
          'starting_intensity': 0.9,
          'ending_intensity': 0.6,
          'rep_increase': 1,
          'sessions_per_week': 3,
        },
        recommendedFor: ['Avanzados', 'Competitivos'],
        difficulty: 'Avanzado',
        example: 'Semana 1: 90kg x 3x3 → Semana 6: 60kg x 3x8',
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),

      // Progresión Autoregulada
      ProgressionTemplate(
        id: 'autoregulated_rpe',
        name: 'Progresión Autoregulada - RPE',
        description: 'Ajusta carga basado en percepción de esfuerzo (RPE).',
        type: ProgressionType.autoregulated,
        defaultUnit: ProgressionUnit.session,
        defaultPrimaryTarget: ProgressionTarget.intensity,
        defaultIncrementValue: 0.0,
        defaultIncrementFrequency: 1,
        defaultCycleLength: 8,
        defaultDeloadWeek: 8,
        defaultDeloadPercentage: 0.8,
        defaultParameters: {
          'target_rpe': 8,
          'rpe_range': 2,
          'auto_adjust': true,
          'sessions_per_week': 3,
        },
        recommendedFor: ['Intermedios', 'Avanzados'],
        difficulty: 'Intermedio',
        example: '3x5 @RPE 8 (peso se ajusta automáticamente)',
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),

      // Progresión Doble Factor
      ProgressionTemplate(
        id: 'double_factor_advanced',
        name: 'Progresión Doble Factor - Avanzado',
        description:
            'Balance entre fitness y fatiga, ajustando volumen e intensidad según la recuperación.',
        type: ProgressionType.doubleFactor,
        defaultUnit: ProgressionUnit.week,
        defaultPrimaryTarget: ProgressionTarget.intensity,
        defaultSecondaryTarget: ProgressionTarget.volume,
        defaultIncrementValue: 2.5,
        defaultIncrementFrequency: 2,
        defaultCycleLength: 8,
        defaultDeloadWeek: 4,
        defaultDeloadPercentage: 0.8,
        defaultParameters: {
          'fitness_fatigue_ratio': 0.7,
          'volume_modifier': 0.1,
          'intensity_modifier': 0.05,
          'recovery_threshold': 0.6,
          'sessions_per_week': 3,
        },
        recommendedFor: ['Avanzados', 'Competitivos'],
        difficulty: 'Avanzado',
        example:
            'Semana 1: 100kg x 4x5 (fitness) → Semana 2: 95kg x 5x5 (fatiga) → Semana 3: 102.5kg x 3x5 (adaptación)',
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),

      // Progresión de Sobrecarga
      ProgressionTemplate(
        id: 'overload_progressive',
        name: 'Progresión de Sobrecarga - Progresiva',
        description:
            'Incremento gradual de volumen o intensidad para maximizar adaptaciones.',
        type: ProgressionType.overload,
        defaultUnit: ProgressionUnit.week,
        defaultPrimaryTarget: ProgressionTarget.volume,
        defaultSecondaryTarget: ProgressionTarget.intensity,
        defaultIncrementValue: 1.0,
        defaultIncrementFrequency: 1,
        defaultCycleLength: 6,
        defaultDeloadWeek: 6,
        defaultDeloadPercentage: 0.75,
        defaultParameters: {
          'overload_type': 'volume', // 'volume' o 'intensity'
          'volume_increment': 1,
          'intensity_increment': 2.5,
          'max_overload_weeks': 4,
          'sessions_per_week': 3,
        },
        recommendedFor: ['Intermedios', 'Avanzados'],
        difficulty: 'Intermedio',
        example:
            'Semana 1: 80kg x 3x8 → Semana 2: 80kg x 4x8 → Semana 3: 80kg x 5x8 → Semana 4: 80kg x 6x8',
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<List<ProgressionTemplate>> _getAllProgressionTemplates() async {
    try {
      final allTemplates =
          _templatesBox.values.cast<ProgressionTemplate>().toList();

      // Verificar si hay plantillas integradas, si no las hay, inicializarlas
      final builtInTemplates = allTemplates.where((t) => t.isBuiltIn).toList();
      if (builtInTemplates.isEmpty) {
        // Devolver integradas en memoria inmediatamente, y en background intentar restaurarlas en DB
        LoggingService.instance.info(
          'No built-in templates found in DB, falling back to in-memory built-ins and triggering initialization...',
        );
        // Fire-and-forget
        unawaited(initializeBuiltInTemplates());
        final builtIns = _getBuiltInTemplates();
        builtIns.sort((a, b) => a.name.compareTo(b.name));
        return builtIns;
      }

      // Verificar si faltan plantillas específicas (para casos donde se agregaron nuevas)
      final expectedTemplateIds =
          _getBuiltInTemplates().map((t) => t.id).toSet();
      final existingTemplateIds = builtInTemplates.map((t) => t.id).toSet();
      final missingTemplateIds = expectedTemplateIds.difference(
        existingTemplateIds,
      );

      if (missingTemplateIds.isNotEmpty) {
        LoggingService.instance.info(
          'Missing built-in templates found, initializing missing ones...',
          {'missing': missingTemplateIds.toList()},
        );
        await initializeBuiltInTemplates();
        // Recargar las plantillas después de la inicialización
        final reloadedTemplates =
            _templatesBox.values.cast<ProgressionTemplate>().toList();
        reloadedTemplates.sort((a, b) {
          // Primero las plantillas integradas, luego las personalizadas
          if (a.isBuiltIn && !b.isBuiltIn) return -1;
          if (!a.isBuiltIn && b.isBuiltIn) return 1;
          return a.name.compareTo(b.name);
        });
        return reloadedTemplates;
      }

      allTemplates.sort((a, b) {
        // Primero las plantillas integradas, luego las personalizadas
        if (a.isBuiltIn && !b.isBuiltIn) return -1;
        if (!a.isBuiltIn && b.isBuiltIn) return 1;
        return a.name.compareTo(b.name);
      });
      return allTemplates;
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error getting all progression templates - returning in-memory built-ins as fallback',
        e,
        stackTrace,
      );
      final builtIns = _getBuiltInTemplates();
      builtIns.sort((a, b) => a.name.compareTo(b.name));
      return builtIns;
    }
  }

  /// Obtiene todas las plantillas de progresión (método público)
  Future<List<ProgressionTemplate>> getAllProgressionTemplates() async {
    return await _getAllProgressionTemplates();
  }

  Future<List<ProgressionTemplate>> getTemplatesByDifficulty(
    String difficulty,
  ) async {
    try {
      final allTemplates = await _getAllProgressionTemplates();
      return allTemplates
          .where((template) => template.difficulty == difficulty)
          .toList();
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error getting templates by difficulty',
        e,
        stackTrace,
        {'difficulty': difficulty},
      );
      return [];
    }
  }

  Future<List<ProgressionTemplate>> getTemplatesByType(
    ProgressionType type,
  ) async {
    try {
      final allTemplates = await _getAllProgressionTemplates();
      return allTemplates.where((template) => template.type == type).toList();
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error getting templates by type',
        e,
        stackTrace,
        {'type': type.name},
      );
      return [];
    }
  }

  Future<ProgressionTemplate?> getTemplate(String templateId) async {
    try {
      return _templatesBox.get(templateId);
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error getting progression template',
        e,
        stackTrace,
        {'templateId': templateId},
      );
      return null;
    }
  }

  Future<void> saveTemplate(ProgressionTemplate template) async {
    try {
      await _templatesBox.put(template.id, template);
      LoggingService.instance.info('Progression template saved', {
        'templateId': template.id,
        'name': template.name,
      });
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error saving progression template',
        e,
        stackTrace,
        {'templateId': template.id},
      );
      rethrow;
    }
  }

  Future<void> deleteTemplate(String templateId) async {
    try {
      await _templatesBox.delete(templateId);
      LoggingService.instance.info('Progression template deleted', {
        'templateId': templateId,
      });
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error deleting progression template',
        e,
        stackTrace,
        {'templateId': templateId},
      );
      rethrow;
    }
  }

  /// Fuerza la restauración de todas las plantillas integradas
  Future<void> restoreBuiltInTemplates() async {
    try {
      LoggingService.instance.info(
        'Restoring all built-in progression templates',
      );

      final templates = _getBuiltInTemplates();

      for (final template in templates) {
        await _templatesBox.put(template.id, template);
      }

      LoggingService.instance.info(
        'Built-in progression templates restored successfully',
        {'count': templates.length},
      );
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error restoring built-in progression templates',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Crea una plantilla personalizada basada en una existente
  Future<ProgressionTemplate> createCustomTemplate({
    required String name,
    required String description,
    required ProgressionType type,
    required ProgressionUnit unit,
    required ProgressionTarget primaryTarget,
    ProgressionTarget? secondaryTarget,
    required double incrementValue,
    required int incrementFrequency,
    required int cycleLength,
    required int deloadWeek,
    required double deloadPercentage,
    required Map<String, dynamic> parameters,
    required List<String> recommendedFor,
    required String difficulty,
    required String example,
  }) async {
    try {
      final uuid = const Uuid();
      final template = ProgressionTemplate(
        id: uuid.v4(),
        name: name,
        description: description,
        type: type,
        defaultUnit: unit,
        defaultPrimaryTarget: primaryTarget,
        defaultSecondaryTarget: secondaryTarget,
        defaultIncrementValue: incrementValue,
        defaultIncrementFrequency: incrementFrequency,
        defaultCycleLength: cycleLength,
        defaultDeloadWeek: deloadWeek,
        defaultDeloadPercentage: deloadPercentage,
        defaultParameters: parameters,
        recommendedFor: recommendedFor,
        difficulty: difficulty,
        example: example,
        isBuiltIn: false,
        createdAt: DateTime.now(),
      );

      await saveTemplate(template);

      LoggingService.instance.info('Custom progression template created', {
        'templateId': template.id,
        'name': name,
      });

      return template;
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error creating custom progression template',
        e,
        stackTrace,
        {'name': name, 'type': type.name},
      );
      rethrow;
    }
  }
}
