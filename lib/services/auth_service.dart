import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sylai2/app_constants.dart';
import 'package:sylai2/models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final client = Supabase.instance.client;
  return AuthService(client);
});

class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  // Get current user
  UserModel? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    return UserModel(
      id: user.id,
      email: user.email,
      phone: user.phone,
      createdAt: DateTime.parse(
        user.createdAt ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        user.updatedAt ?? DateTime.now().toIso8601String(),
      ),
      fullName: user.userMetadata?['full_name'] as String? ?? '',
      avatarUrl: user.userMetadata?['avatar_url'] as String? ?? '',
    );
  }

  // Validate auth token
  Future<bool> validateToken(String token) async {
    try {
      // Get the JWT claims from the token
      final response = await _client.auth.getUser(token);
      return response.user != null;
    } catch (e) {
      return false;
    }
  }

  // Sign in with email OTP
  Future<void> signInWithEmailOtp(String email) async {
    await _client.auth.signInWithOtp(email: email, emailRedirectTo: null);
  }

  // Check if email is registered
  Future<bool> isEmailRegistered(String email) async {
    try {
      final result =
          await _client
              .from(AppConstants.usersTable)
              .select('email')
              .eq('email', email)
              .maybeSingle();

      return result != null;
    } catch (e) {
      throw Exception('Failed to check email registration: $e');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Get current user from database
  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final userData =
        await _client
            .from(AppConstants.usersTable)
            .select('created_at, updated_at')
            .eq('id', user.id)
            .maybeSingle();

    return UserModel(
      id: user.id,
      email: user.email,
      phone: user.phone,
      createdAt:
          userData != null
              ? DateTime.parse(userData['created_at'])
              : DateTime.now(),
      updatedAt:
          userData != null
              ? DateTime.parse(userData['updated_at'])
              : DateTime.now(),
      fullName: user.userMetadata?['full_name'] as String? ?? '',
      avatarUrl: user.userMetadata?['avatar_url'] as String? ?? '',
    );
  }

  // Verify email OTP
  Future<AuthResponse> verifyEmailOtp(String email, String token) async {
    try {
      // Try signup type first
      return await _client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
      );
    } catch (e) {
      // If that fails, try with email (magiclink) type
      return await _client.auth.verifyOTP(
        email: email,
        token: token,
        type:
            OtpType
                .
                //sms,
                magiclink,
      );
    }
  }

  // Sign in with phone OTP
  Future<void> signInWithPhoneOtp(String phone) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  // Verify phone OTP
  Future<AuthResponse> verifyPhoneOtp(String phone, String token) async {
    return await _client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  // Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign in was canceled');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    return await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String fullName,
    String? avatarUrl,
  }) async {
    await _client.auth.updateUser(
      UserAttributes(
        data: {
          'full_name': fullName,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        },
      ),
    );

    // Also update the user in the users table
    await _client.from(AppConstants.usersTable).upsert({
      'id': currentUser!.id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Create or update user in database
  Future<void> upsertUserRecord() async {
    final user = currentUser;
    if (user == null) return;

    await _client.from(AppConstants.usersTable).upsert({
      'id': user.id,
      'email': user.email,
      'phone': user.phone,
      'full_name': user.fullName,
      'avatar_url': user.avatarUrl,
      'last_sign_in': DateTime.now().toIso8601String(),
      'created_at': user.createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
