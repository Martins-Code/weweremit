import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_theme.dart';
import '../screens/onboarding_screen.dart';

class RemitAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RemitAppBar({
    super.key,
    required this.onNavigate,
    required this.currentRoute,
    this.showAuthActions = true,
  });

  final void Function(String route) onNavigate;
  final String currentRoute;
  final bool showAuthActions;

  static const _routes = <String, String>{
    '/': 'Home',
    '/send-money': 'Send Money',
    '/marketplace': 'Marketplace',
    '/transactions': 'Transactions',
  };

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final isCompact = constraints.maxWidth < 720;

        return AppBar(
          automaticallyImplyLeading: true,
          titleSpacing: isCompact ? 0 : 24,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: Row(
            children: [
              _buildLogo(),
              if (!isCompact) const SizedBox(width: 32),
              if (!isCompact) ..._buildNavItems(context),
            ],
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: AppColors.cardBackground,
            ),
          ),
          actions: [
            if (!isCompact && showAuthActions) ...[
              Builder(
                builder: (context) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // User is logged in, show logout button
                    return TextButton.icon(
                      onPressed: () => _handleLogout(context),
                      icon: const Icon(Icons.logout, color: Colors.white, size: 18),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  } else {
                    // User is not logged in, show login/signup buttons
                    return Row(
                      children: [
                        TextButton(
                          onPressed: () => onNavigate('/login'),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            gradient: Gradients.button,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: () => onNavigate('/signup'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: const Text('Join Now'),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(width: 16),
            ],
          ],
        );
      },
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: Gradients.button,
          ),
          child: const Icon(
            Icons.currency_exchange_rounded,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'weweremit',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildNavItems(BuildContext context) {
    return _routes.entries
        .map(
          (entry) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _NavigationButton(
              label: entry.value,
              isActive: currentRoute == entry.key,
              onTap: () => onNavigate(entry.key),
            ),
          ),
        )
        .toList();
  }

  static Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: isActive
            ? BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              )
            : null,
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary.withOpacity(isActive ? 1 : 0.7),
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

