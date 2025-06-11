import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studentrecords/core/constants/color_constants.dart';
import 'package:studentrecords/core/constants/text_styles.dart';
import 'package:studentrecords/core/widgets/sign_buttons.dart';
import 'package:studentrecords/core/widgets/signup_formfileds.dart';
import 'package:studentrecords/core/widgets/signup_validation.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    // Controllers for form fields (UI only)

    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    final _formKey = GlobalKey<FormState>();
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
                    inputFormatters: [LengthLimitingTextInputFormatter(6)],
                    prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                    suffixIcon: const Icon(
                      Icons.visibility,
                      color: Colors.white70,
                    ),
                    validator: SignUpValidator.validatePassword,
                  ),
                  const SizedBox(height: 10),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Sign Up',
                      onPressed: () {
                        // UI only - no functionality
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Already have an account? Login
                  TextButton(
                    onPressed: () {
                      // UI only - no functionality
                    },
                    child: const Text(
                      'Already have an account? Log in',
                      style: TextStyle(color: Colors.white),
                    ),
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
