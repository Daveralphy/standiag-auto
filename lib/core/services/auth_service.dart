import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  // ── Register Car Owner ────────────────────────────────────────
  Future<void> registerCarOwner({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
    required String gender,
    required String phone,
    required String countryCode,
    required Map<String, dynamic> vehicle,
  }) async {
    final res = await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
    );
    final userId = res.user?.id;
    if (userId == null) throw AuthException('Registration failed.');
    await _supabase.from('profiles').upsert({
      'id': userId,
      'email': email.trim(),
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'username': username.trim().toLowerCase(),
      'phone': countryCode + phone.trim(),
      'gender': gender,
      'account_type': 'car_owner',
    });
    await _supabase.from('vehicles').insert({
      'user_id': userId,
      'make': vehicle['make'],
      'model': vehicle['model'],
      'year': vehicle['year'],
      'engine_type': vehicle['engine_type'],
      'nickname': vehicle['nickname'],
      'is_active': true,
    });
  }

  // ── Register Mechanic ─────────────────────────────────────────
  Future<void> registerMechanic({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
    required String gender,
    required String phone,
    required String countryCode,
    required String address,
    required List<String> specialisations,
    required int experienceYears,
  }) async {
    final res = await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
    );
    final userId = res.user?.id;
    if (userId == null) throw AuthException('Registration failed.');
    await _supabase.from('profiles').upsert({
      'id': userId,
      'email': email.trim(),
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'username': username.trim().toLowerCase(),
      'phone': countryCode + phone.trim(),
      'gender': gender,
      'account_type': 'mechanic',
    });
    await _supabase.from('mechanic_profiles').upsert({
      'id': userId,
      'location': address.trim(),
      'specialisations': specialisations,
      'experience_years': experienceYears,
      'is_subscribed': false,
      'is_active': true,
      'rating': 0.0,
    });
  }

  // ── Sign In ───────────────────────────────────────────────────
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
      if (result == null || result['email'] == null) {
        throw AuthException('No account found with that username.');
      }
      email = result['email'] as String;
    }
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ── Sign Out ──────────────────────────────────────────────────
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ── Helpers ───────────────────────────────────────────────────
  Session? get currentSession => _supabase.auth.currentSession;
  User? get currentUser => _supabase.auth.currentUser;
  Stream<AuthState> get authStateStream => _supabase.auth.onAuthStateChange;
}

