import 'package:flutter/material.dart';
import 'package:fashion_store/theme/app_theme.dart';
import 'package:fashion_store/services/product_service.dart';
import 'package:fashion_store/models/product.dart';
import 'package:fashion_store/widgets/custom_button.dart';
import 'package:fashion_store/widgets/custom_text_field.dart';

class ReviewsScreen extends StatefulWidget {
  final String productId;

  const ReviewsScreen({super.key, required this.productId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class Review {
  final String id;
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;
  final String? userImage;
  final List<String>? images;
  final bool verifiedPurchase;

  Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    this.userImage,
    this.images,
    this.verifiedPurchase = false,
  });
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final _productService = ProductService();
  final _reviewController = TextEditingController();
  Product? _product;
  double _selectedRating = 5;
  bool _isLoading = true;

  // Sample reviews - in production, fetch from Firestore
  List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadProduct();
    _loadSampleReviews();
  }

  Future<void> _loadProduct() async {
    final product = await _productService.getProductById(widget.productId);
    setState(() {
      _product = product;
      _isLoading = false;
    });
  }

  void _loadSampleReviews() {
    _reviews = [
      Review(
        id: '1',
        userName: 'Sarah M.',
        rating: 5,
        comment: 'Absolutely love this! The quality is amazing and it fits perfectly. Would definitely recommend.',
        date: DateTime.now().subtract(const Duration(days: 3)),
        verifiedPurchase: true,
      ),
      Review(
        id: '2',
        userName: 'John D.',
        rating: 4,
        comment: 'Great product, but shipping took a bit longer than expected. Still happy with the purchase.',
        date: DateTime.now().subtract(const Duration(days: 7)),
        verifiedPurchase: true,
      ),
      Review(
        id: '3',
        userName: 'Emily R.',
        rating: 5,
        comment: 'Exceeded my expectations! The material feels premium and the color is exactly as shown.',
        date: DateTime.now().subtract(const Duration(days: 14)),
        verifiedPurchase: true,
      ),
    ];
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    return _reviews.fold<double>(0, (sum, r) => sum + r.rating) / _reviews.length;
  }

  Map<int, int> get _ratingDistribution {
    final distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final review in _reviews) {
      distribution[review.rating.toInt()] = (distribution[review.rating.toInt()] ?? 0) + 1;
    }
    return distribution;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.deepBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'REVIEWS & RATINGS',
          style: TextStyle(
            color: AppTheme.deepBlack,
            fontSize: 14,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Info
                  if (_product != null)
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _product!.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _product!.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _product!.formattedPrice,
                                style: TextStyle(
                                  color: AppTheme.gold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),

                  // Rating Overview
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              _averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < _averageRating.floor()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: AppTheme.gold,
                                  size: 20,
                                );
                              }),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_reviews.length} reviews',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            children: [5, 4, 3, 2, 1].map((rating) {
                              final count = _ratingDistribution[rating] ?? 0;
                              final percentage = _reviews.isEmpty
                                  ? 0.0
                                  : count / _reviews.length;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Text(
                                      '$rating',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.star, size: 12, color: AppTheme.gold),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: percentage,
                                        backgroundColor: Colors.grey[300],
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          AppTheme.gold,
                                        ),
                                        minHeight: 6,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$count',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Write Review Button
                  CustomButton(
                    text: 'WRITE A REVIEW',
                    onPressed: () => _showReviewDialog(),
                  ),
                  const SizedBox(height: 24),

                  // Reviews List
                  const Text(
                    'CUSTOMER REVIEWS',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._reviews.map((review) => _buildReviewCard(review)),
                ],
              ),
            ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.lightGrey,
                child: Text(
                  review.userName[0],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: AppTheme.gold,
                            size: 14,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '${review.date.day}/${review.date.month}/${review.date.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (review.verifiedPurchase)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 12, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Write a Review',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Your Rating'),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _selectedRating
                                ? Icons.star
                                : Icons.star_border,
                            color: AppTheme.gold,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedRating = index + 1.0;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Your Review',
                      controller: _reviewController,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'SUBMIT REVIEW',
                      onPressed: () {
                        if (_reviewController.text.isNotEmpty) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Review submitted successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
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

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
