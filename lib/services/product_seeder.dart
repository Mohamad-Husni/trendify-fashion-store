import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_store/models/product.dart';

class ProductSeeder {
  static final List<Map<String, dynamic>> _sampleProducts = [
    {
      'id': '1',
      'title': 'Structured Linen Blazer',
      'collection': 'Office Wear',
      'description': 'Elegant cream blazer perfect for formal occasions. Features a tailored fit with premium linen fabric.',
      'price': 24500.00,
      'imageUrl': 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=600',
      'rating': 4.8,
      'sizes': ['XS', 'S', 'M', 'L', 'XL'],
      'colors': ['Cream', 'Navy', 'Black'],
    },
    {
      'id': '2',
      'title': 'Essential Gold Hoops',
      'collection': 'Accessories',
      'description': '14k gold plated hoops for everyday elegance. Hypoallergenic and tarnish-resistant.',
      'price': 12000.00,
      'imageUrl': 'https://images.unsplash.com/photo-1635767798638-3e2523c0188c?w=600',
      'rating': 4.9,
      'sizes': ['One Size'],
      'colors': ['Gold', 'Silver', 'Rose Gold'],
    },
    {
      'id': '3',
      'title': 'Minimalist Silk Dress',
      'collection': 'Evening Wear',
      'description': 'Flowing silk dress perfect for summer evenings. Lightweight and breathable fabric.',
      'price': 18500.00,
      'imageUrl': 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600',
      'rating': 4.7,
      'sizes': ['XS', 'S', 'M', 'L', 'XL'],
      'colors': ['Champagne', 'Black', 'Navy'],
    },
    {
      'id': '4',
      'title': 'Classic White Shirt',
      'collection': 'Office Wear',
      'description': 'Crisp cotton shirt with modern tailoring. Perfect for professional settings.',
      'price': 8500.00,
      'imageUrl': 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600',
      'rating': 4.6,
      'sizes': ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
      'colors': ['White', 'Light Blue', 'Pink'],
    },
    {
      'id': '5',
      'title': 'Designer Leather Bag',
      'collection': 'Accessories',
      'description': 'Genuine leather handbag with gold hardware. Spacious interior with multiple compartments.',
      'price': 35000.00,
      'imageUrl': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600',
      'rating': 4.9,
      'sizes': ['One Size'],
      'colors': ['Black', 'Brown', 'Tan', 'Navy'],
    },
    {
      'id': '6',
      'title': 'Pleated Midi Skirt',
      'collection': 'Casual Wear',
      'description': 'Elegant pleated skirt that transitions from day to night. Comfortable elastic waistband.',
      'price': 9800.00,
      'imageUrl': 'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=600',
      'rating': 4.5,
      'sizes': ['XS', 'S', 'M', 'L', 'XL'],
      'colors': ['Black', 'Beige', 'Olive', 'Burgundy'],
    },
    {
      'id': '7',
      'title': 'Cashmere Sweater',
      'collection': 'Winter Collection',
      'description': 'Luxurious cashmere sweater for ultimate comfort. Soft, warm, and lightweight.',
      'price': 28000.00,
      'imageUrl': 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=600',
      'rating': 4.8,
      'sizes': ['S', 'M', 'L', 'XL'],
      'colors': ['Camel', 'Grey', 'Navy', 'Black'],
    },
    {
      'id': '8',
      'title': 'Statement Necklace',
      'collection': 'Accessories',
      'description': 'Bold statement piece featuring semi-precious stones. Adjustable chain length.',
      'price': 15000.00,
      'imageUrl': 'https://images.unsplash.com/photo-1599643478518-17488fbbcd75?w=600',
      'rating': 4.7,
      'sizes': ['One Size'],
      'colors': ['Gold/Blue', 'Silver/Green', 'Gold/Pink'],
    },
    {
      'id': '9',
      'title': 'Tailored Trousers',
      'collection': 'Office Wear',
      'description': 'Classic straight-leg trousers with professional finish. Wrinkle-resistant fabric.',
      'price': 12000.00,
      'imageUrl': 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600',
      'rating': 4.6,
      'sizes': ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
      'colors': ['Black', 'Navy', 'Charcoal'],
    },
    {
      'id': '10',
      'title': 'Floral Summer Dress',
      'collection': 'Casual Wear',
      'description': 'Bright floral print dress with flowing silhouette. Perfect for beach days.',
      'price': 11000.00,
      'imageUrl': 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=600',
      'rating': 4.5,
      'sizes': ['XS', 'S', 'M', 'L', 'XL'],
      'colors': ['Yellow Floral', 'Pink Floral', 'Blue Floral'],
    },
    {
      'id': '11',
      'title': 'Wool Overcoat',
      'collection': 'Winter Collection',
      'description': 'Premium wool blend overcoat for cold weather. Classic double-breasted design.',
      'price': 45000.00,
      'imageUrl': 'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=600',
      'rating': 4.9,
      'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
      'colors': ['Camel', 'Black', 'Grey'],
    },
    {
      'id': '12',
      'title': 'Silk Scarf',
      'collection': 'Accessories',
      'description': 'Pure silk scarf with artistic print. Versatile styling options.',
      'price': 6500.00,
      'imageUrl': 'https://images.unsplash.com/photo-1584030373081-f37b7bb4fa33?w=600',
      'rating': 4.4,
      'sizes': ['One Size'],
      'colors': ['Multi Print', 'Solid Red', 'Striped'],
    },
    {
      'id': '13',
      'title': 'Cocktail Evening Gown',
      'collection': 'Evening Wear',
      'description': 'Stunning evening gown with intricate beadwork. Perfect for special occasions.',
      'price': 65000.00,
      'imageUrl': 'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=600',
      'rating': 5.0,
      'sizes': ['XS', 'S', 'M', 'L'],
      'colors': ['Midnight Blue', 'Burgundy', 'Black'],
    },
    {
      'id': '14',
      'title': 'Running Sneakers',
      'collection': 'Sportswear',
      'description': 'High-performance running shoes with advanced cushioning technology.',
      'price': 18000.00,
      'imageUrl': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
      'rating': 4.7,
      'sizes': ['UK 5', 'UK 6', 'UK 7', 'UK 8', 'UK 9', 'UK 10', 'UK 11'],
      'colors': ['White/Black', 'All Black', 'Grey/White'],
    },
    {
      'id': '15',
      'title': 'Vintage Sunglasses',
      'collection': 'Accessories',
      'description': 'Retro-inspired sunglasses with UV protection. Lightweight acetate frames.',
      'price': 9500.00,
      'imageUrl': 'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=600',
      'rating': 4.6,
      'sizes': ['One Size'],
      'colors': ['Black', 'Tortoise', 'Clear'],
    },
    {
      'id': '16',
      'title': 'Yoga Leggings',
      'collection': 'Sportswear',
      'description': 'High-waisted leggings with moisture-wicking fabric. Four-way stretch.',
      'price': 5500.00,
      'imageUrl': 'https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=600',
      'rating': 4.8,
      'sizes': ['XS', 'S', 'M', 'L', 'XL'],
      'colors': ['Black', 'Navy', 'Charcoal', 'Olive'],
    },
    {
      'id': '17',
      'title': 'Bomber Jacket',
      'collection': 'Casual Wear',
      'description': 'Classic bomber jacket with modern fit. Water-resistant outer shell.',
      'price': 16000.00,
      'imageUrl': 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=600',
      'rating': 4.5,
      'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
      'colors': ['Black', 'Olive', 'Navy', 'Maroon'],
    },
    {
      'id': '18',
      'title': 'Pearl Earrings',
      'collection': 'Accessories',
      'description': 'Elegant freshwater pearl drop earrings. Sterling silver posts.',
      'price': 8500.00,
      'imageUrl': 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600',
      'rating': 4.7,
      'sizes': ['One Size'],
      'colors': ['White Pearl', 'Pink Pearl', 'Black Pearl'],
    },
    {
      'id': '19',
      'title': 'Wide Brim Hat',
      'collection': 'Accessories',
      'description': 'Stylish wide brim hat for sun protection. Packable design.',
      'price': 7500.00,
      'imageUrl': 'https://images.unsplash.com/photo-1521369909029-2afed882ba7d?w=600',
      'rating': 4.4,
      'sizes': ['S/M', 'M/L'],
      'colors': ['Natural', 'Black', 'Beige'],
    },
    {
      'id': '20',
      'title': 'Athletic Tank Top',
      'collection': 'Sportswear',
      'description': 'Breathable tank top with quick-dry technology. Racerback design.',
      'price': 3500.00,
      'imageUrl': 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=600',
      'rating': 4.5,
      'sizes': ['XS', 'S', 'M', 'L', 'XL'],
      'colors': ['Black', 'White', 'Grey', 'Pink', 'Blue'],
    },
  ];

  static Future<void> seedProducts() async {
    final firestore = FirebaseFirestore.instance;
    
    print('🌱 Starting to seed products...');
    
    for (final productData in _sampleProducts) {
      try {
        final product = Product(
          id: productData['id'] as String,
          title: productData['title'] as String,
          collection: productData['collection'] as String,
          description: productData['description'] as String,
          price: productData['price'] as double,
          imageUrl: productData['imageUrl'] as String,
          rating: productData['rating'] as double,
          sizes: List<String>.from(productData['sizes'] as List),
          colors: List<String>.from(productData['colors'] as List),
        );
        
        await firestore
            .collection('products')
            .doc(product.id)
            .set({
          ...product.toJson(),
          'createdAt': Timestamp.now(),
        });
        
        print('✅ Added: ${product.title}');
      } catch (e) {
        print('❌ Error adding ${productData['title']}: $e');
      }
    }
    
    print('🎉 Product seeding complete!');
  }

  static Future<void> clearAndReseed() async {
    final firestore = FirebaseFirestore.instance;
    
    print('🗑️ Clearing existing products...');
    
    final snapshot = await firestore.collection('products').get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
    
    print('🌱 Re-seeding products...');
    await seedProducts();
  }

  static Future<int> getProductCount() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    return snapshot.docs.length;
  }
}
