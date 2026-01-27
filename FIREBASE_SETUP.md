# Firebase Setup Guide for FoodLoop

## Firestore Security Rules

The `firestore.rules` file contains security rules for your FoodLoop app. These rules need to be deployed to Firebase for your app to work properly.

### Deploying Firestore Rules

1. **Install Firebase CLI** (if not already installed):
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Initialize Firebase in your project** (if not already done):
   ```bash
   firebase init firestore
   ```
   - Select your Firebase project: `foodloop-22b31`
   - Use the existing `firestore.rules` file

4. **Deploy the rules**:
   ```bash
   firebase deploy --only firestore:rules
   ```

### What the Rules Do

- **Users Collection**: 
  - Authenticated users can read/write their own user document
  - Admins can read all user documents
  - Users cannot change their `uid` or `email` after creation

- **Listings Collection** (for future Module 3):
  - All authenticated users can read available listings
  - Users can create listings (must set `donorId` to their own uid)
  - Users can update their own listings
  - Admins can update/delete any listing

- **Requests Collection** (for future Module 4):
  - Users can read requests related to their listings or their own requests
  - Users can create requests
  - Users can update their own requests or requests for their listings
  - Admins have full access

- **Complaints Collection** (for future Module 5):
  - Users can create and read their own complaints
  - Admins can read/update all complaints

### Testing Rules

After deploying, test your rules using the Firebase Console:
1. Go to Firebase Console → Firestore Database → Rules
2. Use the Rules Playground to test different scenarios

### Important Notes

- **Cloudinary for Images**: The app uses Cloudinary for image storage (not Firebase Storage), so no storage rules are needed.
- **Authentication Required**: All operations require the user to be authenticated via Firebase Auth.
- **Admin Role**: To make a user an admin, manually set `role: "admin"` in their Firestore user document.

