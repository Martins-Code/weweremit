import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/sample_data.dart';
import '../models/dealer.dart';
import '../models/currency_pair.dart';
import '../widgets/remit_app_bar.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  static const routeName = '/send-money';

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  late CurrencyPair _pair;
  final TextEditingController _amountController = TextEditingController(
    text: '2000',
  );
  bool _showDealers = false;

  @override
  void initState() {
    super.initState();
    _pair = SampleData.currencyPairs.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dealers = SampleData.dealers;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: RemitAppBar(
        currentRoute: SendMoneyScreen.routeName,
        onNavigate: (route) => _handleNavigation(context, route),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 720;
          final horizontalPadding = isWide
              ? (constraints.maxWidth - 640) / 2
              : 24.0;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Send Money',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 22),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<CurrencyPair>(
                          decoration: const InputDecoration(
                            labelText: 'Currency Pair',
                          ),
                          value: _pair,
                          items: SampleData.currencyPairs
                              .map(
                                (pair) => DropdownMenuItem(
                                  value: pair,
                                  child: Text(pair.label),
                                ),
                              )
                              .toList(),
                          onChanged: (pair) {
                            if (pair != null) {
                              setState(() => _pair = pair);
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Amount (AUD)',
                            hintText: 'Enter amount',
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: Gradients.button,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withOpacity(
                                    0.32,
                                  ),
                                  blurRadius: 18,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _calculateRate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text('Calculate Rate'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (_showDealers) _DealersSection(dealers: dealers),
              ],
            ),
          );
        },
      ),
    );
  }

  void _calculateRate() {
    setState(() {
      _showDealers = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Showing rates for ${_pair.label}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1800),
      ),
    );
  }

  void _handleNavigation(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.of(context).pushNamed(route);
  }
}

class _DealersSection extends StatefulWidget {
  const _DealersSection({required this.dealers});

  final List<Dealer> dealers;

  @override
  State<_DealersSection> createState() => _DealersSectionState();
}

class _DealersSectionState extends State<_DealersSection> {
  Dealer? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.dealers.isNotEmpty) {
      _selected = widget.dealers.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Dealers',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                Chip(
                  avatar: const Icon(
                    Icons.store_mall_directory_rounded,
                    size: 18,
                  ),
                  label: Text('${widget.dealers.length} Dealers Available'),
                  backgroundColor: const Color(0xFFE6EEFF),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ExpansionPanelList.radio(
              animationDuration: const Duration(milliseconds: 350),
              expandedHeaderPadding: EdgeInsets.zero,
              children: widget.dealers
                  .map(
                    (dealer) => ExpansionPanelRadio(
                      value: dealer.name,
                      headerBuilder: (_, isExpanded) => ListTile(
                        title: Text(
                          dealer.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Exchange rate: ${dealer.exchangeRate}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: _DealerRating(rating: dealer.rating),
                      ),
                      body: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _InfoBadge(
                                  icon: Icons.monetization_on_outlined,
                                  label: 'Limits',
                                  value: dealer.formattedLimits,
                                ),
                                const SizedBox(width: 16),
                                _InfoBadge(
                                  icon: Icons.verified_outlined,
                                  label: 'Status',
                                  value: dealer.status == DealerStatus.active
                                      ? 'Active'
                                      : 'Inactive',
                                  valueColor:
                                      dealer.status == DealerStatus.active
                                      ? AppColors.success
                                      : Colors.orange,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.tonal(
                                    onPressed: () =>
                                        _showDealerDetails(context, dealer),
                                    child: const Text('View Details'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () =>
                                        _selectDealer(context, dealer),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlue,
                                    ),
                                    child: const Text('Select'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (_selected != null) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: Gradients.cardAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'You selected ${_selected!.name}. Continue to complete your transfer and chat with the dealer.',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _selectDealer(BuildContext context, Dealer dealer) {
    setState(() => _selected = dealer);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${dealer.name} selected'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDealerDetails(BuildContext context, Dealer dealer) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dealer.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                _DealerRating(rating: dealer.rating),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              dealer.exchangeRate,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              'Limits: ${dealer.formattedLimits}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Text(
              'Contact: ${dealer.email}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = AppColors.textPrimary,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: Gradients.cardAccent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(color: valueColor, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _DealerRating extends StatelessWidget {
  const _DealerRating({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, color: Color(0xFFFFC94B), size: 20),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
