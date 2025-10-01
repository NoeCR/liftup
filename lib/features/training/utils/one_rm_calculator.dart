import 'dart:math' as math;

/// Utilidades para calcular 1RM (repetición máxima) y porcentajes derivados.
///
/// Métodos implementados:
/// - Epley: 1RM = peso * (1 + reps/30)
/// - Brzycki: 1RM = peso * 36 / (37 - reps)
///
/// Nota: Estas fórmulas son estimaciones. Para >10 repeticiones la precisión baja.
class OneRmCalculator {
  OneRmCalculator._();

  /// Estimación mediante fórmula de Epley.
  static double epley({required double weight, required int reps}) {
    if (weight <= 0 || reps <= 0) return 0;
    return weight * (1 + reps / 30.0);
  }

  /// Estimación mediante fórmula de Brzycki.
  static double brzycki({required double weight, required int reps}) {
    if (weight <= 0 || reps <= 0 || reps >= 37) return 0;
    return weight * (36.0 / (37.0 - reps));
  }

  /// Promedio entre Epley y Brzycki para una estimación más estable.
  static double average({required double weight, required int reps}) {
    final a = epley(weight: weight, reps: reps);
    final b = brzycki(weight: weight, reps: reps);
    if (a == 0 && b == 0) return 0;
    if (a == 0) return b;
    if (b == 0) return a;
    return (a + b) / 2.0;
  }

  /// Devuelve una tabla de porcentajes (50%..95%) basada en un 1RM dado.
  /// Los valores se redondean a la unidad más cercana por defecto.
  static Map<int, double> percentageTable(
    double oneRm, {
    int minPercent = 50,
    int maxPercent = 95,
    int step = 5,
    int roundTo = 1,
  }) {
    if (oneRm <= 0) return {};
    final table = <int, double>{};
    for (int p = minPercent; p <= maxPercent; p += step) {
      final value = oneRm * (p / 100.0);
      table[p] = _roundTo(value, roundTo);
    }
    return table;
  }

  static double _roundTo(double value, int multiple) {
    if (multiple <= 1) return value.roundToDouble();
    final m = multiple.toDouble();
    return (m * (value / m).round()).toDouble();
  }

  /// Calcula el número objetivo de repeticiones para un peso dado según 1RM.
  /// Inversa aproximada (usa Epley por defecto).
  static int targetRepsForWeight({
    required double oneRm,
    required double weight,
  }) {
    if (oneRm <= 0 || weight <= 0 || weight >= oneRm) return 1;
    // Invertimos Epley: oneRm = w * (1 + r/30) => r = 30 * (oneRm/w - 1)
    final reps = 30.0 * ((oneRm / weight) - 1.0);
    return math.max(1, reps.round());
  }
}
