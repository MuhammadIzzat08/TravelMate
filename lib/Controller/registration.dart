// user_controller.dart

import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrationController {
  static Future<void> registerUser(String email, String password) async {
    final url = 'http://192.168.0.121:3000/auth/signup'; // Replace with your backend URL
    final Map<String, String> headers = {
      'Content-Type': 'application/json', // Set Content-Type header to application/json
    };

    final Map<String, dynamic> body = {
      'email': email,
      'password': password,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers, // Pass headers to the request
      body: jsonEncode(body), // Encode body data as JSON string
    );

    if (response.statusCode == 200) {
      print('User registered successfully');
      // Handle success (e.g., navigate to home screen)
    } else {
      print('Failed to register user: ${response.body}');
      // Handle registration failure (e.g., display error message)
    }
  }
}
