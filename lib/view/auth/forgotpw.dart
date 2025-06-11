import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentrecords/core/constants/color_constants.dart';
import 'package:studentrecords/core/constants/text_styles.dart';
import 'package:studentrecords/core/widgets/sign_buttons.dart';
import 'package:studentrecords/core/widgets/signup_formfileds.dart';
import 'package:studentrecords/core/widgets/signup_validation.dart';
import 'package:studentrecords/provider/auth_provider.dart';
import 'package:studentrecords/view/auth/login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool emailSent = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await authProvider.resetPassword(emailController.text.trim());

      if (mounted) {
        if (authProvider.state == AuthState.success) {
          setState(() {
            emailSent = true;
          });
          _showSnackBar(
            'Password reset email sent! Check your inbox.',
            isError: false,
          );
        } else if (authProvider.state == AuthState.error) {
          _showSnackBar(authProvider.errorMessage);
        }
      }
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
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
                    Icon(
                      emailSent ? Icons.email : Icons.lock_reset,
                      color: AllColors.textColor,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      emailSent ? 'Email Sent' : 'Reset Password',
                      style: TextStyles.titleText,
                    ),
                    const SizedBox(height: 20),

                    if (!emailSent) ...[
                      const Text(
                        'Enter your email address and we\'ll send you a link to reset your password.',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
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
                      const SizedBox(height: 30),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: 'Send Reset Email',
                              isLoading: authProvider.isLoading,
                              onPressed:
                                  authProvider.isLoading
                                      ? null
                                      : _handleResetPassword,
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 80,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Password reset email has been sent to your email address.',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Please check your inbox and follow the instructions to reset your password.',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Back to Login',
                          onPressed: _navigateToLogin,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            emailSent = false;
                          });
                        },
                        child: const Text(
                          'Send another email',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
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
