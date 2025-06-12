import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:studentrecords/data/model/student_model.dart';

class StudentProvider with ChangeNotifier {
  final Box<StudentModel> _studentBox = Hive.box<StudentModel>('students');

  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  StudentProvider() {
    print('✪ StudentProvider init, box contains: ${_studentBox.values.length}');
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
    try {
      // First, ensure we have the latest data
      loadStudents();

      // Get the actual key from the box at this index position
      final keys = _studentBox.keys.toList();
      print('Available keys: $keys, trying to update index: $index');

      if (index >= 0 && index < keys.length) {
        final key = keys[index];
        await _studentBox.put(key, updatedStudent);
        print('updateStudent: Updated student at index $index with key $key');

        // Reload students to ensure UI consistency
        loadStudents();
      } else {
        print(
          'Index out of range: $index, available indices: 0-${keys.length - 1}',
        );
        throw Exception('Index out of range: $index');
      }
    } catch (e) {
      print('Error updating student: $e');
      throw e;
    }
  }

  // Alternative method: Update by finding the student first
  Future<void> updateStudentSafe(
    StudentModel originalStudent,
    StudentModel updatedStudent,
  ) async {
    try {
      // Find the key by comparing the original student data
      dynamic keyToUpdate;

      for (var key in _studentBox.keys) {
        final student = _studentBox.get(key);
        if (student != null &&
            student.regNo == originalStudent.regNo &&
            student.name == originalStudent.name &&
            student.phone == originalStudent.phone &&
            student.age == originalStudent.age) {
          keyToUpdate = key;
          break;
        }
      }

      if (keyToUpdate != null) {
        await _studentBox.put(keyToUpdate, updatedStudent);
        print('updateStudentSafe: Updated student with key $keyToUpdate');
        loadStudents();
      } else {
        throw Exception('Student not found in database');
      }
    } catch (e) {
      print('Error updating student safely: $e');
      throw e;
    }
  }

  Future<void> deleteStudent(int index) async {
    await _studentBox.deleteAt(index);
    loadStudents();
  }
}
