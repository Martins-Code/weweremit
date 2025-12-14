import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility class to help set up admin users
/// 
/// IMPORTANT: This should only be used during initial setup.
/// For production, create admin users manually through Firebase Console
/// or use Cloud Functions for better security.
class AdminSetup {
  AdminSetup._();

  /// Creates an admin user in Firestore
  /// 
  /// This should be called after creating a user with Firebase Auth.
  static Future<void> setUserAsAdmin(String uid, {String? email, String? name}) async {
    try {
      final data = <String, dynamic>{
        'uid': uid,
        'role': 'admin',
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (email != null) data['email'] = email;
      if (name != null) data['name'] = name;
      
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        data,
        SetOptions(merge: true),
      );
      print('✅ User $uid has been set as admin');
    } catch (e) {
      print('❌ Error setting user as admin: $e');
      rethrow;
    }
  }

  /// Creates an admin user account (Auth + Firestore)
  /// 
  /// WARNING: Only use this during development/setup!
  /// For production, use Firebase Console to create admin accounts.
  static Future<void> createAdminAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // 1. Create user in Firebase Auth
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create user');
      }

      // 2. Set user as admin in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Admin account created successfully!');
      print('   Email: $email');
      print('   UID: ${user.uid}');
      print('   Role: admin');
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth error creating admin: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Error creating admin account: $e');
      rethrow;
    }
  }

  /// Checks if a user is an admin
  static Future<bool> isAdmin(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      return doc.exists && doc.data()?['role'] == 'admin';
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  /// Checks if admin user exists by email
  static Future<bool> adminExistsByEmail(String email) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if admin exists: $e');
      return false;
    }
  }
}

