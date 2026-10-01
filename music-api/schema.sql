CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS music_artists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  bio TEXT NOT NULL DEFAULT '',
  artwork_url TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS music_albums (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  artist_id UUID NOT NULL REFERENCES music_artists(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  artwork_url TEXT NOT NULL DEFAULT '',
  release_date DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS music_tracks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  album_id UUID REFERENCES music_albums(id) ON DELETE SET NULL,
  artist_id UUID NOT NULL REFERENCES music_artists(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  track_number INTEGER NOT NULL DEFAULT 1,
  duration_seconds INTEGER NOT NULL DEFAULT 0,
  audio_url TEXT NOT NULL,
  artwork_url TEXT NOT NULL DEFAULT '',
  provider TEXT NOT NULL DEFAULT 'nexora',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS music_playlists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  artwork_url TEXT NOT NULL DEFAULT '',
  owner_id TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS music_playlist_tracks (
  playlist_id UUID NOT NULL REFERENCES music_playlists(id) ON DELETE CASCADE,
  track_id UUID NOT NULL REFERENCES music_tracks(id) ON DELETE CASCADE,
  position INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (playlist_id, track_id)
);

CREATE INDEX IF NOT EXISTS music_tracks_title_idx ON music_tracks USING gin (to_tsvector('simple', title));
CREATE INDEX IF NOT EXISTS music_artists_name_idx ON music_artists USING gin (to_tsvector('simple', name));
CREATE INDEX IF NOT EXISTS music_albums_title_idx ON music_albums USING gin (to_tsvector('simple', title));
CREATE INDEX IF NOT EXISTS music_playlists_name_idx ON music_playlists USING gin (to_tsvector('simple', name));