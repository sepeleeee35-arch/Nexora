import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NexoraChatService {
  NexoraChatService._();
  static final NexoraChatService instance = NexoraChatService._();
  SupabaseClient? _client;
  String? _error;
  String? get error => _error;
  SupabaseClient? get client => _client;
  bool get configured => _client != null;

  Future<void> initialize(GoogleSignInAccount account) async {
    if (_client != null) return;
    const url = String.fromEnvironment('SUPABASE_URL');
    const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    if (url.isEmpty || key.isEmpty) {
      _error = 'Supabase belum dikonfigurasi. Tambahkan SUPABASE_URL dan SUPABASE_PUBLISHABLE_KEY pada build.';
      return;
    }
    try {
      await Supabase.initialize(url: url, anonKey: key);
      _client = Supabase.instance.client;
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        _error = 'Token Google tidak tersedia. Keluar lalu login Google kembali.';
        return;
      }
      await _client!.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken);
      final user = _client!.auth.currentUser;
      if (user == null) throw Exception('Sesi Supabase tidak terbentuk.');
      await _client!.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'display_name': account.displayName ?? account.email.split('@').first,
        'avatar_url': account.photoUrl,
      });
      _error = null;
    } catch (e) {
      _error = 'Gagal menghubungkan chat: $e';
    }
  }

  Future<List<Map<String,dynamic>>> searchUsers(String query) async {
    final c=_client; if(c==null) return [];
    final me=c.auth.currentUser?.id;
    if(query.trim().length<2) return [];
    final rows=await c.from('profiles').select('id,email,display_name,avatar_url')
      .ilike('email','%'+query.trim()+'%').neq('id',me ?? '').limit(20);
    return List<Map<String,dynamic>>.from(rows);
  }

  Future<String> openConversation(String otherId) async {
    final row=await _client!.rpc('create_direct_conversation',params:{'other_user':otherId});
    return row.toString();
  }

  Stream<List<Map<String,dynamic>>> conversations() {
    final uid=_client!.auth.currentUser!.id;
    return _client!.from('conversation_members').stream(primaryKey:['conversation_id','user_id'])
      .eq('user_id',uid).map((rows)=>rows);
  }

  Future<List<Map<String,dynamic>>> messages(String conversationId) async {
    final rows=await _client!.from('messages').select('id,conversation_id,sender_id,body,created_at')
      .eq('conversation_id',conversationId).order('created_at');
    return List<Map<String,dynamic>>.from(rows);
  }

  Stream<List<Map<String,dynamic>>> messageStream(String conversationId) =>
    _client!.from('messages').stream(primaryKey:['id']).eq('conversation_id',conversationId)
      .order('created_at').map((rows)=>List<Map<String,dynamic>>.from(rows));

  Future<void> send(String conversationId,String body) async {
    final text=body.trim(); if(text.isEmpty) return;
    await _client!.from('messages').insert({
      'conversation_id':conversationId,
      'sender_id':_client!.auth.currentUser!.id,
      'body':text,
    });
  }
}
