// registration_screen.dart

import 'package:flutter/material.dart';
import 'package:travelmate/Controller/registration.dart'; // Import LoginController

class RegistrationScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  //final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registration')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password')),
            //TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Call registerUser function from UserController
                RegistrationController.registerUser(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                  //nameController.text.trim(),
                );
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
