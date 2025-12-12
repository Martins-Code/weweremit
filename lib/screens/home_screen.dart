import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../widgets/remit_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: RemitAppBar(
        currentRoute: routeName,
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
        borderRadius: BorderRadius.circular(24),
        gradient: Gradients.hero,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.25),
            blurRadius: 32,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send Money to Nigeria with Confidence',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Fast, secure, and transparent remittance marketplace connecting Australia to Nigeria.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _GradientCtaButton(
                label: 'Send Money Now',
                onTap: () => _handleNavigation(context, '/send-money'),
              ),
              TextButton(
                onPressed: () => _handleNavigation(context, '/marketplace'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Browse Dealer Marketplace'),
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
      ),
      (
        icon: Icons.verified_user_rounded,
        title: 'Secure & Safe',
        description:
            'All transactions are encrypted and verified every step of the way.',
      ),
      (
        icon: Icons.public_rounded,
        title: 'Global Network',
        description:
            'Trusted dealer network across Nigeria with instant delivery.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Why Choose RemitHub?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
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
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: Gradients.cardAccent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  item.icon,
                                  color: AppColors.primaryBlue,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item.description,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
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
    return Container(
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
            'Join thousands of users who trust RemitHub for their remittance needs.',
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
    );
  }

  void _handleNavigation(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.of(context).pushNamed(route);
  }
}

class _GradientCtaButton extends StatelessWidget {
  const _GradientCtaButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: Gradients.button,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(label),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: Gradients.cardAccent,
              ),
              child: Icon(icon, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
              ),
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
