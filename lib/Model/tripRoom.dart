import 'package:cloud_firestore/cloud_firestore.dart';

class TripRoom {
  final String id;
  final String name;
  final String profilePicture;
  final DateTime CreatedDate;
  final int daysSpent;

  TripRoom({
    required this.id,
    required this.name,
    required this.profilePicture,
    required this.CreatedDate,
    required this.daysSpent,
  });

  factory TripRoom.fromMap(Map<String, dynamic> map, String id) {
    return TripRoom(
      id: id,
      name: map['name'],
      profilePicture: map['profilePicture'],
      CreatedDate:(map['CreatedDate'] as Timestamp).toDate(),
      daysSpent: map['daysSpent'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profilePicture': profilePicture,
      'CreatedDate': CreatedDate,
      'daysSpent': daysSpent,
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
