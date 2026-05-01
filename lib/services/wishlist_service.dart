import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class WishlistService extends ChangeNotifier {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<String> _wishlistProductIds = [];
  bool _isLoading = false;

  List<String> get wishlistProductIds => _wishlistProductIds;
  bool get isLoading => _isLoading;

  bool isInWishlist(String productId) {
    return _wishlistProductIds.contains(productId);
  }

  Future<void> loadWishlist() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .doc('items')
          .get();

      if (doc.exists) {
        final data = doc.data();
        _wishlistProductIds = List<String>.from(data?['productIds'] ?? []);
      } else {
        _wishlistProductIds = [];
      }
    } catch (e) {
      print('Error loading wishlist: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleWishlist(String productId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Please login to add items to wishlist');
    }

    try {
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .doc('items');

      if (_wishlistProductIds.contains(productId)) {
        _wishlistProductIds.remove(productId);
      } else {
        _wishlistProductIds.add(productId);
      }

      await docRef.set({
        'productIds': _wishlistProductIds,
        'updatedAt': Timestamp.now(),
      });

      notifyListeners();
    } catch (e) {
      print('Error toggling wishlist: $e');
      rethrow;
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .doc('items');

      _wishlistProductIds.remove(productId);

      await docRef.set({
        'productIds': _wishlistProductIds,
        'updatedAt': Timestamp.now(),
      });

      notifyListeners();
    } catch (e) {
      print('Error removing from wishlist: $e');
      rethrow;
    }
  }
}
