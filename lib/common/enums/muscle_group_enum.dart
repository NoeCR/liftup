import 'package:hive/hive.dart';

part 'muscle_group_enum.g.dart';

@HiveType(typeId: 12)
enum MuscleGroup {
  // Pecho
  @HiveField(0)
  pectoralMajor,
  @HiveField(1)
  pectoralMinor,
  @HiveField(2)
  serratusAnterior,

  // Espalda
  @HiveField(3)
  latissimusDorsi,
  @HiveField(4)
  rhomboids,
  @HiveField(5)
  middleTrapezius,
  @HiveField(6)
  lowerTrapezius,
  @HiveField(7)
  erectorSpinae,
  @HiveField(8)
  teresMajor,
  @HiveField(9)
  teresMinor,
  @HiveField(10)
  infraspinatus,

  // Hombros
  @HiveField(11)
  anteriorDeltoid,
  @HiveField(12)
  medialDeltoid,
  @HiveField(13)
  posteriorDeltoid,
  @HiveField(14)
  upperTrapezius,

  // Brazos - Bíceps
  @HiveField(15)
  bicepsLongHead,
  @HiveField(16)
  bicepsShortHead,
  @HiveField(17)
  brachialis,
  @HiveField(18)
  brachioradialis,

  // Brazos - Tríceps
  @HiveField(19)
  tricepsLongHead,
  @HiveField(20)
  tricepsLateralHead,
  @HiveField(21)
  tricepsMedialHead,

  // Antebrazos
  @HiveField(22)
  forearmFlexors,
  @HiveField(23)
  forearmExtensors,
  @HiveField(24)
  wristFlexors,
  @HiveField(25)
  wristExtensors,

  // Piernas - Cuádriceps
  @HiveField(26)
  rectusFemoris,
  @HiveField(27)
  vastusLateralis,
  @HiveField(28)
  vastusMedialis,
  @HiveField(29)
  vastusIntermedius,

  // Piernas - Isquiotibiales
  @HiveField(30)
  bicepsFemoris,
  @HiveField(31)
  semitendinosus,
  @HiveField(32)
  semimembranosus,

  // Piernas - Glúteos
  @HiveField(33)
  gluteusMaximus,
  @HiveField(34)
  gluteusMedius,
  @HiveField(35)
  gluteusMinimus,

  // Piernas - Pantorrillas
  @HiveField(36)
  gastrocnemius,
  @HiveField(37)
  soleus,
  @HiveField(38)
  tibialisAnterior,

  // Core
  @HiveField(39)
  rectusAbdominis,
  @HiveField(40)
  externalObliques,
  @HiveField(41)
  internalObliques,
  @HiveField(42)
  transverseAbdominis,
  @HiveField(43)
  multifidus,
  @HiveField(44)
  quadratusLumborum,

  // Otros
  @HiveField(45)
  hipFlexors,
  @HiveField(46)
  hipAdductors,
  @HiveField(47)
  hipAbductors,
  @HiveField(48)
  rotatorCuff,
}

extension MuscleGroupExtension on MuscleGroup {
  String get displayName {
    switch (this) {
      // Pecho
      case MuscleGroup.pectoralMajor:
        return 'Pectoral Mayor';
      case MuscleGroup.pectoralMinor:
        return 'Pectoral Menor';
      case MuscleGroup.serratusAnterior:
        return 'Serrato Anterior';

      // Espalda
      case MuscleGroup.latissimusDorsi:
        return 'Dorsal Ancho';
      case MuscleGroup.rhomboids:
        return 'Romboides';
      case MuscleGroup.middleTrapezius:
        return 'Trapecio Medio';
      case MuscleGroup.lowerTrapezius:
        return 'Trapecio Inferior';
      case MuscleGroup.erectorSpinae:
        return 'Erectores Espinales';
      case MuscleGroup.teresMajor:
        return 'Redondo Mayor';
      case MuscleGroup.teresMinor:
        return 'Redondo Menor';
      case MuscleGroup.infraspinatus:
        return 'Infraespinoso';

      // Hombros
      case MuscleGroup.anteriorDeltoid:
        return 'Deltoides Anterior';
      case MuscleGroup.medialDeltoid:
        return 'Deltoides Medio';
      case MuscleGroup.posteriorDeltoid:
        return 'Deltoides Posterior';
      case MuscleGroup.upperTrapezius:
        return 'Trapecio Superior';

      // Bíceps
      case MuscleGroup.bicepsLongHead:
        return 'Bíceps Cabeza Larga';
      case MuscleGroup.bicepsShortHead:
        return 'Bíceps Cabeza Corta';
      case MuscleGroup.brachialis:
        return 'Braquial Anterior';
      case MuscleGroup.brachioradialis:
        return 'Braquiorradial';

      // Tríceps
      case MuscleGroup.tricepsLongHead:
        return 'Tríceps Cabeza Larga';
      case MuscleGroup.tricepsLateralHead:
        return 'Tríceps Cabeza Lateral';
      case MuscleGroup.tricepsMedialHead:
        return 'Tríceps Cabeza Medial';

      // Antebrazos
      case MuscleGroup.forearmFlexors:
        return 'Flexores del Antebrazo';
      case MuscleGroup.forearmExtensors:
        return 'Extensores del Antebrazo';
      case MuscleGroup.wristFlexors:
        return 'Flexores de Muñeca';
      case MuscleGroup.wristExtensors:
        return 'Extensores de Muñeca';

      // Cuádriceps
      case MuscleGroup.rectusFemoris:
        return 'Recto Femoral';
      case MuscleGroup.vastusLateralis:
        return 'Vasto Lateral';
      case MuscleGroup.vastusMedialis:
        return 'Vasto Medial';
      case MuscleGroup.vastusIntermedius:
        return 'Vasto Intermedio';

      // Isquiotibiales
      case MuscleGroup.bicepsFemoris:
        return 'Bíceps Femoral';
      case MuscleGroup.semitendinosus:
        return 'Semitendinoso';
      case MuscleGroup.semimembranosus:
        return 'Semimembranoso';

      // Glúteos
      case MuscleGroup.gluteusMaximus:
        return 'Glúteo Mayor';
      case MuscleGroup.gluteusMedius:
        return 'Glúteo Medio';
      case MuscleGroup.gluteusMinimus:
        return 'Glúteo Menor';

      // Pantorrillas
      case MuscleGroup.gastrocnemius:
        return 'Gastrocnemio';
      case MuscleGroup.soleus:
        return 'Sóleo';
      case MuscleGroup.tibialisAnterior:
        return 'Tibial Anterior';

      // Core
      case MuscleGroup.rectusAbdominis:
        return 'Recto Abdominal';
      case MuscleGroup.externalObliques:
        return 'Oblicuos Externos';
      case MuscleGroup.internalObliques:
        return 'Oblicuos Internos';
      case MuscleGroup.transverseAbdominis:
        return 'Transverso Abdominal';
      case MuscleGroup.multifidus:
        return 'Multífidos';
      case MuscleGroup.quadratusLumborum:
        return 'Cuadrado Lumbar';

      // Otros
      case MuscleGroup.hipFlexors:
        return 'Flexores de Cadera';
      case MuscleGroup.hipAdductors:
        return 'Aductores de Cadera';
      case MuscleGroup.hipAbductors:
        return 'Abductores de Cadera';
      case MuscleGroup.rotatorCuff:
        return 'Manguito Rotador';
    }
  }

  String get category {
    switch (this) {
      // Pecho
      case MuscleGroup.pectoralMajor:
      case MuscleGroup.pectoralMinor:
      case MuscleGroup.serratusAnterior:
        return 'Pecho';

      // Espalda
      case MuscleGroup.latissimusDorsi:
      case MuscleGroup.rhomboids:
      case MuscleGroup.middleTrapezius:
      case MuscleGroup.lowerTrapezius:
      case MuscleGroup.erectorSpinae:
      case MuscleGroup.teresMajor:
      case MuscleGroup.teresMinor:
      case MuscleGroup.infraspinatus:
        return 'Espalda';

      // Hombros
      case MuscleGroup.anteriorDeltoid:
      case MuscleGroup.medialDeltoid:
      case MuscleGroup.posteriorDeltoid:
      case MuscleGroup.upperTrapezius:
        return 'Hombros';

      // Bíceps
      case MuscleGroup.bicepsLongHead:
      case MuscleGroup.bicepsShortHead:
      case MuscleGroup.brachialis:
      case MuscleGroup.brachioradialis:
        return 'Bíceps';

      // Tríceps
      case MuscleGroup.tricepsLongHead:
      case MuscleGroup.tricepsLateralHead:
      case MuscleGroup.tricepsMedialHead:
        return 'Tríceps';

      // Antebrazos
      case MuscleGroup.forearmFlexors:
      case MuscleGroup.forearmExtensors:
      case MuscleGroup.wristFlexors:
      case MuscleGroup.wristExtensors:
        return 'Antebrazos';

      // Cuádriceps
      case MuscleGroup.rectusFemoris:
      case MuscleGroup.vastusLateralis:
      case MuscleGroup.vastusMedialis:
      case MuscleGroup.vastusIntermedius:
        return 'Cuádriceps';

      // Isquiotibiales
      case MuscleGroup.bicepsFemoris:
      case MuscleGroup.semitendinosus:
      case MuscleGroup.semimembranosus:
        return 'Isquiotibiales';

      // Glúteos
      case MuscleGroup.gluteusMaximus:
      case MuscleGroup.gluteusMedius:
      case MuscleGroup.gluteusMinimus:
        return 'Glúteos';

      // Pantorrillas
      case MuscleGroup.gastrocnemius:
      case MuscleGroup.soleus:
      case MuscleGroup.tibialisAnterior:
        return 'Pantorrillas';

      // Core
      case MuscleGroup.rectusAbdominis:
      case MuscleGroup.externalObliques:
      case MuscleGroup.internalObliques:
      case MuscleGroup.transverseAbdominis:
      case MuscleGroup.multifidus:
      case MuscleGroup.quadratusLumborum:
        return 'Core';

      // Otros
      case MuscleGroup.hipFlexors:
      case MuscleGroup.hipAdductors:
      case MuscleGroup.hipAbductors:
      case MuscleGroup.rotatorCuff:
        return 'Otros';
    }
  }

  static List<MuscleGroup> getByCategory(String category) {
    return MuscleGroup.values
        .where((muscle) => muscle.category == category)
        .toList();
  }

  static List<String> get allCategories => [
    'Pecho',
    'Espalda',
    'Hombros',
    'Bíceps',
    'Tríceps',
    'Antebrazos',
    'Cuádriceps',
    'Isquiotibiales',
    'Glúteos',
    'Pantorrillas',
    'Core',
    'Otros',
  ];
}
