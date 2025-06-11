import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentrecords/core/constants/color_constants.dart';
import 'package:studentrecords/core/constants/text_styles.dart';
import 'package:studentrecords/provider/auth_provider.dart';
import 'package:studentrecords/view/auth/login_screen.dart';
import 'package:studentrecords/view/auth/reg_screen.dart';
import 'package:studentrecords/view/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  void _navigateAfterDelay() {
    Timer(const Duration(seconds: 2), () {
      _navigateBasedOnAuthState();
    });
  }

  void _navigateBasedOnAuthState() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    switch (authProvider.state) {
      case AuthState.authenticated:
        // User is logged in, go to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case AuthState.unauthenticated:
        // Check if first time to decide between signup and login
        if (authProvider.isFirstTime) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignUpScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
        break;
      case AuthState.initial:
      case AuthState.loading:
        // Wait for auth state to be determined
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _navigateBasedOnAuthState();
          }
        });
        break;
      case AuthState.error:
        // On error, go to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        break;
      case AuthState.success:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AllColors.primaryColor,
              AllColors.gradientSecond,
              AllColors.gradientThird,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school, color: AllColors.textColor, size: 80),
              Text('Student Records', style: TextStyles.titleText),
              SizedBox(height: 20),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AllColors.textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
