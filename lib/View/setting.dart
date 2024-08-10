import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelmate/View/login.dart';
import 'package:travelmate/View/userProfile.dart';

class SettingsPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _confirmLogout(BuildContext context) async {
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('LOGOUT'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      _logout(context);
    }
  }


  Future<void> _logout(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false, // Removes all previous routes
      );
    } catch (e) {
      print('Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to log out. Please try again.'),
      ));
    }
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserProfilePage()), // Navigate to ProfilePage
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.sourceSerif4(
            color: Color(0xFF7A9E9F),
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF7A9E9F)),
        elevation: 1,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person, color: Color(0xFF7A9E9F)),
            title: Text('Profile'),
            onTap: () => _navigateToProfile(context),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Color(0xFF7A9E9F)),
            title: Text('Logout'),
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }
}

/*
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.sourceSerif4(
            color: Color(0xFF7A9E9F),
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF7A9E9F)),
        elevation: 1,
      ),
      body: Center(
        child: Text(
          'Profile Information',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
*/
