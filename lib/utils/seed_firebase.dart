import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SeedFirebase {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> seedProducts() async {
    final products = [
      {
        'id': '1',
        'title': 'Structured Linen Blazer',
        'collection': 'Office Wear',
        'description': 'Elegant cream blazer perfect for formal occasions. Made from premium linen with a relaxed fit.',
        'price': 24500.00,
        'imageUrl': 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=600&q=80',
        'rating': 4.8,
        'sizes': ['XS', 'S', 'M', 'L', 'XL'],
        'colors': ['Cream', 'Navy', 'Black'],
        'createdAt': Timestamp.now(),
      },
      {
        'id': '2',
        'title': 'Essential Gold Hoops',
        'collection': 'Accessories',
        'description': '14k gold plated hoops for everyday elegance. Lightweight and hypoallergenic.',
        'price': 12000.00,
        'imageUrl': 'https://images.unsplash.com/photo-1635767798638-3e2523c0188c?auto=format&fit=crop&w=600&q=80',
        'rating': 4.9,
        'sizes': ['One Size'],
        'colors': ['Gold', 'Silver'],
        'createdAt': Timestamp.now(),
      },
      {
        'id': '3',
        'title': 'Minimalist Silk Dress',
        'collection': 'Evening Wear',
        'description': 'Flowing silk dress with delicate straps. Perfect for summer evenings.',
        'price': 18500.00,
        'imageUrl': 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=600&q=80',
        'rating': 4.7,
        'sizes': ['XS', 'S', 'M', 'L'],
        'colors': ['Champagne', 'Black', 'Navy'],
        'createdAt': Timestamp.now(),
      },
      {
        'id': '4',
        'title': 'Classic Trench Coat',
        'collection': 'Outerwear',
        'description': 'Timeless beige trench coat with belt. Water-resistant cotton blend.',
        'price': 32000.00,
        'imageUrl': 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=600&q=80',
        'rating': 4.9,
        'sizes': ['S', 'M', 'L', 'XL'],
        'colors': ['Beige', 'Camel', 'Black'],
        'createdAt': Timestamp.now(),
      },
      {
        'id': '5',
        'title': 'Leather Crossbody Bag',
        'collection': 'Accessories',
        'description': 'Genuine leather bag with gold hardware. Adjustable strap.',
        'price': 28000.00,
        'imageUrl': 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=600&q=80',
        'rating': 4.8,
        'sizes': ['One Size'],
        'colors': ['Brown', 'Black', 'Tan'],
        'createdAt': Timestamp.now(),
      },
      {
        'id': '6',
        'title': 'Cashmere Sweater',
        'collection': 'Winter Collection',
        'description': 'Luxuriously soft cashmere in a relaxed fit. Perfect layering piece.',
        'price': 22000.00,
        'imageUrl': 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?auto=format&fit=crop&w=600&q=80',
        'rating': 4.9,
        'sizes': ['XS', 'S', 'M', 'L', 'XL'],
        'colors': ['Ivory', 'Grey', 'Camel', 'Navy'],
        'createdAt': Timestamp.now(),
      },
    ];

    for (final product in products) {
      await _firestore.collection('products').doc(product['id'] as String).set(product);
    }
    
    print('✅ Products seeded successfully!');
  }

  static Future<void> verifySetup() async {
    try {
      // Check if we can connect to Firestore
      final snapshot = await _firestore.collection('products').limit(1).get();
      print('✅ Firestore connection: OK');
      print('   Products found: ${snapshot.docs.length}');
      
      // Check auth state
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('✅ User authenticated: ${user.email}');
      } else {
        print('ℹ️ No user logged in');
      }
      
      return;
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }
}
