import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studentrecords/services/auth_services.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  success,
}

class AuthProvider with ChangeNotifier {
  final AuthServices _authServices = AuthServices();
  AuthState _state = AuthState.initial;
  String _errorMessage = '';
  User? _user;
  bool _isFirstTime = true;

  // SharedPreferences keys
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyIsFirstTime = 'is_first_time';

  // Getters
  AuthState get state => _state;
  String get errorMessage => _errorMessage;
  User? get user => _user;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isFirstTime => _isFirstTime;

  // Constructor
  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication state
  Future<void> _initializeAuth() async {
    _setState(AuthState.loading);

    try {
      final prefs = await SharedPreferences.getInstance();
      _isFirstTime = prefs.getBool(_keyIsFirstTime) ?? true;

      // Check if user was previously logged in
      final wasLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

      // Get current Firebase user
      _user = _authServices.currentUser;

      // Listen to auth state changes
      _authServices.authStateChanges.listen((User? user) {
        _user = user;
        _updateAuthState();
      });

      // Set initial state based on current user and previous session
      if (_user != null && wasLoggedIn) {
        _setState(AuthState.authenticated);
      } else {
        _setState(AuthState.unauthenticated);
        // Clear the logged in flag if no current user
        if (_user == null) {
          await _setLoggedInStatus(false);
        }
      }
    } catch (e) {
      _setError('Failed to initialize authentication: ${e.toString()}');
    }
  }

  // Update auth state when Firebase auth state changes
  void _updateAuthState() async {
    if (_user != null) {
      await _setLoggedInStatus(true);
      _setState(AuthState.authenticated);
    } else {
      await _setLoggedInStatus(false);
      _setState(AuthState.unauthenticated);
    }
  }

  // Set logged in status in SharedPreferences
  Future<void> _setLoggedInStatus(bool isLoggedIn) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
    } catch (e) {
      log('Failed to save login status: $e');
    }
  }

  // Set first time status
  Future<void> _setFirstTimeStatus(bool isFirstTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsFirstTime, isFirstTime);
      _isFirstTime = isFirstTime;
    } catch (e) {
      log('Failed to save first time status: $e');
    }
  }

  // Sign Up Method
  Future<void> signUp(String email, String password) async {
    _setState(AuthState.loading);
    try {
      final user = await _authServices.createUserWithEmailAndPassword(
        email,
        password,
      );
      if (user != null) {
        _user = user;
        await _setLoggedInStatus(true);
        await _setFirstTimeStatus(false);
        _setState(AuthState.authenticated);
      } else {
        _setError('Failed to create account. Please try again.');
      }
    } on FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e));
    } catch (e) {
      _setError('Failed to create account: ${e.toString()}');
    }
  }

  // Login Method
  Future<void> login(String email, String password) async {
    _setState(AuthState.loading);
    try {
      final user = await _authServices.loginUserWithEmailAndPassword(
        email,
        password,
      );
      if (user != null) {
        _user = user;
        await _setLoggedInStatus(true);
        await _setFirstTimeStatus(false);
        _setState(AuthState.authenticated);
      } else {
        _setError('Invalid email or password. Please try again.');
      }
    } on FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e));
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
    }
  }

  // Reset Password Method
  Future<void> resetPassword(String email) async {
    _setState(AuthState.loading);
    try {
      final message = await _authServices.resetPassword(email);
      if (message == "Mail sent") {
        _setState(AuthState.unauthenticated);
      } else {
        _setError(message);
      }
    } catch (e) {
      _setError('Failed to send reset email: ${e.toString()}');
    }
  }

  // Sign Out Method
  Future<void> signOut() async {
    _setState(AuthState.loading);
    try {
      await _authServices.signOut();
      await _setLoggedInStatus(false);
      _user = null;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError('Failed to sign out: ${e.toString()}');
    }
  }

  // Get user-friendly error messages
  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }

  // Private helper methods
  void _setState(AuthState newState) {
    _state = newState;
    if (newState != AuthState.error) {
      _errorMessage = '';
    }
    notifyListeners();
  }

  void _setError(String message) {
    _state = AuthState.error;
    _errorMessage = message;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    if (_state == AuthState.error) {
      _state = AuthState.unauthenticated;
      _errorMessage = '';
      notifyListeners();
    }
  }

  // Check if user is first time (for navigation logic)
  Future<bool> checkIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsFirstTime) ?? true;
  }
}
