import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // ==================== REGISTER ====================
  Future<AuthResult> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String username,
  }) async {
    try {
      // Check if username is already taken
      final usernameCheck = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        return AuthResult(
          success: false,
          errorMessage: 'Username is already taken',
        );
      }

      // Create user in Firebase Auth
      final UserCredential credential =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        return AuthResult(
          success: false,
          errorMessage: 'Failed to create account',
        );
      }

      // Create user document in Firestore
      final UserModel newUser = UserModel(
        id: credential.user!.uid,
        email: email.trim(),
        name: name.trim(),
        username: username.toLowerCase().trim(),
        profilePicture: '',
        bio: '',
        followers: 0,
        following: 0,
        projectsCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(newUser.toMap());

      // Update display name in Firebase Auth
      await credential.user!.updateDisplayName(name.trim());

      notifyListeners();

      return AuthResult(
        success: true,
        user: newUser,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      debugPrint('Registration error: $e');
      return AuthResult(
        success: false,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // ==================== LOGIN ====================
  Future<AuthResult> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        return AuthResult(
          success: false,
          errorMessage: 'Failed to sign in',
        );
      }

      // Fetch user data from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      // If user document doesn't exist, create it!
      if (!userDoc.exists) {
        debugPrint('User document not found, creating one...');

        // Create user document from Auth data
        final UserModel newUser = UserModel(
          id: credential.user!.uid,
          email: credential.user!.email ?? email.trim(),
          name: credential.user!.displayName ?? 'User',
          username: email.split('@')[0].toLowerCase(),
          profilePicture: credential.user!.photoURL ?? '',
          bio: '',
          followers: 0,
          following: 0,
          projectsCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(newUser.toMap());

        notifyListeners();

        return AuthResult(
          success: true,
          user: newUser,
        );
      }

      final UserModel user = UserModel.fromMap(
        userDoc.data()!,
        userDoc.id,
      );

      notifyListeners();

      return AuthResult(
        success: true,
        user: user,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      debugPrint('Login error: $e');
      return AuthResult(
        success: false,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  // ==================== PASSWORD RESET ====================
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult(
        success: true,
        message: 'Password reset email sent successfully',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  // ==================== UPDATE PASSWORD ====================
  Future<AuthResult> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return AuthResult(
          success: false,
          errorMessage: 'No user logged in',
        );
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      return AuthResult(
        success: true,
        message: 'Password updated successfully',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  // ==================== UPDATE EMAIL ====================
  Future<AuthResult> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return AuthResult(
          success: false,
          errorMessage: 'No user logged in',
        );
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Update email
      await user.verifyBeforeUpdateEmail(newEmail.trim());

      // Update email in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'email': newEmail.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return AuthResult(
        success: true,
        message: 'Verification email sent to new address',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  // ==================== DELETE ACCOUNT ====================
  Future<AuthResult> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return AuthResult(
          success: false,
          errorMessage: 'No user logged in',
        );
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Delete user data from Firestore
      await _deleteUserData(user.uid);

      // Delete user from Firebase Auth
      await user.delete();

      notifyListeners();

      return AuthResult(
        success: true,
        message: 'Account deleted successfully',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  // ==================== GET CURRENT USER DATA ====================
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc =
      await _firestore.collection('users').doc(user.uid).get();

      // If user document doesn't exist, create it
      if (!userDoc.exists) {
        final UserModel newUser = UserModel(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? 'User',
          username: (user.email ?? 'user').split('@')[0].toLowerCase(),
          profilePicture: user.photoURL ?? '',
          bio: '',
          followers: 0,
          following: 0,
          projectsCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        return newUser;
      }

      return UserModel.fromMap(userDoc.data()!, userDoc.id);
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  // ==================== CHECK AND CREATE USER DOCUMENT ====================
  Future<UserModel?> ensureUserDocument() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // Create user document
        final UserModel newUser = UserModel(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? 'User',
          username: (user.email ?? 'user').split('@')[0].toLowerCase(),
          profilePicture: user.photoURL ?? '',
          bio: '',
          followers: 0,
          following: 0,
          projectsCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        return newUser;
      }

      return UserModel.fromMap(userDoc.data()!, userDoc.id);
    } catch (e) {
      debugPrint('Error ensuring user document: $e');
      return null;
    }
  }

  // ==================== HELPER METHODS ====================

  // Delete all user data from Firestore
  Future<void> _deleteUserData(String userId) async {
    try {
      final batch = _firestore.batch();

      // Delete user document
      batch.delete(_firestore.collection('users').doc(userId));

      // Delete user's projects
      final projects = await _firestore
          .collection('projects')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in projects.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's products
      final products = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: userId)
          .get();

      for (final doc in products.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting user data: $e');
    }
  }

  // Get user-friendly error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'weak-password':
        return 'Password must be at least 6 characters';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'requires-recent-login':
        return 'Please log in again to perform this action';
      default:
        return 'An error occurred. Please try again';
    }
  }
}

// ==================== AUTH RESULT CLASS ====================
class AuthResult {
  final bool success;
  final String? errorMessage;
  final String? message;
  final UserModel? user;

  AuthResult({
    required this.success,
    this.errorMessage,
    this.message,
    this.user,
  });
}