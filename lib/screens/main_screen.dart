import 'package:flutter/material.dart';
import 'package:fashion_store/theme/app_theme.dart';
import 'package:fashion_store/screens/home_screen.dart';
import 'package:fashion_store/screens/product_listing_screen.dart';
import 'package:fashion_store/screens/cart_screen.dart';
import 'package:fashion_store/screens/profile_screen.dart';
import 'package:fashion_store/screens/search_screen.dart';
import 'package:fashion_store/screens/wishlist_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    ProductListingScreen(),
    const CartScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_outlined, Icons.home, 'HOME', 0),
                _buildNavItem(Icons.storefront_outlined, Icons.storefront, 'SHOP', 1),
                _buildCenterButton(),
                _buildNavItem(Icons.favorite_outline, Icons.favorite, 'WISHLIST', 3, isSpecial: true),
                _buildNavItem(Icons.person_outline, Icons.person, 'PROFILE', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label, int index, {bool isSpecial = false}) {
    final isSelected = _currentIndex == index && !isSpecial;
    return InkWell(
      onTap: () => isSpecial ? _navigateToWishlist() : _onItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppTheme.gold : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.gold : Colors.grey,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () => _onItemTapped(2),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.gold,
              const Color(0xFFE5C100),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.gold.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.shopping_bag,
          color: Colors.black,
          size: 28,
        ),
      ),
    );
  }

  void _navigateToWishlist() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WishlistScreen()),
    );
  }
}
