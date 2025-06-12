import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add this import
import 'package:studentrecords/core/constants/color_constants.dart';
import 'package:studentrecords/core/widgets/sign_buttons.dart';
import 'package:studentrecords/core/widgets/signup_formfileds.dart';
import 'package:studentrecords/core/widgets/signup_validation.dart';
import 'package:studentrecords/data/model/student_model.dart';
import 'package:studentrecords/provider/student_provider.dart'; // Add this import
import 'package:flutter/services.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _regNoController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _ageController.dispose();
    _regNoController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void addStudent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final studentProvider = Provider.of<StudentProvider>(
          context,
          listen: false,
        );

        // Check if registration number already exists
        final existingStudents = studentProvider.students;
        final regNoExists = existingStudents.any(
          (student) =>
              student.regNo.toLowerCase() ==
              _regNoController.text.trim().toLowerCase(),
        );

        if (regNoExists) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration number already exists!'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _isLoading = false;
          });
          return;
        }

        final student = StudentModel(
          name: _nameController.text.trim(),
          age: int.parse(_ageController.text.trim()),
          regNo: _regNoController.text.trim(),
          phone: _phoneController.text.trim(),
        );

        // Use the provider to add the student
        await studentProvider.addStudent(student);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Student added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding student: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
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
  }

  void _clearForm() {
    _nameController.clear();
    _ageController.clear();
    _regNoController.clear();
    _phoneController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isLoading) return false; // Prevent back navigation while loading
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Add Student",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        ),
        extendBodyBehindAppBar: true,
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          MediaQuery.of(context).size.height -
                          kToolbarHeight -
                          MediaQuery.of(context).padding.top,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          const SizedBox(height: 30),
                          SignUpFormFields(
                            controller: _nameController,
                            hintText: "Student Name",
                            validator: SignUpValidator.validateName,
                            prefixIcon: const Icon(Icons.person),
                          ),
                          const SizedBox(height: 15),
                          SignUpFormFields(
                            controller: _ageController,
                            hintText: "Age",
                            keyBoardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            validator: SignUpValidator.validateAge,
                            prefixIcon: const Icon(Icons.cake),
                          ),
                          const SizedBox(height: 15),
                          SignUpFormFields(
                            controller: _regNoController,
                            hintText: "Register Number",
                            validator: SignUpValidator.validateRegNo,
                            keyBoardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            prefixIcon: const Icon(Icons.badge),
                          ),
                          const SizedBox(height: 15),
                          SignUpFormFields(
                            controller: _phoneController,
                            hintText: "Phone Number",
                            keyBoardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: SignUpValidator.validatePhone,
                            prefixIcon: const Icon(Icons.phone),
                          ),
                          const SizedBox(height: 30),
                          CustomButton(
                            text: "Save Student",
                            onPressed: addStudent,
                            isLoading: _isLoading,
                            textSize: 16,
                            borderRadius: 25,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
