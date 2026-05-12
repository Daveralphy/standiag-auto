class RegisterState {
  final String accountType;
  final String firstName;
  final String lastName;
  final String gender;
  final String phone;
  final String countryCode;
  final String address;
  final List<String> specialisations;
  final int experienceYears;
  final Map<String, dynamic> vehicle;

  const RegisterState({
    this.accountType = '',
    this.firstName = '',
    this.lastName = '',
    this.gender = '',
    this.phone = '',
    this.countryCode = '+234',
    this.address = '',
    this.specialisations = const [],
    this.experienceYears = 0,
    this.vehicle = const {},
  });

  RegisterState copyWith({
    String? accountType,
    String? firstName,
    String? lastName,
    String? gender,
    String? phone,
    String? countryCode,
    String? address,
    List<String>? specialisations,
    int? experienceYears,
    Map<String, dynamic>? vehicle,
  }) {
    return RegisterState(
      accountType: accountType ?? this.accountType,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      address: address ?? this.address,
      specialisations: specialisations ?? this.specialisations,
      experienceYears: experienceYears ?? this.experienceYears,
      vehicle: vehicle ?? this.vehicle,
    );
  }
}

