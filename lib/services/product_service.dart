import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fashion_store/models/product.dart';

// Firestore Index Note: To optimize, create these indexes in Firebase Console:
// Collection: products | Fields: collection (Ascending), createdAt (Descending)
// Collection: products | Fields: createdAt (Descending)

class ProductService extends ChangeNotifier {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final _firestore = FirebaseFirestore.instance;

  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Product> _newArrivals = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get newArrivals => _newArrivals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Stream of all products for real-time updates
  Stream<List<Product>> get productsStream {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data()))
          .toList();
    });
  }

  // Stream of products by category (no orderBy to avoid index requirement)
  Stream<List<Product>> getProductsByCategoryStream(String category) {
    return _firestore
        .collection('products')
        .where('collection', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      final products = snapshot.docs
          .map((doc) => Product.fromJson(doc.data()))
          .toList();
      // Sort in memory instead of Firestore to avoid index
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return products;
    });
  }

  // Load all products
  Future<void> loadProducts({bool forceRefresh = false}) async {
    if (_products.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();

      _products = snapshot.docs
          .map((doc) => Product.fromJson(doc.data()))
          .toList();

      // Set featured products (top rated)
      _featuredProducts = List.from(_products)
        ..sort((a, b) => b.rating.compareTo(a.rating));
      _featuredProducts = _featuredProducts.take(6).toList();

      // Set new arrivals (most recent)
      _newArrivals = _products.take(8).toList();

      _error = null;
    } catch (e) {
      _error = 'Failed to load products: $e';
      print('Error loading products: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get product by ID
  Future<Product?> getProductById(String productId) async {
    try {
      final doc = await _firestore
          .collection('products')
          .doc(productId)
          .get();

      if (doc.exists) {
        return Product.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('collection', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting products by category: $e');
      return [];
    }
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) return _products;

    final lowercaseQuery = query.toLowerCase();
    
    return _products.where((product) {
      return product.title.toLowerCase().contains(lowercaseQuery) ||
          product.description.toLowerCase().contains(lowercaseQuery) ||
          product.collection.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Filter products
  Future<List<Product>> filterProducts({
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
  }) async {
    try {
      Query<Map<String, dynamic>> firestoreQuery = _firestore.collection('products');

      // Apply category filter
      if (category != null && category.isNotEmpty && category != 'All') {
        firestoreQuery = firestoreQuery.where('collection', isEqualTo: category);
      }

      // Apply sorting
      switch (sortBy) {
        case 'price_low':
          firestoreQuery = firestoreQuery.orderBy('price', descending: false);
          break;
        case 'price_high':
          firestoreQuery = firestoreQuery.orderBy('price', descending: true);
          break;
        case 'rating':
          firestoreQuery = firestoreQuery.orderBy('rating', descending: true);
          break;
        case 'newest':
        default:
          firestoreQuery = firestoreQuery.orderBy('createdAt', descending: true);
      }

      final snapshot = await firestoreQuery.get();
      var products = snapshot.docs
          .map((doc) => Product.fromJson(doc.data()))
          .toList();

      // Apply price filter in memory (Firestore doesn't support multiple range queries efficiently)
      if (minPrice != null) {
        products = products.where((p) => p.price >= minPrice).toList();
      }
      if (maxPrice != null) {
        products = products.where((p) => p.price <= maxPrice).toList();
      }

      // Apply rating filter
      if (minRating != null) {
        products = products.where((p) => p.rating >= minRating).toList();
      }

      return products;
    } catch (e) {
      print('Error filtering products: $e');
      return [];
    }
  }

  // Get related products
  Future<List<Product>> getRelatedProducts(String productId, {int limit = 4}) async {
    try {
      final product = await getProductById(productId);
      if (product == null) return [];

      final snapshot = await _firestore
          .collection('products')
          .where('collection', isEqualTo: product.collection)
          .where(FieldPath.documentId, isNotEqualTo: productId)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting related products: $e');
      return [];
    }
  }

  // Get product recommendations (for user)
  Future<List<Product>> getRecommendations({int limit = 6}) async {
    // For now, return featured products
    // In production, this would use user's order history and wishlist
    return _featuredProducts.take(limit).toList();
  }

  // Add product (Admin only)
  Future<String?> addProduct(Product product) async {
    try {
      final docRef = await _firestore.collection('products').add(product.toJson());
      
      // Update product with ID
      await docRef.update({'id': docRef.id});
      
      // Reload products
      await loadProducts(forceRefresh: true);
      
      return docRef.id;
    } catch (e) {
      _error = 'Failed to add product: $e';
      print('Error adding product: $e');
      return null;
    }
  }

  // Update product (Admin only)
  Future<bool> updateProduct(String productId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('products').doc(productId).update(updates);
      
      // Reload products
      await loadProducts(forceRefresh: true);
      
      return true;
    } catch (e) {
      _error = 'Failed to update product: $e';
      print('Error updating product: $e');
      return false;
    }
  }

  // Delete product (Admin only)
  Future<bool> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      
      // Reload products
      await loadProducts(forceRefresh: true);
      
      return true;
    } catch (e) {
      _error = 'Failed to delete product: $e';
      print('Error deleting product: $e');
      return false;
    }
  }

  // Get all categories
  Future<List<String>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      final categories = snapshot.docs
          .map((doc) => doc.data()['collection'] as String?)
          .where((cat) => cat != null)
          .toSet()
          .toList();
      
      return categories.cast<String>();
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  // Get price range
  Future<Map<String, double>> getPriceRange() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      final prices = snapshot.docs
          .map((doc) => (doc.data()['price'] as num?)?.toDouble() ?? 0)
          .toList();

      if (prices.isEmpty) {
        return {'min': 0, 'max': 100000};
      }

      return {
        'min': prices.reduce((a, b) => a < b ? a : b),
        'max': prices.reduce((a, b) => a > b ? a : b),
      };
    } catch (e) {
      print('Error getting price range: $e');
      return {'min': 0, 'max': 100000};
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
