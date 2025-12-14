import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/sample_data.dart';
import '../models/dealer.dart';
import '../models/currency_pair.dart';
import '../widgets/remit_app_bar.dart';
import '../widgets/app_drawer.dart';
import 'chat_list_screen.dart';

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

  CurrencyDirection? _getDirectionFromPair(CurrencyPair pair) {
    if (pair.code == 'AUD-NGN') {
      return CurrencyDirection.audToNgn;
    } else if (pair.code == 'NGN-AUD') {
      return CurrencyDirection.ngnToAud;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final selectedDirection = _getDirectionFromPair(_pair);
    final dealers = SampleData.dealers.where((dealer) {
      if (selectedDirection == null) return true;
      return dealer.supportsDirection(selectedDirection);
    }).toList();
    
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: AppDrawer(
        currentRoute: SendMoneyScreen.routeName,
        onNavigate: (route) => _handleNavigation(context, route),
      ),
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
                        Icons.send_rounded,
                        color: AppColors.primaryBlue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Send Money',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Calculate the best rates for your transfer',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
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
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transfer Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 28),
                          DropdownButtonFormField<CurrencyPair>(
                            decoration: InputDecoration(
                              labelText: 'Currency Pair',
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryBlue,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.05),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              isDense: true,
                            ),
                            value: _pair,
                            isExpanded: true,
                            items: SampleData.currencyPairs
                                .map(
                                  (pair) => DropdownMenuItem(
                                    value: pair,
                                    child: Text(
                                      pair.label,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            selectedItemBuilder: (context) {
                              return SampleData.currencyPairs.map((pair) {
                                return Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    pair.label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList();
                            },
                            onChanged: (pair) {
                              if (pair != null) {
                                setState(() => _pair = pair);
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Amount (AUD)',
                              hintText: 'Enter amount',
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                              prefixIcon: const Icon(Icons.attach_money_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryBlue,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.05),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: Gradients.button,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _calculateRate,
                                icon: const Icon(Icons.calculate_rounded, size: 20),
                                label: const Text(
                                  'Calculate Rate',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (_showDealers) _DealersSection(dealers: dealers, selectedPair: _pair),
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
  const _DealersSection({
    required this.dealers,
    required this.selectedPair,
  });

  final List<Dealer> dealers;
  final CurrencyPair selectedPair;

  @override
  State<_DealersSection> createState() => _DealersSectionState();
}

class _DealersSectionState extends State<_DealersSection> {
  Dealer? _selected;

  CurrencyDirection? _getDirectionFromPair(CurrencyPair pair) {
    if (pair.code == 'AUD-NGN') {
      return CurrencyDirection.audToNgn;
    } else if (pair.code == 'NGN-AUD') {
      return CurrencyDirection.ngnToAud;
    }
    return null;
  }

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
                          _getDirectionFromPair(widget.selectedPair) != null
                              ? 'Rate: ${dealer.getRateForDirection(_getDirectionFromPair(widget.selectedPair)!)}'
                              : 'Multiple rates available',
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
                                  child: FilledButton.icon(
                                    onPressed: () =>
                                        _selectDealer(context, dealer),
                                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                                    label: const Text('Chat & Select'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlue,
                                    ),
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
    // Navigate to chat with the dealer
    Navigator.of(context).pushNamed(ChatListScreen.routeName);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with ${dealer.name}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDealerDetails(BuildContext context, Dealer dealer) {
    final selectedDirection = _getDirectionFromPair(widget.selectedPair);
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
              selectedDirection != null
                  ? dealer.getRateForDirection(selectedDirection!)
                  : 'Multiple rates available',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              'Limits: ${dealer.formattedLimits}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.primaryBlue,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Contact information is protected. Use chat to communicate.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: dealer.currencyDirections.map((dir) {
                return Chip(
                  label: Text(dir.label),
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  labelStyle: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList(),
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
