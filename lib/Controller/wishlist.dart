

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelmate/Controller/itinerary.dart';
import 'package:travelmate/Model/wishlist.dart';
import 'package:travelmate/Model/itinerary.dart';

class WishlistController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToWishlist(WishlistItem item) async {
    try {
      await _firestore.collection('wishlist').add(item.toMap());
    } catch (e) {
      print('Error adding to wishlist: $e');
      throw e;
    }
  }

  Future<List<Location>> getWishlistItems(String tripRoomId) async {
    try {
      final querySnapshot = await _firestore
          .collection('wishlist')
          .where('tripRoomId', isEqualTo: tripRoomId)
          .get();

      final locationIds = querySnapshot.docs.map((doc) {
        print('Wishlist Item: ${doc.data()}');
        return doc['locationId'];
      }).toList();

      print('Location IDs in wishlist for tripRoomId $tripRoomId: $locationIds');

      final locationDetails = await Future.wait(locationIds.map((id) async {
        final docSnapshot = await _firestore.collection('locations').doc(id).get();
        if (docSnapshot.exists) {
          print('Location details for ID $id: ${docSnapshot.data()}');
          return Location.fromMap(docSnapshot.id, docSnapshot.data()!);
        } else {
          print('Location with ID $id does not exist');
          return null;
        }
      }).toList());

      return locationDetails.where((details) => details != null).cast<Location>().toList();
    } catch (e) {
      print('Error fetching wishlist items: $e');
      throw e;
    }
  }

  Future<void> deleteFromWishlist(String tripRoomId, String locationId) async {
    try {
      final querySnapshot = await _firestore
          .collection('wishlist')
          .where('tripRoomId', isEqualTo: tripRoomId)
          .where('locationId', isEqualTo: locationId)
          .get();

      for (var doc in querySnapshot.docs) {
        await _firestore.collection('wishlist').doc(doc.id).delete();
      }
    } catch (e) {
      print('Error deleting from wishlist: $e');
      throw e;
    }
  }

/*  Future<void> generateAndSaveItinerary(String tripRoomId) async {
    try {
      final wishlistItems = await getWishlistItems(tripRoomId);
      final itineraryController = ItineraryController();
      final itinerary = await itineraryController.generateItinerary(tripRoomId, wishlistItems);
      await itineraryController.saveItinerary(tripRoomId, itinerary);
      await itineraryController.updateItineraryWithGeofencing(tripRoomId);
    } catch (e) {
      print('Error generating and saving itinerary: $e');
      throw e;
    }
  }*/

  Future<bool> checkLocationExistsInWishlist(WishlistItem wishlistItem) async {
    try {
      final querySnapshot = await _firestore
          .collection('wishlist')
          .where('tripRoomId', isEqualTo: wishlistItem.tripRoomId)
          .where('locationId', isEqualTo: wishlistItem.locationId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // Handle error
      print('Error checking location in wishlist: $e');
      return false; // Return false in case of error
    }
  }
}
