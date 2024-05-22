import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travelmate/Controller/wishlist.dart';
import 'package:travelmate/Model/itinerary.dart';
import 'package:travelmate/Model/wishlist.dart';

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

            // Debugging print statement
            print('Displaying ${wishlistItems.length} wishlist items');

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
    );
  }
}