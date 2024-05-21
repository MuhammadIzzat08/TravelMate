import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        backgroundColor: Color(0xFF7A9E9F),
      ),
      body: Center(
        child: Text('User Profile Page'),
      ),
    );
  }
}