import 'package:flutter/material.dart';
import 'package:travelmate/Controller/userProfile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travelmate/Model/userProfile.dart';


class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserProfileController _userProfileController = UserProfileController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Future<UserProfile> _userProfileFuture;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    User? user = _auth.currentUser;
    if (user != null) {
      _userProfileFuture = _userProfileController.getUserProfile(user.uid);
    }
  }

  Future<void> _updateUserProfile(UserProfile userProfile) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _userProfileController.updateUserProfile(userProfile);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: FutureBuilder<UserProfile>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            UserProfile _userProfile = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _userProfile.email,
                      decoration: InputDecoration(labelText: 'Email'),
                      readOnly: true, // Email is usually not editable
                    ),
                    TextFormField(
                      initialValue: _userProfile.name,
                      decoration: InputDecoration(labelText: 'Name'),
                      onSaved: (value) {
                        _userProfile.name = value!;
                      },
                    ),
                    TextFormField(
                      initialValue: _userProfile.gender,
                      decoration: InputDecoration(labelText: 'Gender'),
                      onSaved: (value) {
                        _userProfile.gender = value!;
                      },
                    ),
                    TextFormField(
                      initialValue: _userProfile.phoneNum,
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      onSaved: (value) {
                        _userProfile.phoneNum = value!;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _updateUserProfile(_userProfile),
                      child: Text('Update Profile'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: Text('No profile data found'));
          }
        },
      ),
    );
  }
}
