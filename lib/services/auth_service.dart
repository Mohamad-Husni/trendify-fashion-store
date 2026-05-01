import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final bool isEmailVerified;

  AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.isEmailVerified = false,
  });

  factory AuthUser.fromFirebaseUser(User user) {
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      phoneNumber: user.phoneNumber,
      isEmailVerified: user.emailVerified,
    );
  }
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  String? get userId => _currentUser?.uid;

  // Stream of auth state changes
  Stream<AuthUser?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user != null) {
        _currentUser = AuthUser.fromFirebaseUser(user);
        return _currentUser;
      }
      _currentUser = null;
      return null;
    });
  }

  // Initialize and check current user
  Future<void> initialize() async {
    final user = _auth.currentUser;
    if (user != null) {
      _currentUser = AuthUser.fromFirebaseUser(user);
      await _updateUserLastLogin(user.uid);
    }
    notifyListeners();
  }

  // Register with email and password
  Future<AuthUser?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update display name
        await userCredential.user!.updateDisplayName(name);

        // Create user document in Firestore
        await _createUserDocument(
          uid: userCredential.user!.uid,
          email: email,
          name: name,
          phone: phone,
        );

        _currentUser = AuthUser.fromFirebaseUser(userCredential.user!);
        _isLoading = false;
        notifyListeners();
        return _currentUser;
      }
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      print('Registration error: ${e.code} - ${e.message}');
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
      print('Registration error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  // Login with email and password
  Future<AuthUser?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _updateUserLastLogin(userCredential.user!.uid);
        _currentUser = AuthUser.fromFirebaseUser(userCredential.user!);
        _isLoading = false;
        notifyListeners();
        return _currentUser;
      }
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      print('Login error: ${e.code} - ${e.message}');
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
      print('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  // Sign in with Google
  Future<AuthUser?> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Check if user document exists
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          // Create user document for new Google sign-in
          await _createUserDocument(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            name: userCredential.user!.displayName ?? 'User',
            photoURL: userCredential.user!.photoURL,
          );
        } else {
          await _updateUserLastLogin(userCredential.user!.uid);
        }

        _currentUser = AuthUser.fromFirebaseUser(userCredential.user!);
        _isLoading = false;
        notifyListeners();
        return _currentUser;
      }
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      print('Google sign-in error: ${e.code} - ${e.message}');
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
      print('Google sign-in error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      print('Password reset error: ${e.code} - ${e.message}');
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
      print('Password reset error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Update user profile
  Future<bool> updateProfile({String? displayName, String? photoURL}) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      // Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        if (displayName != null) 'name': displayName,
        if (photoURL != null) 'photoURL': photoURL,
        'updatedAt': Timestamp.now(),
      });

      // Refresh current user
      await user.reload();
      if (_auth.currentUser != null) {
        _currentUser = AuthUser.fromFirebaseUser(_auth.currentUser!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update profile: $e';
      print('Update profile error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      print('Change password error: ${e.code} - ${e.message}');
    } catch (e) {
      _error = 'Failed to change password: $e';
      print('Change password error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _currentUser = null;
    } catch (e) {
      print('Logout error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create user document in Firestore
  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String name,
    String? phone,
    String? photoURL,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'userId': uid,
        'email': email,
        'name': name,
        'phone': phone,
        'photoURL': photoURL,
        'createdAt': Timestamp.now(),
        'lastLogin': Timestamp.now(),
        'isActive': true,
      });
    } catch (e) {
      print('Error creating user document: $e');
    }
  }

  // Update user last login
  Future<void> _updateUserLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLogin': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  // Get error message
  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'requires-recent-login':
        return 'Please log out and log in again to perform this action.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials.';
      case 'invalid-credential':
        return 'The provided credential is invalid or has expired.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
