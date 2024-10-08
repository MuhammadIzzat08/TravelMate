

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travelmate/Controller/expense.dart';
import 'package:travelmate/View/photobook.dart';
import 'package:travelmate/authservice.dart'; // Import your authentication service
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travelmate/Controller/itinerary.dart';
import 'package:travelmate/Model/itinerary.dart';
import 'package:travelmate/View/expense.dart';
import 'package:travelmate/View/itinerary.dart';
import 'package:travelmate/View/login.dart';
import 'package:travelmate/View/profile.dart';
import 'package:travelmate/View/wishlist.dart';
import '../Controller/tripRoom.dart';
import '../Model/tripRoom.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:travelmate/View/setting.dart';


//-------------------------display trip room main page--------------------------

class TripRoomView extends StatefulWidget {
  final String tripRoomId;

  TripRoomView({required this.tripRoomId});

  @override
  _TripRoomViewState createState() => _TripRoomViewState();
}

class _TripRoomViewState extends State<TripRoomView> {
  late TripRoom tripRoom;
  GoogleMapController? mapController;
  Position? _currentPosition;
  Map<int, List<Location>> _dailyItinerary = {};
  final ItineraryController _itineraryController = ItineraryController();

  static const int initialStartHour = 9; // Initial start hour for the first location
  static const int endHour = 22; // Ending hour for the itinerary

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchTripRoom().then((_) => _generateAndLoadItinerary());
  }

  Future<void> _fetchTripRoom() async {

    try {
      tripRoom = await TripRoomController.getTripRoom(widget.tripRoomId);
      setState(() {});
    } catch (e) {
      setState(() {});
      print('Error fetching trip room: $e');
    }
  }

  void _getCurrentLocation() async {
    try {
      Position position = await _itineraryController.determinePosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  void _generateAndLoadItinerary() async {
    try {
      int mealsPerDay = await _itineraryController.fetchMealsPerDay(
          widget.tripRoomId);
      print("Meals per Day: $mealsPerDay");

      int daysSpent = await _itineraryController.fetchdaysSpent(
          widget.tripRoomId);
      print("Meals per Day: $daysSpent");

      List<Location> itinerary = await _itineraryController.generateItinerary(
          widget.tripRoomId, mealsPerDay,daysSpent);
      print("Generated Itinerary: ${itinerary.length} locations");

      if (tripRoom.daysSpent > 0) {
        _dailyItinerary =
            _splitItineraryIntoDays(itinerary, tripRoom.daysSpent);
        print("Split Itinerary into ${tripRoom.daysSpent} days");
        setState(() {});
      } else {
        print('Invalid trip daysSpent');
      }
    } catch (e) {
      print("Error generating itinerary: $e");
    }
  }

  Map<int, List<Location>> _splitItineraryIntoDays(List<Location> itinerary,
      int daysSpent) {
    const int hoursPerDay = endHour -
        initialStartHour; // Hours available each day
    const int minutesPerDay = hoursPerDay * 60;
    Map<int, List<Location>> dailyItinerary = {};

    int currentDay = 1;
    int remainingMinutesInDay = minutesPerDay;

    for (Location location in itinerary) {
      int approximateTimeMinutes = ((location.approximateTime ?? 2) * 60)
          .ceil();

      if (remainingMinutesInDay >= approximateTimeMinutes) {
        // Add location to the current day
        dailyItinerary.putIfAbsent(currentDay, () => []).add(location);
        remainingMinutesInDay -= approximateTimeMinutes;
      } else {
        // Move to the next day
        currentDay++;
        if (currentDay > daysSpent) {
          break; // We've exhausted the number of days
        }
        remainingMinutesInDay = minutesPerDay - approximateTimeMinutes;
        dailyItinerary.putIfAbsent(currentDay, () => []).add(location);
      }
    }
    return dailyItinerary;
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ADVICE'),
          content: Text(
              'Your itinerary includes a significant number of locations.'
                  ' Please be aware that completing this itinerary may require more than one day.'),
          actions: [
            TextButton(
              child: Text(
                'Noted',
                style: GoogleFonts.poppins(
                  color: Color(0xFF7A9E9F),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Set<Marker> _createMarkers() {
    return _dailyItinerary.values.expand((dayLocations) {
      return dayLocations.map((location) {
        if (location.latitude != null && location.longitude != null) {
          return Marker(
            markerId: MarkerId(location.id),
            position: LatLng(location.latitude!, location.longitude!),
            infoWindow: InfoWindow(
              title: location.name ?? 'Unknown',
              snippet: location.description ?? 'No description',
            ),
            icon: location.visited
                ? BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen)
                : BitmapDescriptor.defaultMarker,
          );
        }
        return null;
      }).whereType<Marker>().toSet();
    }).toSet();
  }

  Set<Polyline> _createPolylines() {
    Set<Polyline> polylines = {};

    _dailyItinerary.values.forEach((dayLocations) {
      if (dayLocations.length > 1) {
        List<LatLng> polylineCoordinates = [];

        for (var location in dayLocations) {
          if (location.latitude != null && location.longitude != null) {
            polylineCoordinates.add(LatLng(location.latitude!, location.longitude!));
          }
        }

        polylines.add(Polyline(
          polylineId: PolylineId('polyline_${polylines.length}'),
          visible: true,
          points: polylineCoordinates,
          color: Colors.redAccent,
          width: 5,
        ));
      }
    });

    return polylines;
  }



  String _formatTimeRange(DateTime startTime, DateTime endTime) {
    return '${DateFormat.jm().format(startTime)} - ${DateFormat.jm().format(
        endTime)}';
  }

  void _toggleLocationVisited(Location location) {
    setState(() {
      location.visited = !location.visited;
    });
    _refreshMapMarkers();
  }

  void _refreshMapMarkers() {
    setState(() {}); // Force the UI to refresh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tripRoom.name,
          style: GoogleFonts.poppins(
            color: Color(0xFF7A9E9F),
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF7A9E9F)),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: Color(0xFF7A9E9F)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WishlistScreen(tripRoomId: widget.tripRoomId),
                ),
              ).then((_) => _generateAndLoadItinerary());
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: _currentPosition != null
                ? GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                zoom: 12,
              ),
              markers: _createMarkers(),
              polylines: _createPolylines(),
            )
                : Center(child: CircularProgressIndicator()),
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white.withOpacity(0.85),
              padding: EdgeInsets.all(16),
              child: _dailyItinerary.isEmpty
                  ? Center(
                child: Text(
                  'No itinerary found. Add locations to your wishlist by click  + button to generate an itinerary.',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.builder(
                itemCount: _dailyItinerary.length,
                itemBuilder: (context, dayIndex) {
                  int day = dayIndex + 1;
                  List<Location> locations = _dailyItinerary[day] ?? [];
                  return ExpansionTile(
                    title: Text(
                      'Day $day',
                      style: GoogleFonts.sourceSerifPro(
                        color: Color(0xFF7A9E9F),
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    children: locations.map((location) {
                      var approximateTimeMinutes = ((location.approximateTime ?? 2) * 60).ceil();

                      // Determine the start time for the current location
                      DateTime startTime;
                      if (locations.indexOf(location) == 0) {
                        // If it's the first location of the day, use the start hour based on operating hour
                        if (location.operatingHour == 'Dinner') {
                          // Check if the previous location's end time allows for a valid dinner start time
                          var previousEndTime = locations.isEmpty ? null : locations.last.endTime;
                          if (previousEndTime != null && previousEndTime.hour >= 20 && previousEndTime.hour < 24) {
                            // If the previous end time is within dinner time range, start at that time
                            startTime = previousEndTime;
                          } else {
                            // Otherwise, start at 8 PM for dinner
                            startTime = DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day + (day - 1),
                              20, // Dinner starts at 8 PM
                            );
                          }
                        } else if (location.operatingHour == 'Lunch') {
                          startTime = DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day + (day - 1),
                            12, // Lunch starts at 12 PM
                          );
                        } else {
                          startTime = DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day + (day - 1),
                            initialStartHour, // Default initial start hour
                          );
                        }
                      } else {
                        // Use the end time of the previous location
                        var previousEndTime = locations[locations.indexOf(location) - 1].endTime;
                        startTime = previousEndTime ?? DateTime.now();
                      }

                      // Calculate the end time for the current location
                      var endTime = startTime.add(Duration(minutes: approximateTimeMinutes));

                      // Save the end time back to the location object
                      location.endTime = endTime;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatTimeRange(startTime, endTime),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          ListTile(
                            title: Text(
                              location.name ?? 'Unknown',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(location.description ?? 'No description'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: location.visited
                                  ? Icon(Icons.check, color: Color(0xFF7A9E9F))
                                  : Icon(Icons.check_box_outline_blank),
                              onPressed: () {
                                _toggleLocationVisited(location);
                              },
                            ),
                          ),
                          SizedBox(height: 8),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          // Instruction notice for marking locations as visited
          Container(
            color: Colors.blueGrey.withOpacity(0.1),
            padding: EdgeInsets.all(12),
            child: Text(
              'Tip: To mark a location as visited, tap the checkbox icon next to the location name.',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FilteredItineraryScreen(tripRoomId: widget.tripRoomId),
            ),
          );
        },
        child: Icon(Icons.add_location),
        backgroundColor: Color(0xFF7A9E9F),
      ),
    );
  }
}











//////////////////////////////////////////////////////////////////////////
// List of trip rooms

class TripRoomListView extends StatefulWidget {
  @override
  _TripRoomListViewState createState() => _TripRoomListViewState();
}

class _TripRoomListViewState extends State<TripRoomListView> {
  int _selectedIndex = 0; // Default to the first page (Trip)
  late Future<List<TripRoom>> _tripRoomsFuture;
  final TripRoomController _tripRoomController = TripRoomController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tripRoomsFuture = _fetchTripRooms();
  }

  Future<List<TripRoom>> _fetchTripRooms() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await TripRoomController.getUserTripRooms(user.uid);
    } else {
      throw Exception('User not logged in');
    }
  }

  Future<void> _searchTripRooms(String searchTerm) async {
    setState(() {
      _tripRoomsFuture = TripRoomController.searchTripRooms(searchTerm);
    });
  }

  Future<void> _refreshTripRooms() async {
    setState(() {
      _tripRoomsFuture = _fetchTripRooms();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<String> _showSearchDialog(BuildContext context) async {
    TextEditingController _searchController = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Search Trip Rooms'),
          content: TextField(
            controller: _searchController,
            decoration: InputDecoration(hintText: 'Enter search term'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_searchController.text);
              },
              child: Text('Search'),
            ),
          ],
        );
      },
    ) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      _buildTripRoomsPage(),
      SettingsPage(), // Your settings page
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TravelMate',
          style: GoogleFonts.sourceSerif4(
            color: Color(0xFF7A9E9F),
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF7A9E9F)), // Color for back button, etc.
        elevation: 1, // Remove shadow if preferred
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              String searchTerm = await _showSearchDialog(context);
              if (searchTerm.isNotEmpty) {
                await _searchTripRooms(searchTerm);
              }
            },
            iconSize: 30,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateTripRoomPage(
                onRoomCreated: _refreshTripRooms, // Pass the refresh function
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF7A9E9F), // Match the color of other buttons
        tooltip: 'Create Room',
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trip',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF7A9E9F), // Match the theme color
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildTripRoomsPage() {
    return FutureBuilder<List<TripRoom>>(
      future: _tripRoomsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No trip rooms found'));
        } else {
          List<TripRoom> tripRooms = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refreshTripRooms,
            child: ListView.builder(
              itemCount: tripRooms.length,
              itemBuilder: (context, index) {
                TripRoom tripRoom = tripRooms[index];
                return Card(
                  child: ListTile(
                    title: Text(tripRoom.name),
                    trailing: Text(
                      tripRoom.CreatedDate.toLocal().toString().split(' ')[0],
                      style: TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainPage2(tripRoomId: tripRoom.id, /*itinerary: [],*/),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}

//------------------------SEARCH TRIP ROOM--------------------------------------
class TripRoomSearchDelegate extends SearchDelegate {
  final Function(String) searchFunction;

  TripRoomSearchDelegate(this.searchFunction);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    searchFunction(query);
    close(context, null);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}



//---------------------------REAL MAIN PAGE-------------------------------------
/*class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // Default to the first page (Trip)
  late Future<List<TripRoom>> _tripRoomsFuture;
  final TripRoomController _tripRoomController = TripRoomController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tripRoomsFuture = _fetchTripRooms();
  }

  Future<List<TripRoom>> _fetchTripRooms() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await TripRoomController.getUserTripRooms(user.uid);
    } else {
      throw Exception('User not logged in');
    }
  }

  Future<void> _searchTripRooms(String searchTerm) async {
    setState(() {
      _tripRoomsFuture = TripRoomController.searchTripRooms(searchTerm);
    });
  }

  Future<void> _refreshTripRooms() async {
    setState(() {
      _tripRoomsFuture = _fetchTripRooms();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      TripRoomListView(
        tripRoomsFuture: _tripRoomsFuture,
        searchTripRooms: _searchTripRooms,
        refreshTripRooms: _refreshTripRooms, // Pass the refresh function
      ),
      //SettingsPage(), // Re-enable the SettingsPage
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TravelMate',
          style: GoogleFonts.poppins(
            color: Color(0xFF7A9E9F),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF7A9E9F)), // Color for back button, etc.
        elevation: 0, // Remove shadow if preferred
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateTripRoomPage(
                onRoomCreated: _refreshTripRooms, // Pass the refresh function
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF7A9E9F), // Match the color of other buttons
        tooltip: 'Create Room',
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trip',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF7A9E9F), // Match the theme color
        onTap: _onItemTapped,
      ),
    );
  }
}*/

//------------------------------MAIN PAGE 2-------------------------------------
/*class MainPage2 extends StatefulWidget {
  final String tripRoomId;

  const MainPage2({required this.tripRoomId});

  @override
  _MainPage2State createState() => _MainPage2State();
}

class _MainPage2State extends State<MainPage2> {
  int _currentIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      TripRoomView(tripRoomId: widget.tripRoomId),
      UnifiedExpenseView(tripRoomId: widget.tripRoomId, loggedInUserId: loggedInUserId),
      TripRoomDetailsPage(tripRoomId: widget.tripRoomId), // Settings doesn't need tripRoomId but you can provide if needed
    ]);
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Color(0xFF7A9E9F), // Change hover color here
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Itinerary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}*/

class MainPage2 extends StatefulWidget {
  final String tripRoomId;

  const MainPage2({required this.tripRoomId});

  @override
  _MainPage2State createState() => _MainPage2State();
}
class _MainPage2State extends State<MainPage2> {
  int _currentIndex = 0;
  /*late*/ String _loggedInUserId = '';
  final ExpenseController _expenseController = ExpenseController(); // Create an instance of ExpenseController

  @override
  void initState() {
    super.initState();
    _fetchLoggedInUserId(); // Fetch the logged-in user ID when the page initializes
  }

  Future<void> _fetchLoggedInUserId() async {
    // Fetch the logged-in user ID using your ExpenseController
    _loggedInUserId = await _expenseController.getLoggedInUserId();
    setState(() {}); // Trigger a rebuild after fetching the user ID
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(), // Use a function to determine which page to display
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Color(0xFF7A9E9F),
        unselectedItemColor: Colors.grey,

        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Itinerary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album),
            label: 'Photobook',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _getBody() {
    if (_loggedInUserId.isEmpty) {
      return Center(child: CircularProgressIndicator()); // Show loading indicator while fetching user ID
    } else {
      switch (_currentIndex) {
        case 0:
          return TripRoomView(tripRoomId: widget.tripRoomId);
        case 1:
          return UnifiedExpenseView(tripRoomId: widget.tripRoomId, loggedInUserId: _loggedInUserId); // Pass the logged-in user ID to UnifiedExpenseView
        case 2:
          return PhotoBookView(tripRoomId: widget.tripRoomId); // Navigate to Photobook
        case 3:
          return TripRoomDetailsPage(tripRoomId: widget.tripRoomId); // Settings page
        default:
          return Container();
      }
    }
  }
}


//----------------------CREATE TRIP ROOM!!!!!!---------------------------------

/*class CreateTripRoomPage extends StatefulWidget {
  final VoidCallback? onRoomCreated; // Callback function

  CreateTripRoomPage({this.onRoomCreated});

  @override
  _CreateTripRoomPageState createState() => _CreateTripRoomPageState();
}

class _CreateTripRoomPageState extends State<CreateTripRoomPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  int _selectedDays = 1; // Default selected days

  Future<void> _createTripRoom() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        Uint8List imageBytes = await _imageFile!.readAsBytes();
        String imageUrl = await TripRoomController.uploadImage(imageBytes);
        await TripRoomController.createTripRoom(
          user.uid,
          _nameController.text,
          imageUrl,
          _selectedDays,
        );
        Navigator.pop(context, true); // Pass back true indicating success
      } else {
        throw Exception('User not logged in');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating trip room: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Ensure this is the File from 'dart:io'
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Trip Room'),
        backgroundColor: Color(0xFF7A9E9F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _imageFile == null
                  ? Text('No image selected.')
                  : Image.file(_imageFile!),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  IconButton(
                    icon: Icon(Icons.photo_library),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Please choose the duration of your trip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<int>(
                    value: _selectedDays,
                    onChanged: (value) {
                      setState(() {
                        _selectedDays = value!;
                      });
                    },
                    items: [1, 2, 3, 4, 5].map((days) => DropdownMenuItem<int>(
                      value: days,
                      child: Text('$days days'),
                    )).toList(),
                  ),
                ],
              ),

              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _createTripRoom,
                child: Text('Create Room'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF7A9E9F), // Match the color of other buttons
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
class CreateTripRoomPage extends StatefulWidget {
  final VoidCallback? onRoomCreated; // Callback function

  CreateTripRoomPage({this.onRoomCreated});

  @override
  _CreateTripRoomPageState createState() => _CreateTripRoomPageState();
}

class _CreateTripRoomPageState extends State<CreateTripRoomPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController(); // New controller
  final _personsController = TextEditingController(); // New controller
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  int _selectedDays = 1; // Default selected days
  int _selectedMealsPerDay = 3; // Default selected meals per day

  Future<void> _createTripRoom() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        Uint8List imageBytes = await _imageFile!.readAsBytes();
        String imageUrl = await TripRoomController.uploadImage(imageBytes);
        await TripRoomController.createTripRoom(
          user.uid,
          _nameController.text,
          imageUrl,
          _selectedDays,
          double.parse(_budgetController.text), // New field
          int.parse(_personsController.text), // New field
          _selectedMealsPerDay, // New field
        );
        Navigator.pop(context, true); // Pass back true indicating success
      } else {
        throw Exception('User not logged in');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating trip room: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Ensure this is the File from 'dart:io'
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Trip Room'),
        backgroundColor: Color(0xFF7A9E9F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( // Added to handle scrolling
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _budgetController, // New field
                  decoration: InputDecoration(labelText: 'Budget (RM)'),
                  keyboardType: TextInputType.number, // Ensure only numbers can be entered
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a budget';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _personsController, // New field
                  decoration: InputDecoration(labelText: 'Number of Persons'),
                  keyboardType: TextInputType.number, // Ensure only numbers can be entered
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of persons';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _imageFile == null
                    ? Text('No image selected.')
                    : Image.file(_imageFile!),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                    IconButton(
                      icon: Icon(Icons.photo_library),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please choose the duration of your trip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButton<int>(
                      value: _selectedDays,
                      onChanged: (value) {
                        setState(() {
                          _selectedDays = value!;
                        });
                      },
                      items: [1, 2, 3, 4, 5].map((days) => DropdownMenuItem<int>(
                        value: days,
                        child: Text('$days days'),
                      )).toList(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How many meals per day?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButton<int>(
                      value: _selectedMealsPerDay,
                      onChanged: (value) {
                        setState(() {
                          _selectedMealsPerDay = value!;
                        });
                      },
                      items: [1, 2, 3, 4, 5].map((meals) => DropdownMenuItem<int>(
                        value: meals,
                        child: Text('$meals meals'),
                      )).toList(),
                    ),
                  ],
                ),

                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _createTripRoom,
                  child: Text('Create Room'),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF7A9E9F), // Match the color of other buttons
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



// -----------------------------TRIP ROOM DETAILS ------------------------------


class TripRoomDetailsPage extends StatefulWidget {
  final String tripRoomId;

  TripRoomDetailsPage({required this.tripRoomId});

  @override
  _TripRoomDetailsPageState createState() => _TripRoomDetailsPageState();
}

class _TripRoomDetailsPageState extends State<TripRoomDetailsPage> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _daysSpentController = TextEditingController();
  final _budgetController = TextEditingController();
  final _numPeopleController = TextEditingController();
  final _numMealsController = TextEditingController();

  bool _isLoading = false;
  TripRoom? _tripRoom;
  List<String> _memberNames = [];
  bool _isEditingName = false;
  bool _isEditingDaysSpent = false;
  bool _isEditingBudget = false;
  bool _isEditingNumPeople = false;
  bool _isEditingNumMeals = false;
  int? _selectedDaysSpent;

  @override
  void initState() {
    super.initState();
    _loadTripRoomDetails();
    _loadMembersNames();
  }

  Future<void> _loadTripRoomDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (widget.tripRoomId.isEmpty) {
        throw Exception('tripRoomId is empty');
      }
      TripRoom tripRoom = await TripRoomController.getTripRoom(widget.tripRoomId);
      setState(() {
        _tripRoom = tripRoom;
        _nameController.text = tripRoom.name;
        _selectedDaysSpent = tripRoom.daysSpent;
        _budgetController.text = tripRoom.budget.toString();
        _numPeopleController.text = tripRoom.numberOfPersons.toString();
        _numMealsController.text = tripRoom.mealsPerDay.toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading trip room details: $e')),
      );
    }
  }

  Future<void> _loadMembersNames() async {
    try {
      List<String> memberNames = await TripRoomController.getMembersNames(widget.tripRoomId);
      setState(() {
        _memberNames = memberNames;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading member names: $e')),
      );
    }
  }

  Future<void> _addMember() async {
    if (_tripRoom == null) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      String email = _emailController.text.trim();
      String? userId = await TripRoomController.getUserIdByEmail(email);

      if (userId != null) {
        await TripRoomController.addMemberToTripRoom(widget.tripRoomId, userId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Member added successfully')),
        );
        _loadMembersNames();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding member: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _editTripRoomDetails() async {
    if (_tripRoom == null) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      String newName = _nameController.text.trim();
      int? newDaysSpent;
      double? newBudget;
      int? newNumPeople;
      int? newNumMeals;

      if (_selectedDaysSpent != null) {
        newDaysSpent = _selectedDaysSpent;
      } else {
        String newDaysSpentText = _daysSpentController.text.trim();
        if (newDaysSpentText.isNotEmpty) {
          newDaysSpent = int.tryParse(newDaysSpentText);
        }
      }

      if (_budgetController.text.isNotEmpty) {
        newBudget = double.tryParse(_budgetController.text.trim());
      }

      if (_numPeopleController.text.isNotEmpty) {
        newNumPeople = int.tryParse(_numPeopleController.text.trim());
      }

      if (_numMealsController.text.isNotEmpty) {
        newNumMeals = int.tryParse(_numMealsController.text.trim());
      }

      if (newName.isNotEmpty) {
        await TripRoomController.updateTripRoomName(widget.tripRoomId, newName);
      }
      if (newDaysSpent != null) {
        await TripRoomController.updateTripRoomDaysSpent(widget.tripRoomId, newDaysSpent);
      }
      if (newBudget != null) {
        await TripRoomController.updateTripRoomBudget(widget.tripRoomId, newBudget);
      }
      if (newNumPeople != null) {
        await TripRoomController.updateTripRoomNumberOfPersons(widget.tripRoomId, newNumPeople);
      }
      if (newNumMeals != null) {
        await TripRoomController.updateTripRoomMealsPerDay(widget.tripRoomId, newNumMeals);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trip room details updated successfully')),
      );

      _loadTripRoomDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating trip room details: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showFullSizeImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog when the image is tapped again
                  },
                  child: Image.network(
                    _tripRoom!.profilePicture,
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width * 0.9,
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: FloatingActionButton(
                onPressed: () async {
                  await TripRoomController.changeProfilePicture(widget.tripRoomId);
                  setState(() {
                    _loadTripRoomDetails(); // Reload the trip room details to update the image
                  });
                },
                child: Icon(Icons.edit, color: Colors.white),
                backgroundColor: Color(0xFF7A9E9F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trip Room Details',
          style: GoogleFonts.poppins(
            color: Color(0xFF7A9E9F),
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF7A9E9F)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _tripRoom == null
            ? Center(child: Text('Trip room details not found'))
            : ListView(
          children: <Widget>[
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: () => _showFullSizeImage(context),
                    child: CircleAvatar(
                      radius: 90,
                      backgroundImage: NetworkImage(_tripRoom!.profilePicture),
                      backgroundColor: Colors.grey[200],
                      onBackgroundImageError: (_, __) => Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      await TripRoomController.changeProfilePicture(widget.tripRoomId);
                      setState(() {
                        _loadTripRoomDetails(); // Reload the trip room details to update the image
                      });
                    },
                    mini: true,
                    child: Icon(Icons.edit, color: Colors.white),
                    backgroundColor: Color(0xFF7A9E9F),
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.book, color: Color(0xFF7A9E9F)),
              title: Text(
                'Room Name: ${_tripRoom!.name}',
                style: TextStyle(fontSize: 18),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Color(0xFF7A9E9F),
                ),
                onPressed: () {
                  setState(() {
                    _isEditingName = !_isEditingName;
                    if (!_isEditingName) {
                      _editTripRoomDetails();
                    }
                  });
                },
              ),
            ),
            _isEditingName
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Edit Trip Room Name',
                  border: InputBorder.none,
                ),
                autofocus: true,
              ),
            )
                : Container(),
            Divider(),
            ListTile(
              leading: Icon(Icons.monetization_on, color: Color(0xFF7A9E9F)),
              title: Text(
                'Budget: \RM${_tripRoom!.budget}',
                style: TextStyle(fontSize: 18),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Color(0xFF7A9E9F),
                ),
                onPressed: () {
                  setState(() {
                    _isEditingBudget = !_isEditingBudget;
                    if (!_isEditingBudget) {
                      _editTripRoomDetails();
                    }
                  });
                },
              ),
            ),
            _isEditingBudget
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Edit Budget',
                  border: InputBorder.none,
                ),
                autofocus: true,
              ),
            )
                : Container(),
            Divider(),
            ListTile(
              leading: Icon(Icons.people, color: Color(0xFF7A9E9F)),
              title: Text(
                'Number of People: ${_tripRoom!.numberOfPersons}',
                style: TextStyle(fontSize: 18),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Color(0xFF7A9E9F),
                ),
                onPressed: () {
                  setState(() {
                    _isEditingNumPeople = !_isEditingNumPeople;
                    if (!_isEditingNumPeople) {
                      _editTripRoomDetails();
                    }
                  });
                },
              ),
            ),
            _isEditingNumPeople
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: _numPeopleController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Edit Number of People',
                  border: InputBorder.none,
                ),
                autofocus: true,
              ),
            )
                : Container(),
            Divider(),
            ListTile(
              leading: Icon(Icons.restaurant, color: Color(0xFF7A9E9F)),
              title: Text(
                'Meals Per Day: ${_tripRoom!.mealsPerDay}',
                style: TextStyle(fontSize: 18),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Color(0xFF7A9E9F),
                ),
                onPressed: () {
                  setState(() {
                    _isEditingNumMeals = !_isEditingNumMeals;
                    if (!_isEditingNumMeals) {
                      _editTripRoomDetails();
                    }
                  });
                },
              ),
            ),
            _isEditingNumMeals
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: _numMealsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Edit Meals Per Day',
                  border: InputBorder.none,
                ),
                autofocus: true,
              ),
            )
                : Container(),
        Divider(),
        ListTile(
          leading: Icon(Icons.calendar_today, color: Color(0xFF7A9E9F)),
          title: Text(
            'Days Spent: ${_tripRoom!.daysSpent}',
            style: TextStyle(fontSize: 18),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.edit,
              color: Color(0xFF7A9E9F),
            ),
            onPressed: () {
              setState(() {
                _isEditingDaysSpent = !_isEditingDaysSpent;
                if (!_isEditingDaysSpent) {
                  _editTripRoomDetails();
                }
              });
            },
          ),
        ),
        _isEditingDaysSpent
            ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: DropdownButtonFormField<int>(
            value: _selectedDaysSpent,
            items: [1, 2, 3, 4, 5, 6, 7].map((days) {
              return DropdownMenuItem<int>(
                value: days,
                child: Text('$days days'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDaysSpent = value!;
              });
            },
            decoration: InputDecoration(
              hintText: 'Select Days Spent',
              border: InputBorder.none,
            ),
          ),
        )

        : Container(),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Members',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A9E9F),
                ),
              ),
            ),
            for (var name in _memberNames)
              ListTile(
                title: Text(name),
                leading: Icon(
                  Icons.person,
                  color: Color(0xFF7A9E9F),
                ),
              ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Add member by email',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle,
                      color: Color(0xFF7A9E9F),
                    ),
                    onPressed: _addMember,
                  ),
                ],
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}





