import 'package:flutter_riverpod/flutter_riverpod.dart';

final restSoundEnabledProvider = StateProvider<bool>((ref) => true);

final restVibrationEnabledProvider = StateProvider<bool>((ref) => true);

enum RestSoundType { notification, alarm }

final restSoundTypeProvider = StateProvider<RestSoundType>((ref) => RestSoundType.notification);
