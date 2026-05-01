import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:fashion_store/models/cart_item.dart';
import 'package:fashion_store/models/product.dart';

class CartItemData {
  final String productId;
  final String title;
  final double price;
  final int quantity;
  final String? size;
  final String? color;
  final String? imageUrl;
  final DateTime addedAt;

  CartItemData({
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    this.size,
    this.color,
    this.imageUrl,
    required this.addedAt,
  });

  factory CartItemData.fromJson(Map<String, dynamic> json) {
    return CartItemData(
      productId: json['productId'] ?? '',
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      size: json['size'],
      color: json['color'],
      imageUrl: json['imageUrl'],
      addedAt: (json['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'quantity': quantity,
      'size': size,
      'color': color,
      'imageUrl': imageUrl,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  double get total => price * quantity;
}

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<CartItemData> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CartItemData> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Get cart totals
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  
  double get subtotal => _items.fold(0, (sum, item) => sum + item.total);
  
  double get shipping => subtotal > 5000 ? 0.0 : 150.0;
  
  double get tax => subtotal * 0.18;
  
  double get total => subtotal + shipping + tax;

  bool get isEmpty => _items.isEmpty;

  // Check if product is in cart
  bool isInCart(String productId, {String? size, String? color}) {
    return _items.any((item) => 
      item.productId == productId && 
      item.size == size && 
      item.color == color
    );
  }

  // Get cart item count for specific product
  int getProductQuantity(String productId, {String? size, String? color}) {
    final item = _items.firstWhere(
      (item) => item.productId == productId && item.size == size && item.color == color,
      orElse: () => CartItemData(
        productId: '',
        title: '',
        price: 0,
        quantity: 0,
        addedAt: DateTime.now(),
      ),
    );
    return item.quantity;
  }

  // Load cart from Firestore
  Future<void> loadCart() async {
    final userId = _userId;
    if (userId == null) {
      // Load from local storage for guest users
      _items = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc('items')
          .get();

      if (doc.exists) {
        final data = doc.data();
        final itemsList = data?['items'] as List<dynamic>? ?? [];
        _items = itemsList.map((item) => CartItemData.fromJson(item)).toList();
      } else {
        _items = [];
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to load cart: $e';
      print('Error loading cart: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add item to cart
  Future<void> addItem({
    required Product product,
    int quantity = 1,
    String? size,
    String? color,
  }) async {
    final userId = _userId;
    
    // Check if item already exists in cart
    final existingIndex = _items.indexWhere((item) => 
      item.productId == product.id && 
      item.size == size && 
      item.color == color
    );

    if (existingIndex != -1) {
      // Update quantity
      final existingItem = _items[existingIndex];
      _items[existingIndex] = CartItemData(
        productId: existingItem.productId,
        title: existingItem.title,
        price: existingItem.price,
        quantity: existingItem.quantity + quantity,
        size: existingItem.size,
        color: existingItem.color,
        imageUrl: existingItem.imageUrl,
        addedAt: existingItem.addedAt,
      );
    } else {
      // Add new item
      _items.add(CartItemData(
        productId: product.id,
        title: product.title,
        price: product.price,
        quantity: quantity,
        size: size,
        color: color,
        imageUrl: product.imageUrl,
        addedAt: DateTime.now(),
      ));
    }

    notifyListeners();

    // Sync to Firestore if logged in
    if (userId != null) {
      await _syncCartToFirestore(userId);
    }
  }

  // Update item quantity
  Future<void> updateQuantity(String productId, int quantity, {String? size, String? color}) async {
    final userId = _userId;
    
    final index = _items.indexWhere((item) => 
      item.productId == productId && 
      item.size == size && 
      item.color == color
    );

    if (index == -1) return;

    if (quantity <= 0) {
      // Remove item
      _items.removeAt(index);
    } else {
      // Update quantity
      final item = _items[index];
      _items[index] = CartItemData(
        productId: item.productId,
        title: item.title,
        price: item.price,
        quantity: quantity,
        size: item.size,
        color: item.color,
        imageUrl: item.imageUrl,
        addedAt: item.addedAt,
      );
    }

    notifyListeners();

    // Sync to Firestore if logged in
    if (userId != null) {
      await _syncCartToFirestore(userId);
    }
  }

  // Remove item from cart
  Future<void> removeItem(String productId, {String? size, String? color}) async {
    final userId = _userId;
    
    _items.removeWhere((item) => 
      item.productId == productId && 
      item.size == size && 
      item.color == color
    );

    notifyListeners();

    // Sync to Firestore if logged in
    if (userId != null) {
      await _syncCartToFirestore(userId);
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    final userId = _userId;
    
    _items.clear();
    notifyListeners();

    // Clear from Firestore if logged in
    if (userId != null) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('cart')
            .doc('items')
            .delete();
      } catch (e) {
        print('Error clearing cart: $e');
      }
    }
  }

  // Sync cart to Firestore
  Future<void> _syncCartToFirestore(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc('items')
          .set({
        'items': _items.map((item) => item.toJson()).toList(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error syncing cart: $e');
    }
  }

  // Merge local cart with server cart (on login)
  Future<void> mergeCartOnLogin() async {
    final userId = _userId;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Get server cart
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc('items')
          .get();

      if (doc.exists) {
        final data = doc.data();
        final serverItems = (data?['items'] as List<dynamic>? ?? [])
            .map((item) => CartItemData.fromJson(item))
            .toList();

        // Merge with local cart
        for (final serverItem in serverItems) {
          final localIndex = _items.indexWhere((item) => 
            item.productId == serverItem.productId && 
            item.size == serverItem.size && 
            item.color == serverItem.color
          );

          if (localIndex != -1) {
            // Keep the higher quantity
            if (serverItem.quantity > _items[localIndex].quantity) {
              _items[localIndex] = serverItem;
            }
          } else {
            _items.add(serverItem);
          }
        }

        // Sync merged cart back to server
        await _syncCartToFirestore(userId);
      } else {
        // Just sync local cart to server
        await _syncCartToFirestore(userId);
      }
    } catch (e) {
      print('Error merging cart: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Convert to OrderItems for checkout
  List<OrderItem> toOrderItems() {
    return _items.map((item) => OrderItem(
      productId: item.productId,
      title: item.title,
      price: item.price,
      quantity: item.quantity,
      size: item.size,
      color: item.color,
      imageUrl: item.imageUrl,
    )).toList();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// OrderItem class for checkout
class OrderItem {
  final String productId;
  final String title;
  final double price;
  final int quantity;
  final String? size;
  final String? color;
  final String? imageUrl;

  OrderItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    this.size,
    this.color,
    this.imageUrl,
  });
}
