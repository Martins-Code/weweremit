import 'package:flutter/material.dart';

import '../app_theme.dart';

class TransactionRecord {
  TransactionRecord({
    required this.reference,
    required this.dealerName,
    required this.date,
    required this.amountSent,
    required this.amountReceived,
    required this.status,
  });

  final String reference;
  final String dealerName;
  final DateTime date;
  final double amountSent;
  final double amountReceived;
  final TransactionStatus status;

  String get formattedSent => '\$${amountSent.toStringAsFixed(2)}';
  String get formattedReceived => '₦${amountReceived.toStringAsFixed(0)}';
}

enum TransactionStatus { completed, pending, cancelled }

extension TransactionStatusX on TransactionStatus {
  String get label {
    switch (this) {
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get chipColor {
    switch (this) {
      case TransactionStatus.completed:
        return AppColors.success.withOpacity(0.15);
      case TransactionStatus.pending:
        return AppColors.warning.withOpacity(0.18);
      case TransactionStatus.cancelled:
        return Colors.redAccent.withOpacity(0.15);
    }
  }

  Color get textColor {
    switch (this) {
      case TransactionStatus.completed:
        return AppColors.success;
      case TransactionStatus.pending:
        return AppColors.warning;
      case TransactionStatus.cancelled:
        return Colors.redAccent;
    }
  }
}
