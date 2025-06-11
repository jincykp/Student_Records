import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:studentrecords/data/model/student_model.dart';
import 'package:studentrecords/firebase_options.dart';
import 'package:studentrecords/provider/auth_provider.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:studentrecords/provider/student_provider.dart';
import 'package:studentrecords/view/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  Hive.registerAdapter(StudentModelAdapter());
  await Hive.openBox<StudentModel>('students');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
      ],
      child: MaterialApp(
        title: 'Student Records',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: SplashScreen(),
      ),
    );
  }
}
