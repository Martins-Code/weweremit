import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../data/sample_data.dart';
import '../models/transaction.dart';
import '../widgets/remit_app_bar.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  static const routeName = '/transactions';

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final transactions = SampleData.transactions.where((record) {
      if (_statusFilter == null) return true;
      return record.status == _statusFilter;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: RemitAppBar(
        currentRoute: TransactionsScreen.routeName,
        onNavigate: (route) => _handleNavigation(context, route),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth > 1000
              ? (constraints.maxWidth - 880) / 2
              : 24.0;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transaction History',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _showDownloadHint(context),
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Download CSV'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 12,
                          children: [
                            FilterChip(
                              label: const Text('All Transactions'),
                              selected: _statusFilter == null,
                              onSelected: (_) =>
                                  setState(() => _statusFilter = null),
                            ),
                            FilterChip(
                              label: const Text('Completed'),
                              selected:
                                  _statusFilter == TransactionStatus.completed,
                              onSelected: (_) => setState(
                                () =>
                                    _statusFilter = TransactionStatus.completed,
                              ),
                            ),
                            FilterChip(
                              label: const Text('Pending'),
                              selected:
                                  _statusFilter == TransactionStatus.pending,
                              onSelected: (_) => setState(
                                () => _statusFilter = TransactionStatus.pending,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _TransactionsTable(records: transactions),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleNavigation(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.of(context).pushNamed(route);
  }

  void _showDownloadHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export coming soon. Stay tuned!')),
    );
  }
}

class _TransactionsTable extends StatelessWidget {
  const _TransactionsTable({required this.records});

  final List<TransactionRecord> records;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('yyyy-MM-dd');
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DataTable(
        headingRowColor: MaterialStateProperty.all<Color>(
          const Color(0xFFF0F4FF),
        ),
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Reference')),
          DataColumn(label: Text('Dealer')),
          DataColumn(label: Text('Amount Sent')),
          DataColumn(label: Text('Amount Received')),
          DataColumn(label: Text('Status')),
        ],
        rows: records
            .map(
              (record) => DataRow(
                cells: [
                  DataCell(Text(formatter.format(record.date))),
                  DataCell(
                    Text(
                      record.reference,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataCell(Text(record.dealerName)),
                  DataCell(Text(record.formattedSent)),
                  DataCell(Text(record.formattedReceived)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: record.status.chipColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        record.status.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: record.status.textColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
