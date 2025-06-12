import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studentrecords/core/constants/color_constants.dart';
import 'package:studentrecords/core/widgets/dialogue_utilites.dart';
import 'package:studentrecords/core/widgets/sign_buttons.dart';

import 'package:studentrecords/core/widgets/signup_validation.dart';
import 'package:studentrecords/data/model/student_model.dart';
import 'package:studentrecords/provider/student_provider.dart';

class EditStudentScreen extends StatefulWidget {
  final StudentModel student;
  final int studentIndex;

  const EditStudentScreen({
    super.key,
    required this.student,
    required this.studentIndex,
  });

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _regNoController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate the form fields with existing student data
    _nameController.text = widget.student.name;
    _ageController.text = widget.student.age.toString();
    _regNoController.text = widget.student.regNo;
    _phoneController.text = widget.student.phone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _regNoController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _updateStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated student object
      final updatedStudent = StudentModel(
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        regNo: _regNoController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      final studentProvider = Provider.of<StudentProvider>(
        context,
        listen: false,
      );

      await studentProvider.updateStudent(widget.studentIndex, updatedStudent);

      if (mounted) {
        DialogUtils.showSuccessSnackBar(
          context,
          'Student updated successfully!',
        );

        // IMPORTANT: Return true to indicate successful update
        Navigator.of(context).pop(true); // Changed from pop() to pop(true)
      }
    } catch (e) {
      if (mounted) {
        DialogUtils.showErrorSnackBar(
          context,
          'Failed to update student: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDiscardChangesDialog() {
    // Check if any field has been modified
    bool hasChanges =
        _nameController.text != widget.student.name ||
        _ageController.text != widget.student.age.toString() ||
        _regNoController.text != widget.student.regNo ||
        _phoneController.text != widget.student.phone;

    if (!hasChanges) {
      Navigator.of(context).pop();
      return;
    }

    DialogUtils.showConfirmationDialog(
      context,
      title: 'Discard Changes?',
      content: 'You have unsaved changes. Are you sure you want to go back?',
      confirmText: 'Discard',
      cancelText: 'Continue Editing',
      confirmColor: Colors.red,
      onConfirm: () {
        Navigator.of(context).pop(); // Close dialog
        Navigator.of(context).pop(); // Close edit screen
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showDiscardChangesDialog();
        return false; // Prevent default back navigation
      },
      child: Scaffold(
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
          child: SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: _showDiscardChangesDialog,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Edit Student',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Container
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Center(
                              child: Container(
                                width: 60,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Student Avatar
                            Center(
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AllColors.primaryColor,
                                      AllColors.gradientSecond,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AllColors.primaryColor.withOpacity(
                                        0.3,
                                      ),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    widget.student.name.isNotEmpty
                                        ? widget.student.name[0].toUpperCase()
                                        : 'S',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Name Field
                            _buildTextField(
                              controller: _nameController,
                              label: 'Full Name',
                              icon: Icons.person_outline,
                              validator: SignUpValidator.validateName,
                            ),

                            const SizedBox(height: 20),

                            // Age Field
                            _buildTextField(
                              controller: _ageController,
                              label: 'Age',
                              icon: Icons.cake_outlined,
                              keyboardType: TextInputType.number,
                              validator: SignUpValidator.validateAge,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Registration Number Field
                            _buildTextField(
                              controller: _regNoController,
                              label: 'Registration Number',
                              icon: Icons.badge_outlined,
                              keyboardType: TextInputType.phone,
                              validator: SignUpValidator.validateRegNo,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Phone Field
                            _buildTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: SignUpValidator.validatePhone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                            ),

                            const SizedBox(height: 40),

                            // Update Button using CustomButton
                            SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                text: 'Update Student',
                                onPressed: _updateStudent,
                                isLoading: _isLoading,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                textSize: 18,
                                borderRadius: 16,
                                backgroundColor: AllColors.gradientSecond,
                                textColor: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    // Add these three:
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    List<TextInputFormatter>? inputFormatters, // for restricting input
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType, // you already had this
      validator: validator,
      maxLines: maxLines,
      autovalidateMode: autovalidateMode, // added here
      inputFormatters: inputFormatters, // added here
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AllColors.primaryColor.withOpacity(0.7)),
        labelStyle: TextStyle(
          color: AllColors.primaryColor.withOpacity(0.8),
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AllColors.primaryColor.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AllColors.primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AllColors.primaryColor.withOpacity(0.3),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
