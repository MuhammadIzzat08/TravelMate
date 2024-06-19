
import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:travelmate/Model/itinerary.dart';



/*
class ItineraryController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //------------------------Get the location------------------------------------
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

// -------------------Determine the user current position----------------------
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

  //---calculate the distance between location and user current location--------
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

//-Sort the Location that has been calculated from the nearest to the farthest--
  void sortLocationsByDistance(List<Location> locations, Position startLocation) {
    locations.sort((a, b) {
      final double distanceA = _calculateDistance(startLocation.latitude,
          startLocation.longitude, a.latitude!, a.longitude!);
      final double distanceB = _calculateDistance(startLocation.latitude,
          startLocation.longitude, b.latitude!, b.longitude!);
      return distanceA.compareTo(distanceB);
    });
  }

  //---------------------Get the locations in the wishlist----------------------
  Future<List<Location>> getWishlistItems(String tripRoomId) async {
    try {
      // Query the wishlist collection with an additional condition
      final wishlistSnapshot = await _firestore
          .collection('wishlist')
          .where('tripRoomId', isEqualTo: tripRoomId)
          .where('Visited', isEqualTo: false) // Only include items where Visited is false
          .get();

      // Extract location IDs from the wishlist
      final locationIds = wishlistSnapshot.docs.map((doc) => doc['locationId']).toList();

      // Fetch locations from the locations collection based on IDs
      final locations = await Future.wait(locationIds.map((id) async {
        final docSnapshot = await _firestore.collection('locations').doc(id).get();
        if (docSnapshot.exists) {
          return Location.fromMap(docSnapshot.id, docSnapshot.data()!);
        } else {
          return null;
        }
      }).toList());

      // Filter out any null values from the results
      return locations.where((location) => location != null).cast<Location>().toList();
    } catch (e) {
      print('Error fetching wishlist items: $e');
      throw e;
    }
  }

  //--Generate itinerary by calculate and sort the locations based on distance--
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


//----------------Mark the location as visited when tick the box----------------
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

*/

/*class ItineraryController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Location>> getLocations() async {
    try {
      final locationsRef = _firestore.collection('locations');
      final querySnapshot = await locationsRef.get();
      final locations = querySnapshot.docs.map((doc) => Location.fromMap(doc.id, doc.data())).toList();
      return locations;
    } catch (e) {
      print('Error fetching locations: $e');
      return [];
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
    const double R = 6371;
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
      final double distanceA = _calculateDistance(startLocation.latitude, startLocation.longitude, a.latitude!, a.longitude!);
      final double distanceB = _calculateDistance(startLocation.latitude, startLocation.longitude, b.latitude!, b.longitude!);
      return distanceA.compareTo(distanceB);
    });
  }

  List<Location> filterLocationsByTime(List<Location> locations, DateTime currentTime) {
    List<Location> filteredLocations = [];

    for (var location in locations) {
      final operatingHours = location.operatingHour;
      final approximateTime = location.approximateTime ?? 0.0;

      if (operatingHours == "24-Hours" ||
          (operatingHours == "Breakfast" && currentTime.hour >= 8 && currentTime.hour < 12) ||
          (operatingHours == "Lunch" && currentTime.hour >= 12 && currentTime.hour < 17) ||
          (operatingHours == "Office Hour" && currentTime.hour >= 8 && currentTime.hour < 18) ||
          (operatingHours == "Dinner" && currentTime.hour >= 20 && currentTime.hour < 24) ||
          (operatingHours == "All Time" && currentTime.hour >= 8 && currentTime.hour < 24))
      {
        if (currentTime.add(Duration(hours: approximateTime.toInt())).hour <= 23) {
          filteredLocations.add(location);
        }
      }
    }

    return filteredLocations;
  }

  Future<List<Location>> getWishlistItems(String tripRoomId) async {
    try {
      final wishlistSnapshot = await _firestore
          .collection('wishlist')
          .where('tripRoomId', isEqualTo: tripRoomId)
          .where('Visited', isEqualTo: false)
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

      DateTime currentTime = DateTime(2024, 1, 1, 9, 0);

      List<Location> finalItinerary = [];

      while (currentTime.hour <= 23 && wishlistItems.isNotEmpty) {
        List<Location> filteredLocations = filterLocationsByTime(wishlistItems, currentTime);
        if (filteredLocations.isNotEmpty) {
          Location nextLocation = filteredLocations.first;
          finalItinerary.add(nextLocation);
          currentTime = currentTime.add(Duration(hours: nextLocation.approximateTime!.toInt()));
          wishlistItems.remove(nextLocation);
        } else {
          break;
        }
      }

      return finalItinerary;
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
} *///latest

class ItineraryController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Location>> getLocations() async {
    try {
      final locationsRef = _firestore.collection('locations');
      final querySnapshot = await locationsRef.get();
      final locations = querySnapshot.docs.map((doc) => Location.fromMap(doc.id, doc.data())).toList();
      return locations;
    } catch (e) {
      print('Error fetching locations: $e');
      return [];
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
    const double R = 6371;
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lat2 - lon2);
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
      final double distanceA = _calculateDistance(startLocation.latitude, startLocation.longitude, a.latitude!, a.longitude!);
      final double distanceB = _calculateDistance(startLocation.latitude, startLocation.longitude, b.latitude!, b.longitude!);
      return distanceA.compareTo(distanceB);
    });
  }

  bool _isLocationOpenAtTime(Location location, DateTime time) {
    final operatingHours = location.operatingHour;
    return operatingHours == "24-Hours" ||
        (operatingHours == "Breakfast" && time.hour >= 8 && time.hour < 12) ||
        (operatingHours == "Lunch" && time.hour >= 12 && time.hour < 17) ||
        (operatingHours == "Office Hour" && time.hour >= 8 && time.hour < 18) ||
        (operatingHours == "Dinner" && time.hour >= 20 && time.hour < 24) ||
        (operatingHours == "All Time" && time.hour >= 8 && time.hour < 24);
  }

  DateTime _getNextStartTime(DateTime currentTime, String operatingHours) {
    if (operatingHours == "Lunch") {
      return DateTime(currentTime.year, currentTime.month, currentTime.day, 12);
    } else if (operatingHours == "Dinner") {
      return DateTime(currentTime.year, currentTime.month, currentTime.day, 20);
    }
    return currentTime;
  }

  List<Location> filterLocationsByTime(List<Location> locations, DateTime currentTime) {
    List<Location> filteredLocations = [];

    for (var location in locations) {
      final operatingHours = location.operatingHour;
      final approximateTime = location.approximateTime ?? 0.0;

      if (operatingHours == "24-Hours" ||
          (operatingHours == "Breakfast" && currentTime.hour >= 8 && currentTime.hour < 12) ||
          (operatingHours == "Lunch" && currentTime.hour >= 12 && currentTime.hour < 17) ||
          (operatingHours == "Office Hour" && currentTime.hour >= 8 && currentTime.hour < 18) ||
          (operatingHours == "Dinner" && currentTime.hour >= 20 && currentTime.hour < 24) ||
          (operatingHours == "All Time" && currentTime.hour >= 8 && currentTime.hour < 24))
      {
        if (currentTime.add(Duration(hours: approximateTime.toInt())).hour <= 23) {
          filteredLocations.add(location);
        }
      }
    }

    return filteredLocations;
  }

  Future<List<Location>> getWishlistItems(String tripRoomId) async {
    try {
      final wishlistSnapshot = await _firestore
          .collection('wishlist')
          .where('tripRoomId', isEqualTo: tripRoomId)
          .where('Visited', isEqualTo: false)
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

 /* Future<List<Location>> generateItinerary(String tripRoomId) async {
    try {
      final userPosition = await determinePosition();
      final wishlistItems = await getWishlistItems(tripRoomId);

      sortLocationsByDistance(wishlistItems, userPosition);

      DateTime currentTime = DateTime(2024, 1, 1, 9, 0);

      List<Location> finalItinerary = [];

      while (currentTime.hour <= 23 && wishlistItems.isNotEmpty) {
        List<Location> filteredLocations = filterLocationsByTime(wishlistItems, currentTime);
        if (filteredLocations.isNotEmpty) {
          Location nextLocation = filteredLocations.first;
          finalItinerary.add(nextLocation);
          currentTime = currentTime.add(Duration(hours: nextLocation.approximateTime!.toInt()));
          wishlistItems.remove(nextLocation);
        } else {
          // Adjust the current time to the next possible location's start time
          for (var location in wishlistItems) {
            DateTime nextStartTime = _getNextStartTime(currentTime, location.operatingHour!);
            if (_isLocationOpenAtTime(location, nextStartTime)) {
              currentTime = nextStartTime;
              break;
            }
          }
        }
      }

      return finalItinerary;
    } catch (e) {
      print('Error generating itinerary: $e');
      throw e;
    }
  }
*/ // SIMPAN JANGAN DELTE GENERATE ITINERARY LAMA NI

  Future<List<Location>> generateItinerary(String tripRoomId) async {
    try {
      final userPosition = await determinePosition();
      final wishlistItems = await getWishlistItems(tripRoomId);

      sortLocationsByDistance(wishlistItems, userPosition);

      DateTime currentTime = DateTime(2024, 1, 1, 9, 0); // Assume a start time of 9 AM

      List<Location> finalItinerary = [];

      while (currentTime.hour <= 23 && wishlistItems.isNotEmpty) {
        List<Location> filteredLocations = filterLocationsByTime(wishlistItems, currentTime);

        if (filteredLocations.isNotEmpty) {
          Location nextLocation = filteredLocations.first;
          finalItinerary.add(nextLocation);
          currentTime = currentTime.add(Duration(hours: nextLocation.approximateTime!.toInt()));
          wishlistItems.remove(nextLocation);
        } else {
          // Check for locations with operating hours "Dinner" or "Lunch"
          List<Location> alternativeLocations = wishlistItems.where((location) {
            return location.operatingHour == "Dinner" || location.operatingHour == "Lunch";
          }).toList();

          if (alternativeLocations.isNotEmpty) {
            Location nextLocation = alternativeLocations.first;
            // Set currentTime to the appropriate starting time
            if (nextLocation.operatingHour == "Lunch") {
              currentTime = DateTime(currentTime.year, currentTime.month, currentTime.day, 12, 0);
            } else if (nextLocation.operatingHour == "Dinner") {
              currentTime = DateTime(currentTime.year, currentTime.month, currentTime.day, 20, 0);
            }
            currentTime = currentTime.add(Duration(hours: nextLocation.approximateTime!.toInt()));
            finalItinerary.add(nextLocation);
            wishlistItems.remove(nextLocation);
          } else {
            break; // No suitable locations left
          }
        }
      }

      return finalItinerary;
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
        return location.type ==option/*toLowerCase().contains(option.toLowerCase())*/ ||
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






