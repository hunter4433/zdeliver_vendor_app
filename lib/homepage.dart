import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrs_gorilla_vendor/profile.dart';
import 'package:mrs_gorilla_vendor/support.dart';

import 'cart_items.dart';
import 'mapview.dart';
import 'notification.dart';
import 'order_history1.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage>
    with TickerProviderStateMixin {
  bool addressLoading = true;
  late final FlutterSecureStorage _secureStorage;
  bool _isLoading = true;
  String? _vendorName;
  String? _vendorId;

  // New drawer controller
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? savedAddress;

  @override
  void initState() {
    super.initState();
    _secureStorage = const FlutterSecureStorage();
    _initializePage();
  }

  Future getWareHouseAndVendordetails() async {
    final wareHouseId = await _secureStorage.read(key: 'warehouse_id');
    final wareHouseLat = await _secureStorage.read(key: 'warehouse_lat');
    final wareHouseLong = await _secureStorage.read(key: 'warehouse_long');
    // WareHouse Position
    Position? wareHousePosition = Position(
      latitude: double.parse(wareHouseLat ?? '26.0'),
      longitude: double.parse(wareHouseLong ?? '80.0'),
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

    final vendorLat = await _secureStorage.read(key: 'vendor_lat');
    final vendorLong = await _secureStorage.read(key: 'vendor_long');
    // Vendor Position
    Position? vendorPosition = Position(
      latitude: double.parse(vendorLat ?? '26.0'),
      longitude: double.parse(vendorLong ?? '80.0'),
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
    return {
      'warehouse_id': int.parse(wareHouseId ?? '0'),
      'wareHousePosition': wareHousePosition,
      'vendorPosition': vendorPosition,
    };
  }

  Future<void> _initializePage() async {
    // Retrieve saved address first
    final Address = await _secureStorage.read(key: 'saved_address');
    final vendorName = await _secureStorage.read(key: 'vendor_name');
    final vendorId = await _secureStorage.read(key: 'vendorID');

    setState(() {
      _vendorName = vendorName;
      _vendorId = vendorId;
      savedAddress = Address;
      _isLoading = false;
      addressLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      // Custom drawer that looks like the screenshot
      drawer: _buildDrawer(),
      // Add a gesture detector to the entire screen
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double padding = screenWidth * 0.01;

            return Stack(
              children: [
                // Main content
                Column(
                  children: [
                    // Top section with current location
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: Icon(Icons.menu, size: 40),
                                onPressed: () {
                                  // Open the drawer when menu is clicked
                                  _scaffoldKey.currentState?.openDrawer();
                                },
                                padding: EdgeInsets.zero,
                                alignment: Alignment.centerLeft,
                              ),
                              SizedBox(height: 1),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(
                                  'Current location',
                                  style: GoogleFonts.roboto(
                                    color: Color(0xFF328616),
                                    fontSize: screenWidth * 0.049,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    addressLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 0,
                            bottom: 10,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Home is the new address",
                                style: GoogleFonts.leagueSpartan(
                                  color: Colors.black,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(width: 5), // Add some spacing
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // Default navigation if no custom tap handler
                                    // Navigator.push(context, MaterialPageRoute(
                                    //     builder: (context) => SelectAddressPage()
                                    // ));
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          savedAddress ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.my_location_sharp,
                                        color: Color(0xFF328616),
                                        size: 28,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    // Location text with location icon
                    // Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: 20),
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         child: Text(
                    //           'Neelkanth boys hostel, NIT Hamirpur',
                    //           style: TextStyle(
                    //             fontSize: screenWidth * 0.041,
                    //             color: Colors.grey[700],
                    //           ),
                    //         ),
                    //       ),
                    //       Icon(
                    //         Icons.my_location_sharp,
                    //         color: Color(0xFF328616),
                    //         size: screenWidth * 0.065,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(height: 5),
                    // Expanded map view
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(padding),
                        child: FutureBuilder(
                          future: getWareHouseAndVendordetails(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error loading warehouse details'),
                              );
                            } else if (snapshot.hasData) {
                              final warehouseDetails =
                                  snapshot.data as Map<String, dynamic>;
                              // Pass warehouseDetails to your map widget if needed
                              return MapScreen(
                                wareHouseId: warehouseDetails['warehouse_id'],
                                wareHousePosition:
                                    warehouseDetails['wareHousePosition'],
                                vendorPosition:
                                    warehouseDetails['vendorPosition'],
                              );
                            } else {
                              return Center(
                                child: Text('No warehouse details found'),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Build custom drawer matching the screenshot
  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Drawer header with close button
            Container(
              margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Profile card section
            // Updated profile card with button at bottom right
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFEEE9F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main profile content in a row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile avatar with initials
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Color(0xFFB9CA63),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'MS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      // User info
                      Expanded(
                        child:
                            _isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _vendorName ?? 'Unknown Vendor',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'ID-${_vendorId ?? 'Unknown'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ],
                  ),

                  // Added space between content and button

                  // Profile button at bottom right
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 0,
                        ),
                        minimumSize: Size(0, 0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'profile',
                            style: TextStyle(
                              color: Color(0xFF3F3D56),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Color(0xFF3F3D56)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Menu items
            _buildMenuItem('assets/images/support(1).png', 'Support'),
            _buildMenuItem('assets/images/basket.png', 'Cart items'),
            // _buildMenuItem('assets/images/wallet.png', 'Wallet'),
            _buildMenuItem('assets/images/history(2).png', 'Order History'),
            _buildMenuItem('assets/images/notification.png', 'Notifications'),
            _buildMenuItem('assets/images/share.png', 'Share app'),
            _buildMenuItem('assets/images/aboutus.png', 'About us'),
          ],
        ),
      ),
    );
  }

  // Helper to create menu items with navigation
  Widget _buildMenuItem(String imagePath, String title) {
    return ListTile(
      leading: SizedBox(
        width: 30, // fixed width for consistent sizing
        height: 30, // fixed height for consistent sizing
        child: Image.asset(imagePath, fit: BoxFit.contain),
      ),
      title: Text(
        title,
        style: GoogleFonts.leagueSpartan(
          fontSize: 19,
          fontWeight: FontWeight.w400,
          color: Color(0xFF3F3D56),
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      onTap: () {
        // Close the drawer first
        Navigator.pop(context);

        // Navigate to the appropriate page based on the title
        switch (title) {
          case 'Support':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SupportScreen()),
            );
            break;
          case 'Cart items':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GroceryCartPage()),
            );
            break;
          // case 'Wallet':
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => GroceryCartPage()),
          //   );
          //   break;
          case 'Order History':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderHistoryPage2()),
            );
            break;
          case 'Notifications':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationsScreen()),
            );
            break;
          case 'Share app':
            _shareApp(); // Call a method to handle sharing
            break;
          case 'About us':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderHistoryPage2()),
            );
            break;
        }
      },
    );
  }

  // Method to handle app sharing
  void _shareApp() {
    // Implement share functionality using a package like share_plus
    // Example:
    // Share.share('Check out this amazing app: https://your-app-link.com');
  }
}
