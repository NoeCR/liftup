/// Modos de progresión para la estrategia Double Factor
///
/// Define diferentes enfoques para manipular dos variables simultáneamente
/// en la progresión de doble factor, cada uno optimizado para diferentes objetivos.
enum DoubleFactorMode {
  /// Modo alternado: alterna entre incrementar peso (semanas impares) y reps (semanas pares)
  ///
  /// **Ventajas:**
  /// - Progresión controlada y predecible
  /// - Menor riesgo de fatiga acumulada
  /// - Ideal para principiantes/intermedios
  /// - Permite adaptación gradual a cada variable
  ///
  /// **Cuándo usar:**
  /// - Objetivos de fuerza y resistencia
  /// - Atletas que buscan progresión estable
  /// - Cuando se prioriza la técnica sobre la velocidad de progresión
  alternate,

  /// Modo simultáneo: incrementa peso y reps en la misma sesión
  ///
  /// **Ventajas:**
  /// - Progresión más rápida
  /// - Mayor estímulo de adaptación
  /// - Efectivo para hipertrofia
  /// - Maximiza el volumen e intensidad
  ///
  /// **Cuándo usar:**
  /// - Objetivos de hipertrofia
  /// - Atletas intermedios/avanzados
  /// - Cuando se busca máximo estímulo de crecimiento
  /// - Con buena capacidad de recuperación
  both,

  /// Modo compuesto: usa un índice compuesto que pondera peso > reps
  ///
  /// **Ventajas:**
  /// - Prioriza la intensidad (peso) sobre el volumen (reps)
  /// - Ideal para objetivos de potencia
  /// - Mantiene la especificidad del movimiento
  /// - Progresión más conservadora en reps
  ///
  /// **Cuándo usar:**
  /// - Objetivos de potencia y fuerza máxima
  /// - Atletas de potencia
  /// - Cuando se busca mantener alta intensidad
  /// - Para movimientos técnicos complejos
  composite,
}

/// Extensión para obtener información descriptiva de los modos
extension DoubleFactorModeExtension on DoubleFactorMode {
  /// Obtiene el nombre legible del modo
  String get displayName {
    switch (this) {
      case DoubleFactorMode.alternate:
        return 'Alternado';
      case DoubleFactorMode.both:
        return 'Simultáneo';
      case DoubleFactorMode.composite:
        return 'Compuesto';
    }
  }

  /// Obtiene la descripción del modo
  String get description {
    switch (this) {
      case DoubleFactorMode.alternate:
        return 'Alterna entre incrementar peso (semanas impares) y reps (semanas pares)';
      case DoubleFactorMode.both:
        return 'Incrementa peso y reps simultáneamente en cada sesión';
      case DoubleFactorMode.composite:
        return 'Usa un índice compuesto que prioriza peso sobre reps';
    }
  }

  /// Obtiene los objetivos recomendados para este modo
  List<String> get recommendedObjectives {
    switch (this) {
      case DoubleFactorMode.alternate:
        return ['strength', 'endurance', 'general'];
      case DoubleFactorMode.both:
        return ['hypertrophy'];
      case DoubleFactorMode.composite:
        return ['power'];
    }
  }

  /// Obtiene el nivel de experiencia recomendado
  String get recommendedExperienceLevel {
    switch (this) {
      case DoubleFactorMode.alternate:
        return 'beginner-intermediate';
      case DoubleFactorMode.both:
        return 'intermediate-advanced';
      case DoubleFactorMode.composite:
        return 'intermediate-advanced';
    }
  }
}
