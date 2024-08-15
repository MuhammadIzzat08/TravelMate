
import 'package:cloud_firestore/cloud_firestore.dart';

/*class Location {
  String id;
  String? description;
  double? latitude;
  double? longitude;
  String? name;
  String? operatingHour;
  String? price;
  String? type;
  double? approximate_time;
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
    this.approximate_time,
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
      approximate_time: map['Approximate_Time'],
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
      'Approximate_Time': approximate_time,
      'Visited': visited,
    };
  }
}*/

/*
class Location {
  String id;
  String? description;
  double? latitude;
  double? longitude;
  String? name;
  String? operatingHour;
  String? price;
  String? type;
  double? approximateTime;
  bool visited;
  DateTime? endTime;

  Location({
    required this.id,
    this.description,
    this.latitude,
    this.longitude,
    this.name,
    this.operatingHour,
    this.price,
    this.type,
    this.approximateTime,
    this.visited = false,
    this.endTime,
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
      approximateTime: map['Approximate_Time']?.toDouble(),
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
      'Approximate_Time': approximateTime,
      'Visited': visited,
    };
  }
}
*/ //latest

class Location {
  String id;
  String? description;
  double? latitude;
  double? longitude;
  String? name;
  String? operatingHour;
  String? price;
  String? type;
  double? approximateTime;
  bool visited;
  DateTime? endTime;

  Location({
    required this.id,
    this.description,
    this.latitude,
    this.longitude,
    this.name,
    this.operatingHour,
    this.price,
    this.type,
    this.approximateTime,
    this.visited = false,
    this.endTime,
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
      approximateTime: (map['Approximate_Time'] is String)
          ? double.tryParse(map['Approximate_Time']) ?? 0.0
          : map['Approximate_Time']?.toDouble(),
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
      'Approximate_Time': approximateTime,
      'Visited': visited,
    };
  }

  bool isRestaurant() {
    return type != null && (type!.contains("halal") || type!.contains("restaurant"));
  }
}






// FILTERED LOCATION MODEL //
/*class LocationFilter {
  final String id;
  final String description;
  final double latitude;
  final double longitude;
  final String name;
  final String operatingHour;
  final String price;
  final String type;
  final double? approximateTime;
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
    required this.approximateTime,
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
      approximateTime: map['Approximate_Time']?.toDouble(),
      cuisine: map['Cuisine'] ?? '',
      purpose: map['Purpose'] ?? '',
      accessability: map['Accessability'] ?? '',
    );
  }
}*/
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
  final double? approximateTime;
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
    required this.approximateTime,
    required this.cuisine,
    required this.purpose,
    required this.accessability,
  });

  factory LocationFilter.fromMap(String id, Map<String, dynamic> map) {
    return LocationFilter(
      id: id,
      description: map['Description'] ?? '',
      latitude: _toDouble(map['Latitude']),
      longitude: _toDouble(map['Longitude']),
      name: map['Name'] ?? '',
      operatingHour: map['Operating_hour'] ?? '',
      price: map['Price'] ?? '',
      type: map['Type'] ?? '',
      approximateTime: _toDouble(map['Approximate_Time']),
      cuisine: map['Cuisine'] ?? '',
      purpose: map['Purpose'] ?? '',
      accessability: map['Accessability'] ?? '',
    );
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
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






