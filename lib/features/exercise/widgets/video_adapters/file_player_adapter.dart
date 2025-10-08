import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../video_player_adapter.dart';

class FileVideoPlayerAdapter implements VideoPlayerAdapter {
  final String path;
  late final VideoPlayerController _videoController;

  FileVideoPlayerAdapter(this.path);

  @override
  Future<void> initialize() async {
    _videoController = VideoPlayerController.file(File(path.replaceFirst('file://', '')));
    await _videoController.initialize();
    // No reproducir automáticamente
    _videoController.pause();
  }

  @override
  Widget buildView(BuildContext context) {
    if (!_videoController.value.isInitialized) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: _videoController.value.aspectRatio == 0 ? 16 / 9 : _videoController.value.aspectRatio,
          child: VideoPlayer(_videoController),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_videoController.value.isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                _videoController.value.isPlaying ? _videoController.pause() : _videoController.play();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
  }

  @override
  bool get isInitialized => _videoController.value.isInitialized;

  @override
  void pause() => _videoController.pause();

  @override
  void play() => _videoController.play();

  @override
  Future<void> seek(Duration position) async {
    await _videoController.seekTo(position);
  }
}
