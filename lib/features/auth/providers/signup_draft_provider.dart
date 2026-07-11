// Holds signup data as the user moves across the 3-step CarOwner/Mechanic
// signup flow. GoRouter's `context.go` calls between steps don't carry any
// payload, so this Riverpod-held draft is what lets step three's
// "Create Account" see everything entered on steps one and two.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';

class SignupDraft {
  final UserType type;
  final String firstName;
  final String lastName;
  final String gender;
  final String dob;
  final String phone;
  final String email;
  final String address;
  final String workshopAddress;
  final List<String> expertise;
  final int yearsOfExperience;
  final String username;
  final String password;

  const SignupDraft({
    this.type = UserType.carOwner,
    this.firstName = '',
    this.lastName = '',
    this.gender = '',
    this.dob = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.workshopAddress = '',
    this.expertise = const [],
    this.yearsOfExperience = 0,
    this.username = '',
    this.password = '',
  });

  SignupDraft copyWith({
    UserType? type,
    String? firstName,
    String? lastName,
    String? gender,
    String? dob,
    String? phone,
    String? email,
    String? address,
    String? workshopAddress,
    List<String>? expertise,
    int? yearsOfExperience,
    String? username,
    String? password,
  }) {
    return SignupDraft(
      type: type ?? this.type,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      workshopAddress: workshopAddress ?? this.workshopAddress,
      expertise: expertise ?? this.expertise,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}

class SignupDraftNotifier extends Notifier<SignupDraft> {
  @override
  SignupDraft build() => const SignupDraft();

  void setType(UserType type) => state = SignupDraft(type: type);

  void updateUserStepOne({
    required String firstName,
    required String lastName,
    required String gender,
    required String dob,
  }) {
    state = state.copyWith(
        firstName: firstName, lastName: lastName, gender: gender, dob: dob);
  }

  void updateUserStepTwo({
    required String phone,
    required String email,
    required String address,
  }) {
    state = state.copyWith(phone: phone, email: email, address: address);
  }

  void updateMechanicStepOne({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) {
    state = state.copyWith(
        firstName: firstName, lastName: lastName, email: email, phone: phone);
  }

  void updateMechanicStepTwo({
    required String workshopAddress,
    required List<String> expertise,
    required int yearsOfExperience,
  }) {
    state = state.copyWith(
      workshopAddress: workshopAddress,
      expertise: expertise,
      yearsOfExperience: yearsOfExperience,
    );
  }

  void updateCredentials({required String username, required String password}) {
    state = state.copyWith(username: username, password: password);
  }

  void reset() => state = const SignupDraft();
}

final signupDraftProvider =
    NotifierProvider<SignupDraftNotifier, SignupDraft>(SignupDraftNotifier.new);
