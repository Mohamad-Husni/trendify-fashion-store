import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_store/theme/app_theme.dart';
import 'package:fashion_store/models/product.dart';
import 'package:fashion_store/widgets/product_card.dart';
import 'package:fashion_store/screens/product_details_screen.dart';
import 'package:fashion_store/screens/search_screen.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  final _firestore = FirebaseFirestore.instance;
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      final cats = snapshot.docs
          .map((doc) => (doc.data()['collection'] as String?))
          .where((cat) => cat != null && cat.isNotEmpty)
          .toSet()
          .toList();
      
      setState(() {
        _categories = ['All', ...cats.cast<String>()];
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Stream<QuerySnapshot> _getProductsStream() {
    Query query = _firestore.collection('products');
    
    if (_selectedCategory != 'All') {
      query = query.where('collection', isEqualTo: _selectedCategory);
    }
    
    // Apply sorting
    switch (_sortBy) {
      case 'price_low':
        query = query.orderBy('price', descending: false);
        break;
      case 'price_high':
        query = query.orderBy('price', descending: true);
        break;
      case 'rating':
        query = query.orderBy('rating', descending: true);
        break;
      case 'newest':
      default:
        query = query.orderBy('createdAt', descending: true);
    }
    
    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.gold : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? AppTheme.gold : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.black : Colors.grey[600],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Sort Button
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort),
                  onSelected: (value) {
                    setState(() {
                      _sortBy = value;
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'newest',
                      child: Text('Newest First'),
                    ),
                    const PopupMenuItem(
                      value: 'price_low',
                      child: Text('Price: Low to High'),
                    ),
                    const PopupMenuItem(
                      value: 'price_high',
                      child: Text('Price: High to Low'),
                    ),
                    const PopupMenuItem(
                      value: 'rating',
                      child: Text('Highest Rated'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Products Grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getProductsStream(),
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _selectedCategory == 'All' 
                              ? 'No products available'
                              : 'No products in $_selectedCategory',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        if (_selectedCategory != 'All')
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = 'All';
                              });
                            },
                            child: const Text('Show All Products'),
                          ),
                      ],
                    ),
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
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
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
          ),
        ],
      ),
    );
  }
}
