class AdminSettings {
  AdminSettings({
    required this.commissionPercentage,
    this.updatedAt,
    this.updatedBy,
  });

  final double commissionPercentage; // Admin commission percentage (e.g., 2.5 for 2.5%)
  final DateTime? updatedAt;
  final String? updatedBy; // Admin UID who updated

  static const double defaultCommissionPercentage = 2.5;
}

