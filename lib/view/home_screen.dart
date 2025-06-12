import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studentrecords/core/constants/color_constants.dart';

import 'package:studentrecords/core/widgets/dialogue_utilites.dart';
import 'package:studentrecords/provider/auth_provider.dart';
import 'package:studentrecords/provider/student_provider.dart';
import 'package:studentrecords/view/add_student_screen.dart';
import 'package:studentrecords/view/edit_student_screen.dart';
import 'package:studentrecords/view/student_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) {
    DialogUtils.showConfirmationDialog(
      context,
      title: 'Confirm Logout',
      content: 'Are you sure you want to logout and exit the app?',
      confirmText: 'Logout & Exit',
      cancelText: 'Cancel',
      confirmColor: AllColors.gradientSecond,
      onConfirm: () async {
        // Show loading dialog
        DialogUtils.showLoadingDialog(context, message: 'Logging out...');

        try {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          await authProvider.signOut();

          if (context.mounted) {
            Navigator.of(context).pop();
          }

          _exitApp();
        } catch (e) {
          if (context.mounted) {
            Navigator.of(context).pop();
            DialogUtils.showErrorSnackBar(
              context,
              'Logout failed: ${e.toString()}',
            );
          }
        }
      },
    );
  }

  void _exitApp() {
    SystemNavigator.pop();
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
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Student Records',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: () => _logout(context),
                        tooltip: 'Logout & Exit',
                      ),
                    ),
                  ],
                ),
              ),

              // Student Count Header
              Consumer<StudentProvider>(
                builder: (context, provider, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Students',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${provider.students.length}',
                            style: const TextStyle(
                              color: AllColors.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Student List
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
                  child: Consumer<StudentProvider>(
                    builder: (context, provider, child) {
                      if (provider.students.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 80,
                                color: AllColors.primaryColor.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No students found",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AllColors.primaryColor.withOpacity(
                                    0.7,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: provider.students.length,
                        itemBuilder: (context, index) {
                          final student = provider.students[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Card(
                              elevation: 8,
                              shadowColor: AllColors.primaryColor.withOpacity(
                                0.3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => StudentDetailScreen(
                                            student: student,
                                            studentIndex: index,
                                          ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white,
                                        AllColors.primaryColor.withOpacity(
                                          0.05,
                                        ),
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                AllColors.primaryColor,
                                                AllColors.gradientSecond,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              student.name.isNotEmpty
                                                  ? student.name[0]
                                                      .toUpperCase()
                                                  : 'S',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 16),

                                        // Student Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                student.name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: AllColors.primaryColor,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.badge_outlined,
                                                    size: 16,
                                                    color: AllColors
                                                        .gradientSecond
                                                        .withOpacity(0.7),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "Reg: ${student.regNo}",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: AllColors
                                                          .gradientSecond
                                                          .withOpacity(0.8),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Action Buttons
                                        Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: AllColors.gradientSecond
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                  color:
                                                      AllColors.gradientSecond,
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              EditStudentScreen(
                                                                student:
                                                                    student,
                                                                studentIndex:
                                                                    index,
                                                              ),
                                                    ),
                                                  );
                                                },
                                                iconSize: 20,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  DialogUtils.showDeleteStudentConfirmation(
                                                    context,
                                                    studentIndex: index,
                                                    studentName: student.name,
                                                  );
                                                },
                                                iconSize: 20,
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
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AllColors.gradientSecond, AllColors.gradientThird],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AllColors.gradientSecond.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          tooltip: "Add new student",
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddStudentScreen()),
            );
          },
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
