import 'package:hive/hive.dart';

part 'progression_type_enum.g.dart';

@HiveType(typeId: 20)
enum ProgressionType {
  @HiveField(0)
  none('Sin progresión', 'Entrenamiento libre sin progresión automática'),
  
  @HiveField(1)
  linear('Progresión Lineal', 'Incremento constante de peso cada sesión/semana'),
  
  @HiveField(2)
  undulating('Progresión Ondulante', 'Variación de intensidad y volumen por sesión'),
  
  @HiveField(3)
  stepped('Progresión Escalonada', 'Acumulación de carga con deload periódico'),
  
  @HiveField(4)
  double('Progresión Doble', 'Aumento de repeticiones primero, luego peso'),
  
  @HiveField(5)
  autoregulated('Progresión Autoregulada', 'Ajuste basado en RPE/RIR'),
  
  @HiveField(6)
  doubleFactor('Progresión Doble Factor', 'Balance entre fitness y fatiga'),
  
  @HiveField(7)
  overload('Sobrecarga Progresiva', 'Incremento gradual de volumen o intensidad'),
  
  @HiveField(8)
  wave('Progresión por Oleadas', 'Ciclos de 3 semanas con diferentes énfasis'),
  
  @HiveField(9)
  static('Progresión Estática', 'Mantiene carga constante durante el bloque'),
  
  @HiveField(10)
  reverse('Progresión Inversa', 'Inicia con alta intensidad, reduce progresivamente');

  const ProgressionType(this.displayName, this.description);

  final String displayName;
  final String description;

  static ProgressionType fromString(String value) {
    return ProgressionType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => ProgressionType.none,
    );
  }
}

@HiveType(typeId: 21)
enum ProgressionUnit {
  @HiveField(0)
  session('Por sesión'),
  
  @HiveField(1)
  week('Por semana'),
  
  @HiveField(2)
  cycle('Por ciclo');

  const ProgressionUnit(this.displayName);

  final String displayName;
}

@HiveType(typeId: 22)
enum ProgressionTarget {
  @HiveField(0)
  weight('Peso'),
  
  @HiveField(1)
  reps('Repeticiones'),
  
  @HiveField(2)
  sets('Series'),
  
  @HiveField(3)
  volume('Volumen'),
  
  @HiveField(4)
  intensity('Intensidad');

  const ProgressionTarget(this.displayName);

  final String displayName;
}
