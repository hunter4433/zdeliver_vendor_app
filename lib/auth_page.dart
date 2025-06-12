import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mrs_gorilla_vendor/main.dart';
import 'package:mrs_gorilla_vendor/signup.dart';
import 'otp_number.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'HomePage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool isButtonEnabled = false; // Track button state
  bool isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // New API call for OTP verification
  Future<Map<String, dynamic>> sendOtpVerification(String phoneNumber) async {
    final String baseUrl = 'http://13.126.169.224/api/v1/vendor';
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_no': phoneNumber}),
      );

      print('OTP verification response: ${response.body}');
      print(response.statusCode);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        Map<String, dynamic> response = {
          "error": "You don't have an account",
          "action": "signup",
        };
        return response; // Or whatever signup value you want to return
      } else {
        // Handle other non-200 status codes
        throw Exception('Failed to send OTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending OTP: $e');
      // Return a default response or rethrow
      return {'message': 'Network error. Please try again.', 'action': 'retry'};
    }
  }

  void _validatePhoneNumber(String value) {
    if (value.length == 10 && !isButtonEnabled) {
      setState(() {
        isButtonEnabled = true;
      });
    } else if (value.length != 10 && isButtonEnabled) {
      setState(() {
        isButtonEnabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Main Image with Skip Login button
            Stack(
              children: [
                // Main image
                Image.asset(
                  'assets/images/DALL·E 2025-03-02 11.57.04 - A realistic vector-style illustration of an e-vehicle vegetable cart positioned closer to the camera in the center of a modern Mumbai or Pune society.webp',
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height * 0.62,
                  width: double.infinity,
                ),
                // White gradient overlay at the bottom that fades upward
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100, // Adjust height of gradient as needed
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.white.withOpacity(
                            0.98,
                          ), // More opaque at bottom
                          Colors.white.withOpacity(
                            0.0,
                          ), // Completely transparent at top
                        ],
                      ),
                    ),
                  ),
                ),
                // Logo positioned on top of everything
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        18,
                      ), // Rounded corners for the logo
                      child: Image.asset(
                        'assets/images/newlogo.png',
                        fit: BoxFit.cover,
                        height: 100,
                        width: 260,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 7),

            // Tagline
            const Text(
              'We bring the market to you!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),

            const SizedBox(height: 15),

            // Login or Signup text
            const Text(
              'Login or Signup',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 10),

            // Phone number input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10, // Restrict to 10 digits
                onChanged:
                    _validatePhoneNumber, // Call function on input change
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter mobile number',
                  counterText: "", // Hide character count
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefix: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 1,
                    ),
                    margin: const EdgeInsets.only(right: 10),
                    child: const Text(
                      '+91',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Don\'t have an account?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    // // Navigation code here
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VendorLoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'SIGNUP',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color:
                          Colors
                              .blue, // You can change this color to match your theme
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),

            // Continue button (turns green when valid)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed:
                    isButtonEnabled
                        ? () async {
                          // Show loading indicator
                          setState(() {
                            isLoading = true;
                          });

                          // Call the new OTP verification API
                          final otpResponse = await sendOtpVerification(
                            _phoneController.text,
                          );

                          setState(() {
                            isLoading = false;
                          });

                          // Check if OTP was sent successfully
                          if (otpResponse['action'] == 'verify-otp') {
                            // If successful, navigate to OTP verification screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => OtpVerificationScreen(
                                      phoneNumber: _phoneController.text,
                                    ),
                              ),
                            );
                          } else if (otpResponse['action'] == 'signup') {
                            // If user needs to sign up, navigate to signup page
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  otpResponse['message'] ??
                                      'Please register first',
                                ),
                              ),
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VendorLoginPage(),
                              ),
                            );
                          } else {
                            // Handle other cases (retry, error, etc.)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  otpResponse['message'] ??
                                      'Something went wrong',
                                ),
                              ),
                            );
                          }
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isButtonEnabled ? Color(0xFF49C71F) : Colors.grey[400],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 15),
            Divider(),

            // Terms text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Text(
                    'By continuing you agree to our',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.1, // Even tighter line height
                    ),
                  ),
                  SizedBox(height: 0), // Removes extra spacing between lines
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TermsOfServiceScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero, // Ensures no extra space
                          padding:
                              EdgeInsets.zero, // Removes padding inside button
                          tapTargetSize:
                              MaterialTapTargetSize
                                  .shrinkWrap, // Shrinks tap area
                        ),
                        child: const Text(
                          'Terms of Service',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(
                        ' & ',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrivacyPolicyScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// Terms of Service Screen
class TermsOfServiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms of Service")),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            "Add your Terms of Service text here...",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

// Privacy Policy Screen
class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            "Add your Privacy Policy text here...",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
