# Firebase Security Rules Setup Guide

## Issues Fixed

1. **Image Picker Error**: Added `_isPickingImage` flag to prevent multiple simultaneous image picker calls
2. **Firestore Permission Error**: Updated dealer signup code to match the expected Firestore document structure
3. **Storage Permission Error**: Created Firebase Storage rules for passport image uploads

## Steps to Fix the Errors

### 1. Update Firestore Security Rules

Go to Firebase Console → Firestore Database → Rules tab and replace the existing rules with the content from `FIRESTORE_SECURITY_RULES.md`.

**Key Features:**
- Authenticated users can create their own user document
- Authenticated users can create their own dealer document (with status='pending')
- Dealers can update their own document (except status)
- Only admins can approve/reject dealers (change status)
- Anyone can read active dealers
- Only dealers can read their own pending/inactive dealer documents

### 2. Update Firebase Storage Rules

Go to Firebase Console → Storage → Rules tab and replace the existing rules with the content from `FIREBASE_STORAGE_RULES.md`.

**Key Features:**
- Authenticated users can upload their own passport image (max 5MB, image files only)
- Authenticated users can read passport images (you may want to restrict this further for production)

### 3. Code Changes Made

1. **Fixed Image Picker** (`lib/screens/dealer_signup_screen.dart`):
   - Added `_isPickingImage` flag to prevent concurrent picker calls
   - Added error handling for image picker

2. **Fixed Firestore Document Structure** (`lib/screens/dealer_signup_screen.dart`):
   - Changed `passportUrl` to `passportImageUrl` (matches Dealer model)
   - Changed to use `exchangeRates` map instead of separate fields
   - Changed `uid` to `userId` (matches security rules expectations)

## Important Notes

1. **Storage Rules Limitation**: Firebase Storage rules cannot directly check Firestore to verify if a user is admin. The current rules allow all authenticated users to read passport images. For production, consider:
   - Using Cloud Functions to verify access
   - Storing download URLs in Firestore and controlling access through Firestore rules
   - Using a backend server for image access control

2. **Testing**: After updating the rules, test the dealer signup flow to ensure:
   - Image upload works
   - Firestore write succeeds
   - User document is created
   - Dealer document is created with status='pending'

3. **Admin Approval**: After a dealer signs up, they need admin approval before they can:
   - Be seen in the marketplace
   - Have their status changed from 'pending' to 'active'
   - Access dealer-specific features

## Verification

After applying the rules, try signing up as a dealer again. You should see:
- ✅ No image picker errors
- ✅ Successful passport image upload
- ✅ Successful Firestore write for dealer document
- ✅ Successful Firestore write for user document
- ✅ Navigation to home screen with success message

