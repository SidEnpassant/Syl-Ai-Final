import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authTokenServiceProvider = Provider<AuthTokenService>((ref) {
  return AuthTokenService();
});

class AuthTokenService {
  // Get stored user ID - use Supabase's currentUser directly
  Future<String?> getUserId() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      return user?.id;
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  // Get auth token from Supabase session
  Future<String?> getAuthToken() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      return session?.accessToken;
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  // Clear stored auth data (for logout)
  Future<void> clearAuthData() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      print('Error during sign out: $e');
    }
  }

  // Set auth token in Supabase client
  Future<void> setAuthHeader(SupabaseClient client) async {
    // This is actually not needed as Supabase Flutter SDK
    // automatically handles the auth headers when making requests
    // but we'll keep it for cases where you might need custom headers
    final String? token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token available');
    }

    client.rest.headers['Authorization'] = 'Bearer $token';
  }
}
