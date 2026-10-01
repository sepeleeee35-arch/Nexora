import express from "express";
import cors from "cors";
import "dotenv/config";
import { query } from "./db.js";

const app=express();
const port=Number(process.env.PORT ?? 3000);
app.use(cors({origin:process.env.CORS_ORIGIN ?? "*"}));
app.use(express.json());

app.get("/",(_req,res)=>res.json({name:"Nexora Music API",version:"1.0.0",status:"online"}));

app.get("/api/search",async(req,res)=>{
  try{
    const q=String(req.query.q??"").trim();
    if(!q) return res.json({query:"",tracks:[],artists:[],albums:[],playlists:[]});
    const like=`%${q}%`;
    const [tracks,artists,albums,playlists]=await Promise.all([
      query("SELECT * FROM music_tracks WHERE title ILIKE $1 ORDER BY title LIMIT 50",[like]),
      query("SELECT * FROM music_artists WHERE name ILIKE $1 ORDER BY name LIMIT 25",[like]),
      query("SELECT * FROM music_albums WHERE title ILIKE $1 ORDER BY title LIMIT 25",[like]),
      query("SELECT * FROM music_playlists WHERE name ILIKE $1 ORDER BY name LIMIT 25",[like])
    ]);
    res.json({query:q,tracks,artists,albums,playlists});
  }catch(e){console.error(e);res.status(500).json({error:"Music search failed"});}
});

app.get("/api/tracks",async(_req,res)=>{
  try{res.json(await query("SELECT * FROM music_tracks ORDER BY created_at DESC LIMIT 100"));}
  catch{res.status(500).json({error:"Failed to load tracks"});}
});
app.get("/api/tracks/:id",async(req,res)=>{
  try{
    const rows=await query("SELECT * FROM music_tracks WHERE id=$1 LIMIT 1",[req.params.id]);
    if(!rows.length)return res.status(404).json({error:"Track not found"});
    res.json(rows[0]);
  }catch{res.status(500).json({error:"Failed to load track"});}
});

app.get("/api/artists",async(_req,res)=>{
  try{res.json(await query("SELECT * FROM music_artists ORDER BY name LIMIT 100"));}
  catch{res.status(500).json({error:"Failed to load artists"});}
});
app.get("/api/artists/:id",async(req,res)=>{
  try{
    const artists=await query("SELECT * FROM music_artists WHERE id=$1 LIMIT 1",[req.params.id]);
    if(!artists.length)return res.status(404).json({error:"Artist not found"});
    const tracks=await query("SELECT * FROM music_tracks WHERE artist_id=$1 ORDER BY title LIMIT 100",[req.params.id]);
    res.json({...artists[0],tracks});
  }catch{res.status(500).json({error:"Failed to load artist"});}
});

app.get("/api/albums",async(_req,res)=>{
  try{res.json(await query("SELECT * FROM music_albums ORDER BY title LIMIT 100"));}
  catch{res.status(500).json({error:"Failed to load albums"});}
});
app.get("/api/albums/:id",async(req,res)=>{
  try{
    const albums=await query("SELECT * FROM music_albums WHERE id=$1 LIMIT 1",[req.params.id]);
    if(!albums.length)return res.status(404).json({error:"Album not found"});
    const tracks=await query("SELECT * FROM music_tracks WHERE album_id=$1 ORDER BY track_number,title",[req.params.id]);
    res.json({...albums[0],tracks});
  }catch{res.status(500).json({error:"Failed to load album"});}
});

app.get("/api/playlists",async(_req,res)=>{
  try{res.json(await query("SELECT * FROM music_playlists ORDER BY created_at DESC LIMIT 100"));}
  catch{res.status(500).json({error:"Failed to load playlists"});}
});
app.get("/api/playlists/:id",async(req,res)=>{
  try{
    const playlists=await query("SELECT * FROM music_playlists WHERE id=$1 LIMIT 1",[req.params.id]);
    if(!playlists.length)return res.status(404).json({error:"Playlist not found"});
    const tracks=await query(
      "SELECT t.*,pt.position FROM music_playlist_tracks pt JOIN music_tracks t ON t.id=pt.track_id WHERE pt.playlist_id=$1 ORDER BY pt.position",
      [req.params.id]
    );
    res.json({...playlists[0],tracks});
  }catch{res.status(500).json({error:"Failed to load playlist"});}
});

app.listen(port,()=>console.log(`Nexora Music API listening on port ${port}`));