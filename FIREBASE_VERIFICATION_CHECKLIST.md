# TRENDIFY Firebase Backend Verification Checklist

## ✅ Backend Setup Status

### 1. Firebase Project Configuration - ✅ COMPLETE
- **Project ID:** `trendify-fashion-store`
- **Web App:** Configured with API keys
- **Platforms:** Web, Android, iOS, Windows, macOS
- **Config File:** `lib/firebase_options.dart` ✓

### 2. Flutter Dependencies - ✅ COMPLETE
```yaml
firebase_core: ^3.0.0      ✓
firebase_auth: ^5.0.0      ✓
cloud_firestore: ^5.0.0    ✓
```

### 3. Firebase Initialization - ✅ COMPLETE
- **main.dart:** Firebase initialized before app startup ✓
- **App:** Successfully connects to Firebase backend ✓

---

## ⚠️ MANUAL SETUP REQUIRED (Firebase Console)

### Step 1: Enable Authentication 🔐
**URL:** https://console.firebase.google.com/project/trendify-fashion-store/authentication

**Actions:**
1. Click "Get Started"
2. Select "Email/Password" sign-in method
3. Toggle to **ENABLED**
4. Click **Save**

**Verify:** Green checkmark next to "Email/Password"

---

### Step 2: Enable Firestore Database 📊
**URL:** https://console.firebase.google.com/project/trendify-fashion-store/firestore

**Actions:**
1. Click "Create Database"
2. Select **"Start in test mode"**
3. Choose region: **asia-south1** (Mumbai)
4. Click "Enable"

**Verify:** Database created with collections interface

---

### Step 3: Set Firestore Security Rules 🛡️
**URL:** https://console.firebase.google.com/project/trendify-fashion-store/firestore/rules

**Replace with:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - authenticated users only
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products - public read, authenticated write
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Orders - user can only access their own
    match /orders/{orderId} {
      allow read, write: if request.auth != null && 
        (resource == null || resource.data.userId == request.auth.uid);
    }
  }
}
```

Click **Publish**

---

## 🧪 Functionality Testing

### Test 1: User Registration
```
1. Open https://trendify-fashion-store.web.app
2. Click "SIGN UP"
3. Enter details:
   - Name: John Doe
   - Email: john@example.com
   - Password: Test@123
   - Confirm: Test@123
4. Click "SIGN UP"

✅ Expected: Green "Account created successfully!" message
✅ Expected: Redirect to MainScreen
```

### Test 2: User Login
```
1. Logout or open new tab
2. Click "SIGN IN"
3. Enter:
   - Email: john@example.com
   - Password: Test@123
4. Click "LOGIN"

✅ Expected: Green "Login successful!" message
✅ Expected: Redirect to MainScreen
```

### Test 3: Error Handling
```
1. Try login with wrong password
2. 
✅ Expected: Red error "Incorrect password. Please try again."
```

### Test 4: Firestore Data
```
1. Register new user
2. Go to Firebase Console > Firestore
3. Check "users" collection

✅ Expected: Document with user's name, email, uid, timestamp
```

### Test 5: Product Loading
```
1. Login to app
2. Check Home Screen products

✅ Expected: Products load from Firestore
✅ Expected: No "No products available" message
```

### Test 6: Place Order
```
1. Add items to cart
2. Go to Checkout
3. Fill shipping details
4. Click "PLACE ORDER"

✅ Expected: "Order Placed Successfully!" message
✅ Expected: Order appears in Profile > My Orders
✅ Expected: Order document created in Firestore "orders" collection
```

---

## 🔧 Troubleshooting Common Issues

### Issue: "Authentication is not enabled"
```
Solution: 
1. Go to Firebase Console > Authentication > Sign-in method
2. Enable "Email/Password"
3. Save
```

### Issue: "Permission denied" in Firestore
```
Solution:
1. Check Firestore rules are published
2. Ensure user is logged in
3. Verify userId matches in rules
```

### Issue: "No products available"
```
Solution:
1. Check Firestore "products" collection exists
2. Run seedProducts() function to populate
3. Check browser console for errors
```

### Issue: "Network error" or timeout
```
Solution:
1. Check internet connection
2. Verify Firebase project is active
3. Check Firebase status: https://status.firebase.google.com/
```

---

## 📊 Firebase Console Quick Links

| Service | URL |
|---------|-----|
| Project Overview | https://console.firebase.google.com/project/trendify-fashion-store/overview |
| Authentication | https://console.firebase.google.com/project/trendify-fashion-store/authentication |
| Firestore Database | https://console.firebase.google.com/project/trendify-fashion-store/firestore |
| Hosting | https://console.firebase.google.com/project/trendify-fashion-store/hosting |
| Users List | https://console.firebase.google.com/project/trendify-fashion-store/authentication/users |

---

## ✅ Final Verification

After completing all steps above, verify:

- [ ] Authentication enabled in Firebase Console
- [ ] Firestore database created
- [ ] Security rules published
- [ ] User can register successfully
- [ ] User can login with credentials
- [ ] User document created in Firestore
- [ ] Products load from Firestore
- [ ] Orders can be placed
- [ ] Order history displays correctly

**All functions working?** ✅ Backend is fully set up!

---

## 🚀 Live Application

**URL:** https://trendify-fashion-store.web.app

**Status:** Frontend deployed, waiting for Firebase backend configuration

**Next Steps:**
1. Enable Authentication (5 minutes)
2. Enable Firestore (5 minutes)
3. Test all functions (10 minutes)
4. Done! ✅
