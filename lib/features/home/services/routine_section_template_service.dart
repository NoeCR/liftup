import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/routine_section_template.dart';
import '../../../core/database/database_service.dart';

part 'routine_section_template_service.g.dart';

@riverpod
class RoutineSectionTemplateService extends _$RoutineSectionTemplateService {
  @override
  Future<List<RoutineSectionTemplate>> build() async {
    final box = DatabaseService.getInstance().routineSectionTemplatesBox;
    final templates = box.values.cast<RoutineSectionTemplate>().toList();
    templates.sort((a, b) => a.order.compareTo(b.order));
    return templates;
  }

  Future<void> saveSectionTemplate(RoutineSectionTemplate template) async {
    final box = DatabaseService.getInstance().routineSectionTemplatesBox;
    await box.put(template.id, template);
    ref.invalidateSelf();
  }

  Future<void> deleteSectionTemplate(String id) async {
    final box = DatabaseService.getInstance().routineSectionTemplatesBox;
    await box.delete(id);
    ref.invalidateSelf();
  }

  Future<void> reorderSectionTemplates(
    List<RoutineSectionTemplate> templates,
  ) async {
    final box = DatabaseService.getInstance().routineSectionTemplatesBox;

    for (int i = 0; i < templates.length; i++) {
      final template = templates[i].copyWith(
        order: i,
        updatedAt: DateTime.now(),
      );
      await box.put(template.id, template);
    }

    ref.invalidateSelf();
  }

  Future<void> initializeDefaultTemplates() async {
    final box = DatabaseService.getInstance().routineSectionTemplatesBox;

    // Solo agregar templates por defecto si no existen
    final existingTemplates =
        box.values.cast<RoutineSectionTemplate>().toList();
    final existingIds = existingTemplates.map((t) => t.id).toSet();

    for (final template in DefaultSectionTemplates.templates) {
      if (!existingIds.contains(template.id)) {
        await box.put(template.id, template);
      }
    }
    ref.invalidateSelf();
  }

  Future<List<RoutineSectionTemplate>> getDefaultTemplates() async {
    return DefaultSectionTemplates.templates;
  }

  Future<List<String>> getAvailableIcons() async {
    return DefaultSectionTemplates.availableIcons;
  }
}
