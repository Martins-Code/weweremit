class Dealer {
  Dealer({
    required this.id,
    required this.name,
    required this.exchangeRateAUDtoNGN,
    required this.exchangeRateNGNtoAUD,
    required this.minLimit,
    required this.maxLimit,
    required this.rating,
    required this.status,
    required this.phoneNumber,
    required this.currencyDirections,
    this.passportUrl,
    this.email,
  });

  final String id;
  final String name;
  final double exchangeRateAUDtoNGN; // Rate for AUD -> NGN
  final double exchangeRateNGNtoAUD; // Rate for NGN -> AUD
  final double minLimit;
  final double maxLimit;
  final double rating;
  final DealerStatus status;
  final String phoneNumber;
  final List<CurrencyDirection> currencyDirections;
  final String? passportUrl;
  final String? email; // Hidden from users, only for admin

  String get formattedLimits =>
      '\$${minLimit.toStringAsFixed(0)} - \$${maxLimit.toStringAsFixed(0)}';

  String getRateForDirection(CurrencyDirection direction) {
    if (direction == CurrencyDirection.audToNgn) {
      return '₦${exchangeRateAUDtoNGN.toStringAsFixed(2)} per \$1';
    } else {
      return '\$${exchangeRateNGNtoAUD.toStringAsFixed(4)} per ₦1';
    }
  }

  bool supportsDirection(CurrencyDirection direction) {
    return currencyDirections.contains(direction);
  }
}

enum DealerStatus { active, inactive, pending }

enum CurrencyDirection {
  audToNgn, // AUD -> NGN
  ngnToAud, // NGN -> AUD
  both, // Both directions
}

extension CurrencyDirectionExtension on CurrencyDirection {
  String get label {
    switch (this) {
      case CurrencyDirection.audToNgn:
        return 'AUD → NGN';
      case CurrencyDirection.ngnToAud:
        return 'NGN → AUD';
      case CurrencyDirection.both:
        return 'Both Directions';
    }
  }

  String get description {
    switch (this) {
      case CurrencyDirection.audToNgn:
        return 'Australian Dollar to Nigerian Naira';
      case CurrencyDirection.ngnToAud:
        return 'Nigerian Naira to Australian Dollar';
      case CurrencyDirection.both:
        return 'Both directions available';
    }
  }
}
