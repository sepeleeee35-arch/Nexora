import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'music_models.dart';
import 'music_player.dart';
import 'music_service.dart';

class NexoraMusicPage extends StatefulWidget {
  final MusicService service;
  const NexoraMusicPage({super.key, required this.service});
  @override State<NexoraMusicPage> createState() => _NexoraMusicPageState();
}

class _NexoraMusicPageState extends State<NexoraMusicPage> {
  final _search = TextEditingController();
  final _player = NexoraMusicPlayer.instance;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<PlayerState>? _stateSub;
  List<MusicTrack> _tracks = [];
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _loading = true;
  bool _playing = false;
  String _error = '';
  String _activeGenre = 'trending';

  static const _genres = <String, String>{
    'Trending': 'trending',
    'Electronic': 'electronic',
    'Hip-Hop': 'hiphop',
    'House': 'house',
    'Rock': 'rock',
    'Punk': 'punk',
    'Metal': 'metal',
    'Chillout': 'chillout',
    'Ambient': 'ambient',
    'Dance': 'dance',
  };

  MusicTrack? get _current => _player.currentTrack;

  @override
  void initState() {
    super.initState();
    _positionSub = _player.positionStream.listen((v) { if (mounted) setState(() => _position = v); });
    _durationSub = _player.durationStream.listen((v) { if (mounted) setState(() => _duration = v); });
    _stateSub = _player.playerStateStream.listen((v) { if (mounted) setState(() => _playing = v == PlayerState.playing); });
    _loadTrending();
  }

  Future<void> _loadTrending() async {
    await _load(() => widget.service is JamendoMusicService
        ? (widget.service as JamendoMusicService).trending()
        : widget.service.searchTracks(''), 'trending');
  }

  Future<void> _loadGenre(String tag) async {
    await _load(() => widget.service is JamendoMusicService
        ? (widget.service as JamendoMusicService).genre(tag)
        : widget.service.searchTracks(tag), tag);
  }

  Future<void> _load(Future<List<MusicTrack>> Function() action, String active) async {
    setState(() { _loading = true; _error = ''; _activeGenre = active; });
    try {
      final result = await action();
      if (!mounted) return;
      setState(() { _tracks = result; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _tracks = []; _loading = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  Future<void> _searchNow() async {
    final q = _search.text.trim();
    if (q.isEmpty) return _loadTrending();
    await _load(() => widget.service.searchTracks(q), '');
  }

  Future<void> _play(int index) async {
    if (index < 0 || index >= _tracks.length) return;
    try {
      await _player.setQueue(_tracks, startIndex: index);
    } catch (e) {
      if (mounted) setState(() => _error = 'Audio gagal diputar: ${e.toString()}');
    }
  }

  Future<void> _toggle() async {
    try {
      if (_current == null) {
        if (_tracks.isNotEmpty) await _play(0);
      } else if (_playing) {
        await _player.pause();
      } else {
        await _player.resume();
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Player error: ${e.toString()}');
    }
  }

  String _fmt(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _current;
    final maxMs = _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1.0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      children: [
        Row(children: [
          const Expanded(child: Text('Nexora Music', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900))),
          Chip(avatar: const Icon(Icons.music_note_rounded, size: 17), label: Text(_tracks.length.toString())),
        ]),
        const Text('Real music • legal catalog • DJ • electronic • punk • rock'),
        const SizedBox(height: 14),
        TextField(
          controller: _search,
          onSubmitted: (_) => _searchNow(),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(onPressed: _searchNow, icon: const Icon(Icons.search_rounded)),
            hintText: 'Cari lagu atau artis...',
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _genres.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(entry.key),
                selected: _activeGenre == entry.value,
                onSelected: (_) => entry.value == 'trending' ? _loadTrending() : _loadGenre(entry.value),
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 14),
        if (_error.isNotEmpty)
          Card(child: ListTile(
            leading: const Icon(Icons.error_outline_rounded),
            title: const Text('Music API bermasalah'),
            subtitle: Text(_error),
            trailing: IconButton(onPressed: _loadTrending, icon: const Icon(Icons.refresh_rounded)),
          )),
        if (current != null)
          _NowPlayingCard(
            track: current,
            playing: _playing,
            position: _position,
            duration: _duration,
            format: _fmt,
            onPrevious: () => _player.previous(),
            onNext: () => _player.next(),
            onPlayPause: _toggle,
            onShuffle: () { setState(() => _player.shuffle = !_player.shuffle); },
            onRepeat: () { setState(() => _player.repeat = !_player.repeat); },
            shuffle: _player.shuffle,
            repeat: _player.repeat,
            onSeek: (v) => _player.seek(Duration(milliseconds: v.toInt())),
          ),
        if (_loading)
          const Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator()))
        else if (_tracks.isEmpty)
          const Card(child: ListTile(
            leading: Icon(Icons.music_off_rounded),
            title: Text('Tidak ada lagu ditemukan'),
            subtitle: Text('Coba kata pencarian atau genre lain.'),
          ))
        else
          for (var i = 0; i < _tracks.length; i++)
            _TrackTile(
              track: _tracks[i],
              selected: current?.id == _tracks[i].id,
              playing: current?.id == _tracks[i].id && _playing,
              onTap: () => _play(i),
            ),
        const SizedBox(height: 10),
        const Card(child: ListTile(
          leading: Icon(Icons.verified_rounded),
          title: Text('Sumber resmi'),
          subtitle: Text('Audio dan katalog diambil melalui Jamendo API. Hak penggunaan mengikuti lisensi masing-masing track.'),
        )),
      ],
    );
  }
}

class _NowPlayingCard extends StatelessWidget {
  final MusicTrack track;
  final bool playing;
  final Duration position;
  final Duration duration;
  final String Function(Duration) format;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final ValueChanged<double> onSeek;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;
  final bool shuffle;
  final bool repeat;

  const _NowPlayingCard({required this.track, required this.playing, required this.position, required this.duration, required this.format, required this.onPrevious, required this.onPlayPause, required this.onNext, required this.onSeek, required this.onShuffle, required this.onRepeat, required this.shuffle, required this.repeat});

  @override
  Widget build(BuildContext context) {
    final maxMs = duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0;
    final value = position.inMilliseconds.clamp(0, maxMs.toInt()).toDouble();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          if (track.artworkUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.network(track.artworkUrl, width: 190, height: 190, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const _ArtFallback()),
            )
          else const _ArtFallback(),
          const SizedBox(height: 14),
          Text(track.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(track.artistName),
          if (track.albumName.isNotEmpty) Text(track.albumName, style: const TextStyle(color: Colors.white54)),
          Slider(value: value, min: 0, max: maxMs, onChanged: duration.inMilliseconds > 0 ? onSeek : null),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(format(position)), Text(format(duration))]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(onPressed: onPrevious, icon: const Icon(Icons.skip_previous_rounded, size: 32)),
            FilledButton(onPressed: onPlayPause, style: FilledButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(18)), child: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 30)),
            IconButton(onPressed: onNext, icon: const Icon(Icons.skip_next_rounded, size: 32)),
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(onPressed: onShuffle, color: shuffle ? Theme.of(context).colorScheme.primary : null, tooltip: 'Shuffle', icon: const Icon(Icons.shuffle_rounded)),
            IconButton(onPressed: onRepeat, color: repeat ? Theme.of(context).colorScheme.primary : null, tooltip: 'Repeat', icon: const Icon(Icons.repeat_rounded)),
          ]),
        ]),
      ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  final MusicTrack track;
  final bool selected;
  final bool playing;
  final VoidCallback onTap;
  const _TrackTile({required this.track, required this.selected, required this.playing, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: track.artworkUrl.isEmpty
          ? const CircleAvatar(child: Icon(Icons.music_note_rounded))
          : ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(track.artworkUrl, width: 52, height: 52, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const CircleAvatar(child: Icon(Icons.music_note_rounded)))),
      title: Text(track.title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(track.albumName.isEmpty ? track.artistName : '${track.artistName} • ${track.albumName}', maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Icon(playing ? Icons.pause_circle_filled_rounded : selected ? Icons.music_note_rounded : Icons.play_circle_outline_rounded),
      onTap: onTap,
    ),
  );
}

class _ArtFallback extends StatelessWidget {
  const _ArtFallback();
  @override
  Widget build(BuildContext context) => Container(
    width: 190, height: 190,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF172554)])),
    child: const Icon(Icons.album_rounded, size: 70),
  );
}
