// views/trip_room_view.dart

import 'dart:async';
import 'dart:typed_data';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travelmate/Controller/expense.dart';
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


//-------------------------display trip room main page--------------------------

/*
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
  List<Location> _itinerary = [];
  final ItineraryController _itineraryController = ItineraryController();

  static const int morningStartHour = 9;
  static const int morningEndHour = 13;
  static const int afternoonStartHour = 14;
  static const int afternoonEndHour = 18;
  static const int eveningStartHour = 20;
  static const int eveningEndHour = 22;
  static const int locationDurationMinutes = 120; // Duration for each location

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _generateAndLoadItinerary();
    _fetchTripRoom();
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
      List<Location> itinerary = await _itineraryController.generateItinerary(widget.tripRoomId);
      if (itinerary.length > 6) {
        _showWarningDialog();
      }
      setState(() {
        _itinerary = itinerary;
      });
    } catch (e) {
      print("Error generating itinerary: $e");
    }
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ADVICE'),
          content: Text('Your itinerary includes a significant number of locations.'
              ' Please be aware that completing this itinerary may require more than one day.'),
          actions: [
            TextButton(
              child: Text('Noted',style: GoogleFonts.poppins(
                color: Color(0xFF7A9E9F),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),),
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
    }).whereType<Marker>().toSet();
  }

  String _formatTimeForIndex(int index, int startHour) {
    DateTime startTime = DateTime(2024, 1, 1, startHour).add(Duration(minutes: locationDurationMinutes * index));
    return DateFormat.jm().format(startTime);
  }

  List<Map<String, dynamic>> _groupItineraryByTime(List<Location> itinerary) {
    List<Map<String, dynamic>> groupedItinerary = [
      {'time': 'Morning', 'items': []},
      {'time': 'Evening', 'items': []},
      {'time': 'Night', 'items': []},
    ];

    for (int i = 0; i < itinerary.length; i++) {
      if (i < 2) {
        groupedItinerary[0]['items'].add({'location': itinerary[i], 'time': _formatTimeForIndex(i, morningStartHour)});
      } else if (i < 4) {
        groupedItinerary[1]['items'].add({'location': itinerary[i], 'time': _formatTimeForIndex(i - 2, afternoonStartHour)});
      } else {
        groupedItinerary[2]['items'].add({'location': itinerary[i], 'time': _formatTimeForIndex(i - 4, eveningStartHour)});
      }
    }

    return groupedItinerary;
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
            flex: 5, // Half of the screen excluding app bar
            child: _currentPosition != null
                ? GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                zoom: 12,
              ),
              markers: _createMarkers(),
            )
                : Center(child: CircularProgressIndicator()),
          ),
          Expanded(
            flex: 5, // Half of the screen excluding app bar
            child: Container(
              color: Colors.white.withOpacity(0.85),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Itinerary:',
                    style: GoogleFonts.sourceSerifPro(
                      color: Color(0xFF7A9E9F),
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _groupItineraryByTime(_itinerary).length,
                      itemBuilder: (context, index) {
                        var group = _groupItineraryByTime(_itinerary)[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text(
                              group['time'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7A9E9F),
                              ),
                            ),
                            SizedBox(height: 8),
                            ...group['items'].map<Widget>((item) {
                              var location = item['location'];
                              var time = item['time'];
                              return ListTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(time,style: GoogleFonts.sourceSerifPro(
                                      color: Color(0xFF7A9E9F),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),), // Display the time above the name
                                    Text(location.name ?? 'Unknown'),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(location.description ?? 'No description'),
                                    SizedBox(height: 4), // Add some space between the subtitle and the additional text
                                    Text(location.operatingHour), // Display the operating hour below the description
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: location.visited
                                      ? Icon(Icons.check, color: Color(0xFF7A9E9F))
                                      : Icon(Icons.check_box_outline_blank),
                                  onPressed: () async {
                                    await _itineraryController.markLocationAsVisited(widget.tripRoomId, location.id);
                                    _generateAndLoadItinerary();
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
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
*/

/*
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
  List<Location> _itinerary = [];
  final ItineraryController _itineraryController = ItineraryController();

  static const int morningStartHour = 9;
  static const int morningEndHour = 13;
  static const int afternoonStartHour = 14;
  static const int afternoonEndHour = 18;
  static const int eveningStartHour = 20;
  static const int eveningEndHour = 22;
  static const int locationDurationMinutes = 120; // Duration for each location
  static const int locationsPerDay = 6; // Maximum number of locations per day

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _generateAndLoadItinerary();
    _fetchTripRoom();
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
      List<Location> itinerary = await _itineraryController.generateItinerary(widget.tripRoomId);
      if (itinerary.length > locationsPerDay) {
        _showWarningDialog();
      }
      setState(() {
        _itinerary = itinerary;
      });
    } catch (e) {
      print("Error generating itinerary: $e");
    }
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ADVICE'),
          content: Text('Your itinerary includes a significant number of locations.'
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
    }).whereType<Marker>().toSet();
  }

  String _formatTimeForIndex(int index, int startHour) {
    DateTime startTime = DateTime(2024, 1, 1, startHour).add(Duration(minutes: locationDurationMinutes * index));
    return DateFormat.jm().format(startTime);
  }

  List<Map<String, dynamic>> _groupItineraryByTime(List<Location> itinerary) {
    List<Map<String, dynamic>> groupedItinerary = [];

    int dayCounter = 0;
    int currentDayLocationIndex = 0;

    for (int i = 0; i < itinerary.length; i++) {
      if (currentDayLocationIndex == 0) {
        // Start a new day group
        groupedItinerary.add({'day': 'Day ${dayCounter + 1}', 'items': []});
      }

      // Determine the period (Morning, Evening, Night) based on the index
      String period;
      int startHour;
      if (currentDayLocationIndex < 2) {
        period = 'Morning';
        startHour = morningStartHour;
      } else if (currentDayLocationIndex < 4) {
        period = 'Evening';
        startHour = eveningStartHour;
      } else {
        period = 'Night';
        startHour = eveningEndHour; // Start night from the end of the evening
      }

      // Format the time for the location within the day
      String time = _formatTimeForIndex(currentDayLocationIndex % 6, startHour);

      groupedItinerary[dayCounter]['items'].add({
        'period': period,
        'time': time,
        'location': itinerary[i],
      });

      currentDayLocationIndex++;

      // If we've reached the maximum locations per day, move to the next day
      if (currentDayLocationIndex == locationsPerDay) {
        dayCounter++;
        currentDayLocationIndex = 0;
      }
    }

    return groupedItinerary;
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
            )
                : Center(child: CircularProgressIndicator()),
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white.withOpacity(0.85),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Itinerary:',
                    style: GoogleFonts.sourceSerifPro(
                      color: Color(0xFF7A9E9F),
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _groupItineraryByTime(_itinerary).length,
                      itemBuilder: (context, dayIndex) {
                        var dayGroup = _groupItineraryByTime(_itinerary)[dayIndex];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text(
                              dayGroup['day'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7A9E9F),
                              ),
                            ),
                            SizedBox(height: 8),
                            ...dayGroup['items'].map<Widget>((item) {
                              var location = item['location'];
                              var time = item['time'];
                              var period = item['period'];
                              return ListTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$period - $time',
                                      style: GoogleFonts.sourceSerifPro(
                                        color: Color(0xFF7A9E9F),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ), // Display the period and time
                                    Text(location.name ?? 'Unknown'),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(location.description ?? 'No description'),
                                    SizedBox(height: 4), // Add some space between the subtitle and the additional text
                                    Text(location.operatingHour), // Display the operating hour below the description
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: location.visited
                                      ? Icon(Icons.check, color: Color(0xFF7A9E9F))
                                      : Icon(Icons.check_box_outline_blank),
                                  onPressed: () async {
                                    await _itineraryController.markLocationAsVisited(widget.tripRoomId, location.id);
                                    _generateAndLoadItinerary();
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
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

*/ //YANG NIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII

/*class TripRoomView extends StatefulWidget {
  final String tripRoomId;

  TripRoomView({required this.tripRoomId});

  @override
  _TripRoomViewState createState() => _TripRoomViewState();
}

class _TripRoomViewState extends State<TripRoomView> {
  late TripRoom tripRoom;
  GoogleMapController? mapController;
  Position? _currentPosition;
  List<Location> _itinerary = [];
  final ItineraryController _itineraryController = ItineraryController();

  static const int initialStartHour = 9; // Initial start hour for the first location

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _generateAndLoadItinerary();
    _fetchTripRoom();
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
      List<Location> itinerary = await _itineraryController.generateItinerary(widget.tripRoomId);
      setState(() {
        _itinerary = itinerary;
      });
    } catch (e) {
      print("Error generating itinerary: $e");
    }
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ADVICE'),
          content: Text('Your itinerary includes a significant number of locations.'
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
    }).whereType<Marker>().toSet();
  }

  String _formatTimeRange(DateTime startTime, DateTime endTime) {
    return '${DateFormat.jm().format(startTime)} - ${DateFormat.jm().format(endTime)}';
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
            )
                : Center(child: CircularProgressIndicator()),
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white.withOpacity(0.85),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Itinerary:',
                    style: GoogleFonts.sourceSerifPro(
                      color: Color(0xFF7A9E9F),
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _itinerary.length,
                      itemBuilder: (context, index) {
                        var location = _itinerary[index];
                        var approximateTimeMinutes = (location.approximateTime ?? 2) * 60;

                        // Determine the start time for the current location
                        var startTime = index == 0
                            ? DateTime(
                            DateTime.now().year, DateTime.now().month, DateTime.now().day, initialStartHour, 0)
                            : DateTime.now().add(Duration(
                            hours: initialStartHour,
                            minutes: 0,
                            seconds: 0,
                            microseconds: 0,
                            milliseconds: 0)).add(Duration(
                            minutes: (index > 0 ? _itinerary.sublist(0, index).fold<int>(0, (prev, loc) => prev + ((loc.approximateTime ?? 2) * 60).ceil()) : 0)));

                        // Calculate the end time
                        var endTime = startTime.add(Duration(minutes: approximateTimeMinutes.ceil())); // Ensure it’s an int

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
                                  Text('Operating Hours: ${location.operatingHour ?? "N/A"}'),
                                  Text('Approximate Time: ${location.approximateTime ?? "N/A"} hours'),
                                ],
                              ),
                              trailing: IconButton(
                                icon: location.visited ? Icon(Icons.check, color: Color(0xFF7A9E9F)) : Icon(Icons.check_box_outline_blank),
                                onPressed: () async {
                                  await _itineraryController.markLocationAsVisited(widget.tripRoomId, location.id);
                                  _generateAndLoadItinerary();
                                },
                              ),
                            ),
                            SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
                  ),
                ],
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
}*/

/*class TripRoomView extends StatefulWidget {
  final String tripRoomId;

  TripRoomView({required this.tripRoomId});

  @override
  _TripRoomViewState createState() => _TripRoomViewState();
}

class _TripRoomViewState extends State<TripRoomView> {
  late TripRoom tripRoom;
  GoogleMapController? mapController;
  Position? _currentPosition;
  List<Location> _itinerary = [];
  final ItineraryController _itineraryController = ItineraryController();

  static const int initialStartHour = 9; // Initial start hour for the first location

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _generateAndLoadItinerary();
    _fetchTripRoom();
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
      List<Location> itinerary = await _itineraryController.generateItinerary(widget.tripRoomId);
      setState(() {
        _itinerary = itinerary;
      });
    } catch (e) {
      print("Error generating itinerary: $e");
    }
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ADVICE'),
          content: Text('Your itinerary includes a significant number of locations.'
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
    }).whereType<Marker>().toSet();
  }

  String _formatTimeRange(DateTime startTime, DateTime endTime) {
    return '${DateFormat.jm().format(startTime)} - ${DateFormat.jm().format(endTime)}';
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
            )
                : Center(child: CircularProgressIndicator()),
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white.withOpacity(0.85),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Itinerary:',
                    style: GoogleFonts.sourceSerifPro(
                      color: Color(0xFF7A9E9F),
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _itinerary.length,
                      itemBuilder: (context, index) {
                        var location = _itinerary[index];
                        var approximateTimeMinutes = ((location.approximateTime ?? 2) * 60).ceil();

                        // Determine the start time for the current location
                        DateTime startTime;
                        if (index == 0) {
                          startTime = DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            initialStartHour,
                          );
                        } else {
                          // Use the end time of the previous location
                          var previousEndTime = _itinerary[index - 1].endTime;
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
                                  Text('Operating Hours: ${location.operatingHour ?? "N/A"}'),
                                  Text('Approximate Time: ${location.approximateTime ?? "N/A"} hours'),
                                ],
                              ),
                              trailing: IconButton(
                                icon: location.visited ? Icon(Icons.check, color: Color(0xFF7A9E9F)) : Icon(Icons.check_box_outline_blank),
                                onPressed: () async {
                                  await _itineraryController.markLocationAsVisited(widget.tripRoomId, location.id);
                                  _generateAndLoadItinerary();
                                },
                              ),
                            ),
                            SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
                  ),
                ],
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
}*/ //latest

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
      List<Location> itinerary = await _itineraryController.generateItinerary(widget.tripRoomId);
      if (tripRoom.daysSpent > 0) {
        _dailyItinerary = _splitItineraryIntoDays(itinerary, tripRoom.daysSpent);
        setState(() {});
      } else {
        print('Invalid trip daysSpent');
      }
    } catch (e) {
      print("Error generating itinerary: $e");
    }
  }

  Map<int, List<Location>> _splitItineraryIntoDays(List<Location> itinerary, int daysSpent) {
    const int hoursPerDay = endHour - initialStartHour; // Hours available each day
    const int minutesPerDay = hoursPerDay * 60;
    Map<int, List<Location>> dailyItinerary = {};

    int currentDay = 1;
    int remainingMinutesInDay = minutesPerDay;

    for (Location location in itinerary) {
      int approximateTimeMinutes = ((location.approximateTime ?? 2) * 60).ceil();

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
          content: Text('Your itinerary includes a significant number of locations.'
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
          );
        }
        return null;
      }).whereType<Marker>().toSet();
    }).toSet();
  }

  String _formatTimeRange(DateTime startTime, DateTime endTime) {
    return '${DateFormat.jm().format(startTime)} - ${DateFormat.jm().format(endTime)}';
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
            )
                : Center(child: CircularProgressIndicator()),
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white.withOpacity(0.85),
              padding: EdgeInsets.all(16),
              child: ListView.builder(
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
                        startTime = DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day + (day - 1),
                          initialStartHour,
                        );
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
                                Text('Operating Hours: ${location.operatingHour ?? "N/A"}'),
                                Text('Approximate Time: ${location.approximateTime ?? "N/A"} hours'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: location.visited
                                  ? Icon(Icons.check, color: Color(0xFF7A9E9F))
                                  : Icon(Icons.check_box_outline_blank),
                              onPressed: () async {
                                await _itineraryController.markLocationAsVisited(widget.tripRoomId, location.id);
                                _generateAndLoadItinerary();
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
      //SettingsPage(), // Your settings page
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
  late String _loggedInUserId;
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
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Color(0xFF7A9E9F),
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
          return TripRoomDetailsPage(tripRoomId: widget.tripRoomId); // Settings page
        default:
          return Container();
      }
    }
  }
}

//----------------------CREATE TRIP ROOM!!!!!!----------------------------------

/*
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
*/

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
  int _daysSpent = 1; // Default to 1 day

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
          _daysSpent.toString() as int, // Pass _daysSpent as string
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
              DropdownButtonFormField<int>(
                value: _daysSpent,
                items: [1, 2, 3, 4, 5].map((days) {
                  return DropdownMenuItem<int>(
                    value: days,
                    child: Text('$days day${days != 1 ? 's' : ''}'),
                  );
                }).toList(),
                onChanged: (int? value) {
                  setState(() {
                    _daysSpent = value ?? 1;
                  });
                },
                decoration: InputDecoration(labelText: 'Days Spent'),
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
              DropdownButton<int>(
                value: _selectedDays,
                onChanged: (value) {
                  setState(() {
                    _selectedDays = value!;
                  });
                },
                items: [1, 2, 3, 4, 5]
                    .map((days) => DropdownMenuItem<int>(
                  value: days,
                  child: Text('$days days'),
                ))
                    .toList(),
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

/*
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
  List<String> _memberNames = [];

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
        _loadMembersNames(); // Reload member names after adding a member
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
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Trip Room Name:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _tripRoom!.name,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Members:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _memberNames.isEmpty
                ? Text('No members found')
                : Column(
              children: _memberNames
                  .map(
                    (memberName) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFF7A9E9F),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(memberName),
                ),
              )
                  .toList(),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Add Member by Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addMember,
                child: Text('Add Member'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF7A9E9F),
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/

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

  bool _isLoading = false;
  TripRoom? _tripRoom;
  List<String> _memberNames = [];
  bool _isEditingName = false;
  bool _isEditingDaysSpent = false;
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

 /* Future<void> _editTripRoomDetails() async {
    if (_tripRoom == null) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      if (_isEditingName) {
        String newName = _nameController.text.trim();
        await TripRoomController.updateTripRoomName(widget.tripRoomId, newName);
      }

      if (_isEditingDaysSpent) {
        int newDaysSpent = _selectedDaysSpent!;
        await TripRoomController.updateTripRoomDaysSpent(widget.tripRoomId, newDaysSpent);
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
        _isEditingName = false;
        _isEditingDaysSpent = false;
      });
    }
  }
*/
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

      // Check if _selectedDaysSpent is not null (meaning it was selected from dropdown)
      if (_selectedDaysSpent != null) {
        newDaysSpent = _selectedDaysSpent;
      } else {
        // If dropdown value is null, attempt to parse days spent from text field
        String newDaysSpentText = _daysSpentController.text.trim();
        if (newDaysSpentText.isNotEmpty) {
          newDaysSpent = int.tryParse(newDaysSpentText);
        }
      }

      // Update trip room details based on provided values
      if (newName.isNotEmpty) {
        await TripRoomController.updateTripRoomName(widget.tripRoomId, newName);
      }
      if (newDaysSpent != null) {
        await TripRoomController.updateTripRoomDaysSpent(widget.tripRoomId, newDaysSpent);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trip room details updated successfully')),
      );

      // Reload trip room details after updating
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
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _isEditingName
                    ? Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Edit Trip Room Name',
                      prefixIcon: Icon(Icons.edit),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                )
                    : Expanded(
                  child: Text(
                    'Name: ${_tripRoom!.name}',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isEditingName ? Icons.check : Icons.edit,
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
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _isEditingDaysSpent
                    ? Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedDaysSpent,
                    items: [1, 2, 3, 4, 5].map((days) {
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
                      labelText: 'Select Days Spent',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                )

                    : Expanded(
                  child: Text(
                    'Days Spent: $_selectedDaysSpent',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isEditingDaysSpent ? Icons.check : Icons.edit,
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
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Members:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _memberNames.isEmpty
                ? Text('No members found')
                : Column(
              children: _memberNames
                  .map(
                    (memberName) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFF7A9E9F),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(memberName),
                ),
              )
                  .toList(),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Add Member by Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addMember,
                child: Text('Add Member'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF7A9E9F),
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
