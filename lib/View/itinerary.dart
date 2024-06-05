import 'package:flutter/material.dart';
import 'package:travelmate/Controller/wishlist.dart';
import 'package:travelmate/Model/wishlist.dart';
import '../Controller/itinerary.dart';
import '../Model/itinerary.dart';

class ItineraryScreen extends StatelessWidget {
  final ItineraryController _controller = ItineraryController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _controller.getLocations(),
      builder: (context, AsyncSnapshot<List<Location>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final locations = snapshot.data!;
          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              return Card(
                child: ListTile(
                  title: Text(location.name ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(location.description ?? ''),
                      Text('Type: ${location.type ?? ''}'),
                      Text('Operating Hours: ${location.operatingHour ?? ''}'),
                      //Text('Latitude: ${location.latitude ?? ''}'),
                      //Text('Longitude: ${location.longitude ?? ''}'),
                    ],
                  ),
                  trailing: Text('\$${location.price ?? ''}'),
                ),
              );
            },
          );
        }
      },
    );
  }
}



//filtered itinerary screen///////////////////////////////////////////////////

class FilteredItineraryScreen extends StatefulWidget {
  final String tripRoomId; // Add this line to receive tripRoomId

  const FilteredItineraryScreen({Key? key, required this.tripRoomId}) : super(key: key);

  @override
  _FilteredItineraryScreenState createState() => _FilteredItineraryScreenState();
}

class _FilteredItineraryScreenState extends State<FilteredItineraryScreen> {
  final FilteredItineraryController _controller = FilteredItineraryController();

  List<LocationFilter> filteredLocations = [];

  List<String> selectedPlaceTypes = [];
  List<String> selectedCuisineTypes = [];
  List<String> selectedPriceRates = [];
  List<String> selectedPurposes = [];
  List<String> selectedAccessibilities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtered Locations'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _showFilterDialog(context);
            },
            child: Text('Filter Locations'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredLocations.length,
              itemBuilder: (context, index) {
                final location = filteredLocations[index];
                return Card(
                  child: ListTile(
                    title: Text(location.name),
                    subtitle: Text(location.description),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaceDetailsScreen(
                            tripRoomId: widget.tripRoomId, // Pass tripRoomId here
                            location: location,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Filter Locations'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterCheckboxList(
                      'Place Type:',
                      selectedPlaceTypes,
                      [
                        'Nature',
                        'City',
                        'Beach',
                        'History',
                        'Halal',
                        'Non-Halal'
                      ],
                      setState,
                    ),
                    _buildFilterCheckboxList(
                      'Cuisine Type:',
                      selectedCuisineTypes,
                      ['Western', 'Malay', 'Chinese'],
                      setState,
                    ),
                    _buildFilterCheckboxList(
                      'Price Rate:',
                      selectedPriceRates,
                      ['Moderate', 'Affordable', 'Expensive'],
                      setState,
                    ),
                    _buildFilterCheckboxList(
                      'Purpose:',
                      selectedPurposes,
                      ['Family', 'Friend', 'Solo'],
                      setState,
                    ),
                    _buildFilterCheckboxList(
                      'Accessibility:',
                      selectedAccessibilities,
                      ['Child', 'Elders'],
                      setState,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _applyFilters();
                    Navigator.pop(context);
                  },
                  child: Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _applyFilters() async {
    final filteredResult = await _controller.filterLocations(
      placeType: selectedPlaceTypes.isNotEmpty ? selectedPlaceTypes : null,
      cuisineType: selectedCuisineTypes.isNotEmpty ? selectedCuisineTypes : null,
      priceRate: selectedPriceRates.isNotEmpty ? selectedPriceRates : null,
      purpose: selectedPurposes.isNotEmpty ? selectedPurposes : null,
      accessability: selectedAccessibilities.isNotEmpty ? selectedAccessibilities : null,
    );

    setState(() {
      filteredLocations = filteredResult.cast<LocationFilter>(); //kat siniiiiii

    });
  }

  Widget _buildFilterCheckboxList(String title, List<String> selectedValues, List<String> options, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        ...options.map((option) => CheckboxListTile(
          title: Text(option),
          value: selectedValues.contains(option),
          onChanged: (value) {
            setState(() {
              if (value != null && value) {
                selectedValues.add(option);
              } else {
                selectedValues.remove(option);
              }
            });
          },
        )),
      ],
    );
  }
}



class PlaceDetailsScreen extends StatefulWidget {
  final LocationFilter location;
  final String tripRoomId; // Trip room ID

  const PlaceDetailsScreen({Key? key, required this.location, required this.tripRoomId}) : super(key: key);

  @override
  _PlaceDetailsScreenState createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  final WishlistController _wishlistController = WishlistController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.location.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${widget.location.description}'),
            Text('Type: ${widget.location.type}'),
            Text('Operating Hours: ${widget.location.operatingHour}'),
            Text('Price: ${widget.location.price}'),
            Text('Cuisine: ${widget.location.cuisine}'),
            Text('Purpose: ${widget.location.purpose}'),
            Text('Accessibility: ${widget.location.accessability}'),
            ElevatedButton(
              onPressed: _addToWishlist,
              child: Text('Add To Wishlist'),
            ),
          ],
        ),
      ),
    );
  }

  void _addToWishlist() async {
    final wishlistItem = WishlistItem(
      tripRoomId: widget.tripRoomId, // Use the passed trip room ID
      locationId: widget.location.id,
    );

    // Check if the location already exists in the wishlist
    final existsInWishlist = await _wishlistController.checkLocationExistsInWishlist(wishlistItem);

    if (existsInWishlist) {
      // Show a popup message if the location already exists in the wishlist
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Location Already in Wishlist'),
          content: Text('The location already exists in the wishlist. Please choose another location.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Add the location to the wishlist if it doesn't exist
      _wishlistController.addToWishlist(wishlistItem).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Added to Wishlist'),
        ));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to add to Wishlist: $error'),
        ));
      });
    }
  }

}


