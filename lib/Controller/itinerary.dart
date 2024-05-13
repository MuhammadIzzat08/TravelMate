import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelmate/Model/itinerary.dart';

class ItineraryController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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


}

class FilteredItineraryController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<LocationFilter>> getLocations() async {
    try {
      final locationsRef = _firestore.collection('locations');
      final querySnapshot = await locationsRef.get();
      final locations = querySnapshot.docs.map((doc) => LocationFilter.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
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