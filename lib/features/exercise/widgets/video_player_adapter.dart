import 'package:flutter/widgets.dart';

abstract class VideoPlayerAdapter {
  Future<void> initialize();
  Widget buildView(BuildContext context);
  void play();
  void pause();
  Future<void> seek(Duration position);
  bool get isInitialized;
  void dispose();
}
