# Firebase Storage Security Rules

Copy and paste these rules into your Firebase Console under Storage > Rules:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the file
    function isOwner(userId) {
      return isAuthenticated() && userId == request.auth.uid;
    }
    
    // Dealer passport images
    match /dealer_passports/{userId}.jpg {
      // Users can upload their own passport image during signup
      allow write: if isOwner(userId) && 
                      request.resource.size < 5 * 1024 * 1024 && // Max 5MB
                      request.resource.contentType.matches('image/.*');
      
      // Only the owner and admins can read passport images
      // Note: This requires checking the user's role, which needs Firestore read
      // For now, we'll allow authenticated users to read, but you should enhance this
      // to check if the user is admin by reading from Firestore
      allow read: if isAuthenticated();
    }
    
    // Deny all other access
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

## Important Notes:

1. **Storage Rules Limitation**: Firebase Storage rules cannot directly access Firestore to check user roles. If you need stricter access control for reading passport images (only admins and the owner), you'll need to:
   - Use Cloud Functions to verify access before generating download URLs, OR
   - Store download URLs in Firestore and control access through Firestore rules, OR
   - Use a backend server to handle image access

2. **Image Size Limit**: The rules limit passport images to 5MB. Adjust this value if needed.

3. **Content Type**: Only image files are allowed. The pattern `image/.*` matches all image types (jpg, png, etc.).

4. **Testing**: After updating the rules, test dealer signup to ensure uploads work correctly.

