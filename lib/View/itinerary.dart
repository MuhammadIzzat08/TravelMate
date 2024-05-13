import 'package:flutter/material.dart';
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
  @override
  _FilteredItineraryScreenState createState() => _FilteredItineraryScreenState();
}

class _FilteredItineraryScreenState extends State<FilteredItineraryScreen> {
  final FilteredItineraryController _controller = FilteredItineraryController();

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
            child: FutureBuilder(
              future: _controller.filterLocations(
                placeType: selectedPlaceTypes.isNotEmpty ? selectedPlaceTypes : null,
                cuisineType: selectedCuisineTypes.isNotEmpty ? selectedCuisineTypes : null,
                priceRate: selectedPriceRates.isNotEmpty ? selectedPriceRates : null,
                purpose: selectedPurposes.isNotEmpty ? selectedPurposes : null,
                accessability: selectedAccessibilities.isNotEmpty ? selectedAccessibilities : null,
              ),
              builder: (context, AsyncSnapshot<List<LocationFilter>> snapshot) {
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
                      return ListTile(
                        title: Text(location.name),
                        subtitle: Text(location.description),
                      );
                    },
                  );
                }
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
                      ['Nature', 'City', 'Beach', 'History', 'Halal', 'Non-Halal'],
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

  void _applyFilters() {
    setState(() {}); // Force rebuild to apply filter
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