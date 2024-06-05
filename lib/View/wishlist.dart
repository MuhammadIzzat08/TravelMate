import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
          builder: (context) => TripRoomView(tripRoomId: widget.tripRoomId,),
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
