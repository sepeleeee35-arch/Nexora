import 'dart:convert';
import 'package:http/http.dart' as http;
import 'music_models.dart';

abstract class MusicService {
  Future<List<MusicTrack>> searchTracks(String query);
  Future<List<MusicArtist>> searchArtists(String query);
  Future<List<MusicAlbum>> searchAlbums(String query);
  Future<List<MusicPlaylist>> getPlaylists();
}

class NexoraApiMusicService implements MusicService {
  final String baseUrl;
  final http.Client client;

  NexoraApiMusicService({required this.baseUrl, http.Client? client})
      : client = client ?? http.Client();

  Uri _uri(String path, [Map<String, String>? params]) {
    final root = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return Uri.parse(root + path).replace(queryParameters: params);
  }

  Future<dynamic> _get(String path, [Map<String, String>? params]) async {
    final response = await client.get(_uri(path, params));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Music API error: ' + response.statusCode.toString());
    }
    return jsonDecode(response.body);
  }

  String _s(dynamic value) => value == null ? '' : value.toString();

  MusicTrack _track(Map<String, dynamic> json) {
    return MusicTrack(
      id: _s(json['id']),
      title: _s(json['title']),
      artistId: _s(json['artist_id']),
      artistName: _s(json['artist_name'] ?? json['artist']),
      albumId: _s(json['album_id']),
      albumName: _s(json['album_name'] ?? json['album']),
      artworkUrl: _s(json['artwork_url']),
      audioUrl: _s(json['audio_url']),
      duration: Duration(seconds: (json['duration_seconds'] as num?)?.toInt() ?? 0),
    );
  }

  @override
  Future<List<MusicTrack>> searchTracks(String query) async {
    final data = await _get('/api/search', {'q': query}) as Map<String, dynamic>;
    return ((data['tracks'] as List?) ?? [])
        .whereType<Map<String, dynamic>>()
        .map(_track)
        .toList();
  }

  @override
  Future<List<MusicArtist>> searchArtists(String query) async {
    final data = await _get('/api/search', {'q': query}) as Map<String, dynamic>;
    return ((data['artists'] as List?) ?? []).whereType<Map<String, dynamic>>().map((j) {
      return MusicArtist(id: _s(j['id']), name: _s(j['name']), artworkUrl: _s(j['artwork_url']));
    }).toList();
  }

  @override
  Future<List<MusicAlbum>> searchAlbums(String query) async {
    final data = await _get('/api/search', {'q': query}) as Map<String, dynamic>;
    return ((data['albums'] as List?) ?? []).whereType<Map<String, dynamic>>().map((j) {
      return MusicAlbum(
        id: _s(j['id']),
        title: _s(j['title']),
        artistId: _s(j['artist_id']),
        artistName: _s(j['artist_name']),
        artworkUrl: _s(j['artwork_url']),
        releaseDate: j['release_date'] == null ? null : DateTime.tryParse(_s(j['release_date'])),
      );
    }).toList();
  }

  @override
  Future<List<MusicPlaylist>> getPlaylists() async {
    final data = await _get('/api/playlists') as List;
    return data.whereType<Map<String, dynamic>>().map((j) {
      return MusicPlaylist(id: _s(j['id']), name: _s(j['name']), artworkUrl: _s(j['artwork_url']));
    }).toList();
  }
}

class EmptyMusicService implements MusicService {
  const EmptyMusicService();
  @override Future<List<MusicTrack>> searchTracks(String query) async => [];
  @override Future<List<MusicArtist>> searchArtists(String query) async => [];
  @override Future<List<MusicAlbum>> searchAlbums(String query) async => [];
  @override Future<List<MusicPlaylist>> getPlaylists() async => [];
}
