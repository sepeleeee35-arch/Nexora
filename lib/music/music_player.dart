import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'music_models.dart';

class NexoraMusicPlayer {
  NexoraMusicPlayer._() {
    _completionSub = _audio.onPlayerComplete.listen((_) {
      if (repeat) {
        final track = currentTrack;
        if (track != null) {
          play(track);
        }
      } else {
        next();
      }
    });
  }

  static final NexoraMusicPlayer instance = NexoraMusicPlayer._();

  final AudioPlayer _audio = AudioPlayer();
  StreamSubscription<void>? _completionSub;

  MusicTrack? currentTrack;
  List<MusicTrack> queue = [];
  int queueIndex = -1;
  bool shuffle = false;
  bool repeat = false;
  bool _disposed = false;

  Stream<Duration> get positionStream => _audio.onPositionChanged;
  Stream<Duration> get durationStream => _audio.onDurationChanged;
  Stream<PlayerState> get playerStateStream => _audio.onPlayerStateChanged;

  Future<void> play(MusicTrack track) async {
    if (_disposed) throw StateError('Music player sudah ditutup.');
    currentTrack = track;
    final index = queue.indexWhere((item) => item.id == track.id);
    if (index >= 0) queueIndex = index;
    if (track.audioUrl.isEmpty) {
      throw Exception('Track tidak memiliki URL audio.');
    }
    try {
      await _audio.stop();
      await _audio.play(UrlSource(track.audioUrl), volume: 1.0);
    } catch (e) {
      currentTrack = null;
      throw Exception('Audio gagal diputar: $e');
    }
  }

  Future<void> pause() => _audio.pause();
  Future<void> resume() => _audio.resume();
  Future<void> seek(Duration position) => _audio.seek(position);
  Future<void> stop() => _audio.stop();
  Future<void> setVolume(double value) => _audio.setVolume(value.clamp(0.0, 1.0).toDouble());

  Future<void> next() async {
    if (queue.isEmpty) return;
    if (shuffle && queue.length > 1) {
      final current = queueIndex;
      var nextIndex = current;
      while (nextIndex == current) {
        nextIndex = Random().nextInt(queue.length);
      }
      queueIndex = nextIndex;
    } else {
      queueIndex++;
      if (queueIndex >= queue.length) {
        if (!repeat) {
          queueIndex = queue.length - 1;
          return;
        }
        queueIndex = 0;
      }
    }
    await play(queue[queueIndex]);
  }

  Future<void> previous() async {
    if (queue.isEmpty) return;
    queueIndex--;
    if (queueIndex < 0) queueIndex = queue.length - 1;
    await play(queue[queueIndex]);
  }

  Future<void> setQueue(List<MusicTrack> tracks, {int startIndex = 0}) async {
    if (_disposed) throw StateError('Music player sudah ditutup.');
    queue = List<MusicTrack>.from(tracks.where((t) => t.audioUrl.trim().isNotEmpty));
    if (queue.isEmpty) {
      queueIndex = -1;
      currentTrack = null;
      await stop();
      return;
    }
    queueIndex = startIndex.clamp(0, queue.length - 1);
    await play(queue[queueIndex]);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _completionSub?.cancel();
    await _audio.dispose();
  }
}
