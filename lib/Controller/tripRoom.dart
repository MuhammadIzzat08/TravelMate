// controllers/trip_room_controller.dart

//import 'dart:html';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelmate/Model/itinerary.dart';
import '../Model/tripRoom.dart';
import 'package:flutter/material.dart';



class TripRoomController {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  static Future<void> updateProfilePicture(String tripRoomId, String newProfilePictureUrl) async {
    try {
      await _firestore.collection('tripRooms').doc(tripRoomId).update({
        'profilePicture': newProfilePictureUrl,
      });
    } catch (e) {
      throw Exception('Failed to update profile picture: $e');
    }
  }

  static Future<String> uploadImageAndGetUrl(File image) async {
    try {
      // Create a unique file name for the image
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Get a reference to Firebase Storage
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('tripRooms')
          .child(fileName);

      // Upload the file to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(image);

      // Wait for the upload to complete and get the download URL
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  static Future<void> changeProfilePicture(String tripRoomId) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      String newProfilePictureUrl = await uploadImageAndGetUrl(File(image.path));
      await updateProfilePicture(tripRoomId, newProfilePictureUrl);
    }
  }

  Future<String> fetchTripRoomName(String tripRoomId) async {
    try {
      DocumentSnapshot tripRoomSnapshot = await FirebaseFirestore.instance
          .collection('tripRooms')
          .doc(tripRoomId)
          .get();

      if (tripRoomSnapshot.exists) {
        return tripRoomSnapshot['name']; // Assuming 'name' is the field containing the trip room name
      } else {
        throw Exception('Trip room not found');
      }
    } catch (e) {
      print('Error fetching trip room name: $e');
      rethrow; // Propagate the error up
    }
  }

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
    String fileName = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('trip_room_images')
        .child(fileName);

    UploadTask uploadTask = storageReference.putData(imageBytes);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }


  static Future<void> createTripRoom(
      String userId,
      String name,
      String profilePicture,
      int daysSpent,
      double budget, // New parameter
      int numberOfPersons, // New parameter
      int mealsPerDay, // New parameter
      ) async {
    try {
      DocumentReference tripRoomRef = await _firestore.collection('tripRooms').add({
        'name': name,
        'profilePicture': profilePicture,
        'CreatedDate': FieldValue.serverTimestamp(),
        'daysSpent': daysSpent,
        'budget': budget, // New field
        'numberOfPersons': numberOfPersons, // New field
        'mealsPerDay': mealsPerDay, // New field
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

  static Future<void> addMemberToTripRoom(String tripRoomId,
      String userId) async {
    await _firestore.collection('UserTripRoom').add({
      'TripRoomId': tripRoomId,
      'UserId': userId,
    });
  }



  // Get itinerary list that has been sorted to be displayed at the triproomview
  Future<Itinerary?> getItinerary(String tripRoomId) async {
    try {
      final querySnapshot = await _firestore
          .collection('itineraries')
          .where('tripRoomId', isEqualTo: tripRoomId)
          .get(); // Removed .limit(1)

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return Itinerary.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      throw e;
    }
  }

  static Future<List<String>> getMembersNames(String tripRoomId) async {
    final CollectionReference tripRoomMembersCollection = FirebaseFirestore.instance.collection('UserTripRoom');
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('User');

    final querySnapshot = await tripRoomMembersCollection.where('TripRoomId', isEqualTo: tripRoomId).get();
    final userIds = querySnapshot.docs.map((doc) => doc['UserId'] as String).toList();

    final memberNames = <String>[];
    for (final userId in userIds) {
      final doc = await usersCollection.doc(userId).get();
      if (doc.exists) {
        final userName = doc['Name'] as String;
        memberNames.add(userName);
      }
    }

    return memberNames;
  }

  // New method to update trip room name
  static Future<void> updateTripRoomName(String tripRoomId, String newName) async {
    try {
      await _firestore.collection('tripRooms').doc(tripRoomId).update({'name': newName});
    } catch (e) {
      throw Exception('Failed to update trip room name: $e');
    }
  }

  // New method to update daysSpent
  static Future<void> updateTripRoomDaysSpent(String tripRoomId, int newDaysSpent) async {
    try {
      await _firestore
          .collection('tripRooms')
          .doc(tripRoomId)
          .update({'daysSpent': newDaysSpent});
    } catch (e) {
      throw Exception('Failed to update daysSpent: $e');
    }
  }


  static Future<void> updateTripRoomBudget(String tripRoomId, double budget) async {
    try {
      await FirebaseFirestore.instance
          .collection('tripRooms')
          .doc(tripRoomId)
          .update({'budget': budget});
    } catch (e) {
      throw Exception('Error updating budget: $e');
    }
  }

  static Future<void> updateTripRoomNumberOfPersons(String tripRoomId, int numberOfPeople) async {
    try {
      await FirebaseFirestore.instance
          .collection('tripRooms')
          .doc(tripRoomId)
          .update({'numberOfPersons': numberOfPeople});
    } catch (e) {
      throw Exception('Error updating number of people: $e');
    }
  }

  static Future<void> updateTripRoomMealsPerDay(String tripRoomId, int mealsPerDay) async {
    try {
      await FirebaseFirestore.instance
          .collection('tripRooms')
          .doc(tripRoomId)
          .update({'mealsPerDay': mealsPerDay});
    } catch (e) {
      throw Exception('Error updating meals per day: $e');
    }
  }


  static Future<void> updateTripRoomDetails(String tripRoomId, String newName, int newDaysSpent) async {
    try {
      await _firestore.collection('tripRooms').doc(tripRoomId).update({
        'name': newName,
        'daysSpent': newDaysSpent,
      });
    } catch (e) {
      throw Exception('Failed to update trip room details: $e');
    }
  }
}




