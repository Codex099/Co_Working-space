import 'dart:convert';
import 'package:flutter_projet_tutore/pages/Rooms.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  List<LocationData> locations = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    final response = await http.get(
      Uri.parse('https://1c84-129-45-8-202.ngrok-free.app/locations'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        locations =
            data
                .map(
                  (item) => LocationData(
                    id: item['id'], // Assuming the API provides an 'id' field ////////////////////////////
                    name: item['name'],
                    imageBase64: item['image_base64'],
                  ),
                )
                .toList();
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Locations"),
        backgroundColor: Color.fromARGB(255, 37, 77, 53),
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                  // Changed from direct ListView.builder to Column
                  children: [
                    Expanded(
                      // Wrap ListView.builder with Expanded
                      child: ListView.builder(
                        itemCount: locations.length,
                        itemBuilder: (context, index) {
                          return RoomCard(location: locations[index]);
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.only(top: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1.0,
                        ),
                      ),
                      child: const Text(
                        "Note: Tous nos emplacements disposent d'une salle de repos et d'une salle à manger.",
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final LocationData location;
  const RoomCard({super.key, required this.location});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => RoomsScreen(
                  locationId: location.id,
                  locationName: location.name,
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Stack(
            children: [
              // Background image - Replace with your actual asset
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child:
                    location.imageBase64 != null
                        ? Image.memory(
                          base64Decode(location.imageBase64!),
                          fit: BoxFit.fill,
                          width: double.infinity,
                          //height: 50,
                        )
                        : Container(
                          color: Colors.grey[300],
                          width: double.infinity,
                          height: 200,
                          child: Icon(
                            Icons.image,
                            size: 80,
                            color: Colors.grey[500],
                          ),
                        ),
              ),
              // Bottom overlay with location info
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Room name with location icon
                      Row(
                        children: [
                          const Icon(
                            Icons.location_pin,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            location.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Data model for location information
class LocationData {
  final int id;
  final String name;
  final String? imageBase64;
  LocationData({required this.id, required this.name, this.imageBase64});
}
