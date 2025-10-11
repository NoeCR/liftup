# Guía de Fases Automáticas en OverloadProgressionStrategy

## 📋 Resumen

La estrategia `OverloadProgressionStrategy` ahora incluye soporte para **fases automáticas de periodización**, permitiendo transiciones automáticas entre fases de acumulación, intensificación y peaking sin intervención manual.

## 🎯 Tipos de Sobrecarga Disponibles

### 1. **Sobrecarga de Volumen** (`overload_type: 'volume'`)
- **Enfoque**: Incrementa series manteniendo peso y repeticiones constantes
- **Uso**: Ideal para hipertrofia y acumulación de volumen
- **Parámetro**: `overload_rate` (default: 0.1 = 10%)

```dart
customParameters: {
  'overload_type': 'volume',
  'overload_rate': 0.1, // Incrementa series en 10%
}
```

### 2. **Sobrecarga de Intensidad** (`overload_type: 'intensity'`)
- **Enfoque**: Incrementa peso manteniendo repeticiones y series constantes
- **Uso**: Ideal para desarrollo de fuerza máxima
- **Parámetro**: `overload_rate` (default: 0.1 = 10%)

```dart
customParameters: {
  'overload_type': 'intensity',
  'overload_rate': 0.1, // Incrementa peso en 10%
}
```

### 3. **Sobrecarga por Fases** (`overload_type: 'phases'`) ⭐ **NUEVO**
- **Enfoque**: Cambia automáticamente entre volumen e intensidad según la fase
- **Uso**: Periodización completa automática
- **Parámetros**: Múltiples tasas de incremento por fase

```dart
customParameters: {
  'overload_type': 'phases',
  'phase_duration_weeks': 4,        // Duración de cada fase
  'accumulation_rate': 0.15,        // Tasa en fase de acumulación
  'intensification_rate': 0.1,      // Tasa en fase de intensificación
  'peaking_rate': 0.05,             // Tasa en fase de peaking
}
```

## 🔄 Fases Automáticas

### **Fase 1: Acumulación** (Semanas 1-4)
- **Objetivo**: Construir base de volumen
- **Método**: Incrementa series progresivamente
- **Parámetro**: `accumulation_rate` (default: 0.15 = 15%)
- **Ejemplo**: 4 series → 4.6 series → 5.3 series → 6.1 series

### **Fase 2: Intensificación** (Semanas 5-8)
- **Objetivo**: Desarrollar fuerza máxima
- **Método**: Incrementa peso progresivamente
- **Parámetro**: `intensification_rate` (default: 0.1 = 10%)
- **Ejemplo**: 100kg → 110kg → 121kg → 133kg

### **Fase 3: Peaking** (Semanas 9-12)
- **Objetivo**: Maximizar rendimiento
- **Método**: Incrementa peso con volumen reducido
- **Parámetro**: `peaking_rate` (default: 0.05 = 5%)
- **Ejemplo**: 133kg → 140kg (con series reducidas al 80%)

## ⚙️ Configuración de Parámetros

### **Parámetros Básicos**
```dart
customParameters: {
  'overload_type': 'phases',           // Tipo de sobrecarga
  'overload_rate': 0.1,                // Tasa general (fallback)
  'phase_duration_weeks': 4,           // Duración de cada fase
}
```

### **Parámetros por Fase**
```dart
customParameters: {
  'accumulation_rate': 0.15,           // Tasa de acumulación (15%)
  'intensification_rate': 0.1,         // Tasa de intensificación (10%)
  'peaking_rate': 0.05,                // Tasa de peaking (5%)
}
```

### **Configuración de Deload**
```dart
ProgressionConfig(
  deloadWeek: 12,                      // Semana de deload
  deloadPercentage: 0.8,               // Reducción al 80%
  cycleLength: 12,                     // Longitud total del ciclo
)
```

## 📊 Ejemplos de Configuración

### **Configuración para Hipertrofia**
```dart
ProgressionConfig(
  type: ProgressionType.overload,
  unit: ProgressionUnit.week,
  cycleLength: 12,
  deloadWeek: 12,
  deloadPercentage: 0.8,
  customParameters: {
    'overload_type': 'phases',
    'phase_duration_weeks': 4,
    'accumulation_rate': 0.2,          // 20% incremento de volumen
    'intensification_rate': 0.05,      // 5% incremento de peso
    'peaking_rate': 0.02,              // 2% incremento mínimo
  },
)
```

### **Configuración para Powerlifting**
```dart
ProgressionConfig(
  type: ProgressionType.overload,
  unit: ProgressionUnit.week,
  cycleLength: 16,
  deloadWeek: 16,
  deloadPercentage: 0.85,
  customParameters: {
    'overload_type': 'phases',
    'phase_duration_weeks': 5,         // Fases más largas
    'accumulation_rate': 0.1,          // 10% incremento de volumen
    'intensification_rate': 0.15,      // 15% incremento de peso
    'peaking_rate': 0.08,              // 8% incremento en peaking
  },
)
```

### **Configuración para Powerbuilding**
```dart
ProgressionConfig(
  type: ProgressionType.overload,
  unit: ProgressionUnit.week,
  cycleLength: 12,
  deloadWeek: 12,
  deloadPercentage: 0.8,
  customParameters: {
    'overload_type': 'phases',
    'phase_duration_weeks': 4,
    'accumulation_rate': 0.15,         // 15% incremento de volumen
    'intensification_rate': 0.1,       // 10% incremento de peso
    'peaking_rate': 0.05,              // 5% incremento en peaking
  },
)
```

## 🧪 Casos de Prueba

### **Semana 1-4: Acumulación**
```dart
// Semana 1: 4 series base
// Semana 2: 4.6 series (4 * 1.15)
// Semana 3: 5.3 series (4 * 1.15^2)
// Semana 4: 6.1 series (4 * 1.15^3)
```

### **Semana 5-8: Intensificación**
```dart
// Semana 5: 100kg * 1.1 = 110kg
// Semana 6: 110kg * 1.1 = 121kg
// Semana 7: 121kg * 1.1 = 133kg
// Semana 8: 133kg * 1.1 = 146kg
```

### **Semana 9-12: Peaking**
```dart
// Semana 9: 146kg * 1.05 = 153kg, series: 4 * 0.8 = 3.2 → 3
// Semana 10: 153kg * 1.05 = 161kg, series: 3
// Semana 11: 161kg * 1.05 = 169kg, series: 3
// Semana 12: Deload al 80%
```

## 🔧 Implementación Técnica

### **Determinación de Fase**
```dart
PhaseInfo _determineCurrentPhase(ProgressionConfig config, int currentInCycle) {
  final phaseDurationWeeks = config.customParameters['phase_duration_weeks'] ?? 4;
  final currentPhase = ((currentInCycle - 1) / phaseDurationWeeks).floor().clamp(0, 2);
  final weekInPhase = ((currentInCycle - 1) % phaseDurationWeeks) + 1;
  
  return PhaseInfo(
    phase: currentPhase,        // 0: Acumulación, 1: Intensificación, 2: Peaking
    weekInPhase: weekInPhase,
    phaseDuration: phaseDurationWeeks,
  );
}
```

### **Aplicación por Fase**
```dart
switch (phaseInfo.phase) {
  case 0: // Acumulación
    return _applyAccumulationPhase(config, state, currentWeight, currentReps, currentSets, phaseInfo);
  case 1: // Intensificación
    return _applyIntensificationPhase(config, state, currentWeight, currentReps, currentSets, phaseInfo);
  case 2: // Peaking
    return _applyPeakingPhase(config, state, currentWeight, currentReps, currentSets, phaseInfo);
}
```

## 📈 Beneficios

### **Para Usuarios**
- **Periodización automática** sin configuración manual
- **Progresión científica** basada en principios de entrenamiento
- **Flexibilidad** para diferentes objetivos (hipertrofia, fuerza, powerlifting)
- **Adaptabilidad** a diferentes niveles de experiencia

### **Para Desarrolladores**
- **Código modular** y bien estructurado
- **Fácil extensión** para nuevas fases o tipos
- **Testing completo** con casos de prueba
- **Documentación detallada** y ejemplos

## 🚀 Próximas Mejoras

1. **Fases personalizables** por usuario
2. **Integración con RPE** para ajuste automático
3. **Análisis de fatiga** para deloads inteligentes
4. **Plantillas predefinidas** para diferentes deportes
5. **Visualización de fases** en la UI

## 📚 Referencias

- **Periodización**: Principios de sobrecarga progresiva
- **Fases de entrenamiento**: Acumulación, Intensificación, Peaking
- **Deloads**: Recuperación activa y prevención de sobreentrenamiento
- **Powerlifting**: Preparación para competencia
- **Hipertrofia**: Desarrollo de masa muscular
