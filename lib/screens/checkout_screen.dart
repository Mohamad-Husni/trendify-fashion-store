import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fashion_store/theme/app_theme.dart';
import 'package:fashion_store/widgets/custom_button.dart';
import 'package:fashion_store/widgets/custom_text_field.dart';
import 'package:fashion_store/services/address_service.dart';
import 'package:fashion_store/services/cart_service.dart';
import 'package:fashion_store/services/order_service.dart' as order_service;
import 'package:fashion_store/screens/address_screen.dart';
import 'package:fashion_store/screens/orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _stateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _addressService = AddressService();
  final _cartService = CartService();
  final _orderService = order_service.OrderService();
  bool _isLoading = false;
  List<Address> _savedAddresses = [];
  Address? _selectedAddress;
  List<CartItemData> _cartItems = [];
  double _subtotal = 0;
  String _selectedPaymentMethod = 'cod';

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
    _loadCart();
  }

  Future<void> _loadCart() async {
    await _cartService.loadCart();
    setState(() {
      _cartItems = _cartService.items;
      _subtotal = _cartService.subtotal;
    });
  }

  Future<void> _loadSavedAddresses() async {
    final addresses = await _addressService.getAddresses();
    setState(() {
      _savedAddresses = addresses;
      if (addresses.isNotEmpty) {
        _selectedAddress = addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        );
        _fillAddressFields(_selectedAddress!);
      }
    });
  }

  void _fillAddressFields(Address address) {
    _nameController.text = address.fullName;
    _phoneController.text = address.phone;
    _streetController.text = address.streetAddress;
    _cityController.text = address.city;
    _stateController.text = address.state;
    _zipController.text = address.postalCode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _stateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to place order')),
        );
        return;
      }

      if (_cartItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your cart is empty')),
        );
        return;
      }

      final orderItems = _cartItems.map((item) => order_service.OrderItem(
        productId: item.productId,
        title: item.title,
        price: item.price,
        quantity: item.quantity,
        size: item.size,
        color: item.color,
        imageUrl: item.imageUrl,
      )).toList();

      final order = await _orderService.createOrder(
        items: orderItems,
        subtotal: _subtotal,
        shippingAddress: {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'street': _streetController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'zip': _zipController.text.trim(),
        },
        paymentMethod: _selectedPaymentMethod,
      );

      if (order == null) {
        throw Exception('Failed to create order');
      }

      // Clear cart after successful order
      await _cartService.clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order Placed Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error placing order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
            icon: const Icon(Icons.help_outline),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Secure SSL Encrypted Checkout')),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepper(),
              const SizedBox(height: 32),
              Text(
                'Checkout',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.deepBlack,
                  fontWeight: FontWeight.w300,
                ),
              ),
              _buildSectionTitle('1', 'SHIPPING ADDRESS'),
              const SizedBox(height: 16),

              // Saved Addresses Dropdown
              if (_savedAddresses.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Saved Address',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Address>(
                        value: _selectedAddress,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF2A2A2A),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF2A2A2A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: _savedAddresses.map((address) {
                          return DropdownMenuItem(
                            value: address,
                            child: Text(
                              '${address.label ?? 'Address'} - ${address.streetAddress.substring(0, address.streetAddress.length > 20 ? 20 : address.streetAddress.length)}...',
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (address) {
                          if (address != null) {
                            setState(() {
                              _selectedAddress = address;
                            });
                            _fillAddressFields(address);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Add New Address Button
              if (_savedAddresses.isEmpty)
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddressScreen()),
                    );
                    if (result == true) {
                      _loadSavedAddresses();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('ADD NEW ADDRESS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                  ),
                ),

              const SizedBox(height: 8),
              Text(
                'Enter your shipping details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Full Name',
                hint: '',
                controller: _nameController,
                validator: (value) => _validateRequired(value, 'full name'),
              ),
              CustomTextField(
                label: 'Phone Number',
                hint: '',
                controller: _phoneController,
                validator: (value) => _validateRequired(value, 'phone number'),
              ),
              CustomTextField(
                label: 'Street Address',
                hint: '',
                controller: _streetController,
                validator: (value) => _validateRequired(value, 'street address'),
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'City',
                      hint: '',
                      controller: _cityController,
                      validator: (value) => _validateRequired(value, 'city'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'State',
                      hint: '',
                      controller: _stateController,
                      validator: (value) => _validateRequired(value, 'state'),
                    ),
                  ),
                ],
              ),
              CustomTextField(
                label: 'Zip Code',
                hint: '',
                controller: _zipController,
                validator: (value) => _validateRequired(value, 'zip code'),
              ),
              const SizedBox(height: 32),
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.gold, width: 1),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.radio_button_checked,
                      color: AppTheme.gold,
                      size: 18,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'CREDIT CARD',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.lightGrey, width: 1),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.radio_button_unchecked,
                      color: AppTheme.grey,
                      size: 18,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'PAYPAL',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const CustomTextField(label: 'Card Number', hint: ''),
              Row(
                children: const [
                  Expanded(
                    child: CustomTextField(label: 'Expiry Date', hint: ''),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: CustomTextField(label: 'Security Code', hint: ''),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.lightGrey, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 24),
                    // Summary dummy items
                    _buildSummaryItem(
                      'Structured Linen Blazer',
                      'Cream • Size M',
                      'Rs. 24,500.00',
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryItem(
                      'Essential Gold Hoops',
                      '14k Gold • OS',
                      'Rs. 12,000.00',
                    ),
                    const SizedBox(height: 24),
                    const Divider(
                      color: AppTheme.lightGrey,
                      height: 1,
                      thickness: 1,
                    ),
                    const SizedBox(height: 24),
                    _buildPriceRow('Subtotal', 'Rs. 36,500.00'),
                    const SizedBox(height: 12),
                    _buildPriceRow('Shipping', 'Complimentary'),
                    const SizedBox(height: 12),
                    _buildPriceRow(
                      'Taxes',
                      'Calculated at next step',
                      color: AppTheme.grey,
                    ),
                    const SizedBox(height: 24),
                    const Divider(
                      color: AppTheme.lightGrey,
                      height: 1,
                      thickness: 1,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'TOTAL',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text('Rs. 36,500.00', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: AppTheme.gold),
                          )
                        : CustomButton(
                            text: 'PLACE ORDER',
                            onPressed: _placeOrder,
                          ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'SECURE SSL ENCRYPTED CHECKOUT',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1,
                          color: AppTheme.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String name, String details, String price) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          color: AppTheme.lightGrey,
          // Dummy color box since we might not have the image handy
          child: const Icon(Icons.image, color: AppTheme.grey),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                details,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.grey,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        Text(
          price,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    Color color = AppTheme.deepBlack,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        ),
        Text(value, style: TextStyle(fontSize: 14, color: color)),
      ],
    );
  }

  Widget _buildSectionTitle(String number, String title) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.gold,
            border: Border.all(color: AppTheme.gold, width: 1.5),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStepper() {
    final steps = ['Shipping', 'Payment', 'Review'];
    const currentStep = 0;

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          return Expanded(
            child: Container(
              height: 1,
              color: currentStep >= (index ~/ 2) + 1
                  ? AppTheme.deepBlack
                  : AppTheme.lightGrey,
            ),
          );
        }
        final stepIndex = index ~/ 2;
        final isActive = stepIndex == currentStep;
        final isCompleted = stepIndex < currentStep;
        return Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive || isCompleted
                    ? AppTheme.deepBlack
                    : Colors.transparent,
                border: Border.all(
                  color: isActive || isCompleted
                      ? AppTheme.deepBlack
                      : AppTheme.lightGrey,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : AppTheme.grey,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              steps[stepIndex],
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive || isCompleted
                    ? AppTheme.deepBlack
                    : AppTheme.grey,
                letterSpacing: 0.5,
              ),
            ),
          ],
        );
      }),
    );
  }
}
