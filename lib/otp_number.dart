import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:mrs_gorilla_vendor/api/firebase.dart';
import 'dart:convert';
import './homepage.dart';
import 'bottom_nav.dart';
// import"Dmeo.dart";

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({Key? key, required this.phoneNumber})
    : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  int _remainingSeconds = 30;
  Timer? _timer;
  bool isLoading = false;

  final storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    final String baseUrl = 'http://13.126.169.224/api/v1/vendor';
    try {
      final String? fcmToken = await NotificationService().setupToken();
      print('FCM Token: $fcmToken');
      if (fcmToken == null) {
        return {
          'success': false,
          'message': 'Something went wrong while getting FCM token',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/verify-login-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_no': phoneNumber,
          'otp': otp,
          'fcm_token': fcmToken,
        }),
      );

      final responseData = jsonDecode(response.body);
      print('API Response: $responseData');

      if (response.statusCode == 200) {
        // Successful verification
        final int vendorId = responseData['vendor']['id'] ?? 0;
        final warehouseId = responseData['vendor']['warehouse_id'] ?? 0;
        final wareHouseLat = responseData['vendor']['warehouse_lat'] ?? 26.8500;
        final wareHouseLong =
            responseData['vendor']['warehouse_long'] ?? 80.949997;
        final vendorLat = responseData['vendor']['lat'] ?? 26.8500;
        final vendorLong = responseData['vendor']['long'] ?? 80.949997;
        print('Vendor ID: $vendorId');
        print('Warehouse ID: $warehouseId');
        print('Warehouse Lat: $wareHouseLat');
        print('Warehouse Long: $wareHouseLong');
        print('Vendor Lat: $vendorLat');
        print('Vendor Long: $vendorLong');

        // Store the access token securely
        await storage.write(key: 'isLoggedIn', value: 'true');
        await storage.write(key: 'vendorId', value: vendorId.toString());
        await storage.write(key: 'warehouse_id', value: warehouseId.toString());
        await storage.write(
          key: 'warehouse_lat',
          value: wareHouseLat.toString(),
        );
        await storage.write(
          key: 'warehouse_long',
          value: wareHouseLong.toString(),
        );
        await storage.write(key: 'vendor_lat', value: vendorLat.toString());
        await storage.write(key: 'vendor_long', value: vendorLong.toString());
        return {
          'success': true,
          'message': 'OTP verified successfully',
          'user': responseData['user'] ?? {},
          'isNewUser': false,
        };
      } else {
        // Error handling based on the error response shown in screenshot
        return {
          'success': false,
          'message': responseData['error'] ?? 'Failed to verify OTP',
        };
      }
    } catch (e) {
      print('Exception during API call: $e');
      return {'success': false, 'message': 'Error verifying OTP: $e'};
    }
  }

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Setup focus listeners for OTP fields
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus && _otpControllers[i].text.isNotEmpty) {
          _otpControllers[i].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _otpControllers[i].text.length,
          );
        }
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _onOtpDigitChanged(String value, int index) {
    if (value.isNotEmpty) {
      // If digit entered, move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last field, hide keyboard
        FocusScope.of(context).unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      // If backspace pressed and field is empty, move to previous field
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Modified app bar to include back button and title
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'OTP verification',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phone number text
              Center(
                child: Text(
                  'Enter OTP sent to +91${widget.phoneNumber}',
                  style: const TextStyle(
                    fontSize: 19,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // OTP input fields
              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center, // Center the boxes and reduce space
                children: List.generate(
                  6,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                    ), // Adjust horizontal spacing
                    child: SizedBox(
                      width: 50, // Decreased width
                      height:
                          80, // Increased height (optional, for overall container sizing)
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        onChanged: (value) => _onOtpDigitChanged(value, index),
                        decoration: InputDecoration(
                          counterText: '',
                          isDense: true, // Reduces internal padding
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 20,
                          ), // Adjust vertical padding
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          hintText: '—',
                          hintStyle: const TextStyle(
                            fontSize: 24,
                            color: Colors.grey,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Auto verifying and resend text
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Auto verifying OTP',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Resend OTP in $_formattedTime',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            setState(() {
                              isLoading = true;
                            });

                            // Handle OTP verification
                            String otp =
                                _otpControllers
                                    .map((controller) => controller.text)
                                    .join();
                            if (otp.length == 6) {
                              // Process verification
                              final result = await verifyOtp(
                                widget.phoneNumber,
                                otp,
                              );

                              // Show message in SnackBar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result['message'])),
                              );
                              // Navigator.pushReplacement(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) =>
                              //   ),
                              // );
                              // Navigate if verification was successful
                              if (result['success']) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => MainScreen(
                                          initialIndex:
                                              2, // Or any specific index you want
                                        ),
                                  ),
                                  (route) => false,
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter a complete OTP'),
                                ),
                              );
                            }

                            setState(() {
                              isLoading = false;
                            });
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF49C71F), // Green color
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    // Dim the button when loading
                    disabledBackgroundColor: const Color(
                      0xFF49C71F,
                    ).withOpacity(0.6),
                    disabledForegroundColor: Colors.white.withOpacity(0.7),
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Verify',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
