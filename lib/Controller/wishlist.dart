

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelmate/Controller/itinerary.dart';
import 'package:travelmate/Model/wishlist.dart';
import 'package:travelmate/Model/itinerary.dart';

/*
class WishlistController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToWishlist(WishlistItem item) async {
    try {
      await _firestore.collection('wishlist').add({
        ...item.toMap(),
        'Visited': false, // Default Visited field set to false
      });
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
          final location = Location.fromMap(docSnapshot.id, docSnapshot.data()!);
          // Adding 'Visited' status to the location if not already present
          final wishlistDoc = querySnapshot.docs.firstWhere((doc) => doc['locationId'] == id);
          location.visited = wishlistDoc['Visited'] ?? false;
          return location;
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

  Future<void> updateVisitedStatus(String tripRoomId, String locationId, bool visited) async {
    try {
      final querySnapshot = await _firestore
          .collection('wishlist')
          .where('tripRoomId', isEqualTo: tripRoomId)
          .where('locationId', isEqualTo: locationId)
          .get();

      for (var doc in querySnapshot.docs) {
        await _firestore.collection('wishlist').doc(doc.id).update({
          'Visited': visited,
        });
      }
    } catch (e) {
      print('Error updating visited status: $e');
      throw e;
    }
  }

  Future<bool> checkLocationExistsInWishlist(WishlistItem wishlistItem) async {
    try {
      final querySnapshot = await _firestore
          .collection('wishlist')
          .where('tripRoomId', isEqualTo: wishlistItem.tripRoomId)
          .where('locationId', isEqualTo: wishlistItem.locationId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking location in wishlist: $e');
      return false;
    }
  }

  // New method to get the number of days for the trip from tripRooms collection
  Future<int> getTripDays(String tripRoomId) async {
    try {
      final docSnapshot = await _firestore.collection('tripRooms').doc(tripRoomId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return docSnapshot.data()!['daysSpent'] ?? 0;
      } else {
        print('Trip room with ID $tripRoomId does not exist or has no days field');
        return 0;
      }
    } catch (e) {
      print('Error fetching trip days: $e');
      throw e;
    }
  }


}
*/

class WishlistController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToWishlist(WishlistItem item) async {
    try {
      await _firestore.collection('wishlist').add({
        ...item.toMap(),
        'Visited': false, // Default Visited field set to false
      });
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
          final location = Location.fromMap(docSnapshot.id, docSnapshot.data()!);
          // Adding 'Visited' status to the location if not already present
          final wishlistDoc = querySnapshot.docs.firstWhere((doc) => doc['locationId'] == id);
          location.visited = wishlistDoc['Visited'] ?? false;
          return location;
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

  Future<void> updateVisitedStatus(String tripRoomId, String locationId, bool visited) async {
    try {
      final querySnapshot = await _firestore
          .collection('wishlist')
          .where('tripRoomId', isEqualTo: tripRoomId)
          .where('locationId', isEqualTo: locationId)
          .get();

      for (var doc in querySnapshot.docs) {
        await _firestore.collection('wishlist').doc(doc.id).update({
          'Visited': visited,
        });
      }
    } catch (e) {
      print('Error updating visited status: $e');
      throw e;
    }
  }

  Future<bool> checkLocationExistsInWishlist(WishlistItem wishlistItem) async {
    try {
      final querySnapshot = await _firestore
          .collection('wishlist')
          .where('tripRoomId', isEqualTo: wishlistItem.tripRoomId)
          .where('locationId', isEqualTo: wishlistItem.locationId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking location in wishlist: $e');
      return false;
    }
  }

  Future<int> getTripDays(String tripRoomId) async {
    try {
      final docSnapshot = await _firestore.collection('tripRooms').doc(tripRoomId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return docSnapshot.data()!['daysSpent'] ?? 0;
      } else {
        print('Trip room with ID $tripRoomId does not exist or has no days field');
        return 0;
      }
    } catch (e) {
      print('Error fetching trip days: $e');
      throw e;
    }
  }
}




