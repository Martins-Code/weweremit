# Firestore Security Rules

Copy and paste these rules into your Firebase Console under Firestore Database > Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user is the owner of the document
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Helper function to check if user is admin
    function isAdmin() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Users collection
    match /users/{userId} {
      // Users can read their own data
      allow read: if isOwner(userId);
      
      // Users can create their own user document during signup
      allow create: if isOwner(userId) && 
                       request.resource.data.keys().hasAll(['uid', 'name', 'email', 'role']) &&
                       request.resource.data.uid == request.auth.uid;
      
      // Users can update their own data (except role)
      allow update: if isOwner(userId) && 
                       (!request.resource.data.diff(resource.data).affectedKeys().hasAny(['role']) ||
                        resource.data.role == request.resource.data.role);
      
      // Admins can read and update any user
      allow read, update: if isAdmin();
      
      // Users cannot delete their own documents
      allow delete: if false;
    }
    
    // Dealers collection
    match /dealers/{dealerId} {
      // Anyone can read active dealers, or dealers can read their own document
      allow read: if resource.data.status == 'active' || 
                     (isAuthenticated() && resource.data.userId == request.auth.uid) || 
                     isAdmin();
      
      // Authenticated users can create their own dealer document during signup
      allow create: if isAuthenticated() && 
                       dealerId == request.auth.uid &&
                       request.resource.data.userId == request.auth.uid &&
                       request.resource.data.keys().hasAll(['userId', 'name', 'email', 'status', 'currencyDirections', 'exchangeRates']) &&
                       request.resource.data.status == 'pending';
      
      // Dealers can update their own document (but cannot change status)
      allow update: if isAuthenticated() &&
                       resource.data.userId == request.auth.uid &&
                       (!request.resource.data.diff(resource.data).affectedKeys().hasAny(['status']) ||
                        resource.data.status == request.resource.data.status);
      
      // Only admins can update dealer status or any dealer document
      allow update: if isAdmin();
      
      // Only admins can delete dealers
      allow delete: if isAdmin();
    }
    
    // Admin settings collection
    match /admin/{document=**} {
      // Only admins can read admin settings
      allow read: if isAdmin();
      
      // Only admins can write admin settings
      allow write: if isAdmin();
    }
    
    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

