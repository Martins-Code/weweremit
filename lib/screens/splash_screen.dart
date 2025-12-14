import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_theme.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import 'dealer_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const routeName = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Prevent multiple navigations
    if (_hasNavigated) {
      debugPrint('Splash: Already navigated, skipping');
      return;
    }

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted || _hasNavigated) return;

    // Check auth state and navigate
    try {
      // Get current user
      User? user = FirebaseAuth.instance.currentUser;

      // Verify the user still exists in Firebase Auth (in case they were deleted)
      if (user != null) {
        try {
          // Reload the user to verify they still exist
          await user.reload();
          user = FirebaseAuth.instance.currentUser;
          
          // Double check - if reload fails or user is null after reload, they don't exist
          if (user == null) {
            debugPrint('Splash: User was deleted, signing out');
            await FirebaseAuth.instance.signOut();
          }
        } catch (e) {
          // User doesn't exist anymore, sign out
          debugPrint('Splash: User verification failed, signing out: $e');
          await FirebaseAuth.instance.signOut();
          user = null;
        }
      }

      if (!mounted || _hasNavigated) return;

      debugPrint('Splash: User logged in: ${user != null}, UID: ${user?.uid}');

      _hasNavigated = true;

      if (user != null) {
        // User is logged in, check role and navigate accordingly
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          Widget destination;
          if (doc.exists) {
            final role = doc.data()?['role'] as String?;
            debugPrint('Splash: User role from Firestore: $role');
            if (role == 'admin') {
              debugPrint('Splash: Navigating to AdminDashboardScreen');
              destination = const AdminDashboardScreen();
            } else if (role == 'dealer' || role == 'merchant') {
              debugPrint('Splash: Navigating to DealerDashboardScreen');
              destination = const DealerDashboardScreen();
            } else {
              debugPrint('Splash: Navigating to HomeScreen (role: ${role ?? 'null'})');
              destination = const HomeScreen();
            }
          } else {
            debugPrint('Splash: No user document, navigating to HomeScreen');
            destination = const HomeScreen();
          }
          
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => destination),
              (route) => false,
            );
          }
        } catch (e) {
          debugPrint('Splash: Error checking user role: $e, defaulting to HomeScreen');
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          }
        }
      } else {
        // User is not logged in, show onboarding/login
        debugPrint('Splash: Navigating to OnboardingScreen');
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            (route) => false,
          );
        }
      }
    } catch (e, stackTrace) {
      // If there's an error, go to onboarding
      debugPrint('Error checking auth state: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (_hasNavigated) return;
      _hasNavigated = true;
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: Gradients.authBackground,
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon with glowing effect
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.oceanTeal.withOpacity(0.3),
                                AppColors.blushPurple.withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // Middle glow
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.primaryBlue.withOpacity(0.5),
                                AppColors.oceanTeal.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // Inner circle with icon
                        Container(
                          width: 100,
                          height: 100,
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
                                color: AppColors.primaryBlue.withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // App name
                    const Text(
                      'weweremit',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tagline
                    Text(
                      'Send money securely, anywhere',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

