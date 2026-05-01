import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fashion_store/services/product_seeder.dart';

class FirebaseSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if products exist
  static Future<bool> hasProducts() async {
    try {
      final snapshot = await _firestore.collection('products').limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking products: $e');
      return false;
    }
  }

  // Get product count
  static Future<int> getProductCount() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting product count: $e');
      return 0;
    }
  }

  // Seed all data
  static Future<void> seedAllData() async {
    print('🌱 Starting complete data seeding...');
    
    // Seed products
    await ProductSeeder.seedProducts();
    
    print('✅ All data seeded successfully!');
  }

  // Show seeder dialog
  static void showSeederDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seed Database'),
        content: const Text(
          'This will add sample products to your Firebase database. '
          'Use this for testing when products are empty.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 20),
                      Text('Seeding products...'),
                    ],
                  ),
                ),
              );
              
              try {
                await seedAllData();
                
                if (context.mounted) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Products seeded successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('SEED NOW'),
          ),
        ],
      ),
    );
  }

  // Show data status
  static void showDataStatus(BuildContext context) async {
    final count = await getProductCount();
    
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Database Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Products in database: $count'),
              const SizedBox(height: 8),
              if (count == 0)
                const Text(
                  '⚠️ No products found! Tap "Seed Products" to add sample data.',
                  style: TextStyle(color: Colors.orange),
                )
              else
                const Text(
                  '✅ Products are available in the database.',
                  style: TextStyle(color: Colors.green),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE'),
            ),
            if (count == 0)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  showSeederDialog(context);
                },
                child: const Text('SEED PRODUCTS'),
              ),
          ],
        ),
      );
    }
  }
}
