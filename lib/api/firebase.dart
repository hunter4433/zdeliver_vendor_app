// In services/notification_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mrs_gorilla_vendor/bottom_nav.dart';
import 'package:mrs_gorilla_vendor/order_accept_widget.dart';
import '../main.dart'; // Import to use navigatorKey
import 'package:mrs_gorilla_vendor/notification.dart';

// Background handler for notification actions
@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse response) {
  if (response.payload != null) {
    try {
      final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
      final orderId = message.data['order_id'];
      final bookingId = message.data['booking_id'] ?? 0;

      if (response.actionId == 'ACCEPT_ACTION') {
        print('Accept tapped');
        NotificationService().orderNotificationResponseToServer(
          'accepted',
          'I can fulfill this order',
          bookingId,
        );

        // Handle accept logic here
      } else if (response.actionId == 'REJECT_ACTION') {
        print('----------------Reject tapped----------');

        // Handle reject logic here
      } else {
        print('Notification tapped');
        NotificationService().handleMessage(message);
      }
    } catch (e) {
      print('Error processing notification payload: $e');
    }
  }
}

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final storage = FlutterSecureStorage();
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // Define notification channel for Android
  final androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications',
    importance: Importance.max, // Use max instead of high
    enableLights: true,
    enableVibration: true,
    playSound: true,
  );

  // Initialize the notification service
  Future<void> initialize() async {
    try {
      await _requestPermissions();
      // await _setupToken();
      await initLocalNotifications();
      await initPushNotifications();
      print('mohit here');
      print('Notification service initialized successfully');
    } catch (e) {
      print('Error initializing notification service: $e');
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Error initializing notification service',
      );
    }
  }

  // Add this to your NotificationService class
  Future<void> showTestNotification() async {
    _localNotifications.show(
      99,
      'Test Notification',
      'This is a test notification',
      NotificationDetails(
        android: AndroidNotificationDetails(
          androidChannel.id,
          androidChannel.name,
          channelDescription: androidChannel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
    print('Test notification triggered');
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      print('Notification permission status: ${settings.authorizationStatus}');
    } catch (e) {
      print('Error requesting notification permissions: $e');
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Error requesting notification permissions',
      );
    }
  }

  // Setup FCM token and store it
  Future<String?> setupToken() async {
    try {
      // // Listen for token refresh
      // FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      //   storage.write(key: 'fcmToken', value: fcmToken);
      //   print('new fcm token');
      //   print('FCM Token refreshed: $fcmToken');
      //   // You may want to send the refreshed token to your server
      //   // sendTokenToServer(fcmToken);
      // });

      // Get the current token
      await FirebaseMessaging.instance.deleteToken();
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print('New FCM token: $fcmToken');
      // final fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        print('FCM Token: $fcmToken');
        await storage.write(key: 'fcmToken', value: fcmToken);
        // Send the token to your server
        return fcmToken;
      }
      return null;
    } catch (e) {
      print('Error getting FCM token: $e');
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Error getting FCM token',
      );
    }
  }

  // foreground handler for notification actions
  void onNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      try {
        print('Notification response payload: ${response.payload}');
        final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
        print('Notification response message: $message');
        final bookingId = message.data['booking_id'] ?? 0;
        print('Booking ID: $bookingId');

        if (response.actionId == 'ACCEPT_ACTION') {
          print('Accept tapped');
          orderNotificationResponseToServer(
            "accepted",

            'I can fulfill this order',
            bookingId,
          );
          // Handle accept logic here
        } else if (response.actionId == 'REJECT_ACTION') {
          print('Reject tapped');

          // Handle reject logic here
        } else {
          print('Notification tapped');
          // handleMessage(message);
        }
      } catch (e) {
        print('Error processing notification payload: $e');
      }
    }
  }

  // Initialize local notifications
  Future<void> initLocalNotifications() async {
    // iOS settings
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Android settings
    // const androidSettings = AndroidInitializationSettings('@drawable/android_logo');
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Combined settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    // Initialize
    await _localNotifications.initialize(
      initSettings,
      // onDidReceiveNotificationResponse: onNotificationResponse,
      // // Add this line to handle background notification responses
      // onDidReceiveBackgroundNotificationResponse:
      //     onBackgroundNotificationResponse,
    );

    // Create notification channel for Android
    final androidPlugin =
        _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidPlugin?.createNotificationChannel(androidChannel);
  }

  // Initialize push notifications
  Future<void> initPushNotifications() async {
    // Set foreground notification presentation options
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle initial message (app opened from terminated state)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print(
          'App opened from terminated state with message: ${message.messageId}',
        );
        handleMessage(message);
      }
    });

    // Listen for messages when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print(
        'App opened from background state with message: ${message.messageId}',
      );
      handleMessage(message);
    });

    // Handle foreground messages
    // In your NotificationService class
    // In your NotificationService class
    FirebaseMessaging.onMessage.listen((message) {
      print('FCM DEBUG: Message received in foreground');
      print('FCM DEBUG: Message ID: ${message.messageId}');
      print('FCM DEBUG: Message data: ${message.data}');
      print('FCM DEBUG: Has notification? ${message.notification != null}');
      if (message.notification != null) {
        print('FCM DEBUG: Notification title: ${message.notification!.title}');
        print('FCM DEBUG: Notification body: ${message.notification!.body}');
      }

      _showForegroundNotification(message);
    });
  }

  // Show foreground notification
  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    print(notification);
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          androidChannel.id,
          androidChannel.name,
          channelDescription: androidChannel.description,
          icon: '@mipmap/ic_launcher', // Updated icon reference
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          // actions: <AndroidNotificationAction>[
          //   AndroidNotificationAction(
          //     'ACCEPT_ACTION',
          //     'Accept',
          //     showsUserInterface: true,
          //   ),
          //   AndroidNotificationAction(
          //     'REJECT_ACTION',
          //     'Reject',
          //     showsUserInterface: true,
          //   ),
          // ],
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode({
        ...message.toMap(),
        'notification_id': notification.hashCode, // Add this line
      }),
    );
  }

  // Handle message and navigate to appropriate screen
  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    try {
      // Make sure the navigator key is available and context is ready
      if (navigatorKey.currentState == null) {
        print('Navigator key is not available yet');
        return;
      }
      Map<String, dynamic> data = message.data;
      final orderId = data['order_id'] ?? 0;
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Delay showing the dialog until after the first frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showOrderOverlay(context, data);
        });
      }
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder:
              (context) => MainScreen(
                initialIndex: 2, // Or any specific index you want
              ),
        ),
      );
    } catch (e) {
      print('Error handling message: $e');
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Error handling push notification message',
      );
    }
  }

  // Send FCM token to server
  Future<void> sendTokenToServer(String token) async {
    try {
      const String url = 'https://your-api-endpoint.com/fcm-token';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
          // 'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'token': token,
          // Add additional user information if needed
          // 'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        print('Token successfully sent to server');
      } else {
        print('Failed to send token to server: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending token to server: $e');
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
  }

  Future orderNotificationResponseToServer(
    String status,
    String reason,
    int bookingId,
  ) async {
    try {
      print('Sending order notification response to server');
      print('Status: $status, Reason: $reason, Booking ID: $bookingId');
      // Retrieve the vendorid from secure storage
      final String? vendorId = await storage.read(key: 'vendorId');

      if (vendorId == null) {
        print('Vendor ID not found in secure storage');
        return;
      }

      print('Booking ID: $bookingId');
      final String url =
          'http://13.126.169.224/api/v1/smartOrders/vendor/$vendorId/order-request/status';

      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status, 'booking_id': bookingId}),
      );
      print(response.body);
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('Order notification response successfully sent to server');
        return responseBody['message'];
      }

      return responseBody['error'] ??
          'Failed to send order notification response to server';
    } catch (e) {
      print('Error sending order notification response to server: $e');
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
  }

  void showOrderOverlay(BuildContext context, Map<String, dynamic> data) {
    double progress = 1.0;
    int secondsLeft = 45;
    Timer? timer;

    final int bookingId = int.parse(data['data']['booking_id'] ?? 0);
    final int notificationId =
        data['notification_id'] is int
            ? data['notification_id']
            : (data['notification_id'] is String
                ? int.tryParse(data['notification_id']) ?? data.hashCode
                : data.hashCode);

    // Cancel the notification after 45 seconds
    Future.delayed(const Duration(seconds: 45), () {
      _localNotifications.cancel(notificationId);
    });
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Order Overlay",
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: StatefulBuilder(
              builder: (context, setState) {
                // Start timer only once
                if (timer == null) {
                  timer = Timer.periodic(const Duration(seconds: 1), (t) {
                    if (secondsLeft > 0) {
                      secondsLeft--;
                      progress = secondsLeft / 45;
                      setState(() {});
                    } else {
                      timer?.cancel();
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    }
                  });
                }

                return Container(
                  // margin: const EdgeInsets.only(
                  //   bottom: 60,
                  //   left: 20,
                  //   right: 20,
                  // ),
                  // decoration: BoxDecoration(
                  //   color: Colors.white,
                  //   borderRadius: BorderRadius.circular(16),
                  //   boxShadow: [
                  //     BoxShadow(
                  //       color: Colors.black26,
                  //       blurRadius: 10,
                  //       offset: Offset(0, 4),
                  //     ),
                  //   ],
                  // ),
                  child: OrderAcceptWidget(
                    orderDetails: data,
                    secondsLeft: secondsLeft,
                    progress: progress,
                    onAccept: () async {
                      timer?.cancel();
                      final res = await orderNotificationResponseToServer(
                        'accepted',
                        'I can fulfill this order',
                        bookingId,
                      );
                      Navigator.of(context).pop();
                      _localNotifications.cancel(notificationId);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(res),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    onDecline: () {
                      timer?.cancel();
                      Navigator.of(context).pop();
                      _localNotifications.cancel(notificationId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Order request rejected'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Text(
//                         'New Order Request!',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         data['body'] ?? 'New order request received',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Address: ${data['address'] ?? 'No address provided'}',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Cart Type: ${data['cart_type'] ?? 'No cart type provided'}',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           ElevatedButton(
//                             onPressed: () {
//                               timer?.cancel();
//                               Navigator.of(context).pop();
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Order request rejected'),
//                                   duration: Duration(seconds: 2),
//                                 ),
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.black,
//                               elevation: 0,
//                               minimumSize: const Size(100, 55),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             child: const Text(
//                               'Decline',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Color(0xFF49C71F),
//                               elevation: 0,
//                               minimumSize: const Size(100, 55),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             onPressed: () async {
//                               timer?.cancel(); // Cancel the timer when accepted
//                               await orderNotificationResponseToServer(
//                                 'accepted',
//                                 'I can fulfill this order',
//                               );
//                               Navigator.of(context).pop();
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Order request accepted'),
//                                   duration: Duration(seconds: 2),
//                                 ),
//                               );
//                             },
//                             child: const Text(
//                               'Accept',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       LinearProgressIndicator(
//                         value: progress,
//                         minHeight: 8,
//                         backgroundColor: Colors.white24,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         '$secondsLeft seconds left',
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ],
//                   ),
