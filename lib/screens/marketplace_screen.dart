import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/sample_data.dart';
import '../models/dealer.dart';
import '../widgets/remit_app_bar.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  static const routeName = '/marketplace';

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  DealerStatus? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dealers = SampleData.dealers.where((dealer) {
      final matchesStatus =
          _statusFilter == null || dealer.status == _statusFilter;
      final matchesQuery = dealer.name.toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );
      return matchesStatus && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: RemitAppBar(
        currentRoute: MarketplaceScreen.routeName,
        onNavigate: (route) => _handleNavigation(context, route),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 1100;
          final horizontalPadding = isWide
              ? (constraints.maxWidth - 960) / 2
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
                      'Dealer Marketplace',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (constraints.maxWidth > 720)
                      Chip(
                        avatar: const Icon(Icons.verified, size: 18),
                        label: Text(
                          '${SampleData.dealers.length} trusted dealers',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildFilters(),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: dealers
                      .map(
                        (dealer) => SizedBox(
                          width: constraints.maxWidth > 900
                              ? (constraints.maxWidth / 2) - 36
                              : double.infinity,
                          child: _DealerCard(
                            dealer: dealer,
                            onSelect: () =>
                                _handleNavigation(context, '/send-money'),
                          ),
                        ),
                      )
                      .toList(),
                ),
                if (dealers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: _EmptyState(
                      onClear: () {
                        setState(() {
                          _statusFilter = null;
                          _searchController.clear();
                        });
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search dealers...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                FilterChip(
                  selected: _statusFilter == null,
                  label: const Text('All Dealers'),
                  onSelected: (_) => setState(() => _statusFilter = null),
                ),
                FilterChip(
                  selected: _statusFilter == DealerStatus.active,
                  label: const Text('Active Only'),
                  onSelected: (_) =>
                      setState(() => _statusFilter = DealerStatus.active),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.of(context).pushNamed(route);
  }
}

class _DealerCard extends StatelessWidget {
  const _DealerCard({required this.dealer, required this.onSelect});

  final Dealer dealer;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dealer.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFC94B)),
                    const SizedBox(width: 4),
                    Text(
                      dealer.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Exchange Rate',
              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.9)),
            ),
            const SizedBox(height: 4),
            Text(
              dealer.exchangeRate,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dealer.email,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Tag(
                  icon: Icons.monetization_on_outlined,
                  label: dealer.formattedLimits,
                ),
                _Tag(
                  icon: Icons.check_circle_outline,
                  label: dealer.status == DealerStatus.active
                      ? 'Active'
                      : 'Inactive',
                  color: dealer.status == DealerStatus.active
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => _showDealerModal(context, dealer),
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: onSelect,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                    ),
                    child: const Text('Chat'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDealerModal(BuildContext context, Dealer dealer) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
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
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFC94B)),
                      const SizedBox(width: 4),
                      Text(
                        dealer.rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                dealer.exchangeRate,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Limits: ${dealer.formattedLimits}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              Text(
                'Contact: ${dealer.email}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.icon,
    required this.label,
    this.color = AppColors.primaryBlue,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: Gradients.cardAccent,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          const Text(
            'No dealers found',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters or search terms.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onClear,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            child: const Text('Reset Filters'),
          ),
        ],
      ),
    );
  }
}
