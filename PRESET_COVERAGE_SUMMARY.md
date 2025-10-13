# Resumen de Cobertura de Presets de Progresión

## Análisis Completo de Estrategias vs Presets

### Estrategias Disponibles (11)
1. **linear** - ✅ Completa (4 presets)
2. **stepped** - ✅ Completa (4 presets)
3. **double** - ✅ Completa (4 presets)
4. **undulating** - ✅ Completa (4 presets)
5. **autoregulated** - ✅ Completa (4 presets) - **NUEVO**
6. **doubleFactor** - ✅ Completa (4 presets) - **NUEVO**
7. **wave** - ✅ Completa (4 presets) - **NUEVO**
8. **overload** - ✅ Completa (4 presets) - **NUEVO**
9. **static** - ✅ Completa (4 presets) - **NUEVO**
10. **reverse** - ✅ Completa (4 presets) - **NUEVO**
11. **none** - ❌ No aplicable (no requiere presets)

### Objetivos de Entrenamiento (4)
- **Hipertrofia** - ✅ Completa (10 presets)
- **Fuerza** - ✅ Completa (10 presets)
- **Resistencia** - ✅ Completa (10 presets)
- **Potencia** - ✅ Completa (10 presets)

## Presets Creados (40 total)

### Estrategias Existentes (20 presets)
- **Linear**: 4 presets (hipertrofia, fuerza, resistencia, potencia)
- **Stepped**: 4 presets (hipertrofia, fuerza, resistencia, potencia)
- **Double**: 4 presets (hipertrofia, fuerza, resistencia, potencia)
- **Undulating**: 4 presets (hipertrofia, fuerza, resistencia, potencia)
- **Autoregulated**: 1 preset existente (hipertrofia) + 3 nuevos

### Estrategias Nuevas (20 presets)
- **Autoregulated**: 3 presets nuevos (fuerza, resistencia, potencia)
- **Double Factor**: 4 presets nuevos (todos los objetivos)
- **Wave**: 4 presets nuevos (todos los objetivos)
- **Overload**: 4 presets nuevos (todos los objetivos)
- **Static**: 4 presets nuevos (todos los objetivos)
- **Reverse**: 4 presets nuevos (todos los objetivos)

## Características de los Nuevos Presets

### Autoregulated
- **Parámetros específicos**: `rpe_threshold_low`, `rpe_threshold_high`
- **Uso**: Progresión basada en RPE del usuario
- **Aplicación**: Ideal para usuarios avanzados que pueden autoregularse

### Double Factor
- **Parámetros específicos**: `volume_week_factor`, `intensity_week_factor`
- **Uso**: Alternancia entre semanas de volumen e intensidad
- **Aplicación**: Periodización avanzada con variación sistemática

### Wave
- **Parámetros específicos**: `high_intensity_factor`, `high_volume_factor`
- **Uso**: Progresión por oleadas de 3 semanas
- **Aplicación**: Variación sistemática de estímulos

### Overload
- **Parámetros específicos**: `overload_factor`, `overload_duration_sessions`
- **Uso**: Períodos de sobrecarga controlada
- **Aplicación**: Supercompensación y adaptación

### Static
- **Parámetros específicos**: `manual_progression: true`
- **Uso**: Sin incrementos automáticos, progresión manual
- **Aplicación**: Usuarios que prefieren control total

### Reverse
- **Parámetros específicos**: `reverse_factor`
- **Uso**: Progresión inversa (reducción de peso)
- **Aplicación**: Deloads activos y recuperación

## Configuraciones por Objetivo

### Hipertrofia (8-12 reps, 3 sets, RPE 8.0)
- Rangos de repeticiones: 8-12
- Series base: 3
- RPE objetivo: 8.0
- Tiempo de descanso: 90 segundos
- Sesiones por semana: 3

### Fuerza (3-6 reps, 4 sets, RPE 8.5)
- Rangos de repeticiones: 3-6
- Series base: 4
- RPE objetivo: 8.5
- Tiempo de descanso: 180 segundos
- Sesiones por semana: 3

### Resistencia (12-20 reps, 3 sets, RPE 7.0)
- Rangos de repeticiones: 12-20
- Series base: 3
- RPE objetivo: 7.0
- Tiempo de descanso: 60 segundos
- Sesiones por semana: 4

### Potencia (1-5 reps, 5 sets, RPE 8.0)
- Rangos de repeticiones: 1-5
- Series base: 5
- RPE objetivo: 8.0
- Tiempo de descanso: 240 segundos
- Sesiones por semana: 3

## Integración con AdaptiveIncrementConfig

Todos los presets utilizan:
- `incrementValue: 0` para forzar el uso de `AdaptiveIncrementConfig`
- Incrementos adaptativos basados en `exerciseType` y `loadType`
- Incrementos de series adaptativos por `loadType`
- Metadatos de internacionalización (`title_key`, `description_key`, `key_points_key`)

## Estado Final

✅ **COBERTURA COMPLETA**: 40 presets para 10 estrategias × 4 objetivos
✅ **SIN DUPLICACIÓN**: Cada preset es único y específico
✅ **INTEGRACIÓN COMPLETA**: Todos usan `AdaptiveIncrementConfig`
✅ **INTERNACIONALIZACIÓN**: Todos tienen claves de traducción
✅ **PARÁMETROS ESPECÍFICOS**: Cada estrategia tiene sus parámetros únicos

El sistema ahora tiene cobertura completa para todas las combinaciones de estrategias y objetivos de entrenamiento disponibles.
