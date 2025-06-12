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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  // Main body container with gradient background
  Widget _buildBody() {
    return Container(
      decoration: _buildGradientDecoration(),
      child: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(),
            _buildStudentCountHeader(),
            const SizedBox(height: 20),
            _buildStudentList(),
          ],
        ),
      ),
    );
  }

  // Gradient background decoration
  BoxDecoration _buildGradientDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AllColors.primaryColor,
          AllColors.gradientSecond,
          AllColors.gradientThird,
        ],
      ),
    );
  }

  // Custom app bar with title and logout button
  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_buildAppBarTitle(), _buildLogoutButton()],
      ),
    );
  }

  // App bar title
  Widget _buildAppBarTitle() {
    return const Text(
      'Student Records',
      style: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Logout button with confirmation dialog
  Widget _buildLogoutButton() {
    return Builder(
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => _handleLogout(context),
              tooltip: 'Logout & Exit',
            ),
          ),
    );
  }

  // Student count header with total count
  Widget _buildStudentCountHeader() {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(10),
          decoration: _buildCountHeaderDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCountHeaderLabel(),
              _buildCountBadge(provider.students.length),
            ],
          ),
        );
      },
    );
  }

  // Count header container decoration
  BoxDecoration _buildCountHeaderDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
    );
  }

  // Count header label
  Widget _buildCountHeaderLabel() {
    return const Text(
      'Total Students',
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // Count badge showing number of students
  Widget _buildCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: AllColors.primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Student list container
  Widget _buildStudentList() {
    return Expanded(
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
              return _buildEmptyState();
            }
            return _buildStudentListView(context, provider);
          },
        ),
      ),
    );
  }

  // Empty state when no students
  Widget _buildEmptyState() {
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
              color: AllColors.primaryColor.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // List view of students
  Widget _buildStudentListView(BuildContext context, StudentProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: provider.students.length,
      itemBuilder: (context, index) {
        final student = provider.students[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildStudentCard(context, student, index),
        );
      },
    );
  }

  // Individual student card
  Widget _buildStudentCard(BuildContext context, dynamic student, int index) {
    return Card(
      elevation: 8,
      shadowColor: AllColors.primaryColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => _navigateToStudentDetails(context, student, index),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: _buildStudentCardDecoration(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildStudentAvatar(student),
                const SizedBox(width: 16),
                _buildStudentInfo(student),
                _buildActionButtons(context, student, index),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Student card decoration
  BoxDecoration _buildStudentCardDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, AllColors.primaryColor.withOpacity(0.05)],
      ),
    );
  }

  // Student avatar with first letter
  Widget _buildStudentAvatar(dynamic student) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AllColors.primaryColor, AllColors.gradientSecond],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Student information (name and registration number)
  Widget _buildStudentInfo(dynamic student) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                color: AllColors.gradientSecond.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                "Reg: ${student.regNo}",
                style: TextStyle(
                  fontSize: 14,
                  color: AllColors.gradientSecond.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Action buttons (edit and delete)
  Widget _buildActionButtons(BuildContext context, dynamic student, int index) {
    return Column(
      children: [
        _buildEditButton(context, student, index),
        const SizedBox(height: 8),
        _buildDeleteButton(context, student, index),
      ],
    );
  }

  // Edit button
  Widget _buildEditButton(BuildContext context, dynamic student, int index) {
    return Container(
      decoration: BoxDecoration(
        color: AllColors.gradientSecond.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: const Icon(Icons.edit_outlined, color: AllColors.gradientSecond),
        onPressed: () => _navigateToEditStudent(context, student, index),
        iconSize: 20,
      ),
    );
  }

  // Delete button
  Widget _buildDeleteButton(BuildContext context, dynamic student, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: () => _handleDeleteStudent(context, student, index),
        iconSize: 20,
      ),
    );
  }

  // Floating action button
  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
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
        onPressed: () => _navigateToAddStudent(context),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  // Navigation and action methods
  void _navigateToStudentDetails(
    BuildContext context,
    dynamic student,
    int index,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                StudentDetailScreen(student: student, studentIndex: index),
      ),
    );
  }

  void _navigateToEditStudent(
    BuildContext context,
    dynamic student,
    int index,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                EditStudentScreen(student: student, studentIndex: index),
      ),
    );
  }

  void _navigateToAddStudent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddStudentScreen()),
    );
  }

  void _handleDeleteStudent(BuildContext context, dynamic student, int index) {
    DialogUtils.showDeleteStudentConfirmation(
      context,
      studentIndex: index,
      studentName: student.name,
    );
  }

  void _handleLogout(BuildContext context) {
    DialogUtils.showConfirmationDialog(
      context,
      title: 'Confirm Logout',
      content: 'Are you sure you want to logout and exit the app?',
      confirmText: 'Logout & Exit',
      cancelText: 'Cancel',
      confirmColor: AllColors.gradientSecond,
      onConfirm: () => _performLogout(context),
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    // Show loading dialog
    DialogUtils.showLoadingDialog(context, message: 'Logging out...');

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
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
  }

  void _exitApp() {
    SystemNavigator.pop();
  }
}
