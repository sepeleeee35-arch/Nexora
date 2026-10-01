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
  NexoraApiMusicService({required this.baseUrl, http.Client? client}) : client = client ?? http.Client();

  Uri _uri(String path, [Map<String, String>? params]) {
    final root = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return Uri.parse(root + path).replace(queryParameters: params);
  }

  Future<dynamic> _get(String path, [Map<String, String>? params]) async {
    final response = await client.get(_uri(path, params));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Music API error: ${response.statusCode}');
    }
    return jsonDecode(response.body);
  }

  String _s(dynamic v) => v == null ? '' : v.toString();

  MusicTrack _track(Map<String, dynamic> j) => MusicTrack(
    id: _s(j['id']),
    title: _s(j['title']),
    artistId: _s(j['artist_id']),
    artistName: _s(j['artist_name'] ?? j['artist']),
    albumId: _s(j['album_id']),
    albumName: _s(j['album_name'] ?? j['album']),
    artworkUrl: _s(j['artwork_url']),
    audioUrl: _s(j['audio_url']),
    duration: Duration(seconds: j['duration_seconds'] is num ? (j['duration_seconds'] as num).toInt() : 0),
  );

  @override
  Future<List<MusicTrack>> searchTracks(String query) async {
    final data = await _get('/api/search', {'q': query}) as Map<String, dynamic>;
    return ((data['tracks'] as List?) ?? []).whereType<Map<String, dynamic>>().map(_track).toList();
  }

  @override
  Future<List<MusicArtist>> searchArtists(String query) async {
    final data = await _get('/api/search', {'q': query}) as Map<String, dynamic>;
    return ((data['artists'] as List?) ?? []).whereType<Map<String, dynamic>>().map((j) => MusicArtist(
      id: _s(j['id']), name: _s(j['name']), artworkUrl: _s(j['artwork_url']),
    )).toList();
  }

  @override
  Future<List<MusicAlbum>> searchAlbums(String query) async {
    final data = await _get('/api/search', {'q': query}) as Map<String, dynamic>;
    return ((data['albums'] as List?) ?? []).whereType<Map<String, dynamic>>().map((j) => MusicAlbum(
      id: _s(j['id']), title: _s(j['title']), artistId: _s(j['artist_id']),
      artistName: _s(j['artist_name']), artworkUrl: _s(j['artwork_url']),
      releaseDate: j['release_date'] == null ? null : DateTime.tryParse(_s(j['release_date'])),
    )).toList();
  }

  @override
  Future<List<MusicPlaylist>> getPlaylists() async => [];
}

class JamendoMusicService implements MusicService {
  final String clientId;
  final http.Client client;

  JamendoMusicService({String? clientId, http.Client? client})
      : clientId = (clientId ?? const String.fromEnvironment('JAMENDO_CLIENT_ID', defaultValue: '709fa152')).trim(),
        client = client ?? http.Client();

  static const String _base = 'https://api.jamendo.com/v3.0';

  Uri _uri(String path, Map<String, String> params) => Uri.parse('$_base/$path').replace(
    queryParameters: {'client_id': clientId, 'format': 'json', ...params},
  );

  Future<Map<String, dynamic>> _get(String path, Map<String, String> params) async {
    if (clientId.isEmpty) throw Exception('Jamendo client ID belum dikonfigurasi.');
    final response = await client.get(_uri(path, params));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Jamendo HTTP ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) throw Exception('Respons Jamendo tidak valid.');
    final headers = decoded['headers'];
    if (headers is Map && headers['status'] == 'error') {
      throw Exception(_s(headers['error_message']) == '' ? 'Jamendo API error' : _s(headers['error_message']));
    }
    return decoded;
  }

  String _s(dynamic v) => v == null ? '' : v.toString();
  int _seconds(dynamic v) => v is num ? v.toInt() : int.tryParse(_s(v)) ?? 0;

  MusicTrack _track(Map<String, dynamic> j) => MusicTrack(
    id: _s(j['id']),
    title: _s(j['name']).isEmpty ? 'Untitled' : _s(j['name']),
    artistId: _s(j['artist_id']),
    artistName: _s(j['artist_name']).isEmpty ? 'Unknown artist' : _s(j['artist_name']),
    albumId: _s(j['album_id']),
    albumName: _s(j['album_name']),
    artworkUrl: _s(j['album_image']).isNotEmpty ? _s(j['album_image']) : _s(j['image']),
    audioUrl: _s(j['audio']),
    duration: Duration(seconds: _seconds(j['duration'])),
  );

  List<MusicTrack> _tracks(Map<String, dynamic> data) {
    final raw = data['results'];
    if (raw is! List) return [];
    return raw.whereType<Map<String, dynamic>>().map(_track).where((t) => t.audioUrl.isNotEmpty).toList();
  }

  Future<List<MusicTrack>> _query({String? search, String? tag}) async {
    final p = <String, String>{
      'limit': '50',
      'audioformat': 'mp32',
      'type': 'single albumtrack',
    };
    if (search != null && search.trim().isNotEmpty) p['search'] = search.trim();
    if (tag != null && tag.trim().isNotEmpty) p['tags'] = tag.trim();
    return _tracks(await _get('tracks', p));
  }

  Future<List<MusicTrack>> trending() => _query();
  Future<List<MusicTrack>> genre(String tag) => _query(tag: tag);

  @override
  Future<List<MusicTrack>> searchTracks(String query) => query.trim().isEmpty ? trending() : _query(search: query);

  @override
  Future<List<MusicArtist>> searchArtists(String query) async {
    if (query.trim().isEmpty) return [];
    final data = await _get('artists', {'search': query.trim(), 'limit': '30'});
    final raw = data['results'];
    if (raw is! List) return [];
    return raw.whereType<Map<String, dynamic>>().map((j) => MusicArtist(
      id: _s(j['id']), name: _s(j['name']), artworkUrl: _s(j['image']),
    )).toList();
  }

  @override
  Future<List<MusicAlbum>> searchAlbums(String query) async {
    if (query.trim().isEmpty) return [];
    final data = await _get('albums', {'search': query.trim(), 'limit': '30'});
    final raw = data['results'];
    if (raw is! List) return [];
    return raw.whereType<Map<String, dynamic>>().map((j) => MusicAlbum(
      id: _s(j['id']), title: _s(j['name']), artistId: _s(j['artist_id']),
      artistName: _s(j['artist_name']), artworkUrl: _s(j['image']),
      releaseDate: DateTime.tryParse(_s(j['releasedate'])),
    )).toList();
  }

  @override
  Future<List<MusicPlaylist>> getPlaylists() async => [];
}

class EmptyMusicService implements MusicService {
  const EmptyMusicService();
  @override Future<List<MusicTrack>> searchTracks(String query) async => [];
  @override Future<List<MusicArtist>> searchArtists(String query) async => [];
  @override Future<List<MusicAlbum>> searchAlbums(String query) async => [];
  @override Future<List<MusicPlaylist>> getPlaylists() async => [];
}
