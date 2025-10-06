import 'package:hive/hive.dart';

part 'week_day_enum.g.dart';

@HiveType(typeId: 10)
enum WeekDay {
  @HiveField(0)
  monday,
  @HiveField(1)
  tuesday,
  @HiveField(2)
  wednesday,
  @HiveField(3)
  thursday,
  @HiveField(4)
  friday,
  @HiveField(5)
  saturday,
  @HiveField(6)
  sunday,
}

extension WeekDayExtension on WeekDay {
  String get displayName {
    switch (this) {
      case WeekDay.monday:
        return 'Lunes';
      case WeekDay.tuesday:
        return 'Martes';
      case WeekDay.wednesday:
        return 'Miércoles';
      case WeekDay.thursday:
        return 'Jueves';
      case WeekDay.friday:
        return 'Viernes';
      case WeekDay.saturday:
        return 'Sábado';
      case WeekDay.sunday:
        return 'Domingo';
    }
  }

  String get shortName {
    switch (this) {
      case WeekDay.monday:
        return 'Lun';
      case WeekDay.tuesday:
        return 'Mar';
      case WeekDay.wednesday:
        return 'Mié';
      case WeekDay.thursday:
        return 'Jue';
      case WeekDay.friday:
        return 'Vie';
      case WeekDay.saturday:
        return 'Sáb';
      case WeekDay.sunday:
        return 'Dom';
    }
  }

  static WeekDay fromString(String day) {
    switch (day.toLowerCase()) {
      case 'lunes':
        return WeekDay.monday;
      case 'martes':
        return WeekDay.tuesday;
      case 'miércoles':
        return WeekDay.wednesday;
      case 'jueves':
        return WeekDay.thursday;
      case 'viernes':
        return WeekDay.friday;
      case 'sábado':
        return WeekDay.saturday;
      case 'domingo':
        return WeekDay.sunday;
      default:
        return WeekDay.monday;
    }
  }

  static WeekDay fromInt(int weekday) {
    switch (weekday) {
      case 1:
        return WeekDay.monday;
      case 2:
        return WeekDay.tuesday;
      case 3:
        return WeekDay.wednesday;
      case 4:
        return WeekDay.thursday;
      case 5:
        return WeekDay.friday;
      case 6:
        return WeekDay.saturday;
      case 7:
        return WeekDay.sunday;
      default:
        return WeekDay.monday;
    }
  }

  static List<String> get allDisplayNames => [
    WeekDay.monday.displayName,
    WeekDay.tuesday.displayName,
    WeekDay.wednesday.displayName,
    WeekDay.thursday.displayName,
    WeekDay.friday.displayName,
    WeekDay.saturday.displayName,
    WeekDay.sunday.displayName,
  ];
}
