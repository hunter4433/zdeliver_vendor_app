import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mrs_gorilla_vendor/api/firebase.dart';
import 'package:mrs_gorilla_vendor/splash.dart';
import 'firebase_options.dart';

import 'auth_page.dart';

// Global navigator key for use in notification navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

// Handler for background messages (must be a top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background handler triggered!');
  // Initialize Firebase here if needed when app is terminated
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // print('Handling a background message: ${message.toMap()}');
  // print('Background message data: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Register background handler before initializing Firebase
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize notification service
    await NotificationService().initialize();

    // Other initializations...
    String ACCESS_TOKEN = const String.fromEnvironment("ACCESS_TOKEN");
    mapbox.MapboxOptions.setAccessToken(ACCESS_TOKEN);
  } catch (e) {
    print("Error during initialization: $e");
  }
  // // // Pass your access token to MapboxOptions so you can load a map
  // String ACCESS_TOKEN = const String.fromEnvironment("ACCESS_TOKEN");
  // mapbox.MapboxOptions.setAccessToken(ACCESS_TOKEN);

  runApp(const MyApp());

  // Listen for foreground notifications and show dialog
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground notification!');
      final payload = message.toMap();
      print('Foreground message data: ${payload}');

      final context = navigatorKey.currentContext;
      if (context != null) {
        NotificationService().showOrderOverlay(context, payload);
      }
    });
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    int currentIndex = 0;
    return MaterialApp(
      title: 'ZDeliver',
      scaffoldMessengerKey: scaffoldMessengerKey,
      navigatorKey: navigatorKey,

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Apply Roboto font to the entire app
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
        // Keep your existing color scheme
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // Make sure primary font family is also set to Roboto
        fontFamily: GoogleFonts.roboto().fontFamily,
      ),
      home: SplashScreen(),
    );
  }
}
