import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 🟢 Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      throw AuthException('Email and password cannot be empty.');
    }

    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw AuthException('Login failed. Please check your email or password.');
    }

    return response;
  }

  //sign in with google
  // 🔹 Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://xcmlnqspnqyzwthobyrm.supabase.co/auth/v1/callback',
      );
    } catch (e) {
      throw AuthException('An error occurred during Google sign-in: $e');
    }
  }

  // 🟣 Sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      throw AuthException('Email and password cannot be empty.');
    }

    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw AuthException('Sign-up failed. Please try again.');
    }

    return response;
  }

  // 🔵 Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // 🟡 Get current user email
  String? getCurrentUserEmail() {
    final user = _supabase.auth.currentUser;
    return user?.email;
  }
}
