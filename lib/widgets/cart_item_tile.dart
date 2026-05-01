import 'package:flutter/material.dart';
import 'package:fashion_store/models/cart_item.dart';
import 'package:fashion_store/theme/app_theme.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              image: DecorationImage(
                image: NetworkImage(item.product.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: onRemove,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Size: ${item.selectedSize} | Color: ${item.selectedColor}',
                  style: const TextStyle(color: AppTheme.grey, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Text(
                  item.product.formattedPrice,
                  style: const TextStyle(color: AppTheme.gold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildQuantityButton(Icons.remove, onDecrement),
                    Container(
                      width: 40,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color: AppTheme.grey,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Text('${item.quantity}'),
                    ),
                    _buildQuantityButton(Icons.add, onIncrement),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.grey, width: 0.5),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
