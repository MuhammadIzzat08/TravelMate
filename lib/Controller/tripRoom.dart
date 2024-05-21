// controllers/trip_room_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/tripRoom.dart';
import 'package:flutter/material.dart';

/*
class TripRoomController {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String> createTripRoom(String name, String profilePicture, List<String> members) async {
    DocumentReference docRef = await _firestore.collection('tripRooms').add({
      'name': name,
      'profilePicture': profilePicture,
      'members': members,
    });
    return docRef.id;
  }

  static Future<TripRoom> getTripRoom(String id) async {
    final doc = await _firestore.collection('tripRooms').doc(id).get();
    if (doc.exists) {
      return TripRoom.fromMap(doc.data()!, doc.id);
    } else {
      throw Exception('Trip Room not found');
    }
  }

  static Future<void> addMember(String tripRoomId, String userId) async {
    final tripRoomDoc = _firestore.collection('tripRooms').doc(tripRoomId);
    final doc = await tripRoomDoc.get();
    if (doc.exists) {
      List<String> members = List<String>.from(doc.data()!['members']);
      members.add(userId);
      await tripRoomDoc.update({'members': members});
    } else {
      throw Exception('Trip Room not found');
    }
  }

  static void goToFilteredItineraryScreen(BuildContext context) {
    Navigator.pushNamed(context, '/filtered-itinerary');
  }

  static void goToWishlist(BuildContext context) {
    Navigator.pushNamed(context, '/wishlist');
  }

  static void goToItinerary(BuildContext context) {
    Navigator.pushNamed(context, '/itinerary');
  }

  static void goToExpense(BuildContext context) {
    Navigator.pushNamed(context, '/expense');
  }

  static void goToSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }
}*/




class TripRoomController {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<TripRoom>> getUserTripRooms(String userId) async {
    QuerySnapshot querySnapshot = await _firestore.collection('UserTripRoom')
        .where('UserId', isEqualTo: userId)
        .get();
    List<TripRoom> tripRooms = [];
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      TripRoom tripRoom = await getTripRoom(doc['TripRoomId']);
      tripRooms.add(tripRoom);
    }
    return tripRooms;
  }

  static Future<TripRoom> getTripRoom(String id) async {
    DocumentSnapshot doc = await _firestore.collection('tripRooms')
        .doc(id)
        .get();
    Map<String, dynamic> data = doc.data() as Map<String,
        dynamic>; // Explicit cast
    return TripRoom.fromMap(data, doc.id);
  }

  Future<List<TripRoom>> searchTripRooms(String searchTerm) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tripRooms')
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThanOrEqualTo: searchTerm + '\uf8ff')
        .get();

    return querySnapshot.docs.map((doc) {
      return TripRoom.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }
}


