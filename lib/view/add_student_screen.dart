import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:studentrecords/core/constants/color_constants.dart';
import 'package:studentrecords/core/widgets/sign_buttons.dart';
import 'package:studentrecords/core/widgets/signup_formfileds.dart';
import 'package:studentrecords/core/widgets/signup_validation.dart';
import 'package:studentrecords/data/model/student_model.dart';
import 'package:studentrecords/provider/student_provider.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  // Form key and controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _regNoController = TextEditingController();
  final _phoneController = TextEditingController();

  // State variables
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _regNoController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Main Methods
  Future<void> _addStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final studentProvider = Provider.of<StudentProvider>(
        context,
        listen: false,
      );

      // Check for duplicate registration number
      if (_isDuplicateRegNo(studentProvider.students)) {
        _showSnackBar('Registration number already exists!', Colors.red);
        return;
      }

      // Create and add student
      final student = _createStudentFromForm();
      await studentProvider.addStudent(student);

      if (mounted) {
        _showSnackBar('Student added successfully!', Colors.green);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error adding student: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _ageController.clear();
    _regNoController.clear();
    _phoneController.clear();
  }

  // Helper Methods
  bool _isDuplicateRegNo(List<StudentModel> students) {
    final regNo = _regNoController.text.trim().toLowerCase();
    return students.any((student) => student.regNo.toLowerCase() == regNo);
  }

  StudentModel _createStudentFromForm() {
    return StudentModel(
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      regNo: _regNoController.text.trim(),
      phone: _phoneController.text.trim(),
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: Scaffold(
        appBar: _buildAppBar(),
        extendBodyBehindAppBar: true,
        body: _buildBody(),
      ),
    );
  }

  // UI Building Methods
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Add Student",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          onPressed: _isLoading ? null : _clearForm,
          icon: const Icon(Icons.clear_all),
          tooltip: 'Clear Form',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Container(
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      kToolbarHeight -
                      MediaQuery.of(context).padding.top -
                      40, // Account for padding
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      _buildWelcomeSection(),
                      const SizedBox(height: 40),
                      _buildFormFields(),
                      const Spacer(),
                      const SizedBox(height: 20),
                      _buildSaveButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: const Column(
            children: [
              Icon(Icons.person_add, size: 48, color: Colors.white),
              SizedBox(height: 10),
              Text(
                "Add New Student",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Fill in the details below",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildFormField(
          controller: _nameController,
          hintText: "Student Name",
          validator: SignUpValidator.validateName,
          icon: Icons.person,
        ),
        const SizedBox(height: 20),
        _buildFormField(
          controller: _ageController,
          hintText: "Age",
          validator: SignUpValidator.validateAge,
          icon: Icons.cake,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
        ),
        const SizedBox(height: 20),
        _buildFormField(
          controller: _regNoController,
          hintText: "Registration Number",
          validator: SignUpValidator.validateRegNo,
          icon: Icons.badge,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
        ),
        const SizedBox(height: 20),
        _buildFormField(
          controller: _phoneController,
          hintText: "Phone Number",
          validator: SignUpValidator.validatePhone,
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SignUpFormFields(
        controller: controller,
        hintText: hintText,
        validator: validator,
        prefixIcon: Icon(icon),
        keyBoardType: keyboardType,
        inputFormatters: inputFormatters,
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CustomButton(
        text: "Save Student",
        onPressed: _addStudent,
        isLoading: _isLoading,
        textSize: 18,
        borderRadius: 30,
      ),
    );
  }
}
