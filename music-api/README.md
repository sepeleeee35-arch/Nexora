# Nexora Music API

Backend foundation for the Nexora music catalog.

## Includes
- Tracks
- Artists
- Albums
- Playlists
- Playlist tracks
- Search across all four catalog types

## Setup
1. Create a PostgreSQL database.
2. Run `schema.sql`.
3. Copy `.env.example` to `.env`.
4. Set `DATABASE_URL`.
5. Run `npm install` then `npm run dev`.

## Endpoints
GET /api/search?q=...
GET /api/tracks
GET /api/tracks/:id
GET /api/artists
GET /api/artists/:id
GET /api/albums
GET /api/albums/:id
GET /api/playlists
GET /api/playlists/:id

The database stores references to audio streams/files. It does not bypass DRM or retrieve copyrighted recordings without authorization.