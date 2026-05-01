# Firestore Indexes Required

To fix the "query requires an index" error, create these indexes in Firebase Console:

## Required Composite Indexes

### 1. Products by Collection + CreatedAt
- **Collection ID**: `products`
- **Fields**:
  - `collection` (Ascending)
  - `createdAt` (Descending)

### 2. Products by CreatedAt (for sorting)
- **Collection ID**: `products`
- **Fields**:
  - `createdAt` (Descending)

## How to Create

1. Go to: https://console.firebase.google.com/project/trendify-fashion-store/firestore/indexes
2. Click "Add Index"
3. Enter collection ID: `products`
4. Add fields as specified above
5. Click "Create Index"

## Alternative: Quick Deploy

Run this command to deploy indexes:
```bash
firebase deploy --only firestore:indexes
```

Or create a `firestore.indexes.json` file and deploy it.

## Note

The app has been updated to sort products in memory instead of Firestore to avoid index errors, but creating these indexes will make queries faster and more efficient.
