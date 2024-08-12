import 'package:cloud_firestore/cloud_firestore.dart';

class TripRoom {
  final String id;
  final String name;
  final String profilePicture;
  final DateTime CreatedDate;
  final int daysSpent;
  final double budget; // New field
  final int numberOfPersons; // New field
  final int mealsPerDay; // New field

  TripRoom({
    required this.id,
    required this.name,
    required this.profilePicture,
    required this.CreatedDate,
    required this.daysSpent,
    required this.budget, // New field
    required this.numberOfPersons, // New field
    required this.mealsPerDay, // New field
  });

  factory TripRoom.fromMap(Map<String, dynamic> map, String id) {
    return TripRoom(
      id: id,
      name: map['name'],
      profilePicture: map['profilePicture'],
      CreatedDate: (map['CreatedDate'] as Timestamp).toDate(),
      daysSpent: map['daysSpent'] ?? 1,
      budget: map['budget'] ?? 0.0, // New field
      numberOfPersons: map['numberOfPersons'] ?? 1, // New field
      mealsPerDay: map['mealsPerDay'] ?? 3, // New field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profilePicture': profilePicture,
      'CreatedDate': CreatedDate,
      'daysSpent': daysSpent,
      'budget': budget, // New field
      'numberOfPersons': numberOfPersons, // New field
      'mealsPerDay': mealsPerDay, // New field
    };
  }
}


// User Trip Room model
class UserTripRoom {
  final String userId;
  final String tripRoomId;

  UserTripRoom({
    required this.userId,
    required this.tripRoomId,
  });

  factory UserTripRoom.fromMap(Map<String, dynamic> map) {
    return UserTripRoom(
      userId: map['UserId'],
      tripRoomId: map['TripRoomId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'UserId': userId,
      'TripRoomId': tripRoomId,
    };
  }
}


// models/tripRoomMember.dart

class TripRoomMember {
  final String tripRoomId;
  final String userId;

  TripRoomMember({
    required this.tripRoomId,
    required this.userId,
  });

  factory TripRoomMember.fromMap(Map<String, dynamic> map) {
    return TripRoomMember(
      tripRoomId: map['TripRoomId'],
      userId: map['UserId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'TripRoomId': tripRoomId,
      'UserId': userId,
    };
  }
}
