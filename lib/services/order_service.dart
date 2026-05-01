import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? '',
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      size: json['size'],
      color: json['color'],
      imageUrl: json['imageUrl'],
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
    };
  }

  double get total => price * quantity;
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final String status; // pending, processing, shipped, delivered, cancelled
  final String paymentMethod;
  final Map<String, dynamic> shippingAddress;
  final String? trackingNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    this.shipping = 0.0,
    this.tax = 0.0,
    required this.total,
    this.status = 'pending',
    required this.paymentMethod,
    required this.shippingAddress,
    this.trackingNumber,
    required this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json, String id) {
    return Order(
      id: id,
      userId: json['userId'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shipping: (json['shipping'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? 'cod',
      shippingAddress: json['shippingAddress'] ?? {},
      trackingNumber: json['trackingNumber'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'shipping': shipping,
      'tax': tax,
      'total': total,
      'status': status,
      'paymentMethod': paymentMethod,
      'shippingAddress': shippingAddress,
      'trackingNumber': trackingNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class OrderService extends ChangeNotifier {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Stream of orders for real-time updates
  Stream<List<Order>> get ordersStream {
    final userId = _userId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Order.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  // Load all orders
  Future<void> loadOrders() async {
    final userId = _userId;
    if (userId == null) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      _orders = snapshot.docs
          .map((doc) => Order.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      _error = 'Failed to load orders: $e';
      print('Error loading orders: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create new order
  Future<Order?> createOrder({
    required List<OrderItem> items,
    required double subtotal,
    required Map<String, dynamic> shippingAddress,
    String paymentMethod = 'cod',
  }) async {
    final userId = _userId;
    if (userId == null) {
      _error = 'User not logged in';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final shipping = subtotal > 5000 ? 0.0 : 150.0; // Free shipping above 5000
      final tax = subtotal * 0.18; // 18% GST
      final total = subtotal + shipping + tax;

      final order = Order(
        id: '', // Will be set after creation
        userId: userId,
        items: items,
        subtotal: subtotal,
        shipping: shipping,
        tax: tax,
        total: total,
        status: 'pending',
        paymentMethod: paymentMethod,
        shippingAddress: shippingAddress,
        createdAt: DateTime.now(),
      );

      // Create order in Firestore
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .add(order.toJson());

      // Create with ID
      final createdOrder = Order(
        id: docRef.id,
        userId: userId,
        items: items,
        subtotal: subtotal,
        shipping: shipping,
        tax: tax,
        total: total,
        status: 'pending',
        paymentMethod: paymentMethod,
        shippingAddress: shippingAddress,
        createdAt: DateTime.now(),
      );

      // Also add to global orders collection for admin
      await _firestore.collection('orders').doc(docRef.id).set({
        ...order.toJson(),
        'orderId': docRef.id,
      });

      _orders.insert(0, createdOrder);
      _isLoading = false;
      notifyListeners();

      return createdOrder;
    } catch (e) {
      _error = 'Failed to create order: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    final userId = _userId;
    if (userId == null) return false;

    try {
      final orderRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId);

      // Check if order is pending
      final doc = await orderRef.get();
      if (!doc.exists) return false;

      final data = doc.data();
      if (data?['status'] != 'pending') {
        _error = 'Only pending orders can be cancelled';
        notifyListeners();
        return false;
      }

      // Update status to cancelled
      await orderRef.update({
        'status': 'cancelled',
        'updatedAt': Timestamp.now(),
      });

      // Update in global orders too
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'updatedAt': Timestamp.now(),
      });

      // Update local cache
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = Order(
          id: _orders[index].id,
          userId: _orders[index].userId,
          items: _orders[index].items,
          subtotal: _orders[index].subtotal,
          shipping: _orders[index].shipping,
          tax: _orders[index].tax,
          total: _orders[index].total,
          status: 'cancelled',
          paymentMethod: _orders[index].paymentMethod,
          shippingAddress: _orders[index].shippingAddress,
          trackingNumber: _orders[index].trackingNumber,
          createdAt: _orders[index].createdAt,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'Failed to cancel order: $e';
      notifyListeners();
      return false;
    }
  }

  // Get order by ID
  Future<Order?> getOrder(String orderId) async {
    final userId = _userId;
    if (userId == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId)
          .get();

      if (doc.exists) {
        return Order.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting order: $e');
      return null;
    }
  }

  // Filter orders by status
  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Get order statistics
  Map<String, dynamic> getOrderStats() {
    final total = _orders.length;
    final pending = _orders.where((o) => o.status == 'pending').length;
    final processing = _orders.where((o) => o.status == 'processing').length;
    final shipped = _orders.where((o) => o.status == 'shipped').length;
    final delivered = _orders.where((o) => o.status == 'delivered').length;
    final cancelled = _orders.where((o) => o.status == 'cancelled').length;

    final totalSpent = _orders
        .where((o) => o.status != 'cancelled')
        .fold<double>(0, (sum, o) => sum + o.total);

    return {
      'total': total,
      'pending': pending,
      'processing': processing,
      'shipped': shipped,
      'delivered': delivered,
      'cancelled': cancelled,
      'totalSpent': totalSpent,
    };
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

