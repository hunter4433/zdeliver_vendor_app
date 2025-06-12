import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_page.dart'; // Import your LoginScreen
import 'bottom_nav.dart'; // Import your MainScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // await Future.delayed(const Duration(seconds: 2)); // Optional: show splash for 2 seconds
    String? isLoggedIn = await storage.read(key: 'isLoggedIn');
    if (mounted) {
      if (isLoggedIn == 'true') {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => MainScreen()));
      } else {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Or your logo/image
      ),
    );
  }
}
