# Matriz de Progresión - Liftly

Este documento proporciona una referencia completa de todas las estrategias de progresión, presets, configuraciones adaptativas y ejemplos para validación manual del sistema.

## 📊 **Estrategias de Progresión Disponibles**

| Estrategia | Descripción | Objetivo Principal | Modo de Operación |
|------------|-------------|-------------------|-------------------|
| **Linear** | Incremento constante por sesión/semana | Progresión predecible | Incremento fijo |
| **Stepped** | Acumulación con deload periódico | Fuerza máxima | Ciclos de carga/descarga |
| **Double** | Reps primero, luego peso | Hipertrofia | Progresión secuencial |
| **DoubleFactor** | Alternancia peso/reps por semana | Balance fitness-fatiga | Modos: alternate/both/composite |
| **Undulating** | Variación de intensidad por sesión | Adaptación neuromuscular | Días pesados/ligeros |
| **Wave** | Ciclos de 3 semanas | Periodización | Progresión ondulante |
| **Autoregulated** | Basada en RPE/RIR | Entrenamiento inteligente | Feedback del usuario |
| **Overload** | Sobrecarga progresiva | Adaptación máxima | Incremento gradual |
| **Static** | Sin cambios | Mantenimiento | Valores constantes |
| **Reverse** | Decremento progresivo | Deload activo | Reducción gradual |

## 🎯 **Objetivos de Entrenamiento**

| Objetivo | Descripción | Rango Reps | Incremento Peso | Aplicación |
|----------|-------------|------------|-----------------|------------|
| **Strength** | Fuerza máxima | 3-6 | Alto (5.0-7.5kg) | Powerlifting |
| **Hypertrophy** | Crecimiento muscular | 6-12 | Medio (2.5-5.0kg) | Culturismo |
| **Endurance** | Resistencia muscular | 15-25 | Bajo (1.0-2.5kg) | Atletismo |
| **Power** | Potencia explosiva | 1-5 | Muy alto (7.5-10.0kg) | Deportes |
| **General** | Desarrollo general | 8-12 | Medio (3.0-5.0kg) | Fitness |

## 🏋️ **Tipos de Ejercicio y Carga**

### Tipos de Ejercicio
- **MultiJoint**: Ejercicios compuestos (sentadilla, press banca)
- **Isolation**: Ejercicios de aislamiento (curl bíceps, extensiones)

### Tipos de Carga
- **Barbell**: Barra olímpica
- **Dumbbell**: Mancuernas
- **Machine**: Máquinas de gimnasio
- **Cable**: Poleas y cables
- **Bodyweight**: Peso corporal
- **ResistanceBand**: Bandas elásticas

## 📈 **Configuración Adaptativa de Incrementos**

### Tabla de Incrementos por Objetivo y Tipo

#### **Strength (Fuerza)**
| Ejercicio | Carga | Rango | Valor por Defecto |
|-----------|-------|-------|-------------------|
| MultiJoint | Barbell | 2.5-5.0kg | 2.5kg |
| MultiJoint | Machine | 2.5-5.0kg | 2.5kg |
| MultiJoint | Dumbbell | 1.25-2.5kg | 1.25kg |
| MultiJoint | Cable | 1.25-2.5kg | 1.25kg |
| Isolation | Barbell | 1.25-2.5kg | 1.25kg |
| Isolation | Machine | 1.25-2.5kg | 1.25kg |
| Isolation | Dumbbell | 1.25-2.5kg | 1.25kg |
| Isolation | Cable | 1.25-2.5kg | 1.25kg |

#### **Hypertrophy (Hipertrofia)**
| Ejercicio | Carga | Rango | Valor por Defecto |
|-----------|-------|-------|-------------------|
| MultiJoint | Barbell | 2.5-5.0kg | 2.5kg |
| MultiJoint | Machine | 2.5-5.0kg | 2.5kg |
| MultiJoint | Dumbbell | 1.25-2.5kg | 1.25kg |
| MultiJoint | Cable | 1.25-2.5kg | 1.25kg |
| Isolation | Barbell | 1.25-2.5kg | 1.25kg |
| Isolation | Machine | 1.25-2.5kg | 1.25kg |
| Isolation | Dumbbell | 0.5-1.25kg | 0.5kg |
| Isolation | Cable | 0.5-1.25kg | 0.5kg |

#### **Endurance (Resistencia)**
| Ejercicio | Carga | Rango | Valor por Defecto |
|-----------|-------|-------|-------------------|
| MultiJoint | Barbell | 0.5-1.5kg | 0.5kg |
| MultiJoint | Machine | 0.5-1.5kg | 0.5kg |
| MultiJoint | Dumbbell | 0.5-1.0kg | 0.5kg |
| MultiJoint | Cable | 0.5-1.0kg | 0.5kg |
| Isolation | Barbell | 0.5-1.0kg | 0.5kg |
| Isolation | Machine | 0.5-1.0kg | 0.5kg |
| Isolation | Dumbbell | 0.5-1.0kg | 0.5kg |
| Isolation | Cable | 0.5-1.0kg | 0.5kg |

#### **Power (Potencia)**
| Ejercicio | Carga | Rango | Valor por Defecto |
|-----------|-------|-------|-------------------|
| MultiJoint | Barbell | 3.75-5.0kg | 3.75kg |
| MultiJoint | Machine | 3.75-5.0kg | 3.75kg |
| MultiJoint | Dumbbell | 1.25-2.5kg | 1.25kg |
| MultiJoint | Cable | 1.25-2.5kg | 1.25kg |
| Isolation | Barbell | 1.25-2.5kg | 1.25kg |
| Isolation | Machine | 1.25-2.5kg | 1.25kg |
| Isolation | Dumbbell | 1.25-2.5kg | 1.25kg |
| Isolation | Cable | 1.25-2.5kg | 1.25kg |

#### **General (Desarrollo General)**
| Ejercicio | Carga | Rango | Valor por Defecto |
|-----------|-------|-------|-------------------|
| MultiJoint | Barbell | 3.0-5.0kg | 3.0kg |
| MultiJoint | Machine | 3.0-5.0kg | 3.0kg |
| MultiJoint | Dumbbell | 1.5-2.5kg | 1.5kg |
| MultiJoint | Cable | 1.5-2.5kg | 1.5kg |
| Isolation | Barbell | 1.5-2.5kg | 1.5kg |
| Isolation | Machine | 1.5-2.5kg | 1.5kg |
| Isolation | Dumbbell | 0.75-1.25kg | 0.75kg |
| Isolation | Cable | 0.75-1.25kg | 0.75kg |

## 🔄 **Rangos de Repeticiones por Objetivo**

### Tabla de Repeticiones Adaptativas

| Objetivo | MultiJoint | Isolation |
|----------|------------|-----------|
| **Strength** | 3-6 reps (default: 3) | 5-8 reps (default: 5) |
| **Hypertrophy** | 6-12 reps (default: 8) | 8-15 reps (default: 10) |
| **Endurance** | 15-25 reps (default: 20) | 20-30 reps (default: 25) |
| **Power** | 1-5 reps (default: 3) | 3-8 reps (default: 5) |
| **General** | 8-12 reps (default: 10) | 10-15 reps (default: 12) |

## 🎛️ **Presets de Progresión**

### **Linear Presets**

#### Linear Hypertrophy
- **Objetivo**: Hypertrophy
- **Incremento**: 2.5kg (barbell), 1.25kg (dumbbell)
- **Frecuencia**: Por sesión
- **Reps**: 8-12
- **Deload**: Cada 4 semanas (80%)

#### Linear Strength
- **Objetivo**: Strength
- **Incremento**: 5.0kg (barbell), 2.5kg (dumbbell)
- **Frecuencia**: Por sesión
- **Reps**: 3-6
- **Deload**: Cada 4 semanas (85%)

#### Linear Endurance
- **Objetivo**: Endurance
- **Incremento**: 1.0kg (barbell), 0.5kg (dumbbell)
- **Frecuencia**: Por sesión
- **Reps**: 15-25
- **Deload**: Cada 6 semanas (90%)

#### Linear Power
- **Objetivo**: Power
- **Incremento**: 7.5kg (barbell), 3.75kg (dumbbell)
- **Frecuencia**: Por sesión
- **Reps**: 1-5
- **Deload**: Cada 3 semanas (80%)

### **Double Factor Presets**

#### Double Factor Hypertrophy
- **Modo**: `both` (incremento simultáneo)
- **Objetivo**: Hypertrophy
- **Reps**: 8-12
- **Series**: 3
- **Deload**: Cada 6 semanas (85%)

#### Double Factor Strength
- **Modo**: `alternate` (alternancia peso/reps)
- **Objetivo**: Strength
- **Reps**: 3-6
- **Series**: 4
- **Deload**: Cada 6 semanas (85%)

#### Double Factor Endurance
- **Modo**: `alternate` (alternancia peso/reps)
- **Objetivo**: Endurance
- **Reps**: 12-20
- **Series**: 3
- **Deload**: Cada 8 semanas (90%)

#### Double Factor Power
- **Modo**: `composite` (índice compuesto)
- **Objetivo**: Power
- **Reps**: 1-5
- **Series**: 5
- **Deload**: Cada 4 semanas (80%)

### **Stepped Presets**

#### Stepped Hypertrophy
- **Objetivo**: Hypertrophy
- **Incremento**: 2.5kg
- **Acumulación**: 3 semanas
- **Deload**: Semana 4 (85%)
- **Reps**: 8-12

#### Stepped Strength
- **Objetivo**: Strength
- **Incremento**: 5.0kg
- **Acumulación**: 3 semanas
- **Deload**: Semana 4 (80%)
- **Reps**: 3-6

### **Wave Presets**

#### Wave Hypertrophy
- **Objetivo**: Hypertrophy
- **Ciclo**: 3 semanas
- **Multiplicadores**: 1.0x, 1.05x, 1.1x
- **Deload**: Cada 4 ciclos (85%)
- **Reps**: 8-12

#### Wave Strength
- **Objetivo**: Strength
- **Ciclo**: 3 semanas
- **Multiplicadores**: 1.0x, 1.1x, 1.2x
- **Deload**: Cada 3 ciclos (80%)
- **Reps**: 3-6

## 🔧 **Modos de Double Factor**

### **Alternate Mode**
- **Semana impar**: Incrementa peso
- **Semana par**: Incrementa reps
- **Aplicación**: Strength, Endurance
- **Ventaja**: Progresión equilibrada

### **Both Mode**
- **Todas las semanas**: Incrementa peso Y reps
- **Aplicación**: Hypertrophy
- **Ventaja**: Progresión agresiva

### **Composite Mode**
- **Todas las semanas**: Incrementa peso + reps (30% del peso)
- **Aplicación**: Power
- **Ventaja**: Progresión priorizada en peso

## 📋 **Ejemplos de Progresión (8 Semanas)**

### **Linear Hypertrophy - Press Banca**
| Semana | Peso | Reps | Series | Notas |
|--------|------|------|--------|-------|
| 1 | 80kg | 10 | 3 | Inicio |
| 2 | 82.5kg | 10 | 3 | +2.5kg |
| 3 | 85kg | 10 | 3 | +2.5kg |
| 4 | 87.5kg | 10 | 3 | +2.5kg |
| 5 | 90kg | 10 | 3 | +2.5kg |
| 6 | 92.5kg | 10 | 3 | +2.5kg |
| 7 | 95kg | 10 | 3 | +2.5kg |
| 8 | 76kg | 10 | 3 | Deload (80%) |

### **Double Factor Strength (Alternate) - Sentadilla**
| Semana | Peso | Reps | Series | Modo |
|--------|------|------|--------|------|
| 1 | 100kg | 5 | 4 | Peso +2.5kg |
| 2 | 100kg | 6 | 4 | Reps +1 |
| 3 | 102.5kg | 6 | 4 | Peso +2.5kg |
| 4 | 102.5kg | 5 | 4 | Reps +1 (máximo) |
| 5 | 105kg | 5 | 4 | Peso +2.5kg |
| 6 | 105kg | 6 | 4 | Reps +1 |
| 7 | 107.5kg | 6 | 4 | Peso +2.5kg |
| 8 | 91.4kg | 5 | 4 | Deload (85%) |

### **Double Factor Hypertrophy (Both) - Press Militar**
| Semana | Peso | Reps | Series | Modo |
|--------|------|------|--------|------|
| 1 | 50kg | 8 | 3 | Peso +1.25kg, Reps +1 |
| 2 | 51.25kg | 9 | 3 | Peso +1.25kg, Reps +1 |
| 3 | 52.5kg | 10 | 3 | Peso +1.25kg, Reps +1 |
| 4 | 53.75kg | 11 | 3 | Peso +1.25kg, Reps +1 |
| 5 | 55kg | 12 | 3 | Peso +1.25kg, Reps +1 |
| 6 | 46.75kg | 10 | 3 | Deload (85%) |
| 7 | 47.5kg | 8 | 3 | Peso +1.25kg, Reps +1 |
| 8 | 48.75kg | 9 | 3 | Peso +1.25kg, Reps +1 |

### **Stepped Strength - Peso Muerto**
| Semana | Peso | Reps | Series | Fase |
|--------|------|------|--------|------|
| 1 | 120kg | 5 | 3 | Acumulación |
| 2 | 122.5kg | 5 | 3 | Acumulación |
| 3 | 125kg | 5 | 3 | Acumulación |
| 4 | 100kg | 5 | 3 | Deload (80%) |
| 5 | 102.5kg | 5 | 3 | Acumulación |
| 6 | 105kg | 5 | 3 | Acumulación |
| 7 | 107.5kg | 5 | 3 | Acumulación |
| 8 | 86kg | 5 | 3 | Deload (80%) |

## 🎯 **Reglas de Prioridad**

### **1. Parámetros Personalizados**
- `customParameters` en `ProgressionConfig` tienen **máxima prioridad**
- Sobrescriben configuraciones adaptativas
- Ejemplo: `'min_reps': 8` > tabla adaptativa

### **2. Configuración Adaptativa**
- Se aplica cuando no hay `customParameters`
- Basada en: `TrainingObjective` + `ExerciseType` + `LoadType`
- Ejemplo: Strength + MultiJoint + Barbell = 5.0kg incremento

### **3. Valores por Defecto**
- Se usan como fallback
- Definidos en `ProgressionConfig`
- Ejemplo: `incrementValue: 2.5`

### **4. Lógica de Deload**
- **Detección automática**: Basada en `deloadWeek` y `currentWeek`
- **Aplicación**: Reduce peso según `deloadPercentage`
- **Recuperación**: Retoma progresión normal post-deload

## 🔍 **Validación Manual**

### **Checklist de Validación**

#### **Linear Progression**
- [ ] Incremento constante por sesión
- [ ] Deload aplicado en semana correcta
- [ ] Reps mantenidas durante ciclo
- [ ] Peso se reduce correctamente en deload

#### **Double Factor (Alternate)**
- [ ] Semana impar: solo peso incrementa
- [ ] Semana par: solo reps incrementan
- [ ] Reps no exceden máximo configurado
- [ ] Deload reduce ambos valores proporcionalmente

#### **Double Factor (Both)**
- [ ] Peso y reps incrementan simultáneamente
- [ ] Incremento de reps respeta límites
- [ ] Progresión más agresiva que alternate
- [ ] Deload aplicado correctamente

#### **Double Factor (Composite)**
- [ ] Peso incrementa según configuración
- [ ] Reps incrementan 30% del incremento de peso
- [ ] Prioridad en incremento de peso
- [ ] Deload reduce ambos valores

#### **Stepped Progression**
- [ ] Acumulación durante semanas configuradas
- [ ] Deload en semana correcta
- [ ] Reducción de peso según porcentaje
- [ ] Retoma acumulación post-deload

#### **Wave Progression**
- [ ] Multiplicadores aplicados por semana
- [ ] Ciclo de 3 semanas respetado
- [ ] Deload cada N ciclos
- [ ] Progresión ondulante visible

### **Métricas de Validación**

#### **Progresión Esperada (8 semanas)**
- **Linear**: 8-15% incremento total
- **Double Factor (Alternate)**: 6-12% incremento total
- **Double Factor (Both)**: 10-18% incremento total
- **Double Factor (Composite)**: 8-14% incremento total
- **Stepped**: 10-20% incremento total
- **Wave**: 8-15% incremento total

#### **Deloads Esperados**
- **Linear**: 2 deloads en 8 semanas
- **Double Factor**: 1-2 deloads en 8 semanas
- **Stepped**: 2 deloads en 8 semanas
- **Wave**: 1-2 deloads en 8 semanas

## 🚨 **Casos Especiales**

### **Bodyweight Exercises**
- **Peso**: No incrementa (mantiene 100kg)
- **Progresión**: Solo reps y series
- **Aplicable**: Todas las estrategias

### **Resistance Band Exercises**
- **Peso**: No incrementa (mantiene 100kg)
- **Progresión**: Solo reps y series
- **Aplicable**: Todas las estrategias

### **Autoregulated Progression**
- **Basado en**: RPE/RIR del usuario
- **Incremento**: Condicional según feedback
- **Aplicación**: Entrenamiento inteligente

### **Static Progression**
- **Sin cambios**: Mantiene valores constantes
- **Uso**: Mantenimiento o deload prolongado
- **Aplicación**: Recuperación

## 📊 **Monitoreo y Métricas**

### **KPIs de Progresión**
- **Incremento promedio por semana**
- **Frecuencia de deloads**
- **Adherencia a rangos de reps**
- **Consistencia en incrementos**

### **Alertas del Sistema**
- **Incremento excesivo**: >10% por semana
- **Deload frecuente**: >50% de sesiones
- **Reps fuera de rango**: <min o >max
- **Progresión estancada**: 0% en 4 semanas

---

**Última actualización**: Diciembre 2024  
**Versión del sistema**: 2.0  
**Estrategias implementadas**: 10  
**Presets disponibles**: 16  
**Tests de validación**: 843 passing
