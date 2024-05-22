
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

  Location({
    required this.id,
    this.description,
    this.latitude,
    this.longitude,
    this.name,
    this.operatingHour,
    this.price,
    this.type,
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
    );
  }
}


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




