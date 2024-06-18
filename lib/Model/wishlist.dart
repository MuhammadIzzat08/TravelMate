class WishlistItem {
  final String tripRoomId;
  final String locationId;


  WishlistItem({
    required this.tripRoomId,
    required this.locationId,

  });

  Map<String, dynamic> toMap() {
    return {
      'tripRoomId': tripRoomId,
      'locationId': locationId,
      'Visited': false,

    };
  }

  static WishlistItem fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      tripRoomId: map['tripRoomId'],
      locationId: map['locationId'],
    );
  }
}