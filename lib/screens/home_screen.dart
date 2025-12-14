import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../app_theme.dart';
import '../widgets/remit_app_bar.dart';
import '../widgets/app_drawer.dart';
import '../models/user_model.dart';
import 'dealer_signup_screen.dart';
import 'admin_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserRole? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final role = doc.data()?['role'] as String?;
          setState(() {
            if (role == 'admin') {
              _userRole = UserRole.admin;
            } else if (role == 'dealer') {
              _userRole = UserRole.dealer;
            } else {
              _userRole = UserRole.user;
            }
          });
        }
      } catch (e) {
        debugPrint('Error loading user role: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
              drawer: AppDrawer(
        currentRoute: HomeScreen.routeName,
        onNavigate: (route) => _handleNavigation(context, route),
      ),
      appBar: RemitAppBar(
        currentRoute: HomeScreen.routeName,
        onNavigate: (route) => _handleNavigation(context, route),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final horizontalPadding = maxWidth > 1200
              ? (maxWidth - 1100) / 2
              : maxWidth > 900
              ? 60.0
              : 24.0;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(context),
                const SizedBox(height: 40),
                _buildWhyChooseSection(context),
                const SizedBox(height: 48),
                _buildRecommendedActions(context),
                const SizedBox(height: 48),
                _buildTrustedDealersBanner(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: Gradients.hero,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send Money to Nigeria\nwith Confidence',
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Fast, secure, and transparent remittance marketplace connecting Australia to Nigeria.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 18,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _GradientCtaButton(
                label: 'Send Money Now',
                icon: Icons.send_rounded,
                onTap: () => _handleNavigation(context, '/send-money'),
              ),
              OutlinedButton.icon(
                onPressed: () => _handleNavigation(context, '/marketplace'),
                icon: const Icon(Icons.store_rounded, size: 20),
                label: const Text(
                  'Browse Marketplace',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.3), width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseSection(BuildContext context) {
    const options = [
      (
        icon: Icons.auto_graph_rounded,
        title: 'Best Rates',
        description:
            'Compare rates from multiple dealers and get the best exchange rate.',
        color: AppColors.primaryBlue,
      ),
      (
        icon: Icons.verified_user_rounded,
        title: 'Secure & Safe',
        description:
            'All transactions are encrypted and verified every step of the way.',
        color: AppColors.oceanTeal,
      ),
      (
        icon: Icons.public_rounded,
        title: 'Global Network',
        description:
            'Trusted dealer network across Nigeria with instant delivery.',
        color: AppColors.blushPurple,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Why Choose weweremit?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Everything you need for seamless money transfers',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            return Wrap(
              spacing: 24,
              runSpacing: 24,
              children: options
                  .map(
                    (item) => SizedBox(
                      width: isWide
                          ? (constraints.maxWidth / 3) - 18
                          : double.infinity,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
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
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: item.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Icon(
                                    item.icon,
                                    color: item.color,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item.description,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    height: 1.6,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecommendedActions(BuildContext context) {
    final actions = [
      _RecommendedAction(
        icon: Icons.quickreply_rounded,
        title: 'Start a Transfer',
        description:
            'Use the calculator to find the best exchange rate instantly.',
        buttonLabel: 'Calculate Rate',
        onTap: () => _handleNavigation(context, '/send-money'),
      ),
      _RecommendedAction(
        icon: Icons.storefront_rounded,
        title: 'Compare Dealers',
        description:
            'Explore verified dealers and pick the perfect partner for your transfer.',
        buttonLabel: 'View Marketplace',
        onTap: () => _handleNavigation(context, '/marketplace'),
      ),
      _RecommendedAction(
        icon: Icons.receipt_long_rounded,
        title: 'Track Transactions',
        description:
            'Stay on top of your transfers and download detailed reports.',
        buttonLabel: 'View History',
        onTap: () => _handleNavigation(context, '/transactions'),
      ),
      // Show dealer registration option for regular users only
      if (_userRole == UserRole.user || _userRole == null)
        _RecommendedAction(
          icon: Icons.store_rounded,
          title: 'Become a Dealer',
          description: 'Join our network and start exchanging currencies',
          buttonLabel: 'Register Now',
          onTap: () => Navigator.of(context).pushNamed(DealerSignupScreen.routeName),
        ),
      // Show admin dashboard link for admins
      if (_userRole == UserRole.admin)
        _RecommendedAction(
          icon: Icons.admin_panel_settings_rounded,
          title: 'Admin Dashboard',
          description: 'Manage platform settings and approvals',
          buttonLabel: 'Go to Dashboard',
          onTap: () => Navigator.of(context).pushNamed(AdminDashboardScreen.routeName),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommended Actions',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 880;
            return Wrap(
              spacing: 24,
              runSpacing: 24,
              children: actions
                  .map(
                    (action) => SizedBox(
                      width: isWide
                          ? (constraints.maxWidth / 3) - 18
                          : double.infinity,
                      child: action,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrustedDealersBanner(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          decoration: BoxDecoration(
            gradient: Gradients.button,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ready to Send Money?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join thousands of users who trust weweremit for their remittance needs.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.88),
                ),
              ),
              const SizedBox(height: 24),
              _GradientCtaButton(
                label: 'Get Started',
                onTap: () => _handleNavigation(context, '/signup'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Merchant/Dealer Signup Banner
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.oceanTeal.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.oceanTeal.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: isWide
                  ? Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.oceanTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.store_rounded,
                            color: AppColors.oceanTeal,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Are you a Currency Dealer?',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Join our network and start offering competitive exchange rates to users.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pushNamed(DealerSignupScreen.routeName),
                          icon: const Icon(Icons.person_add_rounded),
                          label: const Text(
                            'Become a Dealer',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.oceanTeal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.oceanTeal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.store_rounded,
                                color: AppColors.oceanTeal,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'Are you a Currency Dealer?',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Join our network and start offering competitive exchange rates to users.',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pushNamed(DealerSignupScreen.routeName),
                            icon: const Icon(Icons.person_add_rounded),
                            label: const Text(
                              'Become a Dealer',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.oceanTeal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
      ],
    );
  }

  void _handleNavigation(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.of(context).pushNamed(route);
  }
}

class _GradientCtaButton extends StatelessWidget {
  const _GradientCtaButton({
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
        onPressed: onTap,
        icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}

class _RecommendedAction extends StatelessWidget {
  const _RecommendedAction({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryBlue.withOpacity(0.1),
                      AppColors.oceanTeal.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryBlue,
                  size: 28,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.6,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(buttonLabel),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
