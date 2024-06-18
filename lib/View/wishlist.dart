import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelmate/Controller/itinerary.dart';
import 'package:travelmate/Controller/wishlist.dart';
import 'package:travelmate/Model/itinerary.dart';
import 'package:travelmate/Model/wishlist.dart';
import 'package:travelmate/View/itineraryfinal.dart';
import 'package:travelmate/View/tripRoom.dart';



/*
class WishlistScreen extends StatefulWidget {
  final String tripRoomId;

  const WishlistScreen({Key? key, required this.tripRoomId}) : super(key: key);

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistController _controller = WishlistController();
  late Future<List<Location>> _wishlistItemsFuture;

  @override
  void initState() {
    super.initState();
    _wishlistItemsFuture = _controller.getWishlistItems(widget.tripRoomId);
  }

  Future<void> _generateItinerary() async {
    try {
      // Fetch wishlist items
      List<Location> wishlistItems = await _controller.getWishlistItems(widget.tripRoomId);

      // Generate itinerary
      List<Location> itinerary = await ItineraryController().generateItinerary(widget.tripRoomId, wishlistItems);

      // Navigate to TripRoomView and pass the generated itinerary
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripRoomView(tripRoomIds: [widget.tripRoomId], */
/*itinerary: itinerary*//*
),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error generating itinerary: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
      ),
      body: FutureBuilder<List<Location>>(
        future: _wishlistItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No items in wishlist.'));
          } else {
            final wishlistItems = snapshot.data!;
            return ListView.builder(
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final item = wishlistItems[index];
                return ListTile(
                  title: Text(item.name ?? 'No Name'), // Display location name
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description: ${item.description ?? 'No Description'}'),
                      Text('Type: ${item.type ?? 'No Type'}'),
                      Text('Price: ${item.price ?? 'No Price'}'),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generateItinerary,
        child: Icon(Icons.add),
      ),
    );
  }
}
*/

/*
class WishlistScreen extends StatefulWidget {
  final String tripRoomId;

  const WishlistScreen({Key? key, required this.tripRoomId}) : super(key: key);

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistController _controller = WishlistController();
  late Future<List<Location>> _wishlistItemsFuture;

  @override
  void initState() {
    super.initState();
    _wishlistItemsFuture = _controller.getWishlistItems(widget.tripRoomId);
  }

  Future<void> _generateItinerary() async {
    try {
      List<Location> wishlistItems = await _controller.getWishlistItems(widget.tripRoomId);
      List<Location> itinerary = await ItineraryController().generateItinerary(widget.tripRoomId, wishlistItems);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripRoomView(tripRoomId: widget.tripRoomId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error generating itinerary: $e'),
      ));
    }
  }

  void _deleteWishlistItem(String locationId) async {
    try {
      await _controller.deleteFromWishlist(widget.tripRoomId, locationId);
      setState(() {
        _wishlistItemsFuture = _controller.getWishlistItems(widget.tripRoomId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error deleting wishlist item: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
      ),
      body: FutureBuilder<List<Location>>(
        future: _wishlistItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No items in wishlist.'));
          } else {
            final wishlistItems = snapshot.data!;
            return ListView.builder(
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final item = wishlistItems[index];
                return Dismissible(
                  key: Key(item.id),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) {
                    _deleteWishlistItem(item.id);
                  },
                  child: ListTile(
                    title: Text(item.name ?? 'No Name'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description: ${item.description ?? 'No Description'}'),
                        Text('Type: ${item.type ?? 'No Type'}'),
                        Text('Price: ${item.price ?? 'No Price'}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generateItinerary,
        child: Icon(Icons.add),
      ),
    );
  }
}
*/

/*class WishlistScreen extends StatefulWidget {
  final String tripRoomId;

  const WishlistScreen({Key? key, required this.tripRoomId}) : super(key: key);

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistController _wishlistController = WishlistController();
  final ItineraryController _itineraryController = ItineraryController();
  late Future<List<Location>> _wishlistItemsFuture;

  @override
  void initState() {
    super.initState();
    _wishlistItemsFuture = _wishlistController.getWishlistItems(widget.tripRoomId);
  }

  void _toggleVisitedStatus(String locationId, bool currentStatus) async {
    await _wishlistController.updateVisitedStatus(widget.tripRoomId, locationId, !currentStatus);
    setState(() {
      _wishlistItemsFuture = _wishlistController.getWishlistItems(widget.tripRoomId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wishlist',
          style: GoogleFonts.poppins(
            color: Color(0xFF7A9E9F),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF7A9E9F)),
      ),
      body: FutureBuilder<List<Location>>(
        future: _wishlistItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No wishlist items found'));
          } else {
            final wishlistItems = snapshot.data!;
            return ListView.builder(
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final item = wishlistItems[index];
                return ListTile(
                  title: Text(item.name ?? 'Unknown'),
                  subtitle: Text(item.description ?? 'No description'),
                  trailing: IconButton(
                    icon: Icon(
                      item.visited
                          ? Icons.check_box // Checked
                          : Icons.check_box_outline_blank, // Unchecked
                      color: item.visited ? Color(0xFF7A9E9F) : Colors.grey,
                    ),
                    onPressed: () => _toggleVisitedStatus(item.id, item.visited),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}*/
 //latestttt

class WishlistScreen extends StatefulWidget {
  final String tripRoomId;

  const WishlistScreen({Key? key, required this.tripRoomId}) : super(key: key);

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistController _wishlistController = WishlistController();
  final ItineraryController _itineraryController = ItineraryController();
  late Future<List<Location>> _wishlistItemsFuture;
  late Future<int> _tripDaysFuture;

  @override
  void initState() {
    super.initState();
    _wishlistItemsFuture = _wishlistController.getWishlistItems(widget.tripRoomId);
    _tripDaysFuture = _wishlistController.getTripDays(widget.tripRoomId);
  }

  void _toggleVisitedStatus(String locationId, bool currentStatus) async {
    await _wishlistController.updateVisitedStatus(widget.tripRoomId, locationId, !currentStatus);
    setState(() {
      _wishlistItemsFuture = _wishlistController.getWishlistItems(widget.tripRoomId);
    });
  }

  Future<void> _showExtendTripPopup(int days) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Extend Trip Days'),
          content: Text('You cannot visit all locations within $days days. '
              'Consider extending your trip by changing the days spent at the room settings.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _checkIfSufficientDays() async {
    final tripDays = await _tripDaysFuture;
    final wishlistItems = await _wishlistItemsFuture;
    const hoursPerDay = 13;
    final totalAvailableHours = tripDays * hoursPerDay;

    final totalTimeRequired = wishlistItems.fold<double>(0.0, (sum, item) {
      return sum + (item.approximateTime ?? 0);
    });

    if (totalTimeRequired > totalAvailableHours) {
      await _showExtendTripPopup(tripDays);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wishlist',
          style: GoogleFonts.poppins(
            color: Color(0xFF7A9E9F),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF7A9E9F)),
      ),
      body: FutureBuilder<List<Location>>(
        future: _wishlistItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No wishlist items found'));
          } else {
            final wishlistItems = snapshot.data!;
            _checkIfSufficientDays(); // Check if sufficient days available
            return ListView.builder(
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final item = wishlistItems[index];
                return ListTile(
                  title: Text(item.name ?? 'Unknown'),
                  subtitle: Text(item.description ?? 'No description'),
                  trailing: IconButton(
                    icon: Icon(
                      item.visited
                          ? Icons.check_box // Checked
                          : Icons.check_box_outline_blank, // Unchecked
                      color: item.visited ? Color(0xFF7A9E9F) : Colors.grey,
                    ),
                    onPressed: () => _toggleVisitedStatus(item.id, item.visited),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}





