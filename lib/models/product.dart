import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Product {
  final String id;
  final String title;
  final String collection;
  final String description;
  final double price;
  final String imageUrl;
  final double rating;
  final List<String> sizes;
  final List<String> colors;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.title,
    required this.collection,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.rating = 0.0,
    required this.sizes,
    required this.colors,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get formattedPrice {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return 'Rs. ${formatter.format(price)}';
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      collection: json['collection'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      sizes: List<String>.from(json['sizes'] ?? []),
      colors: List<String>.from(json['colors'] ?? []),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'collection': collection,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'rating': rating,
      'sizes': sizes,
      'colors': colors,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
