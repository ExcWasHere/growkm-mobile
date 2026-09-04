import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_storage_service.dart';

class SupabaseAuthService {
  SupabaseAuthService._();
  static final instance = SupabaseAuthService._();

  SupabaseClient get _client => Supabase.instance.client;

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final refreshToken = response.session?.refreshToken;
    if (refreshToken != null) {
      await AuthStorageService.instance.saveSession(refreshToken);
    }

    return response;
  }

  Future<bool> signInWithGoogle() async {
    return await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'growkm://login-callback',
    );
  }

  Future<void> persistCurrentSession() async {
    final session = _client.auth.currentSession;
    if (session != null) {
      await AuthStorageService.instance.saveSession(session.refreshToken!);
    }
  }

  Future<bool> hasBusinessProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;
    final row = await _client
        .from('business_profiles')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    return row != null;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    await AuthStorageService.instance.clearAll();
  }
}