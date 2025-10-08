import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/progression/strategies/progression_strategy.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/double_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/undulating_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/stepped_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/wave_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/static_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/reverse_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/autoregulated_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/double_factor_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/overload_progression_strategy.dart';

void main() {
  test('Factory maps types to expected strategies', () {
    expect(ProgressionStrategyFactory.fromType(ProgressionType.linear), isA<LinearProgressionStrategy>());
    expect(ProgressionStrategyFactory.fromType(ProgressionType.double), isA<DoubleProgressionStrategy>());
    expect(ProgressionStrategyFactory.fromType(ProgressionType.undulating), isA<UndulatingProgressionStrategy>());
    expect(ProgressionStrategyFactory.fromType(ProgressionType.stepped), isA<SteppedProgressionStrategy>());
    expect(ProgressionStrategyFactory.fromType(ProgressionType.wave), isA<WaveProgressionStrategy>());
    expect(ProgressionStrategyFactory.fromType(ProgressionType.static), isA<StaticProgressionStrategy>());
    expect(ProgressionStrategyFactory.fromType(ProgressionType.reverse), isA<ReverseProgressionStrategy>());
    expect(ProgressionStrategyFactory.fromType(ProgressionType.autoregulated), isA<AutoregulatedProgressionStrategy>());
    expect(ProgressionStrategyFactory.fromType(ProgressionType.doubleFactor), isA<DoubleFactorProgressionStrategy>());
    expect(ProgressionStrategyFactory.fromType(ProgressionType.overload), isA<OverloadProgressionStrategy>());
  });
}
