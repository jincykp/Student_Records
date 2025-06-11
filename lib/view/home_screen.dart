import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for SystemNavigator
import 'package:provider/provider.dart';
import 'package:studentrecords/core/constants/color_constants.dart';
import 'package:studentrecords/provider/auth_provider.dart';
import 'package:studentrecords/provider/student_provider.dart';
import 'package:studentrecords/view/add_student_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to logout and exit the app?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AllColors.gradientThird,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog first

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const AlertDialog(
                      content: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text('Logging out...'),
                        ],
                      ),
                    );
                  },
                );

                try {
                  // Get the AuthProvider and call signOut
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  await authProvider.signOut();

                  // Close loading dialog
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }

                  // Exit the app after successful logout
                  _exitApp();
                } catch (e) {
                  // Close loading dialog
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }

                  // Show error message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logout failed: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Logout & Exit',
                style: TextStyle(
                  color: AllColors.gradientSecond,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to exit the app
  void _exitApp() {
    SystemNavigator.pop(); // This will close the app on Android
  }

  @override
  Widget build(BuildContext context) {
    print(
      ' HomeScreen build, students length: ${context.watch<StudentProvider>().students.length}',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Records',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AllColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
            tooltip: 'Logout & Exit',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AllColors.gradientSecond,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddStudentScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          print('length: ${provider.students.length}');
          if (provider.students.isEmpty) {
            return const Center(child: Text("No students found."));
          }

          return ListView.builder(
            itemCount: provider.students.length,
            itemBuilder: (context, index) {
              final student = provider.students[index];
              return ListTile(
                title: Text(student.name),
                subtitle: Text("Reg No: ${student.regNo}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Navigate to Edit screen and pass index
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        Provider.of<StudentProvider>(
                          context,
                          listen: false,
                        ).deleteStudent(index);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
