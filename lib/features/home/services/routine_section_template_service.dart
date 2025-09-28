import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/routine_section_template.dart';
import '../../../core/database/database_service.dart';

part 'routine_section_template_service.g.dart';

@riverpod
class RoutineSectionTemplateService extends _$RoutineSectionTemplateService {
  @override
  Future<List<RoutineSectionTemplate>> build() async {
    final box =
        ref.read(databaseServiceProvider.notifier).routineSectionTemplatesBox;
    final templates = box.values.cast<RoutineSectionTemplate>().toList();
    templates.sort((a, b) => a.order.compareTo(b.order));
    return templates;
  }

  Future<void> saveSectionTemplate(RoutineSectionTemplate template) async {
    final box =
        ref.read(databaseServiceProvider.notifier).routineSectionTemplatesBox;
    await box.put(template.id, template);
    ref.invalidateSelf();
  }

  Future<void> deleteSectionTemplate(String id) async {
    final box =
        ref.read(databaseServiceProvider.notifier).routineSectionTemplatesBox;
    await box.delete(id);
    ref.invalidateSelf();
  }

  Future<void> reorderSectionTemplates(
    List<RoutineSectionTemplate> templates,
  ) async {
    final box =
        ref.read(databaseServiceProvider.notifier).routineSectionTemplatesBox;

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
    final box =
        ref.read(databaseServiceProvider.notifier).routineSectionTemplatesBox;

    // Limpiar plantillas existentes y cargar las nuevas
    await box.clear();

    for (final template in DefaultSectionTemplates.templates) {
      await box.put(template.id, template);
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
