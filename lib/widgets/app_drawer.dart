import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_theme.dart';
import '../screens/onboarding_screen.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/dealer_dashboard_screen.dart';
import '../models/user_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  final String currentRoute;
  final void Function(String route) onNavigate;

  static const _routes = <String, Map<String, dynamic>>{
    '/': {
      'label': 'Home',
      'icon': Icons.home_outlined,
      'activeIcon': Icons.home,
    },
    '/send-money': {
      'label': 'Send Money',
      'icon': Icons.send_outlined,
      'activeIcon': Icons.send,
    },
    '/marketplace': {
      'label': 'Marketplace',
      'icon': Icons.store_outlined,
      'activeIcon': Icons.store,
    },
    '/transactions': {
      'label': 'Transactions',
      'icon': Icons.receipt_long_outlined,
      'activeIcon': Icons.receipt_long,
    },
    '/chats': {
      'label': 'Messages',
      'icon': Icons.chat_bubble_outline,
      'activeIcon': Icons.chat_bubble,
    },
  };

  Future<UserRole?> _getUserRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        final role = doc.data()?['role'] as String?;
        if (role == 'admin') return UserRole.admin;
        if (role == 'dealer') return UserRole.dealer;
        return UserRole.user;
      }
    } catch (e) {
      debugPrint('Error getting user role: $e');
    }
    return UserRole.user;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<UserRole?>(
      future: user != null ? _getUserRole(user.uid) : Future.value(null),
      builder: (context, snapshot) {
        final userRole = snapshot.data ?? UserRole.user;
        return _buildDrawer(context, user, userRole);
      },
    );
  }

  Widget _buildDrawer(BuildContext context, User? user, UserRole userRole) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
              AppColors.royalBlue,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with user info
              _buildHeader(context, user),
              
                      // Navigation items
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          children: [
                            ..._routes.entries.map(
                              (route) => _buildDrawerItem(
                                context,
                                route: route.key,
                                label: route.value['label'] as String,
                                icon: route.value['icon'] as IconData,
                                activeIcon: route.value['activeIcon'] as IconData,
                                isActive: currentRoute == route.key,
                              ),
                            ),
                            // Dealer dashboard link for dealers
                            if (userRole == UserRole.dealer) ...[
                              const Divider(height: 32),
                              _buildDrawerItem(
                                context,
                                route: DealerDashboardScreen.routeName,
                                label: 'Dealer Dashboard',
                                icon: Icons.store_outlined,
                                activeIcon: Icons.store,
                                isActive: currentRoute == DealerDashboardScreen.routeName,
                              ),
                            ],
                            // Admin dashboard link for admin users
                            if (userRole == UserRole.admin) ...[
                              const Divider(height: 32),
                              _buildDrawerItem(
                                context,
                                route: AdminDashboardScreen.routeName,
                                label: 'Admin Dashboard',
                                icon: Icons.admin_panel_settings_outlined,
                                activeIcon: Icons.admin_panel_settings,
                                isActive: currentRoute == AdminDashboardScreen.routeName,
                              ),
                            ],
                          ],
                        ),
                      ),

              // Logout button or Auth buttons
              _buildFooter(context, user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User? user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.oceanTeal.withOpacity(0.2),
            AppColors.primaryBlue.withOpacity(0.2),
            AppColors.blushPurple.withOpacity(0.2),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.oceanTeal,
                      AppColors.primaryBlue,
                      AppColors.blushPurple,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'weweremit',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          if (user != null) ...[
            const SizedBox(height: 20),
            // User info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.oceanTeal,
                    child: Text(
                      user.email?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.email ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Signed in',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required String route,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop(); // Close drawer
          onNavigate(route);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(
                    color: AppColors.oceanTeal.withOpacity(0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.oceanTeal.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive
                      ? AppColors.oceanTeal
                      : Colors.white.withOpacity(0.9),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : Colors.white.withOpacity(0.85),
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (isActive)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.oceanTeal,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, User? user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: user != null
          ? _buildLogoutButton(context)
          : _buildAuthButtons(context),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () => _handleLogout(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onNavigate('/login');
            },
            icon: const Icon(Icons.login, size: 20),
            label: const Text('Login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.15),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onNavigate('/signup');
            },
            icon: const Icon(Icons.person_add, size: 20),
            label: const Text('Sign Up'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.oceanTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pop(); // Close drawer
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


