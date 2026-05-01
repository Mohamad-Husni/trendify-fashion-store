import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_store/theme/app_theme.dart';
import 'package:fashion_store/screens/login_screen.dart';
import 'package:fashion_store/screens/orders_screen.dart';
import 'package:fashion_store/screens/address_screen.dart';
import 'package:fashion_store/screens/wishlist_screen.dart';
import 'package:fashion_store/screens/cart_screen.dart';
import 'package:fashion_store/screens/search_screen.dart';
import 'package:fashion_store/screens/notifications_screen.dart';
import 'package:fashion_store/screens/payment_methods_screen.dart';
import 'package:fashion_store/screens/settings_screen.dart';
import 'package:fashion_store/utils/firebase_seeder.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

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
            icon: const Icon(Icons.shopping_bag_outlined),
            tooltip: 'Cart',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.lightGrey,
                    child: Icon(Icons.person, size: 50, color: AppTheme.grey),
                  ),
                  const SizedBox(height: 24),
                  FutureBuilder<DocumentSnapshot>(
                    future: _firestore.collection('users').doc(user?.uid).get(),
                    builder: (context, snapshot) {
                      String name = 'Guest User';
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data = snapshot.data!.data() as Map<String, dynamic>?;
                        name = data?['name'] ?? 'User';
                      }
                      return Text(
                        name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w300,
                          color: AppTheme.deepBlack,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? 'No email',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(user?.uid)
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                int orderCount = 0;
                if (snapshot.hasData) {
                  orderCount = snapshot.data!.docs.length;
                }
                return _buildProfileMenuItem(
                  Icons.local_shipping_outlined,
                  'MY ORDERS',
                  subtitle: orderCount > 0 ? '$orderCount orders' : 'No orders yet',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OrdersScreen()),
                    );
                  },
                );
              },
            ),
            const Divider(color: AppTheme.lightGrey, height: 1, thickness: 1),
            _buildProfileMenuItem(
              Icons.location_on_outlined,
              'ADDRESS BOOK',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddressScreen()),
                );
              },
            ),
            const Divider(color: AppTheme.lightGrey, height: 1, thickness: 1),
            _buildProfileMenuItem(
              Icons.payment_outlined,
              'PAYMENT METHODS',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
                );
              },
            ),
            const Divider(color: AppTheme.lightGrey, height: 1, thickness: 1),
            _buildProfileMenuItem(
              Icons.favorite_border,
              'MY WISHLIST',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WishlistScreen()),
                );
              },
            ),
            const Divider(color: AppTheme.lightGrey, height: 1, thickness: 1),
            _buildProfileMenuItem(
              Icons.search,
              'SEARCH PRODUCTS',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
            ),
            const Divider(color: AppTheme.lightGrey, height: 1, thickness: 1),
            _buildProfileMenuItem(
              Icons.notifications_outlined,
              'NOTIFICATIONS',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
            ),
            const Divider(color: AppTheme.lightGrey, height: 1, thickness: 1),
            _buildProfileMenuItem(
              Icons.settings_outlined,
              'SETTINGS',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            const Divider(color: AppTheme.lightGrey, height: 1, thickness: 1),
            
            // Database Management Section (for development)
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.admin_panel_settings, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'DATABASE MANAGEMENT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildProfileMenuItem(
                    Icons.cloud_upload,
                    'SEED PRODUCTS',
                    subtitle: 'Add sample products to database',
                    onTap: () => FirebaseSeeder.showSeederDialog(context),
                  ),
                  const Divider(color: AppTheme.lightGrey, height: 1, thickness: 1),
                  _buildProfileMenuItem(
                    Icons.storage,
                    'CHECK DATABASE STATUS',
                    subtitle: 'View product count',
                    onTap: () => FirebaseSeeder.showDataStatus(context),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            TextButton.icon(
              onPressed: () async {
                await _auth.signOut();
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              },
              icon: const Icon(
                Icons.logout,
                color: AppTheme.deepBlack,
                size: 20,
              ),
              label: const Text(
                'LOGOUT',
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.deepBlack,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem(
    IconData icon,
    String title, {
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Icon(icon, color: AppTheme.deepBlack),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.grey,
              ),
            )
          : null,
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppTheme.grey,
      ),
      onTap: onTap,
    );
  }

  void _showOrdersBottomSheet(BuildContext context, List<QueryDocumentSnapshot> orders) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        if (orders.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(
              child: Text(
                'No orders yet',
                style: TextStyle(fontSize: 16, color: AppTheme.grey),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index].data() as Map<String, dynamic>;
            final items = (order['items'] as List<dynamic>?) ?? [];
            final timestamp = order['createdAt'] as Timestamp?;
            final date = timestamp?.toDate();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${orders[index].id.substring(0, 8)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.gold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            order['status']?.toString().toUpperCase() ?? 'PENDING',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.gold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      date != null
                          ? '${date.day}/${date.month}/${date.year}'
                          : 'Unknown date',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.grey,
                      ),
                    ),
                    const Divider(height: 16),
                    Text(
                      '${items.length} item${items.length != 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs. ${(order['subtotal'] ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
