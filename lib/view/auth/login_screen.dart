import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studentrecords/core/constants/color_constants.dart';
import 'package:studentrecords/core/constants/text_styles.dart';
import 'package:studentrecords/core/widgets/sign_buttons.dart';
import 'package:studentrecords/core/widgets/signup_formfileds.dart';
import 'package:studentrecords/core/widgets/signup_validation.dart';
import 'package:studentrecords/provider/auth_provider.dart';

import 'package:studentrecords/view/auth/forgotpw.dart';
import 'package:studentrecords/view/auth/reg_screen.dart';

import 'package:studentrecords/view/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await authProvider.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (mounted) {
        if (authProvider.state == AuthState.success) {
          _showSnackBar('Login successful!', isError: false);
          // Navigate to home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ), // Replace with your home screen
          );
        } else if (authProvider.state == AuthState.error) {
          _showSnackBar(authProvider.errorMessage);
        }
      }
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.school,
                      color: AllColors.textColor,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    const Text('Student Records', style: TextStyles.titleText),
                    const SizedBox(height: 30),

                    SignUpFormFields(
                      controller: emailController,
                      hintText: 'Email',
                      keyBoardType: TextInputType.emailAddress,
                      validator: SignUpValidator.validateEmail,
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 15),

                    SignUpFormFields(
                      controller: passwordController,
                      hintText: 'Password',
                      inputFormatters: [LengthLimitingTextInputFormatter(8)],
                      keyBoardType: TextInputType.visiblePassword,
                      validator: SignUpValidator.validatePassword,
                      obscureText: obscurePassword,
                      prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: 'Login',
                            isLoading: authProvider.isLoading,
                            onPressed:
                                authProvider.isLoading ? null : _handleLogin,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.white),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
