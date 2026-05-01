import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_store/models/product.dart';

class SearchService {
  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;
  SearchService._internal();

  final _firestore = FirebaseFirestore.instance;

  Future<List<Product>> searchProducts({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
  }) async {
    try {
      Query<Map<String, dynamic>> firestoreQuery = _firestore.collection('products');

      // Apply category filter
      if (category != null && category.isNotEmpty) {
        firestoreQuery = firestoreQuery.where('collection', isEqualTo: category);
      }

      // Apply price range
      if (minPrice != null) {
        firestoreQuery = firestoreQuery.where('price', isGreaterThanOrEqualTo: minPrice);
      }
      if (maxPrice != null) {
        firestoreQuery = firestoreQuery.where('price', isLessThanOrEqualTo: maxPrice);
      }

      // Apply rating filter
      if (minRating != null) {
        firestoreQuery = firestoreQuery.where('rating', isGreaterThanOrEqualTo: minRating);
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
          firestoreQuery = firestoreQuery.orderBy('createdAt', descending: true);
          break;
        default:
          firestoreQuery = firestoreQuery.orderBy('createdAt', descending: true);
      }

      final snapshot = await firestoreQuery.get();
      var products = snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList();

      // Apply text search locally (Firestore doesn't support full-text search natively)
      if (query != null && query.isNotEmpty) {
        final searchLower = query.toLowerCase();
        products = products.where((product) {
          return product.title.toLowerCase().contains(searchLower) ||
                 product.description.toLowerCase().contains(searchLower) ||
                 product.collection.toLowerCase().contains(searchLower);
        }).toList();
      }

      return products;
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

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

  Future<List<Product>> getTrendingProducts() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .orderBy('rating', descending: true)
          .limit(10)
          .get();
      return snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error getting trending products: $e');
      return [];
    }
  }

  Future<List<Product>> getNewArrivals() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();
      return snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error getting new arrivals: $e');
      return [];
    }
  }
}
