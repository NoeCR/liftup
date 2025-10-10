import 'package:equatable/equatable.dart';

/// Resultado del cálculo de progresión
class ProgressionCalculationResult extends Equatable {
  final double newWeight;
  final int newReps;
  final int newSets;
  final bool incrementApplied;
  final bool isDeload;
  final bool shouldResetCycle;
  final String reason;

  const ProgressionCalculationResult({
    required this.newWeight,
    required this.newReps,
    required this.newSets,
    required this.incrementApplied,
    this.isDeload = false,
    this.shouldResetCycle = false,
    required this.reason,
  });

  @override
  List<Object?> get props => [newWeight, newReps, newSets, incrementApplied, isDeload, shouldResetCycle, reason];

  @override
  String toString() {
    return 'ProgressionCalculationResult(newWeight: $newWeight, newReps: $newReps, newSets: $newSets, incrementApplied: $incrementApplied, isDeload: $isDeload, shouldResetCycle: $shouldResetCycle, reason: $reason)';
  }
}
