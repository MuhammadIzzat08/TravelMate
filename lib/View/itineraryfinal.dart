import 'package:flutter/material.dart';
import 'package:travelmate/Model/itinerary.dart';

class ItineraryScreenFinal extends StatefulWidget {
  final List<Location> itinerary;

  const ItineraryScreenFinal({Key? key, required this.itinerary}) : super(key: key);

  @override
  _ItineraryScreenState createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreenFinal> {
  late List<Location> _itinerary;

  @override
  void initState() {
    super.initState();
    _itinerary = widget.itinerary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generated Itinerary'),
      ),
      body: ListView.builder(
        itemCount: _itinerary.length,
        itemBuilder: (context, index) {
          final item = _itinerary[index];
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
      ),
    );
  }
}
