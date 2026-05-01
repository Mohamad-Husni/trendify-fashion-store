import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_store/utils/dummy_data.dart';

/// Script to seed products to Firestore
/// Run this once to populate the 'products' collection
class SeedProducts {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> seedProducts() async {
    final products = DummyData.products;

    for (final product in products) {
      await _firestore.collection('products').doc(product.id).set({
        'id': product.id,
        'title': product.title,
        'collection': product.collection,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'rating': product.rating,
        'sizes': product.sizes,
        'colors': product.colors,
        'createdAt': Timestamp.now(),
      });
      print('✓ Product ${product.title} uploaded to Firestore');
    }

    print('✓ All ${products.length} products seeded successfully!');
  }

  /// Check if products already exist in Firestore
  static Future<bool> productsExist() async {
    final snapshot = await _firestore.collection('products').limit(1).get();
    return snapshot.docs.isNotEmpty;
  }
}
