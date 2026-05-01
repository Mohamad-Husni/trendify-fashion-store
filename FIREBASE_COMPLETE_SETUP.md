# TRENDIFY - Complete Firebase Backend Setup

## ✅ Firebase Project Configuration

**Project ID:** `trendify-fashion-store`
**Region:** `asia-south1` (Mumbai)

---

## 📊 Firestore Database Structure

### Collections Overview

```
users (collection)
  └── {userId} (document)
      ├── name: string
      ├── email: string
      ├── phone: string
      ├── createdAt: timestamp
      ├── addresses (subcollection)
      │   └── {addressId}
      │       ├── fullName: string
      │       ├── phone: string
      │       ├── streetAddress: string
      │       ├── city: string
      │       ├── state: string
      │       ├── postalCode: string
      │       ├── country: string
      │       ├── label: string (Home/Work)
      │       ├── isDefault: boolean
      │       └── createdAt: timestamp
      ├── orders (subcollection)
      │   └── {orderId}
      │       ├── items: array
      │       ├── total: number
      │       ├── status: string (pending/processing/shipped/delivered/cancelled)
      │       ├── shippingAddress: map
      │       ├── paymentMethod: string
      │       ├── trackingNumber: string
      │       ├── createdAt: timestamp
      │       └── updatedAt: timestamp
      └── wishlist (subcollection)
          └── items (document)
              ├── productIds: array
              └── updatedAt: timestamp

products (collection)
  └── {productId} (document)
      ├── id: string
      ├── title: string
      ├── collection: string
      ├── description: string
      ├── price: number
      ├── imageUrl: string
      ├── rating: number
      ├── sizes: array
      ├── colors: array
      ├── createdAt: timestamp
      └── reviews (subcollection)
          └── {reviewId}
              ├── userId: string
              ├── userName: string
              ├── rating: number
              ├── comment: string
              ├── createdAt: timestamp
```

---

## 🔒 Firestore Security Rules

Go to: https://console.firebase.google.com/project/trendify-fashion-store/firestore/rules

Replace with these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the document
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // Users collection
    match /users/{userId} {
      allow read, write: if isOwner(userId);
      
      // User addresses subcollection
      match /addresses/{addressId} {
        allow read, write: if isOwner(userId);
      }
      
      // User orders subcollection
      match /orders/{orderId} {
        allow read, write: if isOwner(userId);
      }
      
      // User wishlist subcollection
      match /wishlist/{wishlistId} {
        allow read, write: if isOwner(userId);
      }
    }

    // Products collection - Public read, Admin write
    match /products/{productId} {
      allow read: if true;
      allow write: if isAuthenticated(); // Restrict to admin in production
    }
    
    // Product reviews - Public read, Authenticated write
    match /products/{productId}/reviews/{reviewId} {
      allow read: if true;
      allow write: if isAuthenticated();
    }
  }
}
```

**Click "Publish" to apply rules**

---

## 🔐 Firebase Authentication Setup

### Enable Authentication Methods

1. Go to: https://console.firebase.google.com/project/trendify-fashion-store/authentication

2. **Enable Email/Password:**
   - Click "Get Started"
   - Find "Email/Password" provider
   - Toggle to **Enabled**
   - Click "Save"

3. **Additional Providers (Optional):**
   - Google Sign-In (for quick login)
   - Apple Sign-In (required for iOS apps)

---

## 🗂️ Create Firestore Indexes

### Required Indexes for Queries

Go to: https://console.firebase.google.com/project/trendify-fashion-store/firestore/indexes

Create these composite indexes:

#### Index 1: Products by Collection + Created
```
Collection: products
Fields:
  - collection (Ascending)
  - createdAt (Descending)
```

#### Index 2: Products by Price
```
Collection: products
Fields:
  - price (Ascending)
```

#### Index 3: Products by Rating
```
Collection: products
Fields:
  - rating (Descending)
```

#### Index 4: User Orders by Date
```
Collection: users/{userId}/orders
Fields:
  - createdAt (Descending)
```

#### Index 5: Orders by Status
```
Collection: users/{userId}/orders
Fields:
  - status (Ascending)
  - createdAt (Descending)
```

---

## 📱 Firebase App Configuration

### For Android
Already configured in `android/app/google-services.json`

### For iOS
Update `ios/Runner/GoogleService-Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CLIENT_ID</key>
    <string>YOUR_CLIENT_ID</string>
    <key>REVERSED_CLIENT_ID</key>
    <string>YOUR_REVERSED_CLIENT_ID</string>
    <key>API_KEY</key>
    <string>YOUR_API_KEY</string>
    <key>GCM_SENDER_ID</key>
    <string>YOUR_SENDER_ID</string>
    <key>PLIST_VERSION</key>
    <string>1</string>
    <key>BUNDLE_ID</key>
    <string>com.trendify.fashion</string>
    <key>PROJECT_ID</key>
    <string>trendify-fashion-store</string>
    <key>STORAGE_BUCKET</key>
    <string>trendify-fashion-store.appspot.com</string>
    <key>IS_ADS_ENABLED</key>
    <false></false>
    <key>IS_ANALYTICS_ENABLED</key>
    <true></true>
    <key>IS_APPINVITE_ENABLED</key>
    <true></true>
    <key>IS_GCM_ENABLED</key>
    <true></true>
    <key>IS_SIGNIN_ENABLED</key>
    <true></true>
    <key>GOOGLE_APP_ID</key>
    <string>YOUR_GOOGLE_APP_ID</string>
</dict>
</plist>
```

**Get your config from:**
https://console.firebase.google.com/project/trendify-fashion-store/settings/general

---

## 🚀 Firebase Hosting Configuration

Already configured in `firebase.json`:

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

---

## 📦 Backend Features Implemented

### ✅ Authentication
- Email/Password signup/login
- User profile creation in Firestore
- Secure session management

### ✅ Product Catalog
- Product listing from Firestore
- Real-time product updates
- Image loading from URLs
- Category filtering

### ✅ Shopping Cart
- Local cart management
- Add/remove items
- Quantity updates
- Size/color selection

### ✅ Wishlist
- Add/remove favorites
- Persistent storage per user
- Wishlist screen with products

### ✅ Address Management
- Save multiple addresses
- Default address selection
- Address editing/deletion
- Checkout address auto-fill

### ✅ Orders
- Order placement with Firestore
- Order status tracking
- Order history per user
- Cancel order functionality

### ✅ Search
- Full-text product search
- Category, price, rating filters
- Sort by newest, price, rating

---

## 🧪 Testing Backend Connectivity

### Test Script (Run in app):

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> testBackend() async {
  try {
    // Test Firestore connection
    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .limit(1)
        .get();
    print('✅ Firestore connected: ${snapshot.docs.length} products found');
    
    // Test Auth
    final user = FirebaseAuth.instance.currentUser;
    print(user != null ? '✅ User logged in: ${user.email}' : 'ℹ️ No user logged in');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

---

## ⚠️ Security Checklist

- [x] Firestore rules restrict user data access
- [x] Authentication required for sensitive operations
- [x] Test mode expires May 27, 2026 - UPDATE BEFORE EXPIRY
- [ ] Enable App Check for production
- [ ] Set up Firebase Analytics
- [ ] Configure Firebase Crashlytics

---

## 📞 Troubleshooting

### "Permission Denied" Errors
→ Check Firestore security rules are published

### "Authentication Required" Errors
→ Ensure user is logged in before accessing user data

### Missing Data
→ Verify Firestore collections are created with correct structure

### Slow Queries
→ Check composite indexes are created in Firebase Console

---

**Your Firebase backend is now fully configured! 🎉**
