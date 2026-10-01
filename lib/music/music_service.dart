import 'music_models.dart';

/// Provider-agnostic music catalog interface.
///
/// Implementations can later connect to Nexora's backend or an authorized
/// music provider without changing the Flutter UI/player layer.
abstract class MusicService {
  Future<List<MusicTrack>> searchTracks(String query);
  Future<List<MusicArtist>> searchArtists(String query);
  Future<List<MusicAlbum>> searchAlbums(String query);
  Future<List<MusicPlaylist>> getPlaylists();
}

/// Empty local implementation used while the backend is being built.
class EmptyMusicService implements MusicService {
  @override
  Future<List<MusicTrack>> searchTracks(String query) async => [];

  @override
  Future<List<MusicArtist>> searchArtists(String query) async => [];

  @override
  Future<List<MusicAlbum>> searchAlbums(String query) async => [];

  @override
  Future<List<MusicPlaylist>> getPlaylists() async => [];
}
