import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginController {
  final String baseUrl = 'http://192.168.0.121:3000/auth/login';

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email, 'password': password});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        return true;
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final errorMessage = responseData['error'];
        print(errorMessage);
        return false;
      }
    } catch (error) {
      print(error.toString());
      return false;
    }
  }
}
