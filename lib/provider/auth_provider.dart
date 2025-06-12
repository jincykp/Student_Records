import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studentrecords/services/auth_services.dart';

enum AuthState { initial, loading, success, error }

class AuthProvider with ChangeNotifier {
  final AuthServices _authServices = AuthServices();

  AuthState _state = AuthState.initial;
  String _errorMessage = '';
  User? _user;
  bool _isFirstTime = true;
  bool _isLoggedIn = false;
  bool _isInitialized = false;

  // Getters
  AuthState get state => _state;
  String get errorMessage => _errorMessage;
  User? get user => _user;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _user != null && _isLoggedIn;
  bool get isFirstTime => _isFirstTime;
  bool get isInitialized => _isInitialized;

  // Constructor
  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      _user = FirebaseAuth.instance.currentUser;
      _isFirstTime = await _authServices.isFirstTime();
      _isLoggedIn = await _authServices.isLoggedIn();

      // If user exists in Firebase, they are not first time anymore
      if (_user != null) {
        if (_isFirstTime) {
          await _authServices.setFirstTimeFlag(false);
          _isFirstTime = false;
        }
        if (!_isLoggedIn) {
          await _authServices.setLoggedInFlag(true);
          _isLoggedIn = true;
        }
      }

      _isInitialized = true;

      // Listen to auth state changes
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        _user = user;
        if (user == null) {
          _isLoggedIn = false;
        }
        notifyListeners();
      });

      notifyListeners();
    } catch (e) {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password) async {
    _setState(AuthState.loading);

    try {
      final user = await _authServices.createUserWithEmailAndPassword(
        email,
        password,
      );
      if (user != null) {
        _user = user;
        _isFirstTime = false;
        _isLoggedIn = true;
        _setState(AuthState.success);
      } else {
        _setError('Failed to create account. Please try again.');
      }
    } on Exception catch (e) {
      // Handle our custom exception messages
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } catch (e) {
      _setError('Failed to create account. Please try again.');
    }
  }

  Future<void> login(String email, String password) async {
    _setState(AuthState.loading);

    try {
      final user = await _authServices.loginUserWithEmailAndPassword(
        email,
        password,
      );
      if (user != null) {
        _user = user;
        _isLoggedIn = true;
        _setState(AuthState.success);
      } else {
        _setError('Invalid email or password. Please try again.');
      }
    } on Exception catch (e) {
      // Handle our custom exception messages
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } catch (e) {
      _setError('Login failed. Please try again.');
    }
  }

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

  Future<void> signOut() async {
    _setState(AuthState.loading);

    try {
      await _authServices.signOut();
      _user = null;
      _isLoggedIn = false;
      _setState(AuthState.initial);
    } catch (e) {
      _setError('Failed to sign out: ${e.toString()}');
    }
  }

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

  void clearError() {
    if (_state == AuthState.error) {
      _state = AuthState.initial;
      _errorMessage = '';
      notifyListeners();
    }
  }
}
