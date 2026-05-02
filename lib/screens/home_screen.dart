import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_store/theme/app_theme.dart';
import 'package:fashion_store/models/product.dart';
import 'package:fashion_store/widgets/product_card.dart';
import 'package:fashion_store/screens/product_details_screen.dart';
import 'package:fashion_store/screens/product_listing_screen.dart';
import 'package:fashion_store/screens/search_screen.dart';
import 'package:fashion_store/screens/wishlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  int _currentLimit = 6; // Start with fewer items for faster loading

  Future<void> _seedProducts(BuildContext context) async {
    try {
      final products = [
        {
          'id': '1',
          'title': 'Structured Linen Blazer',
          'collection': 'Office Wear',
          'description': 'Elegant cream blazer perfect for formal occasions.',
          'price': 24500.00,
          'imageUrl': 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=600',
          'rating': 4.8,
          'sizes': ['XS', 'S', 'M', 'L', 'XL'],
          'colors': ['Cream', 'Navy', 'Black'],
          'createdAt': Timestamp.now(),
        },
        {
          'id': '2',
          'title': 'Essential Gold Hoops',
          'collection': 'Accessories',
          'description': '14k gold plated hoops for everyday elegance.',
          'price': 12000.00,
          'imageUrl': 'https://images.unsplash.com/photo-1635767798638-3e2523c0188c?w=600',
          'rating': 4.9,
          'sizes': ['One Size'],
          'colors': ['Gold', 'Silver'],
          'createdAt': Timestamp.now(),
        },
        {
          'id': '3',
          'title': 'Minimalist Silk Dress',
          'collection': 'Evening Wear',
          'description': 'Flowing silk dress perfect for summer evenings.',
          'price': 18500.00,
          'imageUrl': 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600',
          'rating': 4.7,
          'sizes': ['XS', 'S', 'M', 'L'],
          'colors': ['Champagne', 'Black'],
          'createdAt': Timestamp.now(),
        },
      ];

      for (final product in products) {
        await _firestore.collection('products').doc(product['id'] as String).set(product);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sample products added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu opened')),
          ),
        ),
        title: Image.asset(
          'assets/images/logo.png',
          height: 40,
          errorBuilder: (context, error, stackTrace) => Text(
            'TS',
            style: TextStyle(
              fontSize: 28,
              color: AppTheme.gold,
              fontFamily: 'serif',
              letterSpacing: -2,
              height: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search Products',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            tooltip: 'Wishlist',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WishlistScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  height: 450,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&w=800&q=80',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromRGBO(0, 0, 0, 0.5),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'THE EDITORIAL EDIT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Lankan Luxe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductListingScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.deepBlack,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Explore Collection'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Horizontal categories
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (context, index) => const SizedBox(width: 24),
                itemBuilder: (context, index) {
                  final categories = [
                    'BATIK WEAR',
                    'OFFICE WEAR',
                    'TRADITIONAL',
                    'CASUAL',
                  ];
                  return Center(
                    child: Text(
                      categories[index],
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.5,
                        fontWeight: index == 0
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: index == 0 ? AppTheme.deepBlack : AppTheme.grey,
                        decoration: index == 0
                            ? TextDecoration.underline
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            // Featured products grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Curated Pieces',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductListingScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: AppTheme.grey,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('products')
                  .orderBy('createdAt', descending: true)
                  .limit(_currentLimit)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.gold),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No products available'),
                  );
                }

                final products = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Product(
                    id: data['id'] ?? doc.id,
                    title: data['title'] ?? '',
                    collection: data['collection'] ?? '',
                    description: data['description'] ?? '',
                    price: (data['price'] ?? 0).toDouble(),
                    imageUrl: data['imageUrl'] ?? '',
                    rating: (data['rating'] ?? 0).toDouble(),
                    sizes: List<String>.from(data['sizes'] ?? []),
                    colors: List<String>.from(data['colors'] ?? []),
                  );
                }).toList();

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 0.8,
                    mainAxisSpacing: 32,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: products[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsScreen(
                              product: products[index],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
