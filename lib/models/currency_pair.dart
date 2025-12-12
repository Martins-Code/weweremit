class CurrencyPair {
  CurrencyPair({required this.code, required this.label});

  final String code;
  final String label;

  static List<CurrencyPair> defaults() => [
    CurrencyPair(code: 'AUD-NGN', label: 'AUD → NGN (Australia → Nigeria)'),
    CurrencyPair(code: 'NGN-AUD', label: 'NGN → AUD (Nigeria → Australia)'),
    CurrencyPair(code: 'GHS-AUD', label: 'GHS → AUD (Ghana → Australia)'),
    CurrencyPair(code: 'AUD-GHS', label: 'AUD → GHS (Australia → Ghana)'),
  ];
}
