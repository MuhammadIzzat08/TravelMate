

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelmate/Model/wishlist.dart';
import 'package:travelmate/Model/itinerary.dart';

class WishlistController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToWishlist(WishlistItem item) async {
    try {
      // Save the item directly to the wishlist collection with a new document ID
      await _firestore.collection('wishlist').add(item.toMap());
    } catch (e) {
      // Handle error
      print('Error adding to wishlist: $e');
      throw e; // Rethrow the error to handle it in the UI if needed
    }
  }


  Future<List<Location>> getWishlistItems(String tripRoomId) async {
    try {
      // Fetch wishlist items for the given tripRoomId
      final querySnapshot = await _firestore
          .collection('wishlist')
          .where('tripRoomId', isEqualTo: tripRoomId)
          .get();

      // Extract locationIds from the fetched wishlist items
      final locationIds = querySnapshot.docs.map((doc) {
        print('Wishlist Item: ${doc.data()}'); // Debugging
        return doc['locationId'];
      }).toList();

      // Debugging print statement
      print('Location IDs in wishlist for tripRoomId $tripRoomId: $locationIds');

      // Fetch details for each locationId
      final locationDetails = await Future.wait(locationIds.map((id) async {
        final docSnapshot = await _firestore.collection('locations').doc(id).get();
        if (docSnapshot.exists) {
          print('Location details for ID $id: ${docSnapshot.data()}'); // Debugging
          return Location.fromMap(docSnapshot.id, docSnapshot.data()!);
        } else {
          print('Location with ID $id does not exist'); // Debugging
          return null; // Handle non-existent document
        }
      }).toList());

      // Filter out any null values
      final validLocationDetails = locationDetails.where((details) => details != null).toList();

      // Debugging print statement
      print('Fetched ${validLocationDetails.length} wishlist items for tripRoomId $tripRoomId');

      return validLocationDetails.cast<Location>();
    } catch (e) {
      print('Error fetching wishlist items: $e');
      throw e;
    }
  }
}