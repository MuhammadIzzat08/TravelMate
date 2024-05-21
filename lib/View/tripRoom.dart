// views/trip_room_view.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelmate/View/itinerary.dart';
import 'package:travelmate/View/login.dart';
import 'package:travelmate/View/profile.dart';
import '../Controller/tripRoom.dart';
import '../Model/tripRoom.dart';

class TripRoomView extends StatefulWidget {
  final List<String> tripRoomIds;

  TripRoomView({required this.tripRoomIds});

  @override
  _TripRoomViewState createState() => _TripRoomViewState();
}

class _TripRoomViewState extends State<TripRoomView> {
  late TripRoom tripRoom;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    print('TripRoomView initialized with tripRoomIds: ${widget.tripRoomIds}'); // Debug print
    _fetchTripRoom();
  }

  Future<void> _fetchTripRoom() async {
    try {
      // Assuming we want to fetch the first trip room in the list for demonstration
      tripRoom = await TripRoomController.getTripRoom(widget.tripRoomIds.first);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
      print('Error fetching trip room: $e'); // Debug print
    }
  }

  /*Future<void> _addMember() async {
    // For demonstration, let's add a static user ID
    String userId = 'newUserId';
    try {
      await TripRoomController.addMember(tripRoom.id, userId);
      setState(() {
        tripRoom.members.add(userId);
      });
    } catch (e) {
      // Handle error
      print('Error adding member: $e'); // Debug print
    }
  }*/

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
                  builder: (context) => LoginScreen(),
                ),
              );
            },
          ),
          /*IconButton(
            icon: Icon(Icons.person_add),
            onPressed: _addMember,
          ),*/
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FilteredItineraryScreen(),
              ),
            );
          },
          child: Text('Create Itinerary'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-trip-room');
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
                  builder: (context) => LoginScreen(),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
              break;
          }
        },
      ),
    );

  }
}

//////////////////////////////////////////////////////////////////////////
// List of trip rooms

class TripRoomListView extends StatelessWidget {
  final Future<List<TripRoom>> tripRoomsFuture;
  final Future<void> Function(String) searchTripRooms;

  TripRoomListView({
    required this.tripRoomsFuture,
    required this.searchTripRooms,
  });

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
                await searchTripRooms(searchTerm);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<TripRoom>>(
        future: tripRoomsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No trip rooms found'));
          } else {
            List<TripRoom> tripRooms = snapshot.data!;
            return ListView.builder(
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
                          builder: (context) => TripRoomView(tripRoomIds: [tripRoom.id]),
                        ),
                      );
                    },
                  ),
                );
              },
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
      _tripRoomsFuture = _tripRoomController.searchTripRooms(searchTerm);
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
      ),
      UserProfilePage(),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trip',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF7A9E9F),
        onTap: _onItemTapped,
      ),
    );
  }
}