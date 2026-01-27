# Firestore Indexes Setup

## Issue
Firestore requires composite indexes for queries that filter by multiple fields and order by another field. The app is currently showing `FAILED_PRECONDITION` errors because these indexes don't exist yet.

## Solution
The `firestore.indexes.json` file has been created with all required composite indexes. You need to deploy these indexes to Firebase.

## How to Deploy Indexes

### Option 1: Using Firebase CLI (Recommended)
1. Make sure you have Firebase CLI installed:
   ```bash
   npm install -g firebase-tools
   ```

2. Login to Firebase (if not already logged in):
   ```bash
   firebase login
   ```

3. Deploy the indexes:
   ```bash
   firebase deploy --only firestore:indexes
   ```

### Option 2: Using Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `foodloop-22b31`
3. Navigate to **Firestore Database** → **Indexes** tab
4. Click **Create Index** and manually create each index from `firestore.indexes.json`

### Option 3: Using the Error Link
When you see the error in the console, it provides a direct link to create the index. Click the link in the error message:
```
https://console.firebase.google.com/v1/r/project/foodloop-22b31/firestore/indexes?create_composite=...
```

## Required Indexes

The following composite indexes are defined in `firestore.indexes.json`:

1. **listings**: `status` + `expiryDate`
   - For queries filtering by status and ordering by expiry date

2. **listings**: `status` + `city` + `expiryDate`
   - For queries filtering by status and city, ordering by expiry date

3. **listings**: `status` + `foodType` + `expiryDate`
   - For queries filtering by status and food type, ordering by expiry date

4. **listings**: `status` + `city` + `foodType` + `expiryDate`
   - For queries filtering by status, city, and food type, ordering by expiry date

5. **listings**: `donorId` + `createdAt` (descending)
   - For getting donor's listings ordered by creation date

6. **requests**: `listingId` + `status` + `createdAt`
   - For getting requests for a listing filtered by status

7. **requests**: `receiverId` + `createdAt` (descending)
   - For getting receiver's requests ordered by creation date

## Index Build Time
After deploying, Firebase will build these indexes. This usually takes a few minutes. You can check the build status in the Firebase Console under **Firestore Database** → **Indexes**.

## Verification
Once the indexes are built, the `FAILED_PRECONDITION` errors should stop appearing, and your queries will work correctly.

## Note
The indexes are automatically created when you deploy using Firebase CLI. If you're using the Firebase Console or error links, you may need to create them manually.

