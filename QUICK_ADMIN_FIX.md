# Quick Fix for Admin Login

If admin login isn't working, here are steps to fix it:

## Check Console Logs

When you run the app, check the console for messages like:
- `✅ Default admin user created successfully!`
- `✅ Admin user already exists in Firestore`
- `❌ Error creating admin...`

## Manual Fix Option 1: Firebase Console (Fastest)

1. **Create Auth User:**
   - Go to Firebase Console → Authentication → Users
   - Click "Add user"
   - Email: `admin@weweremit.com`
   - Password: `Admin123!`
   - Click "Add user"
   - **Copy the User UID**

2. **Create Firestore Document:**
   - Go to Firebase Console → Firestore Database
   - Click `users` collection
   - Click "Add document"
   - **Document ID:** Paste the User UID from step 1
   - Add these fields:
     ```
     email: admin@weweremit.com
     name: Admin User
     role: admin
     uid: [same as document ID]
     createdAt: [current timestamp]
     updatedAt: [current timestamp]
     ```
   - Click "Save"

3. **Test Login:**
   - Use email: `admin@weweremit.com`
   - Use password: `Admin123!`
   - Should redirect to Admin Dashboard

## Manual Fix Option 2: Use App Code

If you want to test the automatic setup, restart the app and check the console logs. The admin should be created automatically on app startup (debug mode only).

## Troubleshooting

If login still doesn't work:

1. **Check Firestore Rules:**
   - Make sure the rules allow creating/reading user documents
   - See `FIRESTORE_SECURITY_RULES.md`

2. **Check Debug Logs:**
   - When logging in, you should see:
     ```
     Login: User UID: [uid]
     Login: User document exists: true
     Login: User role from Firestore: admin
     Login: Redirecting to Admin Dashboard
     ```

3. **Verify Role:**
   - In Firestore, check that the `role` field is exactly `admin` (lowercase, no spaces)

4. **Clear App Data:**
   - Sometimes cached auth state can cause issues
   - Clear app data or reinstall the app

