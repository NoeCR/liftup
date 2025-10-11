import 'package:hive/hive.dart';
import 'package:easy_localization/easy_localization.dart';

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

  /// Obtiene el nombre para mostrar del tipo de progresión usando localización
  String get displayName {
    // Importar easy_localization dinámicamente para evitar dependencias circulares
    try {
      // Usar el displayNameKey para obtener la traducción
      return displayNameKey.tr();
    } catch (e) {
      // Fallback a nombres hardcodeados si hay error de localización
      switch (this) {
        case ProgressionType.none:
          return 'Sin progresión';
        case ProgressionType.linear:
          return 'Progresión Lineal';
        case ProgressionType.stepped:
          return 'Progresión Escalonada';
        case ProgressionType.double:
          return 'Progresión Doble';
        case ProgressionType.doubleFactor:
          return 'Progresión Doble Factor';
        case ProgressionType.undulating:
          return 'Progresión Ondulante';
        case ProgressionType.wave:
          return 'Progresión por Oleadas';
        case ProgressionType.overload:
          return 'Progresión por Sobrecarga';
        case ProgressionType.static:
          return 'Progresión Estática';
        case ProgressionType.reverse:
          return 'Progresión Inversa';
        case ProgressionType.autoregulated:
          return 'Progresión Autoregulada';
      }
    }
  }

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
