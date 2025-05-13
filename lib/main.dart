import 'package:flutter/material.dart';
import 'package:mrs_gorilla_vendor/bottom_nav.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:mrs_gorilla_vendor/signup.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';  // Import Google Fonts
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mrs_gorilla_vendor/api/firebase.dart';
import 'firebase_options.dart';

import 'auth_page.dart';
import 'mapview.dart';



// Global navigator key for use in notification navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Handler for background messages (must be a top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase here if needed when app is terminated
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message: ${message.messageId}');
  print('Background message data: ${message.data}');
  print('Background message notification: ${message.notification?.title}');
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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    int currentIndex=0;
    return MaterialApp(
      title: 'ZDeliver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Apply Roboto font to the entire app
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
        // Keep your existing color scheme
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // Make sure primary font family is also set to Roboto
        fontFamily: GoogleFonts.roboto().fontFamily,
      ),
      home: LoginScreen(),
    );
  }
}