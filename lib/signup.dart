import 'package:flutter/material.dart';
import 'package:mrs_gorilla_vendor/bottom_nav.dart';
import 'package:mrs_gorilla_vendor/wareHouse.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'auth_page.dart';

class VendorLoginPage extends StatefulWidget {
  const VendorLoginPage({Key? key}) : super(key: key);

  @override
  _VendorLoginPageState createState() => _VendorLoginPageState();
}

class _VendorLoginPageState extends State<VendorLoginPage> {
  final TextEditingController _vendorIdController = TextEditingController();
  final TextEditingController _vendorPasskeyController =
      TextEditingController();

  // API call method to verify credentials
  Future<void> _verifyCredentials() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Prepare request body
      final Map<String, String> requestBody = {
        "vendorId": _vendorIdController.text.trim(),
        "passkey": _vendorPasskeyController.text.trim(),
        "fcm_token": "",
      };

      // Make API call
      final response = await http.post(
        Uri.parse('http://13.126.169.224/api/v1/vendor/verify-credentials'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      print('Response status: ${response.body}');
      // Close loading dialog
      Navigator.pop(context);

      if (response.statusCode == 200) {
        // Parse response
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Check if login was successful
        if (responseData['message'] == 'Login successful!') {
          // Navigate to main screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => MainScreen(
                    initialIndex: 2, // Or any specific index you want
                  ),
            ),
          );
        } else {
          // Show error message
          _showErrorMessage(
            'Verification failed. Please check your credentials.',
          );
        }
      } else {
        // Show error for non-200 response
        _showErrorMessage(
          'Server error: ${response.statusCode}. Please try again later.',
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error for exceptions
      _showErrorMessage('Connection error: $e');
    }
  }

  // Helper method to show error messages
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Method to show the bottom sheet
  void _showVendorInfoBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 26),
                Text(
                  'Visit your nearest warehouse to get your Vendor ID & Passkey',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 46),

                // Locate Warehouse Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NearestWarehousePage(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 30,
                    ),
                    label: Text(
                      'Locate your nearest warehouse',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF49C71F),
                      padding: EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Contact Warehouse Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Add contact warehouse logic
                    },
                    icon: Icon(Icons.phone, color: Colors.white, size: 30),
                    label: Text(
                      'Contact your nearest warehouse',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF15A25),
                      padding: EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 18.0,
            bottom: 20,
            top: 15,
            right: 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom back and title row
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 35,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Enter Credentials',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Vendor ID TextField
              const Text(
                'Vendor ID',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 7),
              TextField(
                style: TextStyle(color: Colors.black, fontSize: 17),
                controller: _vendorIdController,
                decoration: InputDecoration(
                  hintText: 'Enter vendor ID',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ), // Set hint text color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Colors.black12,
                    ), // Set border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ), // Border color when not focused
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                    ), // Border color when focused
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Vendor Passkey TextField
              const Text(
                'Vendor Passkey',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 7),
              TextField(
                style: TextStyle(color: Colors.black, fontSize: 17),
                controller: _vendorPasskeyController,
                obscureText: true, // Added to hide passkey input
                decoration: InputDecoration(
                  hintText: 'Enter vendor passkey',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ), // Set hint text color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Colors.black12,
                    ), // Set border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ), // Border color when not focused
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                    ), // Border color when focused
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(fontSize: 15),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Where to get Vendor ID and Passkey link
              Center(
                child: TextButton(
                  onPressed: _showVendorInfoBottomSheet,
                  child: const Text(
                    'Where to get Vendor ID and Passkey?',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _verifyCredentials, // Updated to use the API call method
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF49C71F),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Verify',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
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
