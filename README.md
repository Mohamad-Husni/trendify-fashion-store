# TRENDIFY - Premium Fashion E-Commerce App

[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud%20Services-FFCA28?logo=firebase)](https://firebase.google.com)
[![Live Demo](https://img.shields.io/badge/Live%20Demo-Online-success)](https://trendify-fashion-store.web.app)

A full-stack Flutter e-commerce application for fashion retail, featuring real-time data synchronization, secure authentication, and cloud deployment.

![TRENDIFY Banner](assets/images/logo.png)

## 🌐 Live Demo

**Experience the app live:** [https://trendify-fashion-store.web.app](https://trendify-fashion-store.web.app)

---

## 📋 Table of Contents

- [Architecture](#-architecture)
- [Database Schema](#-database-schema)
- [Application Flow](#-application-flow)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Screenshots](#-screenshots)
- [Getting Started](#-getting-started)
- [Project Structure](#-project-structure)
- [Author](#-author)

---

## 🏗️ Architecture

### Flutter + Firebase Full-Stack Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        A[Flutter Web App]
        B[Flutter Mobile App]
    end
    
    subgraph "Firebase Services"
        C[Firebase Auth]
        D[Cloud Firestore]
        E[Firebase Hosting]
        F[Firebase Cloud Messaging]
    end
    
    subgraph "State Management"
        G[Service Layer]
        H[Provider/ChangeNotifier]
    end
    
    A --> G
    B --> G
    G --> C
    G --> D
    G --> F
    A --> E
    
    style A fill:#02569B,color:#fff
    style B fill:#02569B,color:#fff
    style C fill:#FFCA28,color:#000
    style D fill:#FFCA28,color:#000
    style E fill:#FFCA28,color:#000
```

### Architecture Highlights

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Frontend** | Flutter | Cross-platform UI framework |
| **Backend** | Firebase | Serverless backend services |
| **Database** | Cloud Firestore | NoSQL document database |
| **Authentication** | Firebase Auth | Secure user authentication |
| **Hosting** | Firebase Hosting | Fast global CDN deployment |
| **State Management** | ChangeNotifier | Reactive data flow |

---

## 🗄️ Database Schema

### Firestore Collections Structure

```mermaid
erDiagram
    USERS ||--o{ ORDERS : places
    USERS ||--o{ CART_ITEMS : has
    USERS ||--o{ WISHLIST_ITEMS : saves
    USERS ||--o{ ADDRESSES : owns
    USERS ||--o{ PAYMENT_METHODS : stores
    
    PRODUCTS ||--o{ ORDER_ITEMS : contains
    PRODUCTS ||--o{ CART_ITEMS : added_to
    PRODUCTS ||--o{ WISHLIST_ITEMS : saved_in
    PRODUCTS ||--o{ REVIEWS : has
    
    ORDERS ||--|{ ORDER_ITEMS : contains
    ORDERS ||--|| ADDRESSES : ships_to
    
    USERS {
        string uid PK
        string name
        string email
        string phone
        timestamp createdAt
        timestamp updatedAt
    }
    
    PRODUCTS {
        string id PK
        string title
        string collection
        string description
        float price
        string imageUrl
        float rating
        array sizes
        array colors
        timestamp createdAt
    }
    
    ORDERS {
        string id PK
        string userId FK
        string status
        float subtotal
        float tax
        float shipping
        float total
        string paymentMethod
        string addressId FK
        timestamp orderDate
        timestamp deliveryDate
    }
    
    ORDER_ITEMS {
        string id PK
        string orderId FK
        string productId FK
        string title
        float price
        int quantity
        string size
        string color
        string imageUrl
    }
    
    CART_ITEMS {
        string id PK
        string userId FK
        string productId FK
        int quantity
        string size
        string color
        timestamp addedAt
    }
    
    WISHLIST_ITEMS {
        string id PK
        string userId FK
        string productId FK
        timestamp addedAt
    }
    
    ADDRESSES {
        string id PK
        string userId FK
        string name
        string phone
        string addressLine1
        string addressLine2
        string city
        string state
        string pincode
        bool isDefault
    }
    
    PAYMENT_METHODS {
        string id PK
        string userId FK
        string type
        string cardNumber
        string cardHolderName
        string expiryDate
        string upiId
        bool isDefault
    }
    
    REVIEWS {
        string id PK
        string productId FK
        string userId FK
        string userName
        float rating
        string comment
        timestamp createdAt
    }
```

### Collections Overview

| Collection | Description | Key Features |
|------------|-------------|--------------|
| **users** | User profiles | Auth integration, profile data |
| **products** | Product catalog | Categories, pricing, inventory |
| **orders** | Order records | Status tracking, payment info |
| **orderItems** | Order line items | Product snapshots, quantities |
| **cartItems** | Shopping cart | Real-time updates, session persistence |
| **wishlist** | Saved items | User preferences |
| **addresses** | Shipping addresses | Multiple addresses per user |
| **paymentMethods** | Saved payments | Secure payment info storage |
| **reviews** | Product reviews | Ratings and feedback |

---

## 🔄 Application Flow

### User Journey: Registration → Purchase

```mermaid
sequenceDiagram
    actor User
    participant UI as Flutter UI
    participant Auth as Firebase Auth
    participant Firestore as Cloud Firestore
    participant Hosting as Firebase Hosting
    
    User->>UI: Open App
    UI->>Hosting: Load Web App
    Hosting-->>UI: App Loaded
    
    alt User Not Authenticated
        User->>UI: Click Sign Up
        UI->>Auth: Create Account
        Auth-->>Firestore: Create User Document
        Auth-->>UI: Auth Token
    else User Authenticated
        User->>UI: Click Login
        UI->>Auth: Authenticate
        Auth-->>UI: Auth Token
    end
    
    User->>UI: Browse Products
    UI->>Firestore: Stream Products
    Firestore-->>UI: Product List
    
    User->>UI: View Product Details
    UI->>Firestore: Get Product Reviews
    Firestore-->>UI: Product + Reviews
    
    User->>UI: Add to Cart
    UI->>Firestore: Add Cart Item
    Firestore-->>UI: Cart Updated
    
    User->>UI: View Cart
    UI->>Firestore: Get Cart Items
    Firestore-->>UI: Cart Data
    
    User->>UI: Proceed to Checkout
    UI->>Firestore: Get Addresses
    UI->>Firestore: Get Payment Methods
    Firestore-->>UI: Address + Payment Data
    
    User->>UI: Place Order
    UI->>Firestore: Create Order
    UI->>Firestore: Create Order Items
    UI->>Firestore: Clear Cart
    Firestore-->>UI: Order Confirmed
    
    User->>UI: View Order History
    UI->>Firestore: Get Orders
    Firestore-->>UI: Order List
```

### Key Interactions

1. **Authentication Flow**: Firebase Auth handles user registration/login with email/password
2. **Real-time Data**: Firestore streams provide live updates for cart, orders, and products
3. **Transaction Safety**: Order creation uses batched writes for data consistency
4. **Offline Support**: Firestore offline persistence enables app usage without connectivity

---

## ✨ Features

### 🔐 Authentication
- Email/Password Registration & Login
- Google Sign-In Integration
- Secure Password Reset
- Persistent User Sessions

### 🛍️ E-Commerce Core
- Product Catalog with Categories
- Product Details with Images, Sizes, Colors
- Shopping Cart Management
- Wishlist Functionality
- Order History & Tracking

### 💳 Checkout & Payments
- Multiple Payment Methods (Card, UPI, COD)
- Address Management
- Order Summary & Confirmation
- Payment Method Persistence

### 🎨 UI/UX
- Responsive Design (Mobile & Web)
- Dark Mode Support
- Custom Theme (Gold & Black Premium Aesthetic)
- Smooth Animations & Transitions

### ⚡ Technical Features
| Feature | Implementation |
|---------|---------------|
| **State Management** | ChangeNotifier (Service Layer) |
| **Database** | Cloud Firestore (NoSQL) |
| **Authentication** | Firebase Auth |
| **Image Handling** | NetworkImage with Caching |
| **Icons** | Material Design Icons |
| **Fonts** | Google Fonts (Poppins) |
| **Deployment** | Firebase Hosting |

---

## 🛠️ Tech Stack

### Frontend
- **Flutter** - UI Framework
- **Dart** - Programming Language
- **Material Design** - UI Components
- **Google Fonts** - Typography

### Backend & Services
- **Firebase Auth** - Authentication
- **Cloud Firestore** - Database
- **Firebase Hosting** - Web Hosting
- **Firebase Cloud Messaging** - Notifications

### Development Tools
- **Android Studio** / **VS Code** - IDE
- **Git** - Version Control
- **Firebase CLI** - Deployment

---

## 📱 Screenshots

*Screenshots will be added here showcasing:*
- Home Screen with Product Grid
- Product Details with Size/Color Selection
- Shopping Cart
- Checkout Flow
- Order History
- User Profile
- Dark Mode

---

## 🚀 Getting Started

### Prerequisites

```bash
# Install Flutter
https://flutter.dev/docs/get-started/install

# Install Firebase CLI
curl -sL https://firebase.tools | bash
```

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/Mohamad-Husni/trendify-fashion-store.git
cd trendify-fashion-store
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Enable Authentication and Firestore

4. **Run the app**
```bash
# For Web
flutter run -d chrome

# For Mobile
flutter run
```

5. **Build for production**
```bash
flutter build web --release
firebase deploy
```

---

## 📁 Project Structure

```
trendify-fashion-store/
├── android/                  # Android specific
├── ios/                      # iOS specific
├── lib/
│   ├── main.dart            # App entry point
│   ├── firebase_options.dart # Firebase configuration
│   ├── models/              # Data models
│   │   ├── product.dart
│   │   ├── cart_item.dart
│   │   ├── order.dart
│   │   └── user.dart
│   ├── screens/             # UI screens
│   │   ├── home_screen.dart
│   │   ├── product_listing_screen.dart
│   │   ├── product_details_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── checkout_screen.dart
│   │   ├── orders_screen.dart
│   │   ├── profile_screen.dart
│   │   └── settings_screen.dart
│   ├── services/            # Business logic
│   │   ├── auth_service.dart
│   │   ├── cart_service.dart
│   │   ├── order_service.dart
│   │   ├── payment_service.dart
│   │   ├── product_service.dart
│   │   └── wishlist_service.dart
│   ├── theme/               # App theming
│   │   └── app_theme.dart
│   ├── utils/               # Utilities
│   │   └── firebase_seeder.dart
│   └── widgets/             # Reusable widgets
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       └── product_card.dart
├── assets/                   # Images and fonts
│   └── images/
├── web/                      # Web specific
│   ├── index.html
│   └── manifest.json
├── pubspec.yaml             # Dependencies
├── firebase.json            # Firebase config
└── README.md                # This file
```

---

## 🔗 Firebase Configuration

### Required Firestore Indexes

Create these composite indexes in Firebase Console:

| Collection | Fields | Purpose |
|------------|--------|---------|
| products | collection (Asc), createdAt (Desc) | Category filtering |
| orderItems | orderId (Asc), createdAt (Desc) | Order detail queries |
| cartItems | userId (Asc), addedAt (Desc) | Cart management |

### Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User documents - users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Subcollections inherit parent rules
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Products - public read, admin write
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null && 
        request.auth.token.admin == true;
    }
    
    // Reviews - authenticated users
    match /reviews/{reviewId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

---

## 👤 Author

**Mohamad Husni**

- GitHub: [@Mohamad-Husni](https://github.com/Mohamad-Husni)
- LinkedIn: [Your LinkedIn Profile]
- Email: [your.email@example.com]

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Flutter Team for the amazing framework
- Firebase for comprehensive backend services
- Google Fonts for beautiful typography
- Material Design for UI guidelines

---

<p align="center">
  <strong>⭐ Star this repo if you found it helpful!</strong>
</p>

<p align="center">
  <a href="https://trendify-fashion-store.web.app">
    <img src="https://img.shields.io/badge/Try%20Live%20Demo-Click%20Here-FF6B6B?style=for-the-badge" alt="Live Demo">
  </a>
</p>
