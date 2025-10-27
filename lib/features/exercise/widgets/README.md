# Sistema de Animaciones para Ejercicios

Este directorio contiene los widgets especializados para crear una experiencia de usuario fluida y atractiva en la gestión de ejercicios.

## Componentes Principales

### 1. AnimatedExerciseCard
Widget que representa una tarjeta de ejercicio con animaciones integradas.

**Características:**
- Elevación animada al presionar
- Escalado durante el arrastre
- Animación del botón de favorito
- Feedback háptico
- Estados visuales para drag and drop

**Uso:**
```dart
AnimatedExerciseCard(
  exercise: exercise,
  index: index,
  isDragging: isDragging,
  isBeingDragged: isBeingDragged,
  onTap: () => context.push('/exercise/${exercise.id}'),
  onFavoriteToggle: () => toggleFavorite(exercise.id),
)
```

### 2. ReorderableExerciseList
Lista reordenable que utiliza AnimatedExerciseCard y maneja el drag and drop.

**Características:**
- Reordenamiento por drag and drop
- Animación automática al marcar como favorito
- Integración con el notifier
- Manejo de errores

**Uso:**
```dart
ReorderableExerciseList(
  exercises: filteredExercises,
  onExerciseTap: (exercise) => context.push('/exercise/${exercise.id}'),
  onFavoriteToggle: (exercise) => toggleFavorite(exercise.id),
  emptyBuilder: () => _buildEmptyState(),
  errorBuilder: (error) => _buildErrorState(error),
)
```

### 3. FavoriteAnimationWidget
Widget especializado para animar el movimiento de ejercicios cuando se marcan como favoritos.

**Características:**
- Animación de elevación
- Movimiento suave hacia la posición objetivo
- Animación de descenso
- Feedback háptico

## Flujo de Animaciones

### Al marcar como favorito:
1. **Elevación**: La tarjeta se eleva del fondo con una animación de escala
2. **Movimiento**: Se mueve suavemente hacia la parte superior de la lista
3. **Descenso**: Se deposita en su nueva posición con una animación de descenso
4. **Feedback**: Vibración háptica para confirmar la acción

### Durante el drag and drop:
1. **Inicio**: La tarjeta se eleva y escala ligeramente
2. **Arrastre**: Sigue el dedo del usuario con animaciones suaves
3. **Reordenamiento**: Los elementos se reorganizan automáticamente
4. **Finalización**: La tarjeta regresa a su tamaño normal

## Integración

Para usar estos widgets en tus páginas:

1. **Importa los widgets necesarios:**
```dart
import '../widgets/reorderable_exercise_list.dart';
```

2. **Reemplaza tu ListView.builder con ReorderableExerciseList:**
```dart
// Antes
ListView.builder(
  itemCount: exercises.length,
  itemBuilder: (context, index) => _buildExerciseCard(exercises[index]),
)

// Después
ReorderableExerciseList(
  exercises: exercises,
  onExerciseTap: (exercise) => _handleExerciseTap(exercise),
  onFavoriteToggle: (exercise) => _handleFavoriteToggle(exercise),
)
```

3. **Actualiza tu notifier para manejar reordenamiento:**
```dart
// En tu notifier
Future<void> reorderExercises(List<Exercise> reorderedExercises) async {
  // Implementar lógica de reordenamiento
}
```

## Personalización

### Colores y Estilos
Los widgets respetan el tema de la aplicación y se adaptan automáticamente a los colores del ColorScheme.

### Duración de Animaciones
Puedes ajustar las duraciones en los AnimationController:
- Elevación: 200ms
- Movimiento: 400ms
- Escalado: 150ms

### Feedback Háptico
Se incluye feedback háptico automático:
- `HapticFeedback.lightImpact()` para favoritos
- `HapticFeedback.mediumImpact()` para reordenamiento

## Consideraciones de Rendimiento

- Los widgets están optimizados para listas grandes
- Las animaciones se cancelan automáticamente si el widget se desmonta
- El estado se mantiene sincronizado con el notifier
- Las animaciones no bloquean la UI principal

## Troubleshooting

### Si las animaciones no funcionan:
1. Verifica que el notifier esté correctamente configurado
2. Asegúrate de que los callbacks estén implementados
3. Revisa que el estado se esté actualizando correctamente

### Si el drag and drop no responde:
1. Verifica que el ReorderableListView tenga el padding correcto
2. Asegúrate de que los keys sean únicos para cada elemento
3. Revisa que el onReorder esté implementado

### Si las animaciones son muy lentas:
1. Reduce la duración de las animaciones
2. Usa Curves más simples (easeInOut en lugar de elasticOut)
3. Considera deshabilitar animaciones en dispositivos de bajo rendimiento
