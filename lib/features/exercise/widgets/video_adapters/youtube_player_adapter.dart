import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../video_player_adapter.dart';

class YouTubePlayerAdapter implements VideoPlayerAdapter {
  final String url;
  late final YoutubePlayerController _controller;
  bool _initialized = false;

  YouTubePlayerAdapter(this.url);

  @override
  Future<void> initialize() async {
    final videoId = YoutubePlayerController.convertUrlToId(url) ?? '';
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
      ),
    );
    // Preparar sin reproducir automáticamente
    _controller.cueVideoById(videoId: videoId);
    _initialized = true;
  }

  @override
  Widget buildView(BuildContext context) {
    return YoutubePlayerScaffold(
      controller: _controller,
      aspectRatio: 16 / 9,
      builder: (context, player) => player,
    );
  }

  @override
  void dispose() {
    // Evitar emitir eventos tras dispose
    try {
      _controller.pauseVideo();
    } catch (_) {}
    _controller.close();
  }

  @override
  bool get isInitialized => _initialized;

  @override
  void pause() => _controller.pauseVideo();

  @override
  void play() => _controller.playVideo();

  @override
  Future<void> seek(Duration position) async {
    _controller.seekTo(seconds: position.inSeconds.toDouble());
  }
}
