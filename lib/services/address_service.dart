import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Address {
  final String id;
  final String fullName;
  final String phone;
  final String streetAddress;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;
  final String? label; // Home, Work, etc.

  Address({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = 'India',
    this.isDefault = false,
    this.label,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      streetAddress: json['streetAddress'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
      country: json['country'] ?? 'India',
      isDefault: json['isDefault'] ?? false,
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'isDefault': isDefault,
      'label': label,
    };
  }

  String get formattedAddress {
    return '$streetAddress, $city, $state $postalCode, $country';
  }
}

class AddressService {
  static final AddressService _instance = AddressService._internal();
  factory AddressService() => _instance;
  AddressService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<List<Address>> getAddresses() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .orderBy('isDefault', descending: true)
          .get();

      return snapshot.docs.map((doc) => Address.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e) {
      print('Error getting addresses: $e');
      return [];
    }
  }

  Future<Address?> getDefaultAddress() async {
    final addresses = await getAddresses();
    return addresses.firstWhere(
      (addr) => addr.isDefault,
      orElse: () => addresses.isNotEmpty ? addresses.first : null as Address,
    );
  }

  Future<void> addAddress(Address address) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please login to add address');

    try {
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc();

      final data = {
        ...address.toJson(),
        'id': docRef.id,
        'createdAt': Timestamp.now(),
      };

      // If this is the first address or marked as default, update other addresses
      if (address.isDefault) {
        await _unsetDefaultAddresses(user.uid);
      }

      await docRef.set(data);
    } catch (e) {
      print('Error adding address: $e');
      rethrow;
    }
  }

  Future<void> updateAddress(Address address) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please login to update address');

    try {
      if (address.isDefault) {
        await _unsetDefaultAddresses(user.uid);
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(address.id)
          .update({
            ...address.toJson(),
            'updatedAt': Timestamp.now(),
          });
    } catch (e) {
      print('Error updating address: $e');
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please login to delete address');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(addressId)
          .delete();
    } catch (e) {
      print('Error deleting address: $e');
      rethrow;
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please login');

    try {
      await _unsetDefaultAddresses(user.uid);
      
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(addressId)
          .update({'isDefault': true});
    } catch (e) {
      print('Error setting default address: $e');
      rethrow;
    }
  }

  Future<void> _unsetDefaultAddresses(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .where('isDefault', isEqualTo: true)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({'isDefault': false});
    }
  }
}
