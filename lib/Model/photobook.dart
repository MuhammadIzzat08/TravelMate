/*
class Photo {
  String id;
  String tripRoomId;
  String imageUrl;
  String description;
  DateTime timestamp;

  Photo({
    required this.id,
    required this.tripRoomId,
    required this.imageUrl,
    this.description = '',
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripRoomId': tripRoomId,
      'imageUrl': imageUrl,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Photo.fromMap(Map<String, dynamic> data, String documentId) {
    return Photo(
      id: documentId,
      tripRoomId: data['tripRoomId'],
      imageUrl: data['imageUrl'],
      description: data['description'],
      timestamp: DateTime.parse(data['timestamp']),
    );
  }
}
*/



class Photo {
  final String id;
  final String tripRoomId;
  final String imageUrl;
  final String description;
  final DateTime timestamp;

  Photo({
    required this.id,
    required this.tripRoomId,
    required this.imageUrl,
    required this.description,
    required this.timestamp,
  });

  factory Photo.fromMap(Map<String, dynamic> data, String id) {
    return Photo(
      id: id,
      tripRoomId: data['tripRoomId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      timestamp: DateTime.parse(data['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripRoomId': tripRoomId,
      'imageUrl': imageUrl,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
