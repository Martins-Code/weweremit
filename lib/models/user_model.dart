enum UserRole {
  user,
  dealer,
  admin,
}

class AppUser {
  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? phoneNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isAdmin => role == UserRole.admin;
  bool get isDealer => role == UserRole.dealer || role == UserRole.admin;
  bool get isUser => role == UserRole.user || role == UserRole.admin;

  // Named rates for specific users (dealer can set custom rates)
  Map<String, double>? customRates; // userId -> rate
}

