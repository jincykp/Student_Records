import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studentrecords/services/auth_services.dart';

enum AuthState { initial, loading, success, error }

class AuthProvider with ChangeNotifier {
  final AuthServices _authServices = AuthServices();

  AuthState _state = AuthState.initial;
  String _errorMessage = '';
  User? _user;

  // Getters
  AuthState get state => _state;
  String get errorMessage => _errorMessage;
  User? get user => _user;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _user != null;

  // Constructor
  AuthProvider() {
    _user = FirebaseAuth.instance.currentUser;
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
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
        _setState(AuthState.success);
      } else {
        _setError('Failed to create account. Please try again.');
      }
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
        _setState(AuthState.success);
      } else {
        _setError('Invalid email or password. Please try again.');
      }
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
        _setState(AuthState.success);
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
      _user = null;
      _setState(AuthState.initial);
    } catch (e) {
      _setError('Failed to sign out: ${e.toString()}');
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
      _state = AuthState.initial;
      _errorMessage = '';
      notifyListeners();
    }
  }
}
