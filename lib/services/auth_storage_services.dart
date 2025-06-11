import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentrecords/provider/auth_provider.dart';
import 'package:studentrecords/view/auth/login_screen.dart';
import 'package:studentrecords/view/auth/reg_screen.dart';
import 'package:studentrecords/view/home_screen.dart';
import 'package:studentrecords/view/splash_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        switch (authProvider.state) {
          case AuthState.initial:
          case AuthState.loading:
            return const SplashScreen();
          case AuthState.authenticated:
            return const HomeScreen();
          case AuthState.unauthenticated:
            return authProvider.isFirstTime
                ? const SignUpScreen()
                : const LoginScreen();
          case AuthState.error:
            return const LoginScreen();
          case AuthState.success:
            throw UnimplementedError();
        }
      },
    );
  }
}
