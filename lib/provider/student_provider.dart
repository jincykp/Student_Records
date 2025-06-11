import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:studentrecords/data/model/student_model.dart';

class StudentProvider with ChangeNotifier {
  final Box<StudentModel> _studentBox = Hive.box<StudentModel>('students');

  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  StudentProvider() {
    print('StudentProvider init, box contains: ${_studentBox.values.length}');
    loadStudents();
  }

  void loadStudents() {
    _students = _studentBox.values.toList();
    print(' loadStudents, count= ${_students.length}');
    notifyListeners();
  }

  Future<void> addStudent(StudentModel student) async {
    await _studentBox.add(student);
    print(' addStudent, new count ${_studentBox.values.length}');
    loadStudents();
  }

  Future<void> updateStudent(int index, StudentModel updatedStudent) async {
    await _studentBox.putAt(index, updatedStudent);
    loadStudents();
  }

  Future<void> deleteStudent(int index) async {
    await _studentBox.deleteAt(index);
    loadStudents();
  }
}
