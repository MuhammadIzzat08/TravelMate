class UserProfile {
  String uid;
  String email;
  String name;
  String gender;
  String phoneNum;

  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.gender,
    required this.phoneNum,
  });

  // Factory method to create a UserProfile from a Firestore document
  factory UserProfile.fromDocument(Map<String, dynamic> doc, String uid) {
    return UserProfile(
      uid: uid,
      email: doc['Email'] ?? '',
      name: doc['Name'] ?? '',
      gender: doc['Gender'] ?? '',
      phoneNum: doc['PhoneNum'] ?? '',
    );
  }

  // Convert a UserProfile object to a map to update Firestore
  Map<String, dynamic> toMap() {
    return {
      'Email': email,
      'Name': name,
      'Gender': gender,
      'PhoneNum': phoneNum,
    };
  }
}
