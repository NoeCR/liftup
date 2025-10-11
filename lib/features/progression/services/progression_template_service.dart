import '../../../common/enums/progression_type_enum.dart';
import '../models/progression_template.dart';

class ProgressionTemplateService {
  static final Map<String, ProgressionTemplate> _templates = {};

  /// Inicializa todas las plantillas disponibles
  static void initializeTemplates() {
    _templates.clear();

    // Agregar todas las plantillas
    _addLinearTemplates();
    _addDoubleTemplates();
    _addUndulatingTemplates();
    _addSteppedTemplates();
    _addWaveTemplates();
    _addOverloadTemplates();
    _addAutoregulatedTemplates();
    _addDoubleFactorTemplates();
    _addReverseTemplates();
    _addStaticTemplates();
  }

  /// Obtiene todas las plantillas disponibles
  static List<ProgressionTemplate> getAllTemplates() {
    return _templates.values.toList()..sort((a, b) => a.difficulty.compareTo(b.difficulty));
  }

  /// Obtiene todas las plantillas para un tipo de progresión específico
  static List<ProgressionTemplate> getTemplatesForType(ProgressionType type) {
    return _templates.values.where((template) => template.progressionType == type).toList()
      ..sort((a, b) => a.difficulty.compareTo(b.difficulty));
  }

  /// Obtiene una plantilla por ID
  static ProgressionTemplate? getTemplateById(String id) {
    return _templates[id];
  }

  /// Obtiene plantillas por categoría
  static List<ProgressionTemplate> getTemplatesByCategory(String category) {
    return _templates.values.where((template) => template.category == category).toList();
  }

  /// Obtiene plantillas por objetivo
  static List<ProgressionTemplate> getTemplatesByGoal(String goal) {
    return _templates.values.where((template) => template.goal == goal).toList();
  }

  // ========== PLANTILLAS LINEAR ==========
  static void _addLinearTemplates() {
    _templates['linear_beginner'] = ProgressionTemplate(
      id: 'linear_beginner',
      name: 'Progresión Lineal Básica',
      description: 'Incremento constante de peso cada sesión. Ideal para principiantes.',
      progressionType: ProgressionType.linear,
      category: 'beginner',
      goal: 'strength',
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.weight,
      incrementValue: 2.5,
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 4,
      deloadPercentage: 0.9,
      customParameters: {},
      detailedDescription:
          'Aumenta el peso en 2.5kg cada sesión. Simple y efectivo para ganancias iniciales de fuerza.',
      whenToUse: 'Principiantes, primeras 8-12 semanas de entrenamiento, ejercicios básicos.',
      deloadExplanation: 'Cada 4 semanas reduce el peso al 90% para recuperación.',
      progressionExplanation: 'Peso +2.5kg cada sesión. Mantiene reps y series constantes.',
      benefits: ['Simple de seguir', 'Ganancias rápidas iniciales', 'Fácil de monitorear'],
      considerations: ['Puede volverse insostenible', 'Requiere deloads regulares'],
      estimatedDuration: 12,
      difficulty: 'easy',
      targetAudience: ['beginner'],
    );

    _templates['linear_intermediate'] = ProgressionTemplate(
      id: 'linear_intermediate',
      name: 'Progresión Lineal Intermedia',
      description: 'Incremento semanal de peso con deloads más frecuentes.',
      progressionType: ProgressionType.linear,
      category: 'intermediate',
      goal: 'strength',
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.weight,
      incrementValue: 5.0,
      incrementFrequency: 1,
      cycleLength: 3,
      deloadWeek: 3,
      deloadPercentage: 0.85,
      customParameters: {},
      detailedDescription: 'Aumenta el peso en 5kg cada semana. Deload cada 3 semanas para sostenibilidad.',
      whenToUse: 'Atletas intermedios, ejercicios compuestos, fases de fuerza.',
      deloadExplanation: 'Cada 3 semanas reduce el peso al 85% para recuperación.',
      progressionExplanation: 'Peso +5kg cada semana. Mantiene reps y series constantes.',
      benefits: ['Progresión sostenible', 'Deloads frecuentes', 'Ideal para fuerza'],
      considerations: ['Progresión más lenta', 'Requiere experiencia técnica'],
      estimatedDuration: 16,
      difficulty: 'moderate',
      targetAudience: ['intermediate'],
    );

    _templates['linear_advanced'] = ProgressionTemplate(
      id: 'linear_advanced',
      name: 'Progresión Lineal Avanzada',
      description: 'Incrementos pequeños pero consistentes con deloads programados.',
      progressionType: ProgressionType.linear,
      category: 'advanced',
      goal: 'strength',
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.weight,
      incrementValue: 2.5,
      incrementFrequency: 1,
      cycleLength: 2,
      deloadWeek: 2,
      deloadPercentage: 0.9,
      customParameters: {},
      detailedDescription: 'Incrementos pequeños de 2.5kg cada semana con deloads cada 2 semanas.',
      whenToUse: 'Atletas avanzados, competidores, ejercicios técnicos.',
      deloadExplanation: 'Cada 2 semanas reduce el peso al 90% para recuperación.',
      progressionExplanation: 'Peso +2.5kg cada semana. Incrementos pequeños pero consistentes.',
      benefits: ['Progresión sostenible', 'Deloads frecuentes', 'Ideal para competencia'],
      considerations: ['Progresión muy lenta', 'Requiere alta experiencia'],
      estimatedDuration: 20,
      difficulty: 'hard',
      targetAudience: ['advanced'],
    );

    // Plantilla básica para principiantes - Hipertrofia
    _templates['linear_beginner_hypertrophy'] = ProgressionTemplate(
      id: 'linear_beginner_hypertrophy',
      name: 'Lineal Básica - Hipertrofia',
      description: 'Progresión lineal enfocada en ganancia de masa muscular para principiantes.',
      progressionType: ProgressionType.linear,
      category: 'beginner',
      goal: 'hypertrophy',
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.weight,
      incrementValue: 2.5,
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 4,
      deloadPercentage: 0.9,
      customParameters: {'target_reps': 8, 'target_sets': 3},
      detailedDescription: 'Aumenta peso en 2.5kg cada sesión manteniendo 8 reps x 3 series.',
      whenToUse: 'Principiantes, primeras 8-12 semanas, enfoque en hipertrofia.',
      deloadExplanation: 'Cada 4 semanas reduce peso al 90% para recuperación.',
      progressionExplanation: 'Peso +2.5kg cada sesión. Mantiene 8 reps x 3 series.',
      benefits: ['Simple de seguir', 'Ganancias rápidas', 'Ideal para hipertrofia'],
      considerations: ['Puede volverse insostenible', 'Requiere deloads regulares'],
      estimatedDuration: 12,
      difficulty: 'easy',
      targetAudience: ['beginner'],
    );

    // Plantilla intermedia - Powerlifting
    _templates['linear_intermediate_powerlifting'] = ProgressionTemplate(
      id: 'linear_intermediate_powerlifting',
      name: 'Lineal Intermedia - Powerlifting',
      description: 'Progresión semanal para powerlifting con deloads frecuentes.',
      progressionType: ProgressionType.linear,
      category: 'intermediate',
      goal: 'powerlifting',
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.weight,
      incrementValue: 5.0,
      incrementFrequency: 1,
      cycleLength: 3,
      deloadWeek: 3,
      deloadPercentage: 0.85,
      customParameters: {'target_reps': 5, 'target_sets': 5},
      detailedDescription: 'Aumenta peso en 5kg cada semana. 5x5 con deload cada 3 semanas.',
      whenToUse: 'Powerlifting intermedio, ejercicios principales, desarrollo de fuerza.',
      deloadExplanation: 'Cada 3 semanas reduce peso al 85% para recuperación.',
      progressionExplanation: 'Peso +5kg cada semana. Mantiene 5 reps x 5 series.',
      benefits: ['Progresión sostenible', 'Ideal para powerlifting', 'Deloads frecuentes'],
      considerations: ['Requiere experiencia técnica', 'Progresión moderada'],
      estimatedDuration: 16,
      difficulty: 'moderate',
      targetAudience: ['intermediate'],
    );

    // Plantilla avanzada - Powerbuilding
    _templates['linear_advanced_powerbuilding'] = ProgressionTemplate(
      id: 'linear_advanced_powerbuilding',
      name: 'Lineal Avanzada - Powerbuilding',
      description: 'Progresión que combina fuerza y hipertrofia para atletas avanzados.',
      progressionType: ProgressionType.linear,
      category: 'advanced',
      goal: 'powerbuilding',
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.weight,
      incrementValue: 2.5,
      incrementFrequency: 1,
      cycleLength: 3,
      deloadWeek: 3,
      deloadPercentage: 0.85,
      customParameters: {'target_reps': 6, 'target_sets': 4},
      detailedDescription: 'Aumenta peso en 2.5kg cada semana. 4x6 con deload cada 3 semanas.',
      whenToUse: 'Powerbuilding avanzado, combinación fuerza-hipertrofia, atletas experimentados.',
      deloadExplanation: 'Cada 3 semanas reduce peso al 85% para recuperación.',
      progressionExplanation: 'Peso +2.5kg cada semana. Mantiene 6 reps x 4 series.',
      benefits: ['Combina fuerza e hipertrofia', 'Progresión sostenible', 'Versátil'],
      considerations: ['Requiere experiencia avanzada', 'Planificación cuidadosa'],
      estimatedDuration: 18,
      difficulty: 'hard',
      targetAudience: ['advanced'],
    );
  }

  // ========== PLANTILLAS DOUBLE ==========
  static void _addDoubleTemplates() {
    _templates['double_hypertrophy'] = ProgressionTemplate(
      id: 'double_hypertrophy',
      name: 'Doble Progresión para Hipertrofia',
      description: 'Primero incrementa reps, luego peso. Ideal para ganancia de masa muscular.',
      progressionType: ProgressionType.double,
      category: 'intermediate',
      goal: 'hypertrophy',
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.reps,
      secondaryTarget: ProgressionTarget.weight,
      incrementValue: 2.5,
      incrementFrequency: 1,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.9,
      customParameters: {'min_reps': 8, 'max_reps': 12},
      detailedDescription: 'Incrementa repeticiones de 8 a 12, luego aumenta peso y resetea reps a 8.',
      whenToUse: 'Hipertrofia, ejercicios de aislamiento, atletas intermedios.',
      deloadExplanation: 'Cada 6 semanas reduce el peso al 90% y resetea reps.',
      progressionExplanation: 'Reps: 8→9→10→11→12, luego Peso +2.5kg y reps → 8.',
      benefits: ['Ideal para hipertrofia', 'Progresión gradual', 'Mejora técnica'],
      considerations: ['Progresión lenta en peso', 'Requiere rangos apropiados'],
      estimatedDuration: 18,
      difficulty: 'moderate',
      targetAudience: ['intermediate'],
    );

    _templates['double_strength'] = ProgressionTemplate(
      id: 'double_strength',
      name: 'Doble Progresión para Fuerza',
      description: 'Rango de reps más bajo para desarrollo de fuerza máxima.',
      progressionType: ProgressionType.double,
      category: 'intermediate',
      goal: 'strength',
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.reps,
      secondaryTarget: ProgressionTarget.weight,
      incrementValue: 5.0,
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 4,
      deloadPercentage: 0.85,
      customParameters: {'min_reps': 3, 'max_reps': 6},
      detailedDescription: 'Incrementa repeticiones de 3 a 6, luego aumenta peso en 5kg.',
      whenToUse: 'Desarrollo de fuerza, ejercicios compuestos, powerlifting.',
      deloadExplanation: 'Cada 4 semanas reduce el peso al 85% y resetea reps.',
      progressionExplanation: 'Reps: 3→4→5→6, luego Peso +5kg y reps → 3.',
      benefits: ['Ideal para fuerza', 'Rango óptimo de reps', 'Progresión sostenible'],
      considerations: ['Requiere técnica sólida', 'Deloads más frecuentes'],
      estimatedDuration: 16,
      difficulty: 'moderate',
      targetAudience: ['intermediate'],
    );

    // Plantilla para principiantes - Hipertrofia
    _templates['double_beginner_hypertrophy'] = ProgressionTemplate(
      id: 'double_beginner_hypertrophy',
      name: 'Doble Progresión Básica - Hipertrofia',
      description: 'Progresión doble simple para principiantes enfocada en hipertrofia.',
      progressionType: ProgressionType.double,
      category: 'beginner',
      goal: 'hypertrophy',
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.reps,
      secondaryTarget: ProgressionTarget.weight,
      incrementValue: 2.5,
      incrementFrequency: 1,
      cycleLength: 8,
      deloadWeek: 8,
      deloadPercentage: 0.9,
      customParameters: {'min_reps': 10, 'max_reps': 15},
      detailedDescription: 'Incrementa reps de 10 a 15, luego aumenta peso en 2.5kg.',
      whenToUse: 'Principiantes, hipertrofia, ejercicios de aislamiento.',
      deloadExplanation: 'Cada 8 semanas reduce peso al 90% y resetea reps.',
      progressionExplanation: 'Reps: 10→12→15, luego Peso +2.5kg y reps → 10.',
      benefits: ['Simple para principiantes', 'Ideal para hipertrofia', 'Progresión gradual'],
      considerations: ['Progresión muy lenta', 'Requiere paciencia'],
      estimatedDuration: 20,
      difficulty: 'easy',
      targetAudience: ['beginner'],
    );

    // Plantilla para powerlifting
    _templates['double_powerlifting'] = ProgressionTemplate(
      id: 'double_powerlifting',
      name: 'Doble Progresión - Powerlifting',
      description: 'Progresión doble optimizada para los tres levantamientos principales.',
      progressionType: ProgressionType.double,
      category: 'advanced',
      goal: 'powerlifting',
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.reps,
      secondaryTarget: ProgressionTarget.weight,
      incrementValue: 5.0,
      incrementFrequency: 1,
      cycleLength: 3,
      deloadWeek: 3,
      deloadPercentage: 0.85,
      customParameters: {'min_reps': 2, 'max_reps': 5},
      detailedDescription: 'Incrementa reps de 2 a 5, luego aumenta peso en 5kg.',
      whenToUse: 'Powerlifting, ejercicios principales, desarrollo de fuerza máxima.',
      deloadExplanation: 'Cada 3 semanas reduce peso al 85% y resetea reps.',
      progressionExplanation: 'Reps: 2→3→4→5, luego Peso +5kg y reps → 2.',
      benefits: ['Ideal para powerlifting', 'Desarrollo de fuerza máxima', 'Progresión sostenible'],
      considerations: ['Requiere técnica perfecta', 'Deloads frecuentes'],
      estimatedDuration: 14,
      difficulty: 'hard',
      targetAudience: ['advanced'],
    );

    // Plantilla para powerbuilding
    _templates['double_powerbuilding'] = ProgressionTemplate(
      id: 'double_powerbuilding',
      name: 'Doble Progresión - Powerbuilding',
      description: 'Combina desarrollo de fuerza e hipertrofia con progresión doble.',
      progressionType: ProgressionType.double,
      category: 'intermediate',
      goal: 'powerbuilding',
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.reps,
      secondaryTarget: ProgressionTarget.weight,
      incrementValue: 2.5,
      incrementFrequency: 1,
      cycleLength: 5,
      deloadWeek: 5,
      deloadPercentage: 0.9,
      customParameters: {'min_reps': 6, 'max_reps': 10},
      detailedDescription: 'Incrementa reps de 6 a 10, luego aumenta peso en 2.5kg.',
      whenToUse: 'Powerbuilding, combinación fuerza-hipertrofia, atletas intermedios.',
      deloadExplanation: 'Cada 5 semanas reduce peso al 90% y resetea reps.',
      progressionExplanation: 'Reps: 6→7→8→9→10, luego Peso +2.5kg y reps → 6.',
      benefits: ['Combina fuerza e hipertrofia', 'Rango óptimo', 'Versátil'],
      considerations: ['Progresión moderada', 'Requiere planificación'],
      estimatedDuration: 18,
      difficulty: 'moderate',
      targetAudience: ['intermediate'],
    );
  }

  // ========== PLANTILLAS UNDULATING ==========
  static void _addUndulatingTemplates() {
    _templates['undulating_weekly'] = ProgressionTemplate(
      id: 'undulating_weekly',
      name: 'Progresión Ondulante Semanal',
      description: 'Alterna entre días pesados y ligeros cada semana.',
      progressionType: ProgressionType.undulating,
      category: 'intermediate',
      goal: 'general',
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.weight,
      secondaryTarget: ProgressionTarget.reps,
      incrementValue: 2.5,
      incrementFrequency: 2,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.85,
      customParameters: {'heavy_day_multiplier': 0.85, 'light_day_multiplier': 1.15},
      detailedDescription: 'Semana 1: Días pesados (85% reps), Semana 2: Días ligeros (115% reps).',
      whenToUse: 'Atletas intermedios, variación de estímulos, prevención de estancamiento.',
      deloadExplanation: 'Cada 6 semanas reduce intensidad al 85% para recuperación.',
      progressionExplanation: 'Alterna intensidad semanalmente para variación de estímulos.',
      benefits: ['Variación sistemática', 'Previene estancamiento', 'Adaptaciones múltiples'],
      considerations: ['Requiere planificación', 'Más complejo de seguir'],
      estimatedDuration: 18,
      difficulty: 'moderate',
      targetAudience: ['intermediate'],
    );

    // Plantilla diaria para powerlifting
    _templates['undulating_daily_powerlifting'] = ProgressionTemplate(
      id: 'undulating_daily_powerlifting',
      name: 'Ondulante Diaria - Powerlifting',
      description: 'Alterna intensidad diariamente para powerlifting avanzado.',
      progressionType: ProgressionType.undulating,
      category: 'advanced',
      goal: 'powerlifting',
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.weight,
      incrementValue: 2.5,
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 4,
      deloadPercentage: 0.8,
      customParameters: {'heavy_day_multiplier': 0.9, 'medium_day_multiplier': 1.0, 'light_day_multiplier': 1.1},
      detailedDescription: 'Día 1: Pesado (90% reps), Día 2: Medio (100% reps), Día 3: Ligero (110% reps).',
      whenToUse: 'Powerlifting avanzado, alta frecuencia, desarrollo de fuerza máxima.',
      deloadExplanation: 'Cada 4 semanas reduce intensidad al 80% para recuperación.',
      progressionExplanation: 'Alterna intensidad diariamente: Pesado → Medio → Ligero.',
      benefits: ['Alta frecuencia', 'Ideal para powerlifting', 'Recuperación optimizada'],
      considerations: ['Muy complejo', 'Requiere alta experiencia'],
      estimatedDuration: 16,
      difficulty: 'hard',
      targetAudience: ['advanced'],
    );

    // Plantilla para hipertrofia
    _templates['undulating_hypertrophy'] = ProgressionTemplate(
      id: 'undulating_hypertrophy',
      name: 'Ondulante - Hipertrofia',
      description: 'Variación de volumen e intensidad para maximizar hipertrofia.',
      progressionType: ProgressionType.undulating,
      category: 'intermediate',
      goal: 'hypertrophy',
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.volume,
      incrementValue: 0.0,
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 4,
      deloadPercentage: 0.8,
      customParameters: {
        'high_volume_multiplier': 1.2,
        'moderate_volume_multiplier': 1.0,
        'high_intensity_multiplier': 0.9,
      },
      detailedDescription: 'Semana 1: Alto volumen (120%), Semana 2: Moderado (100%), Semana 3: Alta intensidad (90%).',
      whenToUse: 'Hipertrofia, variación de estímulos, atletas intermedios.',
      deloadExplanation: 'Cada 4 semanas reduce volumen al 80% para recuperación.',
      progressionExplanation: 'Alterna entre alto volumen, moderado y alta intensidad.',
      benefits: ['Ideal para hipertrofia', 'Variación sistemática', 'Adaptaciones múltiples'],
      considerations: ['Requiere planificación', 'Complejo de seguir'],
      estimatedDuration: 16,
      difficulty: 'moderate',
      targetAudience: ['intermediate'],
    );
  }

  // ========== PLANTILLAS STEPPED ==========
  static void _addSteppedTemplates() {
    _templates['stepped_accumulation'] = ProgressionTemplate(
      id: 'stepped_accumulation',
      name: 'Progresión Escalonada de Acumulación',
      description: 'Acumula carga progresivamente durante 3 semanas, luego deload.',
      progressionType: ProgressionType.stepped,
      category: 'advanced',
      goal: 'strength',
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.weight,
      incrementValue: 2.5,
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 4,
      deloadPercentage: 0.8,
      customParameters: {'accumulation_weeks': 3},
      detailedDescription: 'Semana 1: +2.5kg, Semana 2: +5kg, Semana 3: +7.5kg, Semana 4: Deload.',
      whenToUse: 'Fases de acumulación, atletas avanzados, periodización estructurada.',
      deloadExplanation: 'Cada 4 semanas reduce al 80% del peso base para recuperación.',
      progressionExplanation: 'Acumula incrementos: +2.5kg, +5kg, +7.5kg, luego deload.',
      benefits: ['Acumulación progresiva', 'Ideal para periodización', 'Adaptación gradual'],
      considerations: ['Requiere experiencia', 'Planificación cuidadosa'],
      estimatedDuration: 20,
      difficulty: 'hard',
      targetAudience: ['advanced'],
    );
  }

  // ========== PLANTILLAS WAVE ==========
  static void _addWaveTemplates() {
    _templates['wave_3week'] = ProgressionTemplate(
      id: 'wave_3week',
      name: 'Progresión por Oleadas 3 Semanas',
      description: 'Ciclos de 3 semanas: Alta intensidad, Alto volumen, Progresión normal.',
      progressionType: ProgressionType.wave,
      category: 'advanced',
      goal: 'general',
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.weight,
      secondaryTarget: ProgressionTarget.volume,
      incrementValue: 5.0,
      incrementFrequency: 3,
      cycleLength: 9,
      deloadWeek: 3,
      deloadPercentage: 0.7,
      customParameters: {
        'week1_multiplier': 0.85, // Alta intensidad
        'week2_multiplier': 1.2, // Alto volumen
        'week3_multiplier': 1.0, // Progresión normal
      },
      detailedDescription:
          'Semana 1: Alta intensidad (85% reps), Semana 2: Alto volumen (120% reps), Semana 3: Normal.',
      whenToUse: 'Atletas avanzados, variación sistemática, periodización compleja.',
      deloadExplanation: 'Cada 3 semanas reduce intensidad al 70% para recuperación.',
      progressionExplanation: 'Ciclos de 3 semanas con diferentes énfasis en intensidad y volumen.',
      benefits: ['Variación sistemática', 'Adaptaciones múltiples', 'Ideal para avanzados'],
      considerations: ['Muy complejo', 'Requiere alta experiencia'],
      estimatedDuration: 24,
      difficulty: 'hard',
      targetAudience: ['advanced'],
    );
  }

  // ========== PLANTILLAS OVERLOAD ==========
  static void _addOverloadTemplates() {
    _templates['overload_volume'] = ProgressionTemplate(
      id: 'overload_volume',
      name: 'Sobrecarga de Volumen',
      description: 'Incrementa series progresivamente manteniendo peso constante.',
      progressionType: ProgressionType.overload,
      category: 'intermediate',
      goal: 'hypertrophy',
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.volume,
      incrementValue: 2.5,
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 4,
      deloadPercentage: 0.8,
      customParameters: {'overload_type': 'volume', 'overload_rate': 0.1},
      detailedDescription: 'Incrementa series en 10% cada semana manteniendo peso y reps constantes.',
      whenToUse: 'Fases de acumulación de volumen, hipertrofia, atletas intermedios.',
      deloadExplanation: 'Cada 4 semanas reduce series al 80% para recuperación.',
      progressionExplanation: 'Series +10% cada semana. Peso y reps constantes.',
      benefits: ['Ideal para volumen', 'Progresión gradual', 'Adaptación a carga'],
      considerations: ['Requiere tiempo', 'Puede llevar a fatiga'],
      estimatedDuration: 16,
      difficulty: 'moderate',
      targetAudience: ['intermediate'],
    );

    _templates['overload_intensity'] = ProgressionTemplate(
      id: 'overload_intensity',
      name: 'Sobrecarga de Intensidad',
      description: 'Incrementa peso progresivamente manteniendo volumen constante.',
      progressionType: ProgressionType.overload,
      category: 'intermediate',
      goal: 'strength',
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.intensity,
      incrementValue: 2.5,
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 4,
      deloadPercentage: 0.9,
      customParameters: {'overload_type': 'intensity', 'overload_rate': 0.1},
      detailedDescription: 'Incrementa peso en 10% cada semana manteniendo reps y series constantes.',
      whenToUse: 'Fases de intensificación, desarrollo de fuerza, atletas intermedios.',
      deloadExplanation: 'Cada 4 semanas reduce peso al 90% para recuperación.',
      progressionExplanation: 'Peso +10% cada semana. Reps y series constantes.',
      benefits: ['Ideal para fuerza', 'Progresión rápida', 'Adaptación a intensidad'],
      considerations: ['Requiere técnica sólida', 'Deloads importantes'],
      estimatedDuration: 16,
      difficulty: 'moderate',
      targetAudience: ['intermediate'],
    );

    _templates['overload_phases'] = ProgressionTemplate(
      id: 'overload_phases',
      name: 'Sobrecarga por Fases',
      description: 'Fases automáticas: Acumulación (volumen) → Intensificación (peso) → Peaking.',
      progressionType: ProgressionType.overload,
      category: 'advanced',
      goal: 'strength',
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.weight,
      incrementValue: 2.5,
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 4,
      deloadPercentage: 0.9,
      customParameters: {
        'overload_type': 'phases',
        'overload_rate': 0.1,
        'phase_duration_weeks': 4,
        'accumulation_rate': 0.15,
        'intensification_rate': 0.1,
        'peaking_rate': 0.05,
      },
      detailedDescription: 'Fase 1 (4 sem): Volumen +15%, Fase 2 (4 sem): Peso +10%, Fase 3 (4 sem): Peso +5%.',
      whenToUse: 'Periodización avanzada, atletas experimentados, preparación para competencia.',
      deloadExplanation: 'Cada 4 semanas reduce según la fase actual para recuperación.',
      progressionExplanation: 'Cambia automáticamente entre volumen e intensidad según la fase.',
      benefits: ['Periodización automática', 'Adaptación completa', 'Ideal para competencia'],
      considerations: ['Muy complejo', 'Requiere experiencia avanzada'],
      estimatedDuration: 24,
      difficulty: 'hard',
      targetAudience: ['advanced'],
    );

    // Plantilla para principiantes - Hipertrofia
    _templates['overload_beginner_hypertrophy'] = ProgressionTemplate(
      id: 'overload_beginner_hypertrophy',
      name: 'Sobrecarga Básica - Hipertrofia',
      description: 'Progresión de volumen simple para principiantes enfocada en hipertrofia.',
      progressionType: ProgressionType.overload,
      category: 'beginner',
      goal: 'hypertrophy',
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.volume,
      incrementValue: 0.0,
      incrementFrequency: 1,
      cycleLength: 6,
      deloadWeek: 6,
      deloadPercentage: 0.8,
      customParameters: {'overload_type': 'volume', 'overload_rate': 0.05},
      detailedDescription: 'Incrementa series en 5% cada semana manteniendo peso y reps constantes.',
      whenToUse: 'Principiantes, hipertrofia, ejercicios de aislamiento.',
      deloadExplanation: 'Cada 6 semanas reduce series al 80% para recuperación.',
      progressionExplanation: 'Series +5% cada semana. Peso y reps constantes.',
      benefits: ['Simple para principiantes', 'Ideal para hipertrofia', 'Progresión gradual'],
      considerations: ['Progresión muy lenta', 'Requiere paciencia'],
      estimatedDuration: 20,
      difficulty: 'easy',
      targetAudience: ['beginner'],
    );

    // Plantilla para powerlifting
    _templates['overload_powerlifting'] = ProgressionTemplate(
      id: 'overload_powerlifting',
      name: 'Sobrecarga - Powerlifting',
      description: 'Progresión de intensidad optimizada para powerlifting.',
      progressionType: ProgressionType.overload,
      category: 'advanced',
      goal: 'powerlifting',
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.intensity,
      incrementValue: 0.0,
      incrementFrequency: 1,
      cycleLength: 3,
      deloadWeek: 3,
      deloadPercentage: 0.85,
      customParameters: {'overload_type': 'intensity', 'overload_rate': 0.15},
      detailedDescription: 'Incrementa peso en 15% cada semana manteniendo reps y series constantes.',
      whenToUse: 'Powerlifting, ejercicios principales, desarrollo de fuerza máxima.',
      deloadExplanation: 'Cada 3 semanas reduce peso al 85% para recuperación.',
      progressionExplanation: 'Peso +15% cada semana. Reps y series constantes.',
      benefits: ['Ideal para powerlifting', 'Progresión agresiva', 'Desarrollo de fuerza máxima'],
      considerations: ['Requiere técnica perfecta', 'Deloads frecuentes'],
      estimatedDuration: 14,
      difficulty: 'hard',
      targetAudience: ['advanced'],
    );

    // Plantilla para powerbuilding
    _templates['overload_powerbuilding'] = ProgressionTemplate(
      id: 'overload_powerbuilding',
      name: 'Sobrecarga - Powerbuilding',
      description: 'Combina progresión de volumen e intensidad para powerbuilding.',
      progressionType: ProgressionType.overload,
      category: 'intermediate',
      goal: 'powerbuilding',
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.weight,
      incrementValue: 0.0,
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 4,
      deloadPercentage: 0.85,
      customParameters: {
        'overload_type': 'phases',
        'overload_rate': 0.1,
        'phase_duration_weeks': 2,
        'accumulation_rate': 0.1,
        'intensification_rate': 0.1,
      },
      detailedDescription: 'Fase 1 (2 sem): Volumen +10%, Fase 2 (2 sem): Peso +10%.',
      whenToUse: 'Powerbuilding, combinación fuerza-hipertrofia, atletas intermedios.',
      deloadExplanation: 'Cada 4 semanas reduce según la fase actual para recuperación.',
      progressionExplanation: 'Alterna entre incrementar volumen e intensidad cada 2 semanas.',
      benefits: ['Combina fuerza e hipertrofia', 'Progresión equilibrada', 'Versátil'],
      considerations: ['Requiere planificación', 'Complejo de seguir'],
      estimatedDuration: 18,
      difficulty: 'moderate',
      targetAudience: ['intermediate'],
    );
  }

  // ========== PLANTILLAS AUTORREGULADA ==========
  static void _addAutoregulatedTemplates() {
    _templates['autoregulated_rpe'] = ProgressionTemplate(
      id: 'autoregulated_rpe',
      name: 'Progresión Autoregulada por RPE',
      description: 'Ajusta carga basándose en la percepción de esfuerzo (RPE).',
      progressionType: ProgressionType.autoregulated,
      category: 'advanced',
      goal: 'general',
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.intensity,
      incrementValue: 2.5,
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 4,
      deloadPercentage: 0.85,
      customParameters: {'target_rpe': 8, 'rpe_threshold': 2, 'min_rpe': 6, 'max_rpe': 9},
      detailedDescription: 'Si RPE < 6: Aumenta peso. Si RPE > 9: Reduce peso. Objetivo: RPE 8.',
      whenToUse: 'Atletas avanzados, autoregulación, variabilidad individual.',
      deloadExplanation: 'Cada 4 semanas reduce intensidad al 85% para recuperación.',
      progressionExplanation: 'Ajusta peso según RPE reportado para mantener intensidad óptima.',
      benefits: ['Adaptación individual', 'Flexibilidad', 'Ideal para avanzados'],
      considerations: ['Requiere experiencia en RPE', 'Más subjetivo'],
      estimatedDuration: 20,
      difficulty: 'hard',
      targetAudience: ['advanced'],
    );
  }

  // ========== PLANTILLAS DOUBLE FACTOR ==========
  static void _addDoubleFactorTemplates() {
    _templates['double_factor_alternating'] = ProgressionTemplate(
      id: 'double_factor_alternating',
      name: 'Doble Factor Alternante',
      description: 'Semanas impares: Incrementa peso. Semanas pares: Incrementa reps.',
      progressionType: ProgressionType.doubleFactor,
      category: 'advanced',
      goal: 'general',
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.weight,
      secondaryTarget: ProgressionTarget.reps,
      incrementValue: 2.5,
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 4,
      deloadPercentage: 0.85,
      customParameters: {'min_reps': 6, 'max_reps': 10, 'alternating_pattern': true},
      detailedDescription: 'Semana 1,3,5: Peso +2.5kg. Semana 2,4,6: Reps +1.',
      whenToUse: 'Atletas avanzados, progresión rápida, manipulación dual.',
      deloadExplanation: 'Cada 4 semanas reduce peso al 85% y resetea reps.',
      progressionExplanation: 'Alterna entre incrementar peso (semanas impares) y reps (semanas pares).',
      benefits: ['Progresión rápida', 'Manipulación dual', 'Ideal para avanzados'],
      considerations: ['Muy complejo', 'Requiere alta experiencia'],
      estimatedDuration: 20,
      difficulty: 'hard',
      targetAudience: ['advanced'],
    );
  }

  // ========== PLANTILLAS REVERSE ==========
  static void _addReverseTemplates() {
    _templates['reverse_deload'] = ProgressionTemplate(
      id: 'reverse_deload',
      name: 'Progresión Inversa para Deload',
      description: 'Reduce peso progresivamente mientras aumenta reps para deload activo.',
      progressionType: ProgressionType.reverse,
      category: 'specialized',
      goal: 'general',
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.reps,
      secondaryTarget: ProgressionTarget.weight,
      incrementValue: -2.5,
      incrementFrequency: 1,
      cycleLength: 3,
      deloadWeek: 0,
      deloadPercentage: 1.0,
      customParameters: {'max_reps': 15, 'weight_reduction_rate': 0.1},
      detailedDescription: 'Reduce peso en 10% cada semana mientras aumenta reps hasta 15.',
      whenToUse: 'Deloads activos, recuperación, transición entre fases.',
      deloadExplanation: 'No requiere deload adicional, es un deload activo.',
      progressionExplanation: 'Peso -10% cada semana, Reps +1 hasta máximo de 15.',
      benefits: ['Deload activo', 'Mantiene movimiento', 'Recuperación efectiva'],
      considerations: ['Solo para deloads', 'No para progresión principal'],
      estimatedDuration: 6,
      difficulty: 'easy',
      targetAudience: ['intermediate', 'advanced'],
    );

    // ===== PLANTILLAS CON FASES AUTOMÁTICAS =====

    // Plantilla de Fases para Hipertrofia
    _templates['overload_phases_hypertrophy'] = ProgressionTemplate(
      id: 'overload_phases_hypertrophy',
      name: 'Sobrecarga por Fases - Hipertrofia',
      description: 'Periodización automática con fases de acumulación, intensificación y peaking para hipertrofia.',
      progressionType: ProgressionType.overload,
      category: 'intermediate',
      goal: 'hypertrophy',
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.volume,
      incrementValue: 0.0,
      incrementFrequency: 1,
      cycleLength: 12,
      deloadWeek: 12,
      deloadPercentage: 0.8,
      customParameters: {
        'overload_type': 'phases',
        'phase_duration_weeks': 4,
        'accumulation_rate': 0.2, // 20% incremento de volumen
        'intensification_rate': 0.05, // 5% incremento de peso
        'peaking_rate': 0.02, // 2% incremento mínimo
      },
      detailedDescription:
          'Fase 1 (4 sem): Incrementa volumen en 20% cada semana. Fase 2 (4 sem): Incrementa peso en 5% cada semana. Fase 3 (4 sem): Incrementa peso en 2% con volumen reducido.',
      whenToUse: 'Hipertrofia, atletas intermedios, preparación para competencia de culturismo.',
      deloadExplanation: 'Cada 12 semanas reduce peso al 80% y volumen al 70% para recuperación.',
      progressionExplanation:
          'Acumulación: Volumen +20% semanal. Intensificación: Peso +5% semanal. Peaking: Peso +2% con volumen -20%.',
      benefits: [
        'Periodización automática completa',
        'Ideal para hipertrofia',
        'Progresión científica',
        'Preparación para competencia',
      ],
      considerations: [
        'Requiere experiencia intermedia',
        'Planificación de 12 semanas',
        'Monitoreo de fatiga necesario',
      ],
      estimatedDuration: 12,
      difficulty: 'medium',
      targetAudience: ['intermediate', 'advanced'],
    );

    // Plantilla de Fases para Powerlifting
    _templates['overload_phases_powerlifting'] = ProgressionTemplate(
      id: 'overload_phases_powerlifting',
      name: 'Sobrecarga por Fases - Powerlifting',
      description:
          'Periodización automática optimizada para powerlifting con fases de acumulación, intensificación y peaking.',
      progressionType: ProgressionType.overload,
      category: 'advanced',
      goal: 'powerlifting',
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.intensity,
      incrementValue: 0.0,
      incrementFrequency: 1,
      cycleLength: 16,
      deloadWeek: 16,
      deloadPercentage: 0.85,
      customParameters: {
        'overload_type': 'phases',
        'phase_duration_weeks': 5, // Fases más largas
        'accumulation_rate': 0.1, // 10% incremento de volumen
        'intensification_rate': 0.15, // 15% incremento de peso
        'peaking_rate': 0.08, // 8% incremento en peaking
      },
      detailedDescription:
          'Fase 1 (5 sem): Incrementa volumen en 10% cada semana. Fase 2 (5 sem): Incrementa peso en 15% cada semana. Fase 3 (5 sem): Incrementa peso en 8% con volumen reducido.',
      whenToUse: 'Powerlifting, preparación para competencia, desarrollo de fuerza máxima.',
      deloadExplanation: 'Cada 16 semanas reduce peso al 85% y volumen al 70% para recuperación.',
      progressionExplanation:
          'Acumulación: Volumen +10% semanal. Intensificación: Peso +15% semanal. Peaking: Peso +8% con volumen -20%.',
      benefits: [
        'Ideal para powerlifting',
        'Desarrollo de fuerza máxima',
        'Preparación para competencia',
        'Periodización científica',
      ],
      considerations: [
        'Requiere experiencia avanzada',
        'Planificación de 16 semanas',
        'Técnica perfecta necesaria',
        'Monitoreo intensivo de fatiga',
      ],
      estimatedDuration: 16,
      difficulty: 'hard',
      targetAudience: ['advanced'],
    );

    // Plantilla de Fases para Powerbuilding
    _templates['overload_phases_powerbuilding'] = ProgressionTemplate(
      id: 'overload_phases_powerbuilding',
      name: 'Sobrecarga por Fases - Powerbuilding',
      description: 'Periodización automática que combina desarrollo de fuerza e hipertrofia con fases equilibradas.',
      progressionType: ProgressionType.overload,
      category: 'intermediate',
      goal: 'powerbuilding',
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.weight,
      incrementValue: 0.0,
      incrementFrequency: 1,
      cycleLength: 12,
      deloadWeek: 12,
      deloadPercentage: 0.8,
      customParameters: {
        'overload_type': 'phases',
        'phase_duration_weeks': 4,
        'accumulation_rate': 0.15, // 15% incremento de volumen
        'intensification_rate': 0.1, // 10% incremento de peso
        'peaking_rate': 0.05, // 5% incremento en peaking
      },
      detailedDescription:
          'Fase 1 (4 sem): Incrementa volumen en 15% cada semana. Fase 2 (4 sem): Incrementa peso en 10% cada semana. Fase 3 (4 sem): Incrementa peso en 5% con volumen reducido.',
      whenToUse: 'Powerbuilding, combinación fuerza-hipertrofia, atletas intermedios.',
      deloadExplanation: 'Cada 12 semanas reduce peso al 80% y volumen al 70% para recuperación.',
      progressionExplanation:
          'Acumulación: Volumen +15% semanal. Intensificación: Peso +10% semanal. Peaking: Peso +5% con volumen -20%.',
      benefits: [
        'Combina fuerza e hipertrofia',
        'Progresión equilibrada',
        'Versátil para múltiples objetivos',
        'Periodización automática',
      ],
      considerations: [
        'Requiere experiencia intermedia',
        'Planificación de 12 semanas',
        'Monitoreo de fatiga necesario',
      ],
      estimatedDuration: 12,
      difficulty: 'medium',
      targetAudience: ['intermediate', 'advanced'],
    );

    // Plantilla de Fases para Principiantes
    _templates['overload_phases_beginner'] = ProgressionTemplate(
      id: 'overload_phases_beginner',
      name: 'Sobrecarga por Fases - Principiantes',
      description: 'Periodización automática simplificada para principiantes con progresión gradual.',
      progressionType: ProgressionType.overload,
      category: 'beginner',
      goal: 'hypertrophy',
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.volume,
      incrementValue: 0.0,
      incrementFrequency: 1,
      cycleLength: 9,
      deloadWeek: 9,
      deloadPercentage: 0.85,
      customParameters: {
        'overload_type': 'phases',
        'phase_duration_weeks': 3, // Fases más cortas
        'accumulation_rate': 0.1, // 10% incremento de volumen
        'intensification_rate': 0.05, // 5% incremento de peso
        'peaking_rate': 0.02, // 2% incremento mínimo
      },
      detailedDescription:
          'Fase 1 (3 sem): Incrementa volumen en 10% cada semana. Fase 2 (3 sem): Incrementa peso en 5% cada semana. Fase 3 (3 sem): Incrementa peso en 2% con volumen reducido.',
      whenToUse: 'Principiantes, primeras 9-12 semanas, introducción a periodización.',
      deloadExplanation: 'Cada 9 semanas reduce peso al 85% y volumen al 70% para recuperación.',
      progressionExplanation:
          'Acumulación: Volumen +10% semanal. Intensificación: Peso +5% semanal. Peaking: Peso +2% con volumen -20%.',
      benefits: [
        'Ideal para principiantes',
        'Progresión gradual',
        'Introducción a periodización',
        'Fases cortas y manejables',
      ],
      considerations: ['Progresión muy conservadora', 'Requiere paciencia', 'Fases cortas pueden limitar adaptaciones'],
      estimatedDuration: 9,
      difficulty: 'easy',
      targetAudience: ['beginner'],
    );

    // Plantilla de Fases para Competencia
    _templates['overload_phases_competition'] = ProgressionTemplate(
      id: 'overload_phases_competition',
      name: 'Sobrecarga por Fases - Competencia',
      description: 'Periodización automática optimizada para preparación de competencia con pico de rendimiento.',
      progressionType: ProgressionType.overload,
      category: 'advanced',
      goal: 'competition',
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.intensity,
      incrementValue: 0.0,
      incrementFrequency: 1,
      cycleLength: 20,
      deloadWeek: 20,
      deloadPercentage: 0.8,
      customParameters: {
        'overload_type': 'phases',
        'phase_duration_weeks': 6, // Fases largas para adaptación
        'accumulation_rate': 0.12, // 12% incremento de volumen
        'intensification_rate': 0.12, // 12% incremento de peso
        'peaking_rate': 0.06, // 6% incremento en peaking
      },
      detailedDescription:
          'Fase 1 (6 sem): Incrementa volumen en 12% cada semana. Fase 2 (6 sem): Incrementa peso en 12% cada semana. Fase 3 (6 sem): Incrementa peso en 6% con volumen reducido.',
      whenToUse: 'Preparación para competencia, atletas avanzados, pico de rendimiento.',
      deloadExplanation: 'Cada 20 semanas reduce peso al 80% y volumen al 70% para recuperación.',
      progressionExplanation:
          'Acumulación: Volumen +12% semanal. Intensificación: Peso +12% semanal. Peaking: Peso +6% con volumen -20%.',
      benefits: [
        'Ideal para competencia',
        'Pico de rendimiento optimizado',
        'Periodización científica avanzada',
        'Adaptaciones profundas',
      ],
      considerations: [
        'Requiere experiencia avanzada',
        'Planificación de 20 semanas',
        'Monitoreo intensivo necesario',
        'Riesgo de sobreentrenamiento',
      ],
      estimatedDuration: 20,
      difficulty: 'hard',
      targetAudience: ['advanced'],
    );
  }

  // ========== PLANTILLAS STATIC ==========
  static void _addStaticTemplates() {
    _templates['static_maintenance'] = ProgressionTemplate(
      id: 'static_maintenance',
      name: 'Progresión Estática de Mantenimiento',
      description: 'Mantiene valores constantes sin progresión. Para mantenimiento.',
      progressionType: ProgressionType.static,
      category: 'specialized',
      goal: 'general',
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.volume,
      incrementValue: 0.0,
      incrementFrequency: 0,
      cycleLength: 4,
      deloadWeek: 0,
      deloadPercentage: 1.0,
      customParameters: {},
      detailedDescription: 'Mantiene peso, reps y series constantes sin cambios.',
      whenToUse: 'Mantenimiento, recuperación, ejercicios de rehabilitación.',
      deloadExplanation: 'No requiere deload, mantiene intensidad constante.',
      progressionExplanation: 'Sin cambios. Mantiene valores constantes.',
      benefits: ['Sin complejidad', 'Mantenimiento', 'Recuperación'],
      considerations: ['Sin progresión', 'Solo para casos específicos'],
      estimatedDuration: 8,
      difficulty: 'easy',
      targetAudience: ['beginner', 'intermediate', 'advanced'],
    );
  }
}
