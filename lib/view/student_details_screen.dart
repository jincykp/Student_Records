import 'package:flutter/material.dart';
import 'package:studentrecords/core/constants/color_constants.dart';
import 'package:studentrecords/core/widgets/dialogue_utilites.dart';
import 'package:studentrecords/core/widgets/sign_buttons.dart';
import 'package:studentrecords/data/model/student_model.dart';
import 'package:studentrecords/view/edit_student_screen.dart';

class StudentDetailScreen extends StatelessWidget {
  final StudentModel student;
  final int studentIndex;

  const StudentDetailScreen({
    super.key,
    required this.student,
    required this.studentIndex,
  });

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
        child: SafeArea(
          child: Column(
            children: [
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
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Student Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Student Profile Card
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
                    child: Column(
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 33,
                            fontWeight: FontWeight.bold,
                            color: AllColors.primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        _buildInfoCard(
                          icon: Icons.badge_outlined,
                          title: 'Registration Number',
                          value: student.regNo,
                          gradient: const LinearGradient(
                            colors: [
                              AllColors.primaryColor,
                              AllColors.gradientSecond,
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        _buildInfoCard(
                          icon: Icons.cake_outlined,
                          title: 'Age',
                          value: '${student.age} years old',
                          gradient: const LinearGradient(
                            colors: [
                              AllColors.gradientSecond,
                              AllColors.gradientThird,
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        _buildInfoCard(
                          icon: Icons.phone_outlined,
                          title: 'Phone Number',
                          value: student.phone,
                          gradient: const LinearGradient(
                            colors: [
                              AllColors.gradientThird,
                              AllColors.primaryColor,
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Action Buttons using CustomButton
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'Edit Student',
                                onPressed: () async {
                                  // Navigate to edit screen and wait for result
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => EditStudentScreen(
                                            student: student,
                                            studentIndex: studentIndex,
                                          ),
                                    ),
                                  );

                                  // If student was updated, pop back to refresh the previous screen
                                  if (result == true) {
                                    Navigator.of(context).pop(true);
                                  }
                                },
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 20,
                                ),
                                textSize: 16,
                                borderRadius: 15,
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: CustomButton(
                                text: 'Delete Student',
                                onPressed: () {
                                  DialogUtils.showDeleteStudentConfirmation(
                                    context,
                                    studentIndex: studentIndex,
                                    studentName: student.name,
                                    onDeleteSuccess: () {
                                      Navigator.of(context).pop(
                                        true,
                                      ); // Return true to indicate data changed
                                    },
                                  );
                                },
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 20,
                                ),
                                textSize: 16,
                                borderRadius: 15,
                                isOutlined: true,
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AllColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
