import 'package:flutter/material.dart';
import 'package:fashion_store/theme/app_theme.dart';
import 'package:fashion_store/services/cart_service.dart';
import 'package:fashion_store/widgets/cart_item_tile_new.dart';
import 'package:fashion_store/screens/checkout_screen.dart';
import 'package:fashion_store/screens/product_listing_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    await _cartService.loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _cartService,
      builder: (context, child) {
        final items = _cartService.items;
        final subtotal = _cartService.subtotal;
        final shipping = _cartService.shipping;
        final tax = _cartService.tax;
        final total = _cartService.total;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.deepBlack),
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
            centerTitle: true,
          ),
          body: _cartService.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
              : items.isEmpty
                  ? _buildEmptyCart()
                  : _buildCartContent(items, subtotal, shipping, tax, total),
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductListingScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('CONTINUE SHOPPING'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(List items, double subtotal, double shipping, double tax, double total) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Bag',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.deepBlack,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_cartService.itemCount} ${_cartService.itemCount == 1 ? 'item' : 'items'} in your bag',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey[300],
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return CartItemTileNew(
                      cartItem: item,
                      onIncrement: () async {
                        await _cartService.updateQuantity(
                          item.productId,
                          item.quantity + 1,
                          size: item.size,
                          color: item.color,
                        );
                      },
                      onDecrement: () async {
                        await _cartService.updateQuantity(
                          item.productId,
                          item.quantity - 1,
                          size: item.size,
                          color: item.color,
                        );
                      },
                      onRemove: () async {
                        await _cartService.removeItem(
                          item.productId,
                          size: item.size,
                          color: item.color,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        _buildOrderSummary(subtotal, shipping, tax, total),
      ],
    );
  }

  Widget _buildOrderSummary(double subtotal, double shipping, double tax, double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ORDER SUMMARY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Subtotal', 'Rs. ${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Shipping',
            shipping == 0 ? 'FREE' : 'Rs. ${shipping.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow('Tax (18% GST)', 'Rs. ${tax.toStringAsFixed(2)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Rs. ${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 54,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CheckoutScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepBlack,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text('PROCEED TO CHECKOUT  →'),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Secure SSL Encrypted Checkout',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
