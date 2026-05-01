# TRENDIFY - Complete Backend Services Documentation

## ✅ All Backend Services Created

### 1. **Auth Service** (`lib/services/auth_service.dart`)
**Features:**
- Email/Password Registration & Login
- Google Sign-In integration
- Password Reset
- Profile Updates
- Change Password
- User session management
- Error handling with user-friendly messages

**Methods:**
- `registerWithEmail()` - Create new account
- `loginWithEmail()` - Sign in existing user
- `signInWithGoogle()` - Google OAuth login
- `resetPassword()` - Send password reset email
- `updateProfile()` - Update name and photo
- `changePassword()` - Update password
- `logout()` - Sign out user

---

### 2. **User Service** (`lib/services/user_service.dart`)
**Features:**
- User profile management
- User statistics (orders, wishlist, addresses)
- Preferences management
- Account deactivation/deletion
- Real-time profile updates

**Models:**
- `UserProfile` - Complete user data
- `UserStats` - Aggregated user statistics

**Methods:**
- `loadProfile()` - Get user profile
- `updateProfile()` - Update user data
- `loadStats()` - Get user statistics
- `addPreference()` - Add to user preferences
- `deactivateAccount()` - Soft delete
- `deleteAccount()` - Hard delete with cleanup

---

### 3. **Product Service** (`lib/services/product_service.dart`)
**Features:**
- Real-time product streaming
- Category-based filtering
- Search functionality
- Price range filtering
- Rating filtering
- Sorting (newest, price, rating)
- Related products
- Recommendations
- Admin CRUD operations

**Methods:**
- `loadProducts()` - Load all products
- `getProductById()` - Get single product
- `getProductsByCategory()` - Filter by category
- `searchProducts()` - Text search
- `filterProducts()` - Advanced filtering
- `getRelatedProducts()` - Similar products
- `addProduct()` - Admin: Add new product
- `updateProduct()` - Admin: Update product
- `deleteProduct()` - Admin: Delete product

---

### 4. **Cart Service** (`lib/services/cart_service.dart`)
**Features:**
- Persistent cart storage (Firestore)
- Guest cart support
- Cart merge on login
- Real-time cart totals
- Item quantity management
- Checkout conversion

**Models:**
- `CartItemData` - Cart item with metadata
- `OrderItem` - Checkout conversion

**Methods:**
- `loadCart()` - Load user's cart
- `addItem()` - Add product to cart
- `updateQuantity()` - Change item quantity
- `removeItem()` - Remove from cart
- `clearCart()` - Empty cart
- `mergeCartOnLogin()` - Merge guest + server cart
- `toOrderItems()` - Convert for checkout

**Getters:**
- `itemCount` - Total items in cart
- `subtotal` - Cart subtotal
- `shipping` - Shipping cost (free > ₹5000)
- `tax` - 18% GST
- `total` - Final total

---

### 5. **Order Service** (`lib/services/order_service.dart`)
**Features:**
- Complete order lifecycle
- Real-time order status updates
- Order filtering by status
- Order statistics
- Order cancellation
- Admin integration

**Models:**
- `OrderItem` - Order line item
- `Order` - Complete order with status

**Status Flow:**
```
pending → processing → shipped → delivered
   ↓
cancelled (only from pending)
```

**Methods:**
- `loadOrders()` - Get all orders
- `createOrder()` - Place new order
- `cancelOrder()` - Cancel pending order
- `getOrder()` - Get order details
- `getOrdersByStatus()` - Filter orders
- `getOrderStats()` - Order statistics

---

### 6. **Wishlist Service** (`lib/services/wishlist_service.dart`)
**Features:**
- Add/remove favorites
- Persistent storage
- Quick check if in wishlist
- Product ID list management

**Methods:**
- `loadWishlist()` - Load wishlist
- `toggleWishlist()` - Add/remove product
- `isInWishlist()` - Check if favorited
- `addToWishlist()` - Add product
- `removeFromWishlist()` - Remove product

---

### 7. **Address Service** (`lib/services/address_service.dart`)
**Features:**
- Multiple addresses per user
- Default address management
- Address validation
- Formatted address display

**Model:**
- `Address` - Complete address with label

**Methods:**
- `getAddresses()` - Get all addresses
- `addAddress()` - Add new address
- `updateAddress()` - Update existing
- `deleteAddress()` - Remove address
- `setDefaultAddress()` - Set as default

---

### 8. **Search Service** (`lib/services/search_service.dart`)
**Features:**
- Full-text search
- Category filtering
- Price range filtering
- Rating filtering
- Multiple sort options

**Methods:**
- `searchProducts()` - Search with filters
- `getCategories()` - Available categories
- `getPriceRange()` - Min/max prices

---

### 9. **Notification Service** (`lib/services/notification_service.dart`)
**Features:**
- Push notifications (FCM)
- Local notifications
- In-app notification center
- Unread count badge
- Notification types (order, promo, system)
- Topic subscriptions
- Token management

**Model:**
- `AppNotification` - Notification data

**Methods:**
- `initialize()` - Setup notifications
- `loadNotifications()` - Get notification history
- `markAsRead()` - Mark single as read
- `markAllAsRead()` - Mark all as read
- `subscribeToTopic()` - Subscribe to topics
- `sendTestNotification()` - Test notification

---

## 📊 Firestore Database Structure

```
users/{userId}/
  ├── email: string
  ├── name: string
  ├── phone: string
  ├── photoURL: string
  ├── fcmToken: string
  ├── notificationsEnabled: boolean
  ├── createdAt: timestamp
  ├── lastLogin: timestamp
  ├── isActive: boolean
  │
  ├── addresses/{addressId}/
  │   ├── fullName: string
  │   ├── phone: string
  │   ├── streetAddress: string
  │   ├── city: string
  │   ├── state: string
  │   ├── postalCode: string
  │   ├── country: string (default: India)
  │   ├── label: string (Home/Work/Other)
  │   ├── isDefault: boolean
  │   └── createdAt: timestamp
  │
  ├── orders/{orderId}/
  │   ├── items: array of order items
  │   ├── subtotal: number
  │   ├── shipping: number (0 if > 5000)
  │   ├── tax: number (18% GST)
  │   ├── total: number
  │   ├── status: string (pending/processing/shipped/delivered/cancelled)
  │   ├── paymentMethod: string (cod/card/upi)
  │   ├── shippingAddress: map
  │   ├── trackingNumber: string
  │   ├── createdAt: timestamp
  │   └── updatedAt: timestamp
  │
  ├── cart/items/
  │   ├── items: array of cart items
  │   └── updatedAt: timestamp
  │
  ├── wishlist/items/
  │   ├── productIds: array of strings
  │   └── updatedAt: timestamp
  │
  └── notifications/{notificationId}/
      ├── title: string
      ├── body: string
      ├── type: string (order/promotion/system)
      ├── data: map (additional data)
      ├── isRead: boolean
      └── createdAt: timestamp

products/{productId}/
  ├── id: string
  ├── title: string
  ├── description: string
  ├── collection: string (category)
  ├── price: number
  ├── imageUrl: string
  ├── rating: number (0-5)
  ├── sizes: array of strings
  ├── colors: array of strings
  └── createdAt: timestamp

orders/{orderId}/ (Global orders for admin)
  ├── (Same as user orders)
  └── orderId: string
```

---

## 🔐 Security Rules

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Check if user owns the document
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // Users collection
    match /users/{userId} {
      allow read, write: if isOwner(userId);
      
      match /addresses/{addressId} {
        allow read, write: if isOwner(userId);
      }
      
      match /orders/{orderId} {
        allow read, write: if isOwner(userId);
      }
      
      match /cart/{cartId} {
        allow read, write: if isOwner(userId);
      }
      
      match /wishlist/{wishlistId} {
        allow read, write: if isOwner(userId);
      }
      
      match /notifications/{notificationId} {
        allow read, write: if isOwner(userId);
      }
    }

    // Products - Public read, Admin write
    match /products/{productId} {
      allow read: if true;
      allow write: if isAuthenticated(); // Add admin check in production
    }
    
    // Global orders - User read own, Admin read all
    match /orders/{orderId} {
      allow read: if isAuthenticated() && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true);
      allow write: if isAuthenticated();
    }
  }
}
```

---

## 🚀 Firebase Cloud Functions (Optional)

### Setup Cloud Functions

```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Cloud Functions
firebase init functions

# Deploy functions
firebase deploy --only functions
```

### Recommended Functions

#### 1. Send Order Status Notification
```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.onOrderStatusChange = functions.firestore
  .document('users/{userId}/orders/{orderId}')
  .onUpdate(async (change, context) => {
    const newValue = change.after.data();
    const previousValue = change.before.data();
    
    if (newValue.status !== previousValue.status) {
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(context.params.userId)
        .get();
      
      const fcmToken = userDoc.data().fcmToken;
      
      if (fcmToken) {
        await admin.messaging().sendToDevice(fcmToken, {
          notification: {
            title: 'Order Update',
            body: `Your order is now ${newValue.status}`,
          },
          data: {
            orderId: context.params.orderId,
            status: newValue.status,
          },
        });
      }
    }
  });
```

#### 2. Welcome Email on Registration
```javascript
exports.onUserCreated = functions.auth.user().onCreate(async (user) => {
  // Send welcome email or create welcome notification
  await admin.firestore()
    .collection('users')
    .doc(user.uid)
    .collection('notifications')
    .add({
      title: 'Welcome to TRENDIFY!',
      body: 'Thank you for joining us. Start exploring our latest collections.',
      type: 'system',
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
});
```

---

## 📱 Service Integration Examples

### Example 1: Complete Login Flow
```dart
import 'package:fashion_store/services/auth_service.dart';
import 'package:fashion_store/services/user_service.dart';
import 'package:fashion_store/services/cart_service.dart';

Future<void> loginUser(String email, String password) async {
  final authService = AuthService();
  final userService = UserService();
  final cartService = CartService();
  
  // Login
  final user = await authService.loginWithEmail(
    email: email,
    password: password,
  );
  
  if (user != null) {
    // Load user data
    await userService.loadProfile();
    await userService.loadStats();
    
    // Merge cart
    await cartService.mergeCartOnLogin();
    
    // Navigate to home
    Navigator.pushReplacementNamed(context, '/home');
  }
}
```

### Example 2: Place Order Flow
```dart
import 'package:fashion_store/services/cart_service.dart';
import 'package:fashion_store/services/order_service.dart';
import 'package:fashion_store/services/address_service.dart';

Future<void> placeOrder(Address selectedAddress) async {
  final cartService = CartService();
  final orderService = OrderService();
  
  // Get cart items
  final items = cartService.toOrderItems();
  final subtotal = cartService.subtotal;
  
  // Create order
  final order = await orderService.createOrder(
    items: items,
    subtotal: subtotal,
    shippingAddress: selectedAddress.toJson(),
    paymentMethod: 'cod',
  );
  
  if (order != null) {
    // Clear cart
    await cartService.clearCart();
    
    // Show success
    showSuccessMessage('Order placed successfully!');
    
    // Navigate to order confirmation
    Navigator.pushNamed(context, '/order-confirmation', arguments: order.id);
  }
}
```

### Example 3: Real-time Order Updates
```dart
import 'package:fashion_store/services/order_service.dart';

StreamBuilder<List<Order>>(
  stream: OrderService().ordersStream,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final orders = snapshot.data!;
      return ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return OrderCard(order: orders[index]);
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

---

## 🔧 Backend Configuration Checklist

### Firebase Setup
- [x] Firebase project created
- [x] Android app registered
- [x] iOS app registered
- [x] Firestore database enabled
- [x] Firebase Authentication enabled
- [ ] Firebase Cloud Messaging enabled (for notifications)
- [ ] Cloud Functions enabled (optional)

### App Configuration
- [x] `google-services.json` in `android/app/`
- [x] `GoogleService-Info.plist` in `ios/Runner/`
- [x] Firebase initialized in `main.dart`
- [x] Security rules published

### Dependencies (pubspec.yaml)
```yaml
dependencies:
  # Firebase
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_messaging: ^15.0.0
  
  # Notifications
  flutter_local_notifications: ^17.0.0
  
  # Google Sign In
  google_sign_in: ^6.2.0
  
  # Other
  google_fonts: ^8.0.2
  intl: ^0.20.2
```

---

## 🎯 Next Steps

1. **Enable Firebase Cloud Messaging**
   - Go to Firebase Console → Cloud Messaging
   - Get server key for backend
   - Add FCM token handling

2. **Set Up Firebase Cloud Functions** (Optional)
   - Automated order notifications
   - Welcome emails
   - Inventory management

3. **Add Payment Gateway**
   - Razorpay integration
   - Stripe integration
   - UPI/NetBanking

4. **Admin Dashboard**
   - Web-based admin panel
   - Order management
   - Product management
   - User management

5. **Analytics & Crashlytics**
   - Firebase Analytics for tracking
   - Crashlytics for error reporting

---

**All backend services are now complete and ready! 🎉**
