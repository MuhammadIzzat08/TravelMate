import 'package:flutter/material.dart';
import 'package:travelmate/Controller/login.dart';
import 'package:travelmate/View/register.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Color(0xFF7A9E9F),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final success = await LoginController().login(emailController.text, passwordController.text);
                if (success) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RegistrationScreen()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Login failed. Please try again.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF7A9E9F), // Use the color #7a9e9f as button background
              ),
              child: Text('Login'),
            ),
            SizedBox(height: 8.0), // Add some space between the buttons
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationScreen()),
                );
              },
              child: Text(
                'Register?',
                style: TextStyle(
                  color: Colors.blue, // Set text color to blue
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
