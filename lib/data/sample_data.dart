import '../models/currency_pair.dart';
import '../models/dealer.dart';
import '../models/transaction.dart';

class SampleData {
  SampleData._();

  static final List<CurrencyPair> currencyPairs = CurrencyPair.defaults();

  static final List<Dealer> dealers = [
    Dealer(
      id: '1',
      name: 'FastRemit Nigeria',
      exchangeRateAUDtoNGN: 950.0,
      exchangeRateNGNtoAUD: 0.00105,
      minLimit: 100,
      maxLimit: 5000,
      rating: 4.8,
      status: DealerStatus.active,
      phoneNumber: '+61 400 000 000',
      currencyDirections: [
        CurrencyDirection.audToNgn,
        CurrencyDirection.ngnToAud,
      ],
      email: 'support@fastremit.ng',
    ),
    Dealer(
      id: '2',
      name: 'Global Transfers',
      exchangeRateAUDtoNGN: 945.0,
      exchangeRateNGNtoAUD: 0.0,
      minLimit: 50,
      maxLimit: 10000,
      rating: 4.5,
      status: DealerStatus.active,
      phoneNumber: '+61 400 000 001',
      currencyDirections: [CurrencyDirection.audToNgn],
      email: 'info@globaltransfers.ng',
    ),
    Dealer(
      id: '3',
      name: 'MoneyBridge',
      exchangeRateAUDtoNGN: 955.0,
      exchangeRateNGNtoAUD: 0.00104,
      minLimit: 200,
      maxLimit: 3000,
      rating: 4.6,
      status: DealerStatus.active,
      phoneNumber: '+61 400 000 002',
      currencyDirections: [
        CurrencyDirection.audToNgn,
        CurrencyDirection.ngnToAud,
      ],
      email: 'hello@moneybridge.ng',
    ),
    Dealer(
      id: '4',
      name: 'Swift Remit',
      exchangeRateAUDtoNGN: 948.0,
      exchangeRateNGNtoAUD: 0.0,
      minLimit: 75,
      maxLimit: 8000,
      rating: 4.3,
      status: DealerStatus.active,
      phoneNumber: '+61 400 000 003',
      currencyDirections: [CurrencyDirection.audToNgn],
      email: 'contact@swiftremit.ng',
    ),
  ];

  static final List<TransactionRecord> transactions = [
    TransactionRecord(
      reference: 'REF-2024-001',
      dealerName: 'FastRemit Nigeria',
      date: DateTime(2024, 1, 15),
      amountSent: 500,
      amountReceived: 250000,
      status: TransactionStatus.completed,
    ),
    TransactionRecord(
      reference: 'REF-2024-002',
      dealerName: 'Global Transfers',
      date: DateTime(2024, 1, 14),
      amountSent: 1000,
      amountReceived: 500000,
      status: TransactionStatus.pending,
    ),
    TransactionRecord(
      reference: 'REF-2024-003',
      dealerName: 'MoneyBridge',
      date: DateTime(2024, 1, 13),
      amountSent: 250,
      amountReceived: 125000,
      status: TransactionStatus.completed,
    ),
  ];
}
