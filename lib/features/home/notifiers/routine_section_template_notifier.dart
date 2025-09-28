import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/routine_section_template.dart';
import '../services/routine_section_template_service.dart';
import '../../../common/enums/section_muscle_group_enum.dart';

part 'routine_section_template_notifier.g.dart';

@riverpod
class RoutineSectionTemplateNotifier extends _$RoutineSectionTemplateNotifier {
  final _uuid = const Uuid();

  @override
  Future<List<RoutineSectionTemplate>> build() async {
    final service = ref.read(routineSectionTemplateServiceProvider.notifier);
    await service.initializeDefaultTemplates();
    return ref.read(routineSectionTemplateServiceProvider.future);
  }

  Future<void> addSectionTemplate({
    required String name,
    String? description,
    required String iconName,
    required SectionMuscleGroup muscleGroup,
  }) async {
    final service = ref.read(routineSectionTemplateServiceProvider.notifier);
    final currentTemplates = await future;
    
    final newTemplate = RoutineSectionTemplate(
      id: _uuid.v4(),
      name: name,
      description: description,
      iconName: iconName,
      order: currentTemplates.length,
      isDefault: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      muscleGroup: muscleGroup,
    );

    await service.saveSectionTemplate(newTemplate);
    ref.invalidateSelf();
  }

  Future<void> updateSectionTemplate(RoutineSectionTemplate template) async {
    final service = ref.read(routineSectionTemplateServiceProvider.notifier);
    final updatedTemplate = template.copyWith(updatedAt: DateTime.now());
    
    await service.saveSectionTemplate(updatedTemplate);
    ref.invalidateSelf();
  }

  Future<void> deleteSectionTemplate(String id) async {
    final service = ref.read(routineSectionTemplateServiceProvider.notifier);
    await service.deleteSectionTemplate(id);
    ref.invalidateSelf();
  }

  Future<void> reorderSectionTemplates(List<RoutineSectionTemplate> templates) async {
    final service = ref.read(routineSectionTemplateServiceProvider.notifier);
    await service.reorderSectionTemplates(templates);
    ref.invalidateSelf();
  }

  Future<List<String>> getAvailableIcons() async {
    final service = ref.read(routineSectionTemplateServiceProvider.notifier);
    return await service.getAvailableIcons();
  }
}
