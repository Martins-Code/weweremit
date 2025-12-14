import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../app_theme.dart';
import '../models/dealer.dart';
import '../widgets/app_drawer.dart';
import 'chat_list_screen.dart';

class DealerDashboardScreen extends StatefulWidget {
  const DealerDashboardScreen({super.key});

  static const routeName = '/dealer-dashboard';

  @override
  State<DealerDashboardScreen> createState() => _DealerDashboardScreenState();
}

class _DealerDashboardScreenState extends State<DealerDashboardScreen> {
  Dealer? _dealer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDealerData();
  }

  Future<void> _loadDealerData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
          final doc = await FirebaseFirestore.instance
              .collection('dealers')
              .doc(user.uid)
              .get();
        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            _dealer = _dealerFromFirestore(data, doc.id);
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('Error loading dealer data: $e');
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Dealer _dealerFromFirestore(Map<String, dynamic> data, String id) {
    final exchangeRates = Map<String, double>.from(data['exchangeRates'] ?? {});
    final currencyDirections = (data['currencyDirections'] as List<dynamic>?)
            ?.map((e) {
          if (e == 'audToNgn') return CurrencyDirection.audToNgn;
          if (e == 'ngnToAud') return CurrencyDirection.ngnToAud;
          return CurrencyDirection.audToNgn;
        }).toList() ??
        [];

    return Dealer(
      id: id,
      name: data['name'] as String? ?? '',
      exchangeRateAUDtoNGN: exchangeRates['audToNgn'] ?? 0.0,
      exchangeRateNGNtoAUD: exchangeRates['ngnToAud'] ?? 0.0,
      minLimit: (data['minLimit'] as num?)?.toDouble() ?? 0.0,
      maxLimit: (data['maxLimit'] as num?)?.toDouble() ?? 0.0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      status: DealerStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => DealerStatus.pending,
      ),
      phoneNumber: data['phoneNumber'] as String? ?? '',
      currencyDirections: currencyDirections,
      passportUrl: data['passportImageUrl'] as String?,
      email: data['email'] as String?,
    );
  }

  void _handleNavigation(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: AppDrawer(
        currentRoute: DealerDashboardScreen.routeName,
        onNavigate: (route) => _handleNavigation(context, route),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        title: const Text(
          'Dealer Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dealer == null
              ? _buildNoDealerData()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildStatusCard(),
                      const SizedBox(height: 24),
                      _buildStatsSection(),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.oceanTeal.withOpacity(0.1),
                AppColors.primaryBlue.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.store_rounded,
            color: AppColors.oceanTeal,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _dealer?.name ?? 'Dealer',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _dealer?.email ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    final status = _dealer?.status ?? DealerStatus.pending;
    final statusColor = status == DealerStatus.active
        ? AppColors.success
        : status == DealerStatus.pending
            ? Colors.orange
            : Colors.red;

    final statusText = status == DealerStatus.active
        ? 'Active'
        : status == DealerStatus.pending
            ? 'Pending Approval'
            : 'Inactive';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: statusColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  status == DealerStatus.active
                      ? Icons.check_circle
                      : status == DealerStatus.pending
                          ? Icons.pending
                          : Icons.cancel,
                  color: statusColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Status',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Exchange Rates',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            if (_dealer!.supportsDirection(CurrencyDirection.audToNgn))
              _buildRateCard(
                'AUD → NGN',
                _dealer!.getRateForDirection(CurrencyDirection.audToNgn),
                Icons.trending_up,
                AppColors.primaryBlue,
              ),
            if (_dealer!.supportsDirection(CurrencyDirection.ngnToAud))
              _buildRateCard(
                'NGN → AUD',
                _dealer!.getRateForDirection(CurrencyDirection.ngnToAud),
                Icons.trending_down,
                AppColors.oceanTeal,
              ),
            _buildInfoCard(
              'Rating',
              '${_dealer!.rating.toStringAsFixed(1)} ⭐',
              Icons.star,
              Colors.amber,
            ),
            _buildInfoCard(
              'Limits',
              _dealer!.formattedLimits,
              Icons.attach_money,
              AppColors.blushPurple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRateCard(String title, String rate, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              rate,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        if (_dealer!.status == DealerStatus.active) ...[
          _buildActionCard(
            'View Messages',
            'Check your conversations with customers',
            Icons.chat_bubble_outline,
            AppColors.primaryBlue,
            () => _handleNavigation(context, ChatListScreen.routeName),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            'Update Rates',
            'Modify your exchange rates',
            Icons.edit_outlined,
            AppColors.oceanTeal,
            () {
              // TODO: Navigate to rate update screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rate update feature coming soon!'),
                ),
              );
            },
          ),
        ] else
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Your dealer account is pending approval. Once approved, you\'ll be able to manage your rates and chat with customers.',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoDealerData() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No dealer data found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your dealer account information could not be loaded.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

