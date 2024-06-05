
import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
  String id;
  String? description;
  double? latitude;
  double? longitude;
  String? name;
  String? operatingHour;
  String? price;
  String? type;
  bool visited;

  Location({
    required this.id,
    this.description,
    this.latitude,
    this.longitude,
    this.name,
    this.operatingHour,
    this.price,
    this.type,
    this.visited = false,
  });

  factory Location.fromMap(String id, Map<String, dynamic> map) {
    return Location(
      id: id,
      description: map['Description'],
      latitude: map['Latitude'],
      longitude: map['Longitude'],
      name: map['Name'],
      operatingHour: map['Operating_hour'],
      price: map['Price'],
      type: map['Type'],
      visited: map['Visited'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Description': description,
      'Latitude': latitude,
      'Longitude': longitude,
      'Name': name,
      'Operating_hour': operatingHour,
      'Price': price,
      'Type': type,
      'Visited': visited,
    };
  }
}

// FILTERED LOCATION MODEL //
class LocationFilter {
  final String id;
  final String description;
  final double latitude;
  final double longitude;
  final String name;
  final String operatingHour;
  final String price;
  final String type;
  final String cuisine;
  final String purpose;
  final String accessability;

  LocationFilter({
    required this.id,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.operatingHour,
    required this.price,
    required this.type,
    required this.cuisine,
    required this.purpose,
    required this.accessability,
  });

  factory LocationFilter.fromMap(String id, Map<String, dynamic> map) {
    return LocationFilter(
      id: id,
      description: map['Description'] ?? '',
      latitude: (map['Latitude'] ?? 0.0).toDouble(),
      longitude: (map['Longitude'] ?? 0.0).toDouble(),
      name: map['Name'] ?? '',
      operatingHour: map['Operating_hour'] ?? '',
      price: map['Price'] ?? '',
      type: map['Type'] ?? '',
      cuisine: map['Cuisine'] ?? '',
      purpose: map['Purpose'] ?? '',
      accessability: map['Accessability'] ?? '',
    );
  }
}

//  ITINERARY MODEL  //
class Itinerary {
  String id;
  String tripRoomId;
  List<Location> locations;

  Itinerary({
    required this.id,
    required this.tripRoomId,
    required this.locations,
  });

  factory Itinerary.fromMap(String id, Map<String, dynamic>? map) {
    if (map == null || map['itinerary'] == null) {
      // Handle the case where map or 'locations' is null
      return Itinerary(
        id: id,
        tripRoomId: '',
        locations: [], // Return an empty list
      );
    }

    var locationsFromMap = (map['itinerary'] as List<dynamic>)
        .map((item) => Location.fromMap(id, item as Map<String, dynamic>))
        .toList();

    return Itinerary(
      id: id,
      tripRoomId: map['tripRoomId'] ?? '', // Use default value if tripRoomId is null
      locations: locationsFromMap,
    );
  }
}






