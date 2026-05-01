import 'package:flutter/material.dart';
import 'package:fashion_store/theme/app_theme.dart';
import 'package:fashion_store/models/product.dart';
import 'package:fashion_store/services/search_service.dart';
import 'package:fashion_store/screens/product_details_screen.dart';
import 'package:fashion_store/widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchService = SearchService();
  final _searchController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  
  List<Product> _searchResults = [];
  List<String> _categories = [];
  bool _isLoading = false;
  bool _showFilters = false;
  
  String? _selectedCategory;
  String _sortBy = 'newest';
  double? _minRating;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadTrendingProducts();
  }

  Future<void> _loadCategories() async {
    final categories = await _searchService.getCategories();
    setState(() => _categories = categories);
  }

  Future<void> _loadTrendingProducts() async {
    setState(() => _isLoading = true);
    final products = await _searchService.getTrendingProducts();
    setState(() {
      _searchResults = products;
      _isLoading = false;
    });
  }

  Future<void> _performSearch() async {
    setState(() => _isLoading = true);
    
    final results = await _searchService.searchProducts(
      query: _searchController.text.isEmpty ? null : _searchController.text,
      category: _selectedCategory,
      minPrice: _minPriceController.text.isEmpty ? null : double.tryParse(_minPriceController.text),
      maxPrice: _maxPriceController.text.isEmpty ? null : double.tryParse(_maxPriceController.text),
      minRating: _minRating,
      sortBy: _sortBy,
    );
    
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _sortBy = 'newest';
      _minRating = null;
      _minPriceController.clear();
      _maxPriceController.clear();
    });
    _performSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search Products',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.gold, width: 1),
                ),
              ),
              onSubmitted: (_) => _performSearch(),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Filters
          if (_showFilters) _buildFilters(),

          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_searchResults.length} products found',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                if (_selectedCategory != null || _minRating != null || 
                    _minPriceController.text.isNotEmpty || _maxPriceController.text.isNotEmpty)
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
          ),

          // Results Grid
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.gold),
                  )
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text(
                              'No products found',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Try adjusting your search or filters',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final product = _searchResults[index];
                          return ProductCard(
                            product: product,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsScreen(product: product),
                                ),
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

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1E1E1E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Filter
          const Text(
            'Category',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _selectedCategory == null,
                onSelected: (selected) {
                  setState(() => _selectedCategory = null);
                  _performSearch();
                },
                backgroundColor: const Color(0xFF2A2A2A),
                selectedColor: AppTheme.gold,
                checkmarkColor: Colors.black,
                labelStyle: TextStyle(
                  color: _selectedCategory == null ? Colors.black : Colors.white,
                ),
              ),
              ..._categories.map((category) => FilterChip(
                label: Text(category),
                selected: _selectedCategory == category,
                onSelected: (selected) {
                  setState(() => _selectedCategory = selected ? category : null);
                  _performSearch();
                },
                backgroundColor: const Color(0xFF2A2A2A),
                selectedColor: AppTheme.gold,
                checkmarkColor: Colors.black,
                labelStyle: TextStyle(
                  color: _selectedCategory == category ? Colors.black : Colors.white,
                ),
              )),
            ],
          ),

          const SizedBox(height: 16),

          // Price Range
          const Text(
            'Price Range (Rs.)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPriceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Min',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => _performSearch(),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('to'),
              ),
              Expanded(
                child: TextField(
                  controller: _maxPriceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Max',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => _performSearch(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Rating Filter
          const Text(
            'Minimum Rating',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildRatingChip(null, 'Any'),
              _buildRatingChip(4.0, '4+'),
              _buildRatingChip(4.5, '4.5+'),
            ],
          ),

          const SizedBox(height: 16),

          // Sort By
          const Text(
            'Sort By',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSortChip('newest', 'Newest'),
              _buildSortChip('price_low', 'Price: Low to High'),
              _buildSortChip('price_high', 'Price: High to Low'),
              _buildSortChip('rating', 'Highest Rated'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingChip(double? rating, String label) {
    final isSelected = _minRating == rating;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (rating != null) ...[
              const Icon(Icons.star, size: 16, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _minRating = selected ? rating : null);
          _performSearch();
        },
        backgroundColor: const Color(0xFF2A2A2A),
        selectedColor: AppTheme.gold,
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _sortBy = value);
        _performSearch();
      },
      backgroundColor: const Color(0xFF2A2A2A),
      selectedColor: AppTheme.gold,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white,
      ),
    );
  }
}
