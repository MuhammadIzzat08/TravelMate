// controllers/trip_room_controller.dart

//import 'dart:html';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../Model/tripRoom.dart';
import 'package:flutter/material.dart';


/*
class TripRoomController {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<TripRoom>> getUserTripRooms(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('UserTripRoom')
          .where('UserId', isEqualTo: userId)
          .get();
      List<TripRoom> tripRooms = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        TripRoom tripRoom = await getTripRoom(doc['TripRoomId']);
        tripRooms.add(tripRoom);
      }
      return tripRooms;
    } catch (e) {
      throw Exception('Failed to fetch user trip rooms: $e');
    }
  }

  static Future<TripRoom> getTripRoom(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('tripRooms')
          .doc(id)
          .get();
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return TripRoom.fromMap(data, doc.id);
    } catch (e) {
      throw Exception('Failed to fetch trip room: $e');
    }
  }

  static Future<List<TripRoom>> searchTripRooms(String searchTerm) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('tripRooms')
          .where('name', isGreaterThanOrEqualTo: searchTerm)
          .where('name', isLessThanOrEqualTo: searchTerm + '\uf8ff')
          .get();

      return querySnapshot.docs.map((doc) {
        return TripRoom.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search trip rooms: $e');
    }
  }


  static Future<String> uploadImage(Uint8List imageBytes) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('trip_room_images')
        .child(fileName);

    UploadTask uploadTask = storageReference.putData(imageBytes);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }


  static Future<void> createTripRoom(String userId, String name, String profilePicture) async {
    try {
      DocumentReference tripRoomRef = await _firestore.collection('tripRooms').add({
        'name': name,
        'profilePicture': profilePicture,
        'CreatedDate': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('UserTripRoom').add({
        'UserId': userId,
        'TripRoomId': tripRoomRef.id,
      });
    } catch (e) {
      throw Exception('Failed to create trip room: $e');
    }
  }

  static Future<String?> getUserIdByEmail(String email) async {
    QuerySnapshot querySnapshot = await _firestore.collection('User')
        .where('Email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      return null;
    }
  }

  static Future<void> addMemberToTripRoom(String tripRoomId, String userId) async {
    await _firestore.collection('UserTripRoom').add({
      'TripRoomId': tripRoomId,
      'UserId': userId,
    });
  }
}
*/

class TripRoomController {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<TripRoom>> getUserTripRooms(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('UserTripRoom')
          .where('UserId', isEqualTo: userId)
          .get();
      List<TripRoom> tripRooms = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        TripRoom tripRoom = await getTripRoom(doc['TripRoomId']);
        tripRooms.add(tripRoom);
      }
      return tripRooms;
    } catch (e) {
      throw Exception('Failed to fetch user trip rooms: $e');
    }
  }

  static Future<TripRoom> getTripRoom(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('TripRoom ID is empty');
      }
      DocumentSnapshot doc = await _firestore.collection('tripRooms')
          .doc(id)
          .get();
      if (!doc.exists) {
        throw Exception('TripRoom with ID $id does not exist');
      }
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return TripRoom.fromMap(data, doc.id);
    } catch (e) {
      throw Exception('Failed to fetch trip room: $e');
    }
  }

  static Future<List<TripRoom>> searchTripRooms(String searchTerm) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('tripRooms')
          .where('name', isGreaterThanOrEqualTo: searchTerm)
          .where('name', isLessThanOrEqualTo: searchTerm + '\uf8ff')
          .get();

      return querySnapshot.docs.map((doc) {
        return TripRoom.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search trip rooms: $e');
    }
  }

  static Future<String> uploadImage(Uint8List imageBytes) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('trip_room_images')
        .child(fileName);

    UploadTask uploadTask = storageReference.putData(imageBytes);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  static Future<void> createTripRoom(String userId, String name, String profilePicture) async {
    try {
      DocumentReference tripRoomRef = await _firestore.collection('tripRooms').add({
        'name': name,
        'profilePicture': profilePicture,
        'CreatedDate': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('UserTripRoom').add({
        'UserId': userId,
        'TripRoomId': tripRoomRef.id,
      });
    } catch (e) {
      throw Exception('Failed to create trip room: $e');
    }
  }

  static Future<String?> getUserIdByEmail(String email) async {
    QuerySnapshot querySnapshot = await _firestore.collection('User')
        .where('Email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      return null;
    }
  }

  static Future<void> addMemberToTripRoom(String tripRoomId, String userId) async {
    await _firestore.collection('UserTripRoom').add({
      'TripRoomId': tripRoomId,
      'UserId': userId,
    });
  }
}


