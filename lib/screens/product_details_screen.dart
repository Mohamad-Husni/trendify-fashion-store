import 'package:flutter/material.dart';
import 'package:fashion_store/models/product.dart';
import 'package:fashion_store/theme/app_theme.dart';
import 'package:fashion_store/services/cart_service.dart';
import 'package:fashion_store/services/wishlist_service.dart';
import 'package:fashion_store/screens/reviews_screen.dart';
import 'package:fashion_store/screens/cart_screen.dart';
import 'package:fashion_store/screens/checkout_screen.dart';
import 'package:fashion_store/screens/wishlist_screen.dart';
import 'package:fashion_store/widgets/custom_button.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? selectedSize;
  String? selectedColor;

  @override
  void initState() {
    super.initState();
    if (widget.product.sizes.isNotEmpty) {
      selectedSize = widget.product.sizes.first;
    }
    if (widget.product.colors.isNotEmpty) {
      selectedColor = widget.product.colors.first;
    }
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
            icon: const Icon(Icons.favorite_outline),
            onPressed: () async {
              try {
                await WishlistService().toggleWishlist(widget.product.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.product.title} added to wishlist!'),
                      backgroundColor: Colors.green,
                      action: SnackBarAction(
                        label: 'VIEW',
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const WishlistScreen()),
                          );
                        },
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please login to add to wishlist'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product-image-${widget.product.id}',
              child: Container(
                height: 400,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  image: DecorationImage(
                    image: NetworkImage(widget.product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.title,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 28,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.product.collection,
                              style: const TextStyle(
                                color: AppTheme.grey,
                                fontSize: 10,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.deepBlack,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.product.description,
                    style: const TextStyle(
                      color: AppTheme.deepBlack,
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Rating & Reviews Button
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewsScreen(productId: widget.product.id),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppTheme.gold, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.product.rating}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'See all reviews',
                          style: TextStyle(
                            color: Colors.grey[600],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'COLOR',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        selectedColor ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: widget.product.colors.map((color) {
                      Color boxColor = _getColorFromName(color);
                      bool isSelected = selectedColor == color;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.deepBlack
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: boxColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SIZE',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        'Size Guide',
                        style: TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          color: AppTheme.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: widget.product.sizes.map((size) {
                      bool isSelected = selectedSize == size;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSize = size;
                            });
                          },
                          child: Container(
                            height: 48,
                            margin: const EdgeInsets.only(right: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.deepBlack
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.deepBlack
                                    : AppTheme.lightGrey,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              size,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.deepBlack,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 48),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'ADD TO CART',
                          onPressed: () async {
                            if (widget.product.sizes.isNotEmpty && selectedSize == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a size'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            if (widget.product.colors.isNotEmpty && selectedColor == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a color'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            
                            final cartService = CartService();
                            await cartService.addItem(
                              product: widget.product,
                              quantity: 1,
                              size: selectedSize,
                              color: selectedColor,
                            );
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${widget.product.title} added to cart!'),
                                  backgroundColor: Colors.green,
                                  action: SnackBarAction(
                                    label: 'VIEW CART',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const CartScreen()),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          text: 'BUY NOW',
                          backgroundColor: AppTheme.deepBlack,
                          onPressed: () async {
                            if (widget.product.sizes.isNotEmpty && selectedSize == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a size'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            if (widget.product.colors.isNotEmpty && selectedColor == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a color'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            
                            // Add to cart first
                            final cartService = CartService();
                            await cartService.addItem(
                              product: widget.product,
                              quantity: 1,
                              size: selectedSize,
                              color: selectedColor,
                            );
                            
                            if (context.mounted) {
                              // Go directly to checkout
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorFromName(String color) {
    switch (color.toLowerCase()) {
      case 'cream':
        return const Color(0xFFFDFBF7);
      case 'onyx':
      case 'black':
        return const Color(0xFF1B1B1B);
      case 'rose':
        return const Color(0xFFD4A5A5);
      case 'navy':
        return const Color(0xFF1B2A47);
      case 'beige':
        return const Color(0xFFE5DCC5);
      case 'tan':
        return const Color(0xFFCAA074);
      case 'brown':
        return const Color(0xFF5C4033);
      default:
        return Colors.grey;
    }
  }
}
