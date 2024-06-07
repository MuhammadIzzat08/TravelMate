
import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:travelmate/Model/itinerary.dart';

/*class ItineraryController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }


  Future<List<Location>> getLocations() async {
    try {
      final locationsRef = _firestore.collection('locations');
      final querySnapshot = await locationsRef.get();
      final locations = querySnapshot.docs.map((doc) => Location.fromMap(doc.id, doc.data())).toList();
      return locations;
    } catch (e) {
      // Handle error
      print('Error fetching locations: $e');
      return []; // Return an empty list in case of error
    }
  }
  Future<List<Location>> getWishlistItems(String tripRoomId) async {
    try {
      final querySnapshot = await _firestore
          .collection('wishlist')
          .where('tripRoomId', isEqualTo: tripRoomId)
          .get();

      final locationIds = querySnapshot.docs.map((doc) {
        return doc['locationId'];
      }).toList();

      final locationDetails = await Future.wait(locationIds.map((id) async {
        final docSnapshot = await _firestore.collection('locations').doc(id).get();
        if (docSnapshot.exists) {
          return Location.fromMap(docSnapshot.id, docSnapshot.data()!);
        } else {
          return null;
        }
      }).toList());

      return locationDetails.where((details) => details != null).cast<Location>().toList();
    } catch (e) {
      throw e;
    }
  }

  Future<void> saveItinerary(String tripRoomId, List<Location> itinerary) async {
    final itineraryData = itinerary.map((location) => location.toMap()).toList();
    final newItineraryRef = await _firestore.collection('itineraries').add({
      'tripRoomId': tripRoomId,
      'itinerary': itineraryData,
    });
    await _firestore.collection('tripRooms').doc(tripRoomId).update({
      'itineraryId': newItineraryRef.id,
    });
  }

  Future<List<Location>> getItinerary(String tripRoomId) async {
    try {
      final querySnapshot = await _firestore
          .collection('itineraries')
          .where('tripRoomId', isEqualTo: tripRoomId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        final locationsData = data['locations'] as List<dynamic>? ?? [];

        return locationsData.map((item) => Location.fromMap(item['id'] as String, item as Map<String, dynamic>)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw e;
    }
  }



  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Radius of the Earth in kilometers
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  void sortLocationsByDistance(List<Location> locations, Position startLocation) {
    locations.sort((a, b) {
      final double distanceA = _calculateDistance(startLocation.latitude!, startLocation.longitude!, a.latitude!, a.longitude!);
      final double distanceB = _calculateDistance(startLocation.latitude!, startLocation.longitude!, b.latitude!, b.longitude!);
      return distanceA.compareTo(distanceB);
    });
  }

*//*  Future<List<Location>> generateItinerary(String tripRoomId, List<Location> wishlistItems) async {
    try {
      // Define your starting location
      Location startLocation = wishlistItems.first;

      // Sort wishlist items by distance from the starting point
      sortLocationsByDistance(wishlistItems, startLocation);

      // Save the sorted itinerary
      await saveItinerary(tripRoomId, wishlistItems);

      return wishlistItems;
    } catch (e) {
      throw e;
    }
  }*//*
  Future<List<Location>> generateItinerary(String tripRoomId, List<Location> wishlistItems) async {
    try {
      final userPosition = await determinePosition();
      sortLocationsByDistance(wishlistItems, userPosition);
      await saveItinerary(tripRoomId, wishlistItems);
      return wishlistItems;
    } catch (e) {
      throw e;
    }
  }

  Future<void> markLocationAsVisited(String tripRoomId, String locationId) async {
    try {
      final querySnapshot = await _firestore.collection('itineraries')
          .where('tripRoomId', isEqualTo: tripRoomId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        final itinerary = data['itinerary'] as List<dynamic>;

        final updatedItinerary = itinerary.map((item) {
          if (item['id'] == locationId) {
            return {...item, 'visited': true};
          }
          return item;
        }).toList();

        await _firestore.collection('itineraries').doc(doc.id).update({
          'itinerary': updatedItinerary,
        });
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateItineraryWithGeofencing(String tripRoomId) async {
    // Implement geofencing setup here
  }
}*/

class ItineraryController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Location>> getLocations() async {
    try {
      final locationsRef = _firestore.collection('locations');
      final querySnapshot = await locationsRef.get();
      final locations = querySnapshot.docs.map((doc) => Location.fromMap
        (doc.id, doc.data())).toList();
      return locations;
    } catch (e) {
      // Handle error
      print('Error fetching locations: $e');
      return []; // Return an empty list in case of error
    }
  }


  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Radius of the earth in km
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distance in km
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  void sortLocationsByDistance(List<Location> locations, Position startLocation) {
    locations.sort((a, b) {
      final double distanceA = _calculateDistance(startLocation.latitude,
          startLocation.longitude, a.latitude!, a.longitude!);
      final double distanceB = _calculateDistance(startLocation.latitude,
          startLocation.longitude, b.latitude!, b.longitude!);
      return distanceA.compareTo(distanceB);
    });
  }

  Future<List<Location>> getWishlistItems(String tripRoomId) async {
    try {
      final wishlistSnapshot = await _firestore
          .collection('wishlist')
          .where('tripRoomId', isEqualTo: tripRoomId)
          .get();

      final locationIds = wishlistSnapshot.docs.map((doc) => doc['locationId']).toList();

      final locations = await Future.wait(locationIds.map((id) async {
        final docSnapshot = await _firestore.collection('locations').doc(id).get();
        if (docSnapshot.exists) {
          return Location.fromMap(docSnapshot.id, docSnapshot.data()!);
        } else {
          return null;
        }
      }).toList());

      return locations.where((location) => location != null).cast<Location>().toList();
    } catch (e) {
      print('Error fetching wishlist items: $e');
      throw e;
    }
  }

  Future<List<Location>> generateItinerary(String tripRoomId) async {
    try {
      final userPosition = await determinePosition();
      final wishlistItems = await getWishlistItems(tripRoomId);
      sortLocationsByDistance(wishlistItems, userPosition);
      return wishlistItems;
    } catch (e) {
      print('Error generating itinerary: $e');
      throw e;
    }
  }

  Future<void> markLocationAsVisited(String tripRoomId, String locationId) async {
    try {
      final querySnapshot = await _firestore
          .collection('wishlist')
          .where('tripRoomId', isEqualTo: tripRoomId)
          .where('locationId', isEqualTo: locationId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        await _firestore.collection('wishlist').doc(doc.id).update({'Visited': true});
      }
    } catch (e) {
      print('Error marking location as visited: $e');
      throw e;
    }
  }
}






class FilteredItineraryController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<LocationFilter>> getLocations() async {
    try {
      final locationsRef = _firestore.collection('locations');
      final querySnapshot = await locationsRef.get();
      final locations = querySnapshot.docs.map((doc) =>
          LocationFilter.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      return locations;
    } catch (e) {
      // Handle error
      print('Error fetching locations: $e');
      return []; // Return an empty list in case of error
    }
  }

  Future<List<LocationFilter>> filterLocations({
    List<String>? placeType,
    List<String>? cuisineType,
    List<String>? priceRate,
    List<String>? purpose,
    List<String>? accessability,
  }) async {
    final allLocations = await getLocations();

    final filteredResult = allLocations.where((location) {
      // Check if any of the selected options match the specific fields in the location data
      return [
        ...placeType ?? [],
        ...cuisineType ?? [],
        ...priceRate ?? [],
        ...purpose ?? [],
        ...accessability ?? [],
      ].any((option) {
        // Check if the option matches the Type, Price, Purpose, or Accessibility field in the location data
        return location.type.toLowerCase().contains(option.toLowerCase()) ||
            location.cuisine.toLowerCase().contains(option.toLowerCase()) ||
            location.price.toLowerCase().contains(option.toLowerCase()) ||
            location.purpose.toLowerCase().contains(option.toLowerCase()) ||
            location.accessability.toLowerCase().contains(option.toLowerCase());
      });
    }).toList();

    return filteredResult;
  }

  Future<List<LocationFilter>> searchLocations(String searchText) async {
    final allLocations = await getLocations();
    final filteredResult = allLocations.where((location) {
      return location.name.toLowerCase().contains(searchText.toLowerCase()) ||
          location.description.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
    return filteredResult;
  }


}






