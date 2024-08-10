import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelmate/Model/userProfile.dart'; // Import your UserProfile model

class UserProfileController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch user profile from Firestore
  Future<UserProfile> getUserProfile(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('User').doc(uid).get();
    if (doc.exists) {
      return UserProfile.fromDocument(doc.data() as Map<String, dynamic>, uid);
    } else {
      throw Exception('User profile not found');
    }
  }

  // Update user profile in Firestore
  Future<void> updateUserProfile(UserProfile userProfile) async {
    await _firestore.collection('User').doc(userProfile.uid).update(userProfile.toMap());
  }
}
