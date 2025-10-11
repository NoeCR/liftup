import 'package:hive/hive.dart';

part 'progression_type_enum.g.dart';

@HiveType(typeId: 15)
enum ProgressionType {
  @HiveField(0)
  none('progression.types.none', 'progression.types.noneDescription'),

  @HiveField(1)
  linear('progression.types.linear', 'progression.types.linearDescription'),

  @HiveField(2)
  undulating('progression.types.undulating', 'progression.types.undulatingDescription'),

  @HiveField(3)
  stepped('progression.types.stepped', 'progression.types.steppedDescription'),

  @HiveField(4)
  double('progression.types.double', 'progression.types.doubleDescription'),

  @HiveField(5)
  autoregulated('progression.types.autoregulated', 'progression.types.autoregulatedDescription'),

  @HiveField(6)
  doubleFactor('progression.types.doubleFactor', 'progression.types.doubleFactorDescription'),

  @HiveField(7)
  overload('progression.types.overload', 'progression.types.overloadDescription'),

  @HiveField(8)
  wave('progression.types.wave', 'progression.types.waveDescription'),

  @HiveField(9)
  static('progression.types.static', 'progression.types.staticDescription'),

  @HiveField(10)
  reverse('progression.types.reverse', 'progression.types.reverseDescription');

  const ProgressionType(this.displayNameKey, this.descriptionKey);

  final String displayNameKey;
  final String descriptionKey;

  static ProgressionType fromString(String value) {
    return ProgressionType.values.firstWhere((type) => type.name == value, orElse: () => ProgressionType.none);
  }
}

@HiveType(typeId: 16)
enum ProgressionUnit {
  @HiveField(0)
  session('progression.units.session'),

  @HiveField(1)
  week('progression.units.week'),

  @HiveField(2)
  cycle('progression.units.cycle');

  const ProgressionUnit(this.displayNameKey);

  final String displayNameKey;
}

@HiveType(typeId: 17)
enum ProgressionTarget {
  @HiveField(0)
  weight('progression.targets.weight'),

  @HiveField(1)
  reps('progression.targets.reps'),

  @HiveField(2)
  sets('progression.targets.sets'),

  @HiveField(3)
  volume('progression.targets.volume'),

  @HiveField(4)
  intensity('progression.targets.intensity');

  const ProgressionTarget(this.displayNameKey);

  final String displayNameKey;
}
