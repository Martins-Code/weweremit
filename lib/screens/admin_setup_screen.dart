import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_theme.dart';
import '../utils/admin_setup.dart';
import 'admin_dashboard_screen.dart';

/// Temporary screen to manually create admin user
/// Remove this before production!
class AdminSetupScreen extends StatefulWidget {
  const AdminSetupScreen({super.key});

  static const routeName = '/admin-setup';

  @override
  State<AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends State<AdminSetupScreen> {
  bool _isLoading = false;
  String _statusMessage = '';
  bool _isSuccess = false;

  Future<void> _createAdmin() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Creating admin user...';
      _isSuccess = false;
    });

    const adminEmail = 'admin@weweremit.com';
    const adminPassword = 'Admin123!';
    const adminName = 'Admin User';

    try {
      // First try to sign in - if user exists, we'll update their role
      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
        
        final uid = credential.user?.uid;
        if (uid != null) {
          // User exists in Auth, check and update Firestore
          debugPrint('Admin user exists in Auth. UID: $uid');
          debugPrint('Setting role in Firestore...');
          
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'uid': uid,
            'name': adminName,
            'email': adminEmail,
            'role': 'admin',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          
          debugPrint('✅ Firestore document created/updated with admin role');
          
          setState(() {
            _statusMessage = '✅ Admin user configured successfully!\n\nEmail: $adminEmail\nPassword: $adminPassword\n\nYou can now log in.';
            _isSuccess = true;
            _isLoading = false;
          });
          
          // Sign out and let them log in manually
          await FirebaseAuth.instance.signOut();
          
          // Show message for 3 seconds, then navigate to login
          await Future.delayed(const Duration(seconds: 3));
          if (mounted) {
            Navigator.of(context).pop(); // Go back to login
          }
          return;
        }
      } on FirebaseAuthException catch (authError) {
        if (authError.code == 'user-not-found' || authError.code == 'wrong-password') {
          // User doesn't exist or wrong password, create new one
          debugPrint('User not found, creating new admin account...');
        } else {
          rethrow;
        }
      }

      // User doesn't exist, create new account
      await AdminSetup.createAdminAccount(
        email: adminEmail,
        password: adminPassword,
        name: adminName,
      );

      setState(() {
        _statusMessage = '✅ Admin user created successfully!\n\nEmail: $adminEmail\nPassword: $adminPassword\n\nAuto-logging in...';
        _isSuccess = true;
        _isLoading = false;
      });

      // Auto login after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
        
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AdminDashboardScreen.routeName);
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _statusMessage = '❌ Auth Error: ${e.code}\n${e.message}\n\nPlease check:\n1. User exists in Firebase Auth\n2. Password is correct\n3. Firestore rules allow writes';
        _isSuccess = false;
        _isLoading = false;
      });
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
    } catch (e, stackTrace) {
      setState(() {
        _statusMessage = '❌ Error: ${e.toString()}\n\nCheck console for details.';
        _isSuccess = false;
        _isLoading = false;
      });
      debugPrint('Error creating admin: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Admin Setup'),
        backgroundColor: AppColors.cardBackground,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings,
                size: 64,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Create Admin User',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This will create a default admin user for testing.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              if (_statusMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: _isSuccess
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isSuccess ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _isSuccess ? Colors.green.shade800 : Colors.red.shade800,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createAdmin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Create Admin User',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Default Credentials:\nEmail: admin@weweremit.com\nPassword: Admin123!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

