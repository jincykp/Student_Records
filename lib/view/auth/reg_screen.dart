import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studentrecords/core/constants/color_constants.dart';
import 'package:studentrecords/core/constants/text_styles.dart';
import 'package:studentrecords/core/widgets/sign_buttons.dart';
import 'package:studentrecords/core/widgets/signup_formfileds.dart';
import 'package:studentrecords/core/widgets/signup_validation.dart';
import 'package:studentrecords/provider/auth_provider.dart';
import 'package:studentrecords/view/auth/login_screen.dart';
import 'package:studentrecords/view/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await authProvider.signUp(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (mounted) {
        if (authProvider.state == AuthState.success) {
          _showSnackBar('Account created successfully!', isError: false);
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.school,
                    color: AllColors.textColor,
                    size: 60,
                  ),
                  const SizedBox(height: 10),
                  const Text('Create Account', style: TextStyles.titleText),
                  const SizedBox(height: 20),

                  // Email Field
                  SignUpFormFields(
                    controller: emailController,
                    hintText: 'Email',
                    keyBoardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email, color: Colors.white70),
                    validator: SignUpValidator.validateEmail,
                  ),
                  const SizedBox(height: 10),

                  // Password Field
                  SignUpFormFields(
                    controller: passwordController,
                    hintText: 'Password',
                    keyBoardType: TextInputType.visiblePassword,
                    inputFormatters: [LengthLimitingTextInputFormatter(8)],
                    prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                    validator: SignUpValidator.validatePassword,
                    obscureText: obscurePassword,
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
                  const SizedBox(height: 20),

                  // Sign Up Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Sign Up',
                          isLoading: authProvider.isLoading,
                          onPressed:
                              authProvider.isLoading ? null : _handleSignUp,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Already have an account? Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Log In',
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
    );
  }
}
