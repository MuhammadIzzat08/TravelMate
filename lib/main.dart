/*
import 'package:flutter/material.dart';
import 'package:travelmate/View/login.dart';
import 'View/itinerary.dart';
import 'View/registration.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(
        primaryColor: Color(0xFFE4F1EE), // Set primary color directly
      ),
      home: RegistrationPage(),////ItineraryList(),//LoginScreen(),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'View/itinerary.dart';
import 'View/login.dart';
import 'View/registration.dart';
import 'View/tripRoom.dart'; // Import Firebase Core

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration Demo',
      theme: ThemeData(
        primaryColor: Color(0xFFE4F1EE),
      ),
      //home: RegistrationPage(),
      home: LoginScreen(),
      //home: ItineraryScreen(),
      //home: FilteredItineraryScreen(),
      //home: TripRoomView(tripRoomId: '',),
      //home: CreateTripRoomView(),
    );
  }
}

