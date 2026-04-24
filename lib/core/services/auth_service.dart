import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  // â”€â”€ Sign Up â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
    );
  }

  // â”€â”€ Create Profile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> createProfile({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
    required String username,
    required String phone,
    required String gender,
    required int age,
  }) async {
    await _supabase.from('profiles').upsert({
      'id': userId,
      'email': email.trim(),
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'username': username.trim().toLowerCase(),
      'phone': phone.trim(),
      'gender': gender,
      'age': age,
    });
  }

  // â”€â”€ Sign In â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<AuthResponse> signIn({
    required String emailOrUsername,
    required String password,
  }) async {
    String email = emailOrUsername.trim();

    if (!email.contains('@')) {
      final result = await _supabase
          .from('profiles')
          .select('email')
          .eq('username', email.toLowerCase())
          .maybeSingle();

      if (result == null ||
          result['email'] == null ||
          (result['email'] as String).isEmpty) {
        throw AuthException('No account found with that username.');
      }
      email = result['email'] as String;
    }

    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // â”€â”€ Sign Out â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // â”€â”€ Current Session â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Session? get currentSession => _supabase.auth.currentSession;

  // â”€â”€ Current User â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  User? get currentUser => _supabase.auth.currentUser;

  // â”€â”€ Auth State Stream â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Stream<AuthState> get authStateStream =>
      _supabase.auth.onAuthStateChange;
}


