import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_page.dart';
import 'bottom_nav.dart';

// Vendor model class to parse API response
class Vendor {
  final int id;
  final String vendorId;
  String? emailId;
  String name;
  String phoneNo;
  String permanentAddress;
  String? imageUrl;

  Vendor({
    required this.id,
    required this.vendorId,
    this.emailId,
    required this.name,
    required this.phoneNo,
    required this.permanentAddress,
    this.imageUrl,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] ?? 0,
      vendorId: json['vendorId'] ?? '',
      emailId: json['emailId'],
      name: json['name'] ?? '',
      phoneNo: json['phone_no'] ?? '',
      permanentAddress: json['address'] ?? '',
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      // Additional fields can be included as needed
    };
  }
}
final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
// API service to fetch and update vendor data
class VendorApiService {
  static Future<Vendor> fetchVendorDetails(String id) async {
    final response = await http.get(
      Uri.parse('http://3.111.39.222/api/v1/fetch/basic-info?id=$id'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      Map<String, dynamic> data=jsonData;
      print(data);
       String name=data['vendors'][0]['name'];
      await _secureStorage.write(
          key: 'vendor_name',
          value: name
      );
      String vendorID=data['vendors'][0]['vendorId'];
      await _secureStorage.write(
          key: 'vendorID',
          value: vendorID
      );
      if (jsonData['vendors'] != null && jsonData['vendors'].isNotEmpty) {
        return Vendor.fromJson(jsonData['vendors'][0]);
      } else {
        throw Exception('No vendor data found');
      }
    } else {
      throw Exception('Failed to load vendor data');
    }
  }

  static Future<bool> updateVendorDetails(int vendorId, Map<String, dynamic> data) async {
    try {
      // Using the endpoint format from Postman
      final response = await http.put(
        Uri.parse('http://3.111.39.222/api/v1/fetch/vendor/$vendorId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['message'] == 'Vendor updated successfully';
      }
      return false;
    } catch (e) {
      print('Error updating vendor details: $e');
      return false;
    }
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Vendor> futureVendor;
  bool isEditing = false;
  String vendorId = '1'; // Default vendor ID

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the API call with the vendor ID
    _loadVendorData();
  }

  void _loadVendorData() {
    futureVendor = VendorApiService.fetchVendorDetails(vendorId);
  }

  void _initializeControllers(Vendor vendor) {
    nameController.text = vendor.name;
    phoneController.text = vendor.phoneNo;
    emailController.text = vendor.emailId ?? '';
    addressController.text = vendor.permanentAddress;
  }

  Future<void> _saveChanges(Vendor vendor) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    // Prepare data according to the API format shown in Postman
    Map<String, dynamic> updateData = {
      "name": nameController.text,
      "emailId":emailController.text,
       "phone_no":phoneController.text,
      "address":addressController.text
    };

    try {
      bool success = await VendorApiService.updateVendorDetails(vendor.id, updateData);

      // Close loading dialog
      Navigator.pop(context);

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );

        // Reset editing mode and refresh data
        setState(() {
          isEditing = false;
          _loadVendorData(); // Refresh data from API
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile')),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<Vendor>(
          future: futureVendor,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final vendor = snapshot.data!;
              if (!isEditing) {
                // Initialize controllers when data is first loaded
                _initializeControllers(vendor);
              }
              return isEditing
                  ? buildEditProfileForm(vendor)
                  : buildProfileContent(vendor);
            } else {
              return const Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }

  Widget buildProfileContent(Vendor vendor) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and title
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // IconButton(
                //   icon: const Icon(Icons.arrow_back, size: 30),
                //   padding: EdgeInsets.zero,
                //   alignment: Alignment.centerLeft,
                //   onPressed: () {
                //     Navigator.pushReplacement(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => MainScreen(
                //           initialIndex: 2, // Or any specific index you want
                //         ),
                //       ),
                //     );
                //   },
                // ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Profile details',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Profile Information Section with light blue background
          Container(
            color: Color(0xFFF0F8FF),
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: 20),
                // Profile Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 196,
                    width: 196,
                    color: Colors.grey.shade300,
                    child: vendor.imageUrl != null
                        ? Image.network(
                      vendor.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.grey.shade300),
                    )
                        : null,
                  ),
                ),
                SizedBox(height: 16),
                // Name
                Text(
                  vendor.name,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                // Vendor ID
                Text(
                  'Vendor ID : ${vendor.vendorId}',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),

                // Profile details section
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name section
                        Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          vendor.name,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Divider(color: Color(0xFFF0F8FF), height: 35),

                        // Phone number section
                        Text(
                          'Phone number',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          vendor.phoneNo,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Divider(color: Color(0xFFF0F8FF), height: 35),

                        // Email address section
                        Text(
                          'Email address',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          vendor.emailId ?? 'Not available',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Divider(color: Color(0xFFF0F8FF), height: 35),

                        // Vendor ID section
                        Text(
                          'Vendor ID',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          vendor.vendorId,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Divider(color: Color(0xFFF0F8FF), height: 35),

                        // Home address section
                        Text(
                          'Home address',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          vendor.permanentAddress,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 24),

                        // Edit details button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 78.0),
                          child: Container(
                            width: double.infinity,
                            height: 42,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isEditing = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFDCC29), // Yellow color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Edit details',
                                style: TextStyle(
                                  color: Color(0xFF3F2E78),
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  color: Color(0xFFF0F8FF),
                  width: double.infinity,
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3F2E78), // Purple color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Change Passkey',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Logout button
                Container(
                  width: double.infinity,
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 76),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEditProfileForm(Vendor vendor) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => isEditing = false),
                  child: Icon(Icons.arrow_back, size: 34),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Update your profile details',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Edit form with light blue background
          Container(
            color: Color(0xFFF0F8FF),
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: 20),
                // Profile Image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 196,
                        width: 196,
                        color: Colors.grey.shade300,
                        child: vendor.imageUrl != null
                            ? Image.network(
                          vendor.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: Colors.grey.shade300),
                        )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Color(0xFF3F2E78),
                        radius: 20,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Name
                Text(
                  nameController.text,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                // Vendor ID (non-editable)
                Text(
                  'Vendor ID : ${vendor.vendorId}',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),

                // Edit form section
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name field
                        Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Phone number field
                        Text(
                          'Phone number',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Email address field
                        Text(
                          'Email address',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Vendor ID field (read-only)
                        Text(
                          'Vendor ID',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        TextFormField(
                          initialValue: vendor.vendorId,
                          readOnly: true,
                          enabled: false,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            fillColor: Colors.grey.shade200,
                            filled: true,
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Home address field
                        Text(
                          'Home address',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        TextFormField(
                          controller: addressController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.all(12),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Save and Cancel buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => setState(() => isEditing = false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: Color(0xFF3F2E78)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Color(0xFF3F2E78),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _saveChanges(vendor),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFDCC29),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Color(0xFF3F2E78),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 76),
              ],
            ),
          ),
        ],
      ),
    );
  }
}