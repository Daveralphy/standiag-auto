import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

// ── Auth Service Provider ────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// ── Current User Provider ────────────────────────────────
final currentUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

// ── Auth State Provider ──────────────────────────────────
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateStream;
});

// ── Registration Data Notifier ───────────────────────────
// Holds data across the 4 registration steps
class RegistrationData {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String countryCode;
  final String gender;
  final int age;
  final String username;
  final String password;

  const RegistrationData({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.countryCode = '+234',
    this.gender = '',
    this.age = 0,
    this.username = '',
    this.password = '',
  });

  RegistrationData copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? countryCode,
    String? gender,
    int? age,
    String? username,
    String? password,
  }) {
    return RegistrationData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}

class RegistrationNotifier extends Notifier<RegistrationData> {
  @override
  RegistrationData build() => const RegistrationData();

  void setStep1(String firstName, String lastName) {
    state = state.copyWith(
      firstName: firstName,
      lastName: lastName,
    );
  }

  void setStep2(String email, String phone, String countryCode) {
    state = state.copyWith(
      email: email,
      phone: phone,
      countryCode: countryCode,
    );
  }

  void setStep3(String gender, int age) {
    state = state.copyWith(
      gender: gender,
      age: age,
    );
  }

  void setStep4(String username, String password) {
    state = state.copyWith(
      username: username,
      password: password,
    );
  }

  void reset() {
    state = const RegistrationData();
  }
}

final registrationProvider =
    NotifierProvider<RegistrationNotifier, RegistrationData>(
  RegistrationNotifier.new,
);