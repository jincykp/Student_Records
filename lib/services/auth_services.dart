import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthServices {
  final _auth = FirebaseAuth.instance;
  static const String _isFirstTimeKey = 'is_first_time';
  static const String _isLoggedInKey = 'is_logged_in';

  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user != null) {
        await setFirstTimeFlag(false);
        await setLoggedInFlag(true);
      }
      return cred.user;
    } on FirebaseAuthException catch (e) {
      log('Firebase Auth Error: ${e.code} - ${e.message}');
      // Convert Firebase error codes to user-friendly messages
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('An account already exists with this email address.');
        case 'invalid-email':
          throw Exception('Please enter a valid email address.');
        case 'weak-password':
          throw Exception(
            'Password is too weak. Please use at least 6 characters.',
          );
        case 'operation-not-allowed':
          throw Exception(
            'Email/password accounts are not enabled. Please contact support.',
          );
        case 'network-request-failed':
          throw Exception(
            'Network error. Please check your internet connection.',
          );
        default:
          throw Exception(
            e.message ?? 'Failed to create account. Please try again.',
          );
      }
    } catch (e) {
      log('Auth Error: $e');
      rethrow;
    }
  }

  Future<User?> loginUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user != null) {
        await setLoggedInFlag(true);
      }
      return cred.user;
    } on FirebaseAuthException catch (e) {
      log('Firebase Auth Error: ${e.code} - ${e.message}');
      // Convert Firebase error codes to user-friendly messages
      switch (e.code) {
        case 'invalid-credential':
          throw Exception(
            'Invalid email or password. Please check your credentials and try again.',
          );
        case 'user-not-found':
          throw Exception('No account found with this email address.');
        case 'wrong-password':
          throw Exception('Incorrect password. Please try again.');
        case 'invalid-email':
          throw Exception('Please enter a valid email address.');
        case 'user-disabled':
          throw Exception(
            'This account has been disabled. Please contact support.',
          );
        case 'too-many-requests':
          throw Exception('Too many failed attempts. Please try again later.');
        case 'network-request-failed':
          throw Exception(
            'Network error. Please check your internet connection.',
          );
        default:
          throw Exception(e.message ?? 'Login failed. Please try again.');
      }
    } catch (e) {
      log('Auth Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await setLoggedInFlag(false);
    } catch (e) {
      log('Sign out error: $e');
      rethrow;
    }
  }

  Future<String> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Mail sent";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An error occurred";
    }
  }

  // SharedPreferences methods
  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstTimeKey) ?? true;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> setFirstTimeFlag(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstTimeKey, value);
  }

  Future<void> setLoggedInFlag(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
