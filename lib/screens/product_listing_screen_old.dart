import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_store/theme/app_theme.dart';
import 'package:fashion_store/models/product.dart';
import 'package:fashion_store/widgets/product_card.dart';
import 'package:fashion_store/screens/product_details_screen.dart';

class ProductListingScreen extends StatelessWidget {
  ProductListingScreen({super.key});

  final _firestore = FirebaseFirestore.instance;

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
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bag opened')),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: const [
                        Text(
                          'ALL',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        SizedBox(width: 24),
                        Text(
                          'DRESSES',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.grey,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(width: 24),
                        Text(
                          'ACCESSORIES',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.grey,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: const [
                    Text(
                      'SORT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.tune, size: 16),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('products').snapshots(),
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.55,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: products[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailsScreen(product: products[index]),
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
