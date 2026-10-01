class MusicTrack {
  final String id;
  final String title;
  final String artistId;
  final String artistName;
  final String albumId;
  final String albumName;
  final String artworkUrl;
  final String audioUrl;
  final Duration duration;

  const MusicTrack({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    required this.albumId,
    required this.albumName,
    required this.artworkUrl,
    required this.audioUrl,
    required this.duration,
  });
}

class MusicArtist {
  final String id;
  final String name;
  final String artworkUrl;

  const MusicArtist({
    required this.id,
    required this.name,
    required this.artworkUrl,
  });
}

class MusicAlbum {
  final String id;
  final String title;
  final String artistId;
  final String artistName;
  final String artworkUrl;
  final DateTime? releaseDate;

  const MusicAlbum({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    required this.artworkUrl,
    this.releaseDate,
  });
}

class MusicPlaylist {
  final String id;
  final String name;
  final String artworkUrl;
  final List<MusicTrack> tracks;

  const MusicPlaylist({
    required this.id,
    required this.name,
    required this.artworkUrl,
    this.tracks = const [],
  });
}
