# How to Create an Admin User

## Option 1: Using Firebase Console (Recommended)

1. **Create User in Firebase Authentication:**
   - Go to Firebase Console → Authentication → Users
   - Click "Add user"
   - Enter email: `admin@weweremit.com`
   - Enter password: `Admin123!` (or your preferred password)
   - Click "Add user"
   - Copy the User UID

2. **Set Role in Firestore:**
   - Go to Firebase Console → Firestore Database
   - Navigate to `users` collection
   - Click "Add document" (or find the user's document by UID)
   - Document ID: Use the User UID from step 1
   - Add these fields:
     ```
     uid: [User UID]
     email: admin@weweremit.com
     name: Admin User
     role: admin
     createdAt: [current timestamp]
     updatedAt: [current timestamp]
     ```
   - Click "Save"

## Option 2: Using Flutter Code (Development Only)

You can use the `AdminSetup` utility class:

```dart
import 'package:weweremit/utils/admin_setup.dart';

// In your code (e.g., in main.dart or a setup screen)
await AdminSetup.createAdminAccount(
  email: 'admin@weweremit.com',
  password: 'Admin123!',
  name: 'Admin User',
);
```

**OR** if the user already exists in Firebase Auth:

```dart
// Get the user's UID first, then:
await AdminSetup.setUserAsAdmin('user-uid-here');
```

## Default Admin Credentials (for Testing)

For development/testing purposes, you can use:
- **Email:** `admin@weweremit.com`
- **Password:** `Admin123!`

⚠️ **Important:** Change these credentials before deploying to production!

## Troubleshooting

If a user isn't being redirected correctly:

1. **Check Firestore user document:**
   - Ensure the `role` field exists and is set correctly (`admin`, `dealer`, or `user`)
   - Verify the document ID matches the Firebase Auth UID

2. **Check logs:**
   - The login screen now prints debug information:
     - User UID
     - Whether the document exists
     - The role found
     - Which route is being used

3. **For the dealer issue:**
   - The dealer's email is: `michael.korbly@shrinqghana.com`
   - Check in Firestore `users` collection if the document with their UID has `role: 'dealer'`
   - The code now also checks for `role: 'merchant'` as an alias

## Setting User Roles Manually in Firestore

For any user, update their document in the `users` collection:

```
users/{userId}
  - uid: {userId}
  - email: user@example.com
  - name: User Name
  - role: admin | dealer | user  ← Set this field
  - createdAt: timestamp
  - updatedAt: timestamp
```

