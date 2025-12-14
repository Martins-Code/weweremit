# Fix Dealer/Merchant Role Issue

## Problem
If a dealer/merchant is being redirected to the user home page instead of the dealer dashboard after login, their role in Firestore is not set correctly.

## Solution

### For the user: michael.korbly@shrinqghana.com

1. **Find the User UID:**
   - Go to Firebase Console → Authentication → Users
   - Search for `michael.korbly@shrinqghana.com`
   - Copy the User UID

2. **Update Role in Firestore:**
   - Go to Firebase Console → Firestore Database
   - Navigate to `users` collection
   - Find the document with ID = [User UID from step 1]
   - Click on the document to edit it
   - Update the `role` field to: `dealer` (or `merchant` - both work)
   - Click "Update"

3. **Verify:**
   - The document should have these fields:
     ```
     uid: [User UID]
     email: michael.korbly@shrinqghana.com
     name: [User's name]
     role: dealer  ← This is the important field
     createdAt: [timestamp]
     updatedAt: [timestamp]
     ```

4. **Test:**
   - Log out and log back in
   - The user should now be redirected to the Dealer Dashboard

## Alternative: Using Firebase Console UI

1. Go to Firebase Console → Firestore Database
2. Click on `users` collection
3. Find the user document (you can search by email in the console)
4. Click on the document
5. Edit the `role` field
6. Change it to: `dealer`
7. Save

## Quick Check

To verify a user's current role, check the debug logs when logging in. You should see:
```
Login: User role from Firestore: dealer
Login: Redirecting to Dealer Dashboard
```

If you see `Login: User role from Firestore: null` or `Login: User role from Firestore: user`, then the role needs to be updated.

