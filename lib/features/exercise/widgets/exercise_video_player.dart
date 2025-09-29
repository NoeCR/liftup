import 'package:flutter/material.dart';
import 'video_player_adapter.dart';
import 'video_adapters/youtube_player_adapter.dart' as yt;
import 'video_adapters/network_player_adapter.dart' as net;
import 'video_adapters/file_player_adapter.dart' as file;

class ExerciseVideoPlayer extends StatefulWidget {
  final String url;
  const ExerciseVideoPlayer({super.key, required this.url});

  @override
  State<ExerciseVideoPlayer> createState() => _ExerciseVideoPlayerState();
}

class _ExerciseVideoPlayerState extends State<ExerciseVideoPlayer> {
  VideoPlayerAdapter? _adapter;
  bool _loading = false;
  bool _started = false; // carga diferida
  String? _error;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _setup() async {
    try {
      setState(() => _loading = true);
      _adapter = _resolveConcrete(widget.url);
      await _adapter!.initialize();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() { _loading = false; _started = true; });
    }
  }

  @override
  void dispose() {
    _adapter?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return const SizedBox(
        height: 200,
        child: Center(child: Icon(Icons.error_outline)),
      );
    }

    if (!_started) {
      // Placeholder con botón de reproducir para iniciar la carga
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Theme.of(context).colorScheme.surfaceVariant),
            Center(
              child: ElevatedButton.icon(
                onPressed: _setup,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Reproducir'),
              ),
            ),
          ],
        ),
      );
    }

    if (_adapter == null || !_adapter!.isInitialized) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return _adapter!.buildView(context);
  }
}

VideoPlayerAdapter _resolveConcrete(String url) {
  final lower = url.toLowerCase();
  if (lower.contains('youtube.com') || lower.contains('youtu.be')) {
    return yt.YouTubePlayerAdapter(url);
  }
  if (url.startsWith('/') || url.startsWith('file:')) {
    return file.FileVideoPlayerAdapter(url);
  }
  return net.NetworkVideoPlayerAdapter(url);
}
