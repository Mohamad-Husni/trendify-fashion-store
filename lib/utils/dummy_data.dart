import 'package:fashion_store/models/product.dart';
import 'package:fashion_store/models/category.dart';
import 'package:fashion_store/models/cart_item.dart';
import 'package:fashion_store/models/user.dart';

class DummyData {
  static final User currentUser = User(
    name: 'Jane Doe',
    email: 'jane.doe@example.com',
  );

  static final List<Category> categories = [
    Category(id: 'c1', name: 'ALL'),
    Category(id: 'c2', name: 'DRESSES'),
    Category(id: 'c3', name: 'ACCESSORIES'),
    Category(id: 'c4', name: 'SHOES'),
    Category(id: 'c5', name: 'MENSWEAR'),
  ];

  static final List<Product> products = [
    Product(
      id: 'p1',
      title: 'Silk Wrap Dress',
      collection: 'ETHEREAL COLLECTION',
      description:
          'Crafted from the finest mulberry silk, this wrap dress embodies effortless sophistication. Its fluid silhouette drapes gracefully, offering a minimalist aesthetic that transitions seamlessly from day to evening. A quiet statement piece for the modern wardrobe.',
      price: 18500.0,
      imageUrl:
          'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=1200&q=90',
      rating: 4.8,
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      colors: ['Cream', 'Onyx', 'Rose'],
    ),
    Product(
      id: 'p2',
      title: 'Minimalist Clutch',
      collection: 'ACCESSORIES',
      description: 'A sleek and modern clutch designed for everyday elegance.',
      price: 8200.0,
      imageUrl:
          'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=1200&q=90',
      rating: 4.9,
      sizes: ['OS'],
      colors: ['Black', 'Tan'],
    ),
    Product(
      id: 'p3',
      title: 'Leather Mules',
      collection: 'FOOTWEAR',
      description:
          'Comfortable premium leather mules perfect for all-day wear.',
      price: 6800.0,
      imageUrl:
          'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=1200&q=90',
      rating: 4.6,
      sizes: ['38', '39', '40', '41'],
      colors: ['Black', 'Brown'],
    ),
    Product(
      id: 'p4',
      title: 'Linen Trousers',
      collection: 'MENSWEAR',
      description:
          'Lightweight linen trousers tailored for a relaxed yet refined fit.',
      price: 5400.0,
      imageUrl:
          'https://images.unsplash.com/photo-1606777553018-05f12e63d932?auto=format&fit=crop&w=1200&q=90',
      rating: 4.7,
      sizes: ['28', '30', '32', '34', '36'],
      colors: ['Beige', 'Navy'],
    ),
    Product(
      id: 'p5',
      title: 'Structured Linen Blazer',
      collection: 'MENSWEAR',
      description: 'A versatile linen blazer for smarter occasions.',
      price: 24500.0,
      imageUrl:
          'https://images.unsplash.com/photo-1507522974820-cef266b406df?auto=format&fit=crop&w=1200&q=90',
      rating: 4.5,
      sizes: ['S', 'M', 'L'],
      colors: ['Cream', 'Navy'],
    ),
  ];

  static List<CartItem> cartItems = [
    CartItem(
      id: 'ci1',
      product: products[0],
      selectedSize: 'M',
      selectedColor: 'Cream',
      quantity: 1,
    ),
    CartItem(
      id: 'ci2',
      product: products[1],
      selectedSize: 'OS',
      selectedColor: 'Black',
      quantity: 1,
    ),
  ];
}
