import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class PaymentMethod {
  final String id;
  final String type; // card, cod
  final String? cardNumber;
  final String? cardHolderName;
  final String? expiryDate;
  final bool isDefault;
  final DateTime createdAt;

  PaymentMethod({
    required this.id,
    required this.type,
    this.cardNumber,
    this.cardHolderName,
    this.expiryDate,
    this.isDefault = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get displayTitle {
    switch (type) {
      case 'card':
        if (cardNumber == null || cardNumber!.length < 4) return 'Card';
        return '•••• •••• •••• ${cardNumber!.substring(cardNumber!.length - 4)}';
      case 'cod':
        return 'Cash on Delivery';
      default:
        return type;
    }
  }

  IconData get icon {
    switch (type) {
      case 'card':
        return Icons.credit_card;
      case 'cod':
        return Icons.payments;
      default:
        return Icons.payment;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryDate': expiryDate,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? '',
      type: json['type'] ?? 'card',
      cardNumber: json['cardNumber'],
      cardHolderName: json['cardHolderName'],
      expiryDate: json['expiryDate'],
      isDefault: json['isDefault'] ?? false,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  PaymentMethod copyWith({
    String? id,
    String? type,
    String? cardNumber,
    String? cardHolderName,
    String? expiryDate,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryDate: expiryDate ?? this.expiryDate,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PaymentService extends ChangeNotifier {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = false;
  String? _error;

  List<PaymentMethod> get paymentMethods => _paymentMethods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get _userId => _auth.currentUser?.uid;

  Future<void> loadPaymentMethods() async {
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
          .collection('paymentMethods')
          .orderBy('createdAt', descending: true)
          .get();

      _paymentMethods = snapshot.docs
          .map((doc) => PaymentMethod.fromJson(doc.data()))
          .toList();

      _error = null;
    } catch (e) {
      _error = 'Failed to load payment methods: $e';
      print('Error loading payment methods: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addPaymentMethod(PaymentMethod method) async {
    final userId = _userId;
    if (userId == null) {
      _error = 'User not logged in';
      notifyListeners();
      return false;
    }

    try {
      // If this is the first payment method or marked as default, update others
      if (method.isDefault || _paymentMethods.isEmpty) {
        await _clearDefaultFlag(userId);
      }

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('paymentMethods')
          .doc(method.id);

      await docRef.set(method.copyWith(isDefault: _paymentMethods.isEmpty || method.isDefault).toJson());

      await loadPaymentMethods();
      return true;
    } catch (e) {
      _error = 'Failed to add payment method: $e';
      print('Error adding payment method: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePaymentMethod(PaymentMethod method) async {
    final userId = _userId;
    if (userId == null) {
      _error = 'User not logged in';
      notifyListeners();
      return false;
    }

    try {
      if (method.isDefault) {
        await _clearDefaultFlag(userId);
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('paymentMethods')
          .doc(method.id)
          .update(method.toJson());

      await loadPaymentMethods();
      return true;
    } catch (e) {
      _error = 'Failed to update payment method: $e';
      print('Error updating payment method: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePaymentMethod(String methodId) async {
    final userId = _userId;
    if (userId == null) {
      _error = 'User not logged in';
      notifyListeners();
      return false;
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('paymentMethods')
          .doc(methodId)
          .delete();

      await loadPaymentMethods();
      return true;
    } catch (e) {
      _error = 'Failed to delete payment method: $e';
      print('Error deleting payment method: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> setDefaultPaymentMethod(String methodId) async {
    final userId = _userId;
    if (userId == null) {
      _error = 'User not logged in';
      notifyListeners();
      return false;
    }

    try {
      await _clearDefaultFlag(userId);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('paymentMethods')
          .doc(methodId)
          .update({'isDefault': true});

      await loadPaymentMethods();
      return true;
    } catch (e) {
      _error = 'Failed to set default payment method: $e';
      print('Error setting default: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> _clearDefaultFlag(String userId) async {
    final batch = _firestore.batch();
    
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('paymentMethods')
        .where('isDefault', isEqualTo: true)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }

    await batch.commit();
  }

  PaymentMethod? getDefaultPaymentMethod() {
    try {
      return _paymentMethods.firstWhere((m) => m.isDefault);
    } catch (e) {
      return _paymentMethods.isNotEmpty ? _paymentMethods.first : null;
    }
  }
}
