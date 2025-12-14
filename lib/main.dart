import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'app_theme.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_setup_screen.dart';
import 'screens/chat_detail_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/dealer_dashboard_screen.dart';
import 'screens/dealer_signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/send_money_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/transactions_screen.dart';
import 'utils/admin_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Automatically create default admin user (only in debug mode)
    // This runs in background - check console for status
    if (kDebugMode) {
      _setupDefaultAdmin().catchError((e) {
        debugPrint('Admin setup error: $e');
      });
    }
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Continue anyway - Firebase might already be initialized
  }
  runApp(const WeweremitApp());
}

/// Sets up default admin user automatically (debug mode only)
Future<void> _setupDefaultAdmin() async {
  try {
    const adminEmail = 'admin@weweremit.com';
    const adminPassword = 'Admin123!';
    const adminName = 'Admin User';

    debugPrint('🔧 Checking for default admin user...');

    // First, check if user exists in Firestore by email (more reliable)
    try {
      final usersQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: adminEmail)
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      if (usersQuery.docs.isNotEmpty) {
        final userDoc = usersQuery.docs.first;
        debugPrint('✅ Admin user already exists in Firestore');
        debugPrint('   UID: ${userDoc.id}');
        debugPrint('   Email: $adminEmail');
        return;
      }
    } catch (e) {
      debugPrint('⚠️  Error checking for existing admin: $e');
    }

    // Try to create admin account
    try {
      debugPrint('Creating default admin user...');
      await AdminSetup.createAdminAccount(
        email: adminEmail,
        password: adminPassword,
        name: adminName,
      );
      debugPrint('✅ Default admin user created successfully!');
      debugPrint('   Email: $adminEmail');
      debugPrint('   Password: $adminPassword');
      debugPrint('   ⚠️  Change these credentials before production!');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // User exists in Auth but might not have Firestore document
        debugPrint('⚠️  User exists in Auth, checking Firestore...');
        try {
          // Try to sign in to get UID
          final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: adminEmail,
            password: adminPassword,
          );
          final uid = credential.user?.uid;
          if (uid != null) {
            // Check if user document exists
            final doc = await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .get();
            
            if (!doc.exists) {
              // Create user document with admin role
              await FirebaseFirestore.instance.collection('users').doc(uid).set({
                'uid': uid,
                'name': adminName,
                'email': adminEmail,
                'role': 'admin',
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              });
              debugPrint('✅ Created Firestore document for existing admin user');
            } else {
              // Update existing document to ensure admin role
              await FirebaseFirestore.instance.collection('users').doc(uid).update({
                'role': 'admin',
                'updatedAt': FieldValue.serverTimestamp(),
              });
              debugPrint('✅ Updated existing user document to admin role');
            }
          }
          await FirebaseAuth.instance.signOut();
        } catch (setupError) {
          debugPrint('❌ Error setting up existing admin: $setupError');
        }
      } else {
        debugPrint('❌ Error creating admin: ${e.code} - ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ Could not create default admin: $e');
      debugPrint('   You may need to create admin manually via Firebase Console');
    }
  } catch (e) {
    debugPrint('❌ Fatal error in admin setup: $e');
  }
}

class WeweremitApp extends StatelessWidget {
  const WeweremitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'weweremit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const SplashScreen(),
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    // Handle null or empty route names
    final routeName = settings.name ?? HomeScreen.routeName;

    switch (routeName) {
      case HomeScreen.routeName:
        return _materialRoute(const HomeScreen(), settings);
      case SendMoneyScreen.routeName:
        return _materialRoute(const SendMoneyScreen(), settings);
      case MarketplaceScreen.routeName:
        return _materialRoute(const MarketplaceScreen(), settings);
      case TransactionsScreen.routeName:
        return _materialRoute(const TransactionsScreen(), settings);
      case LoginScreen.routeName:
        return _materialRoute(const LoginScreen(), settings);
      case SignUpScreen.routeName:
        return _materialRoute(const SignUpScreen(), settings);
      case SplashScreen.routeName:
        return _materialRoute(const SplashScreen(), settings);
      case OnboardingScreen.routeName:
        return _materialRoute(const OnboardingScreen(), settings);
      case ForgotPasswordScreen.routeName:
        return _materialRoute(const ForgotPasswordScreen(), settings);
      case ChatListScreen.routeName:
        return _materialRoute(const ChatListScreen(), settings);
      case ChatDetailScreen.routeName:
        return _materialRoute(const ChatDetailScreen(), settings);
      case DealerSignupScreen.routeName:
        return _materialRoute(const DealerSignupScreen(), settings);
      case DealerDashboardScreen.routeName:
        return _materialRoute(const DealerDashboardScreen(), settings);
      case AdminDashboardScreen.routeName:
        return _materialRoute(const AdminDashboardScreen(), settings);
      case AdminSetupScreen.routeName:
        return _materialRoute(const AdminSetupScreen(), settings);
      default:
        return _materialRoute(
          const HomeScreen(),
          RouteSettings(
            name: HomeScreen.routeName,
            arguments: settings.arguments,
          ),
        );
    }
  }

  PageRouteBuilder<dynamic> _materialRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
