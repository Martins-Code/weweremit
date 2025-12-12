class Dealer {
  Dealer({
    required this.name,
    required this.exchangeRate,
    required this.minLimit,
    required this.maxLimit,
    required this.rating,
    required this.status,
    required this.email,
  });

  final String name;
  final String exchangeRate;
  final double minLimit;
  final double maxLimit;
  final double rating;
  final DealerStatus status;
  final String email;

  String get formattedLimits =>
      '\$${minLimit.toStringAsFixed(0)} - \$${maxLimit.toStringAsFixed(0)}';
}

enum DealerStatus { active, inactive, pending }
