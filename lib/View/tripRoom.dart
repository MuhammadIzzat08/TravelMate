// views/trip_room_view.dart

import 'dart:async';
import 'dart:typed_data';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

/*class TripRoomView extends StatefulWidget {
  final List<String> tripRoomIds;

  TripRoomView({required this.tripRoomIds});

  @override
  _TripRoomViewState createState() => _TripRoomViewState();
}

class _TripRoomViewState extends State<TripRoomView> {
  late TripRoom tripRoom;
  bool isLoading = true;
  String? errorMessage;
  List<Location> itinerary = [];
  late String loggedInUserId; // Declare a variable to store the logged-in user's ID

  @override
  void initState() {
    super.initState();
    _fetchLoggedInUserId(); // Fetch the logged-in user's ID
    _fetchTripRoom();
    _fetchItinerary();
  }

  Future<void> _fetchLoggedInUserId() async {
    try {
      loggedInUserId = await AuthService.getLoggedInUserId(); // Fetch the logged-in user's ID
    } catch (e) {
      print('Error fetching logged-in user ID: $e');
    }
  }

  Future<void> _fetchTripRoom() async {
    try {
      tripRoom = await TripRoomController.getTripRoom(widget.tripRoomIds.first);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
      print('Error fetching trip room: $e');
    }
  }

  Future<void> _fetchItinerary() async {
    try {
      final controller = TripRoomController(); // Create an instance of TripRoomController
      final itineraryData = await controller.getItinerary(widget.tripRoomIds.first);
      setState(() {
        itinerary = (itineraryData?.locations ?? []); // Access locations from itineraryData, or use empty list if null
      });
    } catch (e) {
      print('Error fetching itinerary: $e'); // Debug print
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Trip Room'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Trip Room'),
        ),
        body: Center(child: Text('Error: $errorMessage')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tripRoom.name),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WishlistScreen(tripRoomId:  widget.tripRoomIds.first),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: itinerary.length,
              itemBuilder: (context, index) {
                final location = itinerary[index];
                return ListTile(
                  title: Text(location.name ?? 'Unknown Location'),
                  subtitle: Text(location.description ?? 'No description'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FilteredItineraryScreen(tripRoomId: widget.tripRoomIds.first,),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Itinerary'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Expense'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItineraryScreen(),
                ),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExpenseList(tripRoomId: widget.tripRoomIds.first, loggedInUserId: loggedInUserId,),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripRoomDetailsPage(tripRoomId:  widget.tripRoomIds.first),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}*/

/*class TripRoomView extends StatefulWidget {
  final List<String> tripRoomIds;

  TripRoomView({super.key, required this.tripRoomIds});

  @override
  _TripRoomViewState createState() => _TripRoomViewState();
}

class _TripRoomViewState extends State<TripRoomView> {
  late TripRoom tripRoom;
  bool isLoading = true;
  String? errorMessage;
  List<Location> itinerary = [];
  late String loggedInUserId;
  late GoogleMapController mapController;
  Position? userPosition;

  @override
  void initState() {
    super.initState();
    _fetchLoggedInUserId();
    _fetchTripRoom();
    _fetchItinerary();
    _determinePosition();
  }

  Future<void> _fetchLoggedInUserId() async {
    try {
      loggedInUserId = await AuthService.getLoggedInUserId();
    } catch (e) {
      print('Error fetching logged-in user ID: $e');
    }
  }

  Future<void> _fetchTripRoom() async {
    try {
      tripRoom = await TripRoomController.getTripRoom(widget.tripRoomIds.first);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
      print('Error fetching trip room: $e');
    }
  }

  Future<void> _fetchItinerary() async {
    try {
      final controller = ItineraryController();
      final itineraryData = await controller.getItinerary(widget.tripRoomIds.first);
      setState(() {
        itinerary = itineraryData;
      });
    } catch (e) {
      print('Error fetching itinerary: $e');
    }
  }

  Future<void> _determinePosition() async {
    final controller = ItineraryController();
    try {
      final position = await controller.determinePosition();
      setState(() {
        userPosition = position;
      });
    } catch (e) {
      print('Error fetching user location: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Trip Room'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Trip Room'),
        ),
        body: Center(child: Text('Error: $errorMessage')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tripRoom.name),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WishlistScreen(tripRoomId: widget.tripRoomIds.first),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: userPosition != null
                    ? LatLng(userPosition!.latitude, userPosition!.longitude)
                    : LatLng(0, 0),
                zoom: 14.0,
              ),
              markers: itinerary.map((location) {
                return Marker(
                  markerId: MarkerId(location.id),
                  position: LatLng(location.latitude!, location.longitude!),
                  infoWindow: InfoWindow(
                    title: location.name,
                    snippet: location.description,
                  ),
                );
              }).toSet(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: itinerary.length,
              itemBuilder: (context, index) {
                final location = itinerary[index];
                return ListTile(
                  title: Text(location.name ?? 'Unknown Location'),
                  subtitle: Text(location.description ?? 'No description'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FilteredItineraryScreen(tripRoomId: widget.tripRoomIds.first),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Itinerary'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Expense'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItineraryScreen(),
                ),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExpenseList(tripRoomId: widget.tripRoomIds.first, loggedInUserId: loggedInUserId),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripRoomDetailsPage(tripRoomId: widget.tripRoomIds.first),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}*/


class TripRoomView extends StatefulWidget {
  final String tripRoomId;

  TripRoomView({required this.tripRoomId});

  @override
  _TripRoomViewState createState() => _TripRoomViewState();
}

class _TripRoomViewState extends State<TripRoomView> {
  GoogleMapController? mapController;
  Position? _currentPosition;
  List<Location> _itinerary = [];
  final ItineraryController _itineraryController = ItineraryController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _generateAndLoadItinerary();
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
      List<Location> itinerary = await _itineraryController.generateItinerary(widget.tripRoomId);
      setState(() {
        _itinerary = itinerary;
      });
    } catch (e) {
      print("Error generating itinerary: $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Set<Marker> _createMarkers() {
    return _itinerary.map((location) {
      if (location.latitude != null && location.longitude != null) {
        return Marker(
          markerId: MarkerId(location.id),
          position: LatLng(location.latitude!, location.longitude!),
          infoWindow: InfoWindow(
            title: location.name ?? 'Unknown',
            snippet: location.description ?? 'No description',
          ),
        );
      }
      return null;
    }).whereType<Marker>().toSet(); // Filter out any null values
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trip Room"),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
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
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                zoom: 12,
              ),
              markers: _createMarkers(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _itinerary.length,
              itemBuilder: (context, index) {
                final location = _itinerary[index];
                return ListTile(
                  title: Text(location.name ?? 'Unknown'),
                  subtitle: Text(location.description ?? 'No description'),
                  trailing: location.visited
                      ? Icon(Icons.check, color: Colors.green)
                      : IconButton(
                    icon: Icon(Icons.check_box_outline_blank),
                    onPressed: () async {
                      await _itineraryController.markLocationAsVisited(widget.tripRoomId, location.id);
                      _generateAndLoadItinerary();
                    },
                  ),
                );
              },
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
        child: Icon(Icons.filter_list),
      ),
    );
  }
}











//////////////////////////////////////////////////////////////////////////
// List of trip rooms

class TripRoomListView extends StatefulWidget {
  final Future<List<TripRoom>> tripRoomsFuture;
  final Future<void> Function(String searchTerm) searchTripRooms;
  final Future<void> Function() refreshTripRooms;

  TripRoomListView({
    required this.tripRoomsFuture,
    required this.searchTripRooms,
    required this.refreshTripRooms,
  });

  @override
  _TripRoomListViewState createState() => _TripRoomListViewState();
}

class _TripRoomListViewState extends State<TripRoomListView> {
  late Future<List<TripRoom>> _tripRoomsFuture;

  @override
  void initState() {
    super.initState();
    _tripRoomsFuture = widget.tripRoomsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TravelMate'),
        backgroundColor: Color(0xFF7A9E9F),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              String searchTerm = await _showSearchDialog(context);
              if (searchTerm.isNotEmpty) {
                await widget.searchTripRooms(searchTerm);
                setState(() {
                  _tripRoomsFuture = widget.tripRoomsFuture;
                });
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<TripRoom>>(
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
              onRefresh: widget.refreshTripRooms,
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
      ),
    );
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
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
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
      UserProfilePage(),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () async {
          bool? result = await Navigator.push(
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

    );
  }
}



//------------------------------MAIN PAGE 2-------------------------------------
class MainPage2 extends StatefulWidget {
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
      ExpenseView(tripRoomId: widget.tripRoomId),
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
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Trip',
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
}

//----------------------CREATE TRIP ROOM!!!!!!----------------------------------

class CreateTripRoomPage extends StatefulWidget {
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
  bool _isLoading = false;
  TripRoom? _tripRoom;

  @override
  void initState() {
    super.initState();
    print('TripRoomDetailsPage initialized with tripRoomId: ${widget.tripRoomId}');
    _loadTripRoomDetails();
  }

  // Function to load trip room details
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

  // Function to add a member to the trip room
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Room Details'),
        backgroundColor: Color(0xFF7A9E9F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _tripRoom == null
            ? Center(child: Text('Trip room details not found'))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Display trip room details
            Text(
              'Trip Room ID: ${_tripRoom!.id}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Trip Room Name: ${_tripRoom!.name}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Trip Room Profile Picture: ${_tripRoom!.profilePicture}',
              style: TextStyle(fontSize: 18),
            ),
            // Add more details as needed...
            SizedBox(height: 20),
            Text(
              'Add Member:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Member Email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addMember,
              child: Text('Add Member'),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF7A9E9F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}