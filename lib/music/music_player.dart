import 'package:audioplayers/audioplayers.dart';
import 'music_models.dart';

class NexoraMusicPlayer {
  NexoraMusicPlayer._();

  static final NexoraMusicPlayer instance = NexoraMusicPlayer._();

  final AudioPlayer _audio = AudioPlayer();

  MusicTrack? currentTrack;
  List<MusicTrack> queue = [];
  int queueIndex = -1;
  bool shuffle = false;
  bool repeat = false;

  Stream<Duration> get positionStream => _audio.onPositionChanged;
  Stream<Duration> get durationStream => _audio.onDurationChanged;
  Stream<PlayerState> get playerStateStream => _audio.onPlayerStateChanged;

  Future<void> play(MusicTrack track) async {
    currentTrack = track;
    await _audio.play(UrlSource(track.audioUrl));
  }

  Future<void> pause() => _audio.pause();

  Future<void> resume() => _audio.resume();

  Future<void> seek(Duration position) => _audio.seek(position);

  Future<void> stop() => _audio.stop();

  Future<void> setVolume(double value) => _audio.setVolume(value.clamp(0.0, 1.0));

  Future<void> next() async {
    if (queue.isEmpty) return;

    if (shuffle) {
      queueIndex = (queueIndex + 1) % queue.length;
    } else {
      queueIndex++;
      if (queueIndex >= queue.length) {
        if (!repeat) return;
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
    queue = List<MusicTrack>.from(tracks);
    if (queue.isEmpty) {
      queueIndex = -1;
      currentTrack = null;
      return;
    }

    queueIndex = startIndex.clamp(0, queue.length - 1);
    await play(queue[queueIndex]);
  }

  Future<void> dispose() => _audio.dispose();
}
