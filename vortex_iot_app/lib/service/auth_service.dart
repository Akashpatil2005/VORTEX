import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  // Singleton pattern
  static final AuthServices _instance = AuthServices._internal();
  factory AuthServices() => _instance;
  AuthServices._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Create user with email and password
  Future<User?> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      log(password);
      // Update display name
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload(); // refresh info

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  /// Login user with email and password
  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      log(password);

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      log('loggedin');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      log('$e not loooged');

      throw _handleAuthException(e);
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Private method to handle common Firebase Auth exceptions
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return Exception("The email address is badly formatted.");
      case 'user-disabled':
        return Exception("This user has been disabled.");
      case 'user-not-found':
        return Exception("No user found with this email.");
      case 'wrong-password':
        return Exception("Incorrect password provided.");
      case 'email-already-in-use':
        return Exception("Email is already registered.");
      case 'operation-not-allowed':
        return Exception("Operation not allowed.");
      case 'weak-password':
        return Exception("Password is too weak.");
      default:
        return Exception(e.message);
    }
  }
}
