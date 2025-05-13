import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrs_gorilla_vendor/profile.dart';
import 'package:mrs_gorilla_vendor/support.dart';
import '';
import 'cart_items.dart';
import 'mapview.dart';
import 'notification.dart';
import 'order_history1.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);


  @override
  State<LocationPage> createState() => _LocationPageState();
}


class _LocationPageState extends State<LocationPage> with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late Animation<Offset> _cardOffsetAnimation;
  bool addressLoading=true;
  late final FlutterSecureStorage _secureStorage;
  bool _isLoading = true;
  String? _vendorName;
  String? _vendorId;

  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonColorAnimation;


  // New drawer controller
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isCardVisible = true;
  String? savedAddress;


  @override
  void initState() {
    super.initState();
    _secureStorage = const FlutterSecureStorage();
    _initializePage();

    // Card slide-up animation
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );


    _cardOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start from bottom
      end: Offset.zero, // End at original position
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutQuart,
    ));


    // Button color animation
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3200),
      vsync: this,
    );


    _buttonColorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_buttonAnimationController);


    // Start card animation as soon as widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cardAnimationController.forward().then((_) {
        // Start button animation after card animation completes
        _buttonAnimationController.forward();
      });
    });
  }

  Future<void> _initializePage() async {
    // Retrieve saved address first
    final Address = await _secureStorage.read(key: 'saved_address');
    final vendorName = await _secureStorage.read(key: 'vendor_name');
    final vendorId = await _secureStorage.read(key: 'vendorID');

    setState(() {
      _vendorName = vendorName;
      _vendorId = vendorId;
      savedAddress=Address;
      _isLoading = false;
      addressLoading= false;
    });

  }


  @override
  void dispose() {
    _cardAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }


  // Function to dismiss the card
  void _dismissCard() {
    if (_isCardVisible) {
      _cardAnimationController.reverse().then((_) {
        setState(() {
          _isCardVisible = false;
        });
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      key: _scaffoldKey,
      // Custom drawer that looks like the screenshot
      drawer: _buildDrawer(),
      // Add a gesture detector to the entire screen
      body: GestureDetector(
        onTap: _dismissCard,
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
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
                            horizontal: 10, vertical: 5),
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
                                      horizontal: 8.0),
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
                        padding: const EdgeInsets.only(left: 20,right: 20, top: 0, bottom: 10),
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
                                onTap:  () {
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
                          child: MapScreen(),
                        ),
                      ),
                    ],
                  ),


                  // Animated card that slides up from bottom
                  if (_isCardVisible)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SlideTransition(
                        position: _cardOffsetAnimation,
                        child: Card(
                          color: Colors.white,
                          margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          elevation: 8,
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Location: ',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 25,),
                                    Expanded(
                                      child: Text(
                                        'Kailash boys hostel, NIt hamirpur, himachal pradesh',
                                        style: TextStyle(fontSize: 17,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text(
                                      'Order type: ',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 6,),
                                    Text(
                                      'Standard Gorilla cart',
                                      style: TextStyle(fontSize: 17,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text(
                                      'Trip fare: ',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 26,),
                                    Text(
                                      'Rs 250',
                                      style: TextStyle(fontSize: 17,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24),
                                // Animated button
                                AnimatedBuilder(
                                  animation: _buttonColorAnimation,
                                  builder: (context, child) {
                                    return ClipRect(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2.0),
                                        child: Container(
                                          color: Colors.white,
                                          width: double.infinity,
                                          height: 50,
                                          child: Stack(
                                            children: [
                                              // Base button
                                              Container(
                                                width: double.infinity,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF49C71F),
                                                  borderRadius: BorderRadius
                                                      .circular(12),
                                                ),
                                              ),
                                              // Animated darker overlay
                                              Container(
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width *
                                                    _buttonColorAnimation.value,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF328616),
                                                  borderRadius: BorderRadius
                                                      .only(
                                                    topLeft: Radius.circular(
                                                        12),
                                                    bottomLeft: Radius.circular(
                                                        12),
                                                    topRight: _buttonColorAnimation
                                                        .value == 1.0
                                                        ? Radius.circular(12)
                                                        : Radius.zero,
                                                    bottomRight: _buttonColorAnimation
                                                        .value == 1.0
                                                        ? Radius.circular(12)
                                                        : Radius.zero,
                                                  ),
                                                ),
                                              ),
                                              // Button text
                                              Center(
                                                child: Text(
                                                  'Accept',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 4),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
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
            Container(margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
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
                child: _isLoading
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
                          MaterialPageRoute(builder: (context) => ProfilePage()),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 0, vertical: 0),
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
                          Icon(
                            Icons.chevron_right,
                            color: Color(0xFF3F3D56),
                          ),
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
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
        ),
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
              MaterialPageRoute(builder: (context) =>OrderHistoryPage2()),
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