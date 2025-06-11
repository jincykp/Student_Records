import 'package:hive/hive.dart';
part 'student_model.g.dart';

@HiveType(typeId: 0)
class StudentModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int age;

  @HiveField(2)
  final String regNo;

  @HiveField(3)
  final String phone;

  StudentModel({
    required this.name,
    required this.age,
    required this.regNo,
    required this.phone,
  });
}
