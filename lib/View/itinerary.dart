import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

/*class FilteredItineraryScreen extends StatefulWidget {
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
  List<String> selectedAccessabilities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtered Locations',
          style: GoogleFonts.poppins(
            color: Color(0xFF7A9E9F),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF7A9E9F)),
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
              title: Text('Filter Locations',
                style: GoogleFonts.poppins(
                  color: Color(0xFF7A9E9F),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),),
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
                        *//*'Halal',
                        'Non-Halal'*//*
                      ],
                      setState,
                    ),
                    SizedBox(height:30),
                    _buildFilterCheckboxList(
                      'Cuisine Status:',
                      selectedPlaceTypes,
                      [
                        'Halal',
                        'Non-Halal'
                      ],
                      setState,
                    ),
                    SizedBox(height:30),
                    _buildFilterCheckboxList(
                      'Cuisine Type:',
                      selectedCuisineTypes,
                      ['Western', 'Malay', 'Chinese'],
                      setState,
                    ),
                    SizedBox(height:30),
                    _buildFilterCheckboxList(
                      'Price Rate:',
                      selectedPriceRates,
                      ['Moderate', 'Affordable', 'Expensive'],
                      setState,
                    ),

                   *//* SizedBox(height:30),
                    _buildFilterCheckboxList(
                      'Purpose:',
                      selectedPurposes,
                      ['Family', 'Friend', 'Solo'],
                      setState,
                    ),*//*

                    SizedBox(height:30),
                    _buildFilterCheckboxList(
                      'Accessibility:',
                      selectedAccessabilities,
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
                  child: Text('Cancel',
                    style: GoogleFonts.poppins(
                      color: Color(0xFF7A9E9F),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),),
                ),
                TextButton(
                  onPressed: () {
                    _applyFilters();
                    Navigator.pop(context);
                  },
                  child: Text('Apply',
                    style: GoogleFonts.poppins(
                      color: Color(0xFF7A9E9F),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),),
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
      accessability: selectedAccessabilities.isNotEmpty ? selectedAccessabilities : null,
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
}*/


class FilteredItineraryScreen extends StatefulWidget {
  final String tripRoomId;

  const FilteredItineraryScreen({Key? key, required this.tripRoomId}) : super(key: key);

  @override
  _FilteredItineraryScreenState createState() => _FilteredItineraryScreenState();
}

class _FilteredItineraryScreenState extends State<FilteredItineraryScreen> {
  final FilteredItineraryController _controller = FilteredItineraryController();
  final WishlistController _wishlistController = WishlistController();

  List<LocationFilter> filteredLocations = [];

  List<String> selectedPlaceTypes = [];
  List<String> selectedCuisineTypes = [];
  List<String> selectedPriceRates = [];
  List<String> selectedPurposes = [];
  List<String> selectedAccessabilities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Filtered Locations',
          style: GoogleFonts.poppins(
            color: Color(0xFF7A9E9F),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF7A9E9F)),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _showFilterDialog(context);
            },
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF7A9E9F),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: SizedBox(
              width: double.infinity, // Makes the button full width
              child: Center(
                child: Text(
                  'Filter Locations',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _addAllToWishlist,
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF7A9E9F),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: SizedBox(
              width: double.infinity, // Makes the button full width
              child: Center(
                child: Text(
                  'Add All to Wishlist',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
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
                            tripRoomId: widget.tripRoomId,
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
              title: Text(
                'Filter Locations',
                style: GoogleFonts.poppins(
                  color: Color(0xFF7A9E9F),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
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
                      ],
                      setState,
                    ),
                    SizedBox(height: 30),
                    _buildFilterCheckboxList(
                      'Cuisine Status:',
                      selectedPlaceTypes,
                      [
                        'Halal',
                        'Non-Halal',
                      ],
                      setState,
                    ),
                    SizedBox(height: 30),
                    _buildFilterCheckboxList(
                      'Cuisine Type:',
                      selectedCuisineTypes,
                      ['Western', 'Malay', 'Chinese'],
                      setState,
                    ),
                    SizedBox(height: 30),
                    _buildFilterCheckboxList(
                      'Price Rate:',
                      selectedPriceRates,
                      ['Moderate', 'Affordable', 'Expensive'],
                      setState,
                    ),
                    SizedBox(height: 30),
                    _buildFilterCheckboxList(
                      'Accessibility:',
                      selectedAccessabilities,
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
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      color: Color(0xFF7A9E9F),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _applyFilters();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Apply',
                    style: GoogleFonts.poppins(
                      color: Color(0xFF7A9E9F),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
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
      accessability: selectedAccessabilities.isNotEmpty ? selectedAccessabilities : null,
    );

    setState(() {
      filteredLocations = filteredResult.cast<LocationFilter>();
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

  void _addAllToWishlist() async {
    // Iterate over all filtered locations and add them to the wishlist
    for (final location in filteredLocations) {
      final wishlistItem = WishlistItem(
        tripRoomId: widget.tripRoomId, // Use the passed trip room ID
        locationId: location.id,
      );

      // Check if the location already exists in the wishlist
      final existsInWishlist = await _wishlistController.checkLocationExistsInWishlist(wishlistItem);

      if (!existsInWishlist) {
        await _wishlistController.addToWishlist(wishlistItem).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to add ${location.name} to Wishlist: $error'),
          ));
        });
      }
    }

    // Show a success message after adding all locations
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('All filtered locations added to Wishlist'),
    ));
  }
}


//-------------------------Details location Screen------------------------------
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
        title: Text(
          widget.location.name,
          style: GoogleFonts.poppins(
            color: Color(0xFF7A9E9F),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF7A9E9F)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFEFEFEF),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Description', widget.location.description),
                      _buildDetailRow('Type', widget.location.type),
                      _buildDetailRow('Operating Hours', widget.location.operatingHour),
                      _buildDetailRow('Price', widget.location.price),
                      _buildDetailRow('Cuisine', widget.location.cuisine),
                      _buildDetailRow('Purpose', widget.location.purpose),
                      _buildDetailRow('Accessibility', widget.location.accessability),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _addToWishlist,
                  icon: Icon(Icons.favorite_border),
                  label: Text(
                    'Add To Wishlist',
                    style: GoogleFonts.poppins(),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF7A9E9F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Color(0xFF7A9E9F),
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            value,
            style: GoogleFonts.poppins(),
            textAlign: TextAlign.justify,
          ),
        ],
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







