import 'package:flutter/material.dart';
import 'package:travelmate/View/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(
        primaryColor: Color(0xFFE4F1EE), // Set primary color directly
      ),
      home: LoginScreen(),
    );
  }
}
