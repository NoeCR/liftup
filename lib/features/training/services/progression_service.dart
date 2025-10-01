import 'dart:math' as math;

/// Servicio sencillo para sugerencias de progresión (MVP).
/// Regla base: si la última semana se completó >=90% de las reps objetivo,
/// aumentar peso en incremento fijo; si <70%, reducir; en otro caso, mantener.
class ProgressionService {
  static const double defaultIncrementKg = 2.5;
  static const double minWeightKg = 0.0;

  const ProgressionService();

  double suggestNextWeight({
    required double currentWeight,
    required int targetReps,
    required int achievedReps,
    double incrementKg = defaultIncrementKg,
  }) {
    if (currentWeight <= 0) return math.max(minWeightKg, incrementKg);

    final ratio = achievedReps / targetReps.clamp(1, 999).toDouble();
    if (ratio >= 0.9) {
      return currentWeight + incrementKg;
    } else if (ratio < 0.7) {
      return math.max(minWeightKg, currentWeight - incrementKg);
    }
    return currentWeight;
  }
}


