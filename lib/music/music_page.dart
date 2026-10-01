import 'package:flutter/material.dart';
import 'music_models.dart';
import 'music_player.dart';
import 'music_service.dart';

class NexoraMusicPage extends StatefulWidget {
  final MusicService service;

  const NexoraMusicPage({
    super.key,
    this.service = const EmptyMusicService(),
  });

  @override
  State<NexoraMusicPage> createState() => _NexoraMusicPageState();
}

class _NexoraMusicPageState extends State<NexoraMusicPage> {
  final _searchController = TextEditingController();
  final _player = NexoraMusicPlayer.instance;

  List<MusicTrack> _tracks = [];
  bool _loading = false;

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _loading = true);
    final tracks = await widget.service.searchTracks(query);
    if (!mounted) return;

    setState(() {
      _tracks = tracks;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nexora Music')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Cari lagu, artis, atau album...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: _search,
                  icon: const Icon(Icons.arrow_forward),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _tracks.isEmpty
                    ? const Center(
                        child: Text('Belum ada hasil musik.'),
                      )
                    : ListView.builder(
                        itemCount: _tracks.length,
                        itemBuilder: (context, index) {
                          final track = _tracks[index];
                          return ListTile(
                            leading: const Icon(Icons.music_note),
                            title: Text(track.title),
                            subtitle: Text(track.artistName),
                            onTap: () => _player.play(track),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
