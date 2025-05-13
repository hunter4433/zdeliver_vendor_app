import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// Import your MapScreen
import 'mapview.dart';
// import 'path_to_your_map_screen.dart';

class NearestWarehousePage extends StatefulWidget {
  @override
  _NearestWarehousePageState createState() => _NearestWarehousePageState();
}

class _NearestWarehousePageState extends State<NearestWarehousePage> {
  bool isLoading = true;
  String warehouseAddress = 'Loading...';
  // Store warehouse locations
  List<CoordinatePair> warehouseLocations = [];

  @override
  void initState() {
    super.initState();
    fetchWarehouseLocations();
  }

  Future<void> fetchWarehouseLocations() async {
    try {
      // Replace with your actual API endpoint
      final response = await http.get(Uri.parse('https://your-api-endpoint.com/warehouses'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Parse warehouse locations from API response
        // Adjust this according to your actual API response structure
        List<CoordinatePair> locations = [];
        for (var warehouse in data['warehouses']) {
          locations.add(CoordinatePair(
              warehouse['latitude'].toDouble(),
              warehouse['longitude'].toDouble()
          ));
        }

        // Get nearest warehouse address
        if (locations.isNotEmpty) {
          final nearestWarehouse = data['warehouses'][0]; // Assuming first one is nearest
          final address = nearestWarehouse['address'] ?? 'Address not available';

          setState(() {
            warehouseLocations = locations;
            warehouseAddress = address;
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load warehouse data');
      }
    } catch (e) {
      print('Error fetching warehouse locations: $e');
      setState(() {
        warehouseAddress = 'Could not load warehouse data';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Back Button
                  IconButton(
                    icon: Icon(Icons.arrow_back, size: 30),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(width: 16),
                  // Title
                  Text(
                    'Nearest warehouse',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Map with warehouses
            Expanded(
              child: Stack(
                children: [
                  // Use the MapScreen instead of placeholder
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : MapScreen(
                    // containerHeight: MediaQuery.of(context).size.height * 0.6,
                    // isEmbedded: true,
                    // warehouseLocations: warehouseLocations,
                  ),

                  // Search Bar ON the map (positioned at top)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search manually',
                        prefixIcon: Icon(Icons.location_on, size: 30, color: Colors.black87),
                        suffixIcon: Icon(Icons.search, size: 30, color: Colors.black87),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  // Use Current Location Button with rounded left corner
                  Positioned(
                    bottom: 20,
                    right: 0,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.my_location, size: 30),
                      label: Text(
                        'Use current\nlocation',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4F4F4F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      ),
                      onPressed: () {
                        // Refresh map with current location
                        if (!isLoading) {
                          // Refresh map
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 10, 0, 0),
              child: Row(
                children: [
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Nearest warehouse is at:',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Location Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.orange, size: 30),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      warehouseAddress,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // Google Maps Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 26),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(36),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Implement open in Google Maps logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.black, width: 1.5),
                    minimumSize: Size(double.infinity, 65),
                    padding: EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/googleMap.png', // Fixed typo in assets path
                        height: 36,
                        width: 36,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Open in Google Maps',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward, size: 24),
                    ],
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