import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static Future<String> getLoggedInUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('User').doc(user.uid).get();
      return userDoc.id;
    } else {
      throw Exception('User not logged in');
    }
  }
}
