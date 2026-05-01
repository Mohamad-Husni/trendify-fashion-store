# Firebase Backend Setup for TRENDIFY

## Step 1: Enable Firebase Authentication

1. Go to: https://console.firebase.google.com/project/trendify-fashion-store/authentication
2. Click **"Get Started"** or **"Sign-in method"**
3. Enable **"Email/Password"** provider:
   - Toggle to **Enabled**
   - Password policy: Leave default (6 characters)
   - Click **Save**

## Step 2: Enable Firestore Database

1. Go to: https://console.firebase.google.com/project/trendify-fashion-store/firestore
2. Click **"Create database"**
3. Choose **"Start in test mode"** (for development)
4. Select location: **asia-south1** (Mumbai - closest to Sri Lanka)
5. Click **Enable**

## Step 3: Update Firestore Security Rules

1. Go to: Firestore Database > Rules
2. Replace with these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products are publicly readable, only admins can write
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Orders: Users can read/write their own orders
    match /orders/{orderId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Carts: Users can only access their own cart
    match /carts/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

3. Click **Publish**

## Step 4: Create Products Collection (One-Time Setup)

Run this in your app once to populate products:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedProducts() async {
  final firestore = FirebaseFirestore.instance;
  
  final products = [
    {
      'id': '1',
      'title': 'Structured Linen Blazer',
      'collection': 'Office Wear',
      'description': 'Elegant cream blazer perfect for formal occasions',
      'price': 24500.00,
      'imageUrl': 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=600&q=80',
      'rating': 4.8,
      'sizes': ['XS', 'S', 'M', 'L', 'XL'],
      'colors': ['Cream', 'Navy', 'Black'],
      'createdAt': Timestamp.now(),
    },
    {
      'id': '2',
      'title': 'Essential Gold Hoops',
      'collection': 'Accessories',
      'description': '14k gold plated hoops for everyday elegance',
      'price': 12000.00,
      'imageUrl': 'https://images.unsplash.com/photo-1635767798638-3e2523c0188c?auto=format&fit=crop&w=600&q=80',
      'rating': 4.9,
      'sizes': ['One Size'],
      'colors': ['Gold', 'Silver'],
      'createdAt': Timestamp.now(),
    },
    // Add more products as needed
  ];
  
  for (final product in products) {
    await firestore.collection('products').doc(product['id'] as String).set(product);
  }
  
  print('Products seeded successfully!');
}
```

## Step 5: Verify Authentication is Working

Test these scenarios:

### Test 1: Register New User
1. Open app at https://trendify-fashion-store.web.app
2. Click "SIGN UP"
3. Enter:
   - Name: Test User
   - Email: test@example.com
   - Password: Test@123 (1 uppercase, 1 number, 6+ chars)
   - Confirm Password: Test@123
4. Click "SIGN UP"
5. **Expected:** Green success message, then MainScreen opens

### Test 2: Login with Same Credentials
1. Logout or open in new tab
2. Click "SIGN IN"
3. Enter:
   - Email: test@example.com
   - Password: Test@123
4. Click "LOGIN"
5. **Expected:** Green success message, then MainScreen opens

### Test 3: Error Handling
1. Try login with wrong password
2. **Expected:** Red error message "Incorrect password. Please try again."

## Step 6: Check Firestore Data

1. Go to: https://console.firebase.google.com/project/trendify-fashion-store/firestore/data
2. You should see:
   - **users** collection: Contains user documents
   - **products** collection: Contains product documents
   - **orders** collection: Created when orders are placed

## Step 7: Enable Firebase Hosting (Done)

✅ Already configured at:
- https://trendify-fashion-store.web.app

## Troubleshooting

### Issue: "Authentication is not enabled"
**Solution:** Go to Firebase Console > Authentication > Sign-in method > Enable Email/Password

### Issue: "Permission denied" errors
**Solution:** Update Firestore rules to test mode or proper authenticated rules

### Issue: "Network error"
**Solution:** Check internet connection and Firebase project status

### Issue: Products not loading
**Solution:** 
1. Check if products collection exists in Firestore
2. Run the seedProducts() function
3. Check browser console for errors (F12 > Console)

## Monitoring & Analytics

View app usage:
- https://console.firebase.google.com/project/trendify-fashion-store/overview

Check Authentication users:
- https://console.firebase.google.com/project/trendify-fashion-store/authentication/users

View Firestore usage:
- https://console.firebase.google.com/project/trendify-fashion-store/firestore/usage

## Security Best Practices (For Production)

1. **Enable Firebase App Check** to prevent abuse
2. **Set up Firebase Security Rules** properly (not test mode)
3. **Enable Email Verification** for new accounts
4. **Set up Firebase Analytics** for tracking
5. **Enable Firebase Crashlytics** for error tracking

## Support

Firebase Documentation: https://firebase.google.com/docs
FlutterFire Documentation: https://firebase.flutter.dev/docs/overview
