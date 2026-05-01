import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserProfile {
  final String uid;
  final String email;
  final String name;
  final String? phone;
  final String? photoURL;
  final DateTime? dateOfBirth;
  final String? gender;
  final List<String>? preferences;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;

  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    this.phone,
    this.photoURL,
    this.dateOfBirth,
    this.gender,
    this.preferences,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json, String uid) {
    return UserProfile(
      uid: uid,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      photoURL: json['photoURL'],
      dateOfBirth: (json['dateOfBirth'] as Timestamp?)?.toDate(),
      gender: json['gender'],
      preferences: json['preferences'] != null
          ? List<String>.from(json['preferences'])
          : null,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (json['lastLogin'] as Timestamp?)?.toDate(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'photoURL': photoURL,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'gender': gender,
      'preferences': preferences,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'isActive': isActive,
    };
  }

  String get initials {
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

class UserStats {
  final int totalOrders;
  final int wishlistCount;
  final int addressCount;
  final double totalSpent;
  final DateTime? lastOrderDate;

  UserStats({
    this.totalOrders = 0,
    this.wishlistCount = 0,
    this.addressCount = 0,
    this.totalSpent = 0.0,
    this.lastOrderDate,
  });
}

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserProfile? _profile;
  UserStats? _stats;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  UserStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _profile != null;

  String? get _userId => _auth.currentUser?.uid;

  // Stream of user profile for real-time updates
  Stream<UserProfile?> get profileStream {
    final userId = _userId;
    if (userId == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return UserProfile.fromJson(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  // Load user profile
  Future<void> loadProfile() async {
    final userId = _userId;
    if (userId == null) {
      _profile = null;
      _error = 'User not logged in';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        _profile = UserProfile.fromJson(doc.data()!, doc.id);
        _error = null;
      } else {
        _error = 'User profile not found';
      }
    } catch (e) {
      _error = 'Failed to load profile: $e';
      print('Error loading profile: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? photoURL,
    DateTime? dateOfBirth,
    String? gender,
    List<String>? preferences,
  }) async {
    final userId = _userId;
    if (userId == null) {
      _error = 'User not logged in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.now(),
      };

      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (photoURL != null) updates['photoURL'] = photoURL;
      if (dateOfBirth != null) updates['dateOfBirth'] = Timestamp.fromDate(dateOfBirth);
      if (gender != null) updates['gender'] = gender;
      if (preferences != null) updates['preferences'] = preferences;

      await _firestore.collection('users').doc(userId).update(updates);

      // Reload profile
      await loadProfile();

      return true;
    } catch (e) {
      _error = 'Failed to update profile: $e';
      print('Error updating profile: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Load user statistics
  Future<void> loadStats() async {
    final userId = _userId;
    if (userId == null) {
      _stats = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Get order count and total spent
      final ordersSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .get();

      final totalOrders = ordersSnapshot.docs.length;
      double totalSpent = 0.0;
      DateTime? lastOrderDate;

      for (final doc in ordersSnapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String?;
        if (status != 'cancelled') {
          totalSpent += (data['total'] as num?)?.toDouble() ?? 0;
        }
        
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        if (createdAt != null) {
          if (lastOrderDate == null || createdAt.isAfter(lastOrderDate)) {
            lastOrderDate = createdAt;
          }
        }
      }

      // Get wishlist count
      final wishlistDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc('items')
          .get();

      final wishlistCount = wishlistDoc.exists
          ? (wishlistDoc.data()?['productIds'] as List<dynamic>?)?.length ?? 0
          : 0;

      // Get address count
      final addressesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .get();

      final addressCount = addressesSnapshot.docs.length;

      _stats = UserStats(
        totalOrders: totalOrders,
        wishlistCount: wishlistCount,
        addressCount: addressCount,
        totalSpent: totalSpent,
        lastOrderDate: lastOrderDate,
      );
    } catch (e) {
      print('Error loading stats: $e');
      _stats = UserStats();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add to preferences
  Future<bool> addPreference(String preference) async {
    final userId = _userId;
    if (userId == null) return false;

    try {
      final currentPrefs = _profile?.preferences ?? [];
      if (!currentPrefs.contains(preference)) {
        currentPrefs.add(preference);
        await updateProfile(preferences: currentPrefs);
      }
      return true;
    } catch (e) {
      print('Error adding preference: $e');
      return false;
    }
  }

  // Remove from preferences
  Future<bool> removePreference(String preference) async {
    final userId = _userId;
    if (userId == null) return false;

    try {
      final currentPrefs = _profile?.preferences ?? [];
      currentPrefs.remove(preference);
      await updateProfile(preferences: currentPrefs);
      return true;
    } catch (e) {
      print('Error removing preference: $e');
      return false;
    }
  }

  // Deactivate account
  Future<bool> deactivateAccount() async {
    final userId = _userId;
    if (userId == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': false,
        'deactivatedAt': Timestamp.now(),
      });

      return true;
    } catch (e) {
      _error = 'Failed to deactivate account: $e';
      print('Error deactivating account: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Delete account completely
  Future<bool> deleteAccount() async {
    final userId = _userId;
    if (userId == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Delete user data from Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Delete subcollections
      final batch = _firestore.batch();

      final addresses = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .get();
      for (final doc in addresses.docs) {
        batch.delete(doc.reference);
      }

      final orders = await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .get();
      for (final doc in orders.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // Delete Firebase Auth user
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }

      return true;
    } catch (e) {
      _error = 'Failed to delete account: $e';
      print('Error deleting account: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Clear cache
  void clearCache() {
    _profile = null;
    _stats = null;
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
