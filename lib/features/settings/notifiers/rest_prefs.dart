import 'package:flutter_riverpod/flutter_riverpod.dart';

final restSoundEnabledProvider = StateProvider<bool>((ref) => true);

final restVibrationEnabledProvider = StateProvider<bool>((ref) => true);

enum RestSoundType { notification, alarm }

final restSoundTypeProvider = StateProvider<RestSoundType>((ref) => RestSoundType.notification);

// Máximo de series permitido por configuración. Valor por defecto: 30
final maxSetsPerExerciseProvider = StateProvider<int>((ref) => 30);
