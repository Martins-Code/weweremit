import '../models/currency_pair.dart';
import '../models/dealer.dart';
import '../models/transaction.dart';

class SampleData {
  SampleData._();

  static final List<CurrencyPair> currencyPairs = CurrencyPair.defaults();

  static final List<Dealer> dealers = [
    Dealer(
      name: 'FastRemit Nigeria',
      exchangeRate: '₦500 → \$1',
      minLimit: 100,
      maxLimit: 5000,
      rating: 4.8,
      status: DealerStatus.active,
      email: 'support@fastremit.ng',
    ),
    Dealer(
      name: 'Global Transfers',
      exchangeRate: '₦495 → \$1',
      minLimit: 50,
      maxLimit: 10000,
      rating: 4.5,
      status: DealerStatus.active,
      email: 'info@globaltransfers.ng',
    ),
    Dealer(
      name: 'MoneyBridge',
      exchangeRate: '₦505 → \$1',
      minLimit: 200,
      maxLimit: 3000,
      rating: 4.6,
      status: DealerStatus.active,
      email: 'hello@moneybridge.ng',
    ),
    Dealer(
      name: 'Swift Remit',
      exchangeRate: '₦498 → \$1',
      minLimit: 75,
      maxLimit: 8000,
      rating: 4.3,
      status: DealerStatus.active,
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
