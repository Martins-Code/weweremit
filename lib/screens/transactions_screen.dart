import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../data/sample_data.dart';
import '../models/transaction.dart';
import '../widgets/remit_app_bar.dart';
import '../widgets/app_drawer.dart';

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
      drawer: AppDrawer(
        currentRoute: TransactionsScreen.routeName,
        onNavigate: (route) => _handleNavigation(context, route),
      ),
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryBlue.withOpacity(0.1),
                            AppColors.oceanTeal.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.primaryBlue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transaction History',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${transactions.length} total transactions',
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _showDownloadHint(context),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Download CSV'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filter Transactions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              FilterChip(
                                label: const Text(
                                  'All Transactions',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                selected: _statusFilter == null,
                                selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                                checkmarkColor: AppColors.primaryBlue,
                                onSelected: (_) =>
                                    setState(() => _statusFilter = null),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              FilterChip(
                                label: const Text(
                                  'Completed',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                selected:
                                    _statusFilter == TransactionStatus.completed,
                                selectedColor: AppColors.success.withOpacity(0.2),
                                checkmarkColor: AppColors.success,
                                onSelected: (_) => setState(
                                  () =>
                                      _statusFilter = TransactionStatus.completed,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              FilterChip(
                                label: const Text(
                                  'Pending',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                selected:
                                    _statusFilter == TransactionStatus.pending,
                                selectedColor: Colors.orange.withOpacity(0.2),
                                checkmarkColor: Colors.orange,
                                onSelected: (_) => setState(
                                  () => _statusFilter = TransactionStatus.pending,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: _TransactionsTable(records: transactions),
                          ),
                        ],
                      ),
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
    final formatter = DateFormat('MMM dd, yyyy');
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.withOpacity(0.1),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all<Color>(
                AppColors.primaryBlue.withOpacity(0.05),
              ),
              headingRowHeight: 56,
              dataRowMinHeight: 64,
              dataRowMaxHeight: 80,
              columnSpacing: isWide ? 24 : 16,
          columns: const [
            DataColumn(
              label: Text(
                'Date',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Reference',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Dealer',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Sent',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Received',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Status',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
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
                  DataCell(
                    Text(
                      record.dealerName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(
                      record.formattedSent,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(
                      record.formattedReceived,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
          ),
        );
      },
    );
  }
}
