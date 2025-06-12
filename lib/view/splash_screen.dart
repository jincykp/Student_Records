import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:studentrecords/core/constants/color_constants.dart';
import 'package:studentrecords/core/constants/text_styles.dart';
import 'package:studentrecords/provider/auth_provider.dart';

import 'package:studentrecords/view/auth_screens/login_screen.dart';
import 'package:studentrecords/view/auth_screens/reg_screen.dart';
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
    _waitForInitializationAndNavigate();
  }

  void _waitForInitializationAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Wait for initialization to complete
    while (!authProvider.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Add minimum splash duration for better UX
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    _determineNextScreen();
  }

  void _determineNextScreen() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    print('Debug - isFirstTime: ${authProvider.isFirstTime}');
    print('Debug - isAuthenticated: ${authProvider.isAuthenticated}');
    print('Debug - user: ${authProvider.user}');

    // Priority logic: if user is authenticated, go to home regardless of first time flag
    if (authProvider.isAuthenticated) {
      // User is logged in - go to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (authProvider.isFirstTime) {
      // First time user - go to signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignUpScreen()),
      );
    } else {
      // User has account but not logged in - go to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
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
            ],
          ),
        ),
      ),
    );
  }
}
