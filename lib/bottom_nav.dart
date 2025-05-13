import 'package:flutter/material.dart';
import 'package:mrs_gorilla_vendor/cart_items.dart';
import 'package:mrs_gorilla_vendor/order_history1.dart';
import 'package:mrs_gorilla_vendor/order_history2.dart';
import 'package:mrs_gorilla_vendor/billing.dart';
import 'package:mrs_gorilla_vendor/homepage.dart';
import 'package:mrs_gorilla_vendor/profile.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define image paths - replace these with your actual image paths
    final List<String> imagePaths = [
      'assets/images/cart_items.png',
      'assets/images/billing.png',
      'assets/images/billing.png',
      'assets/images/order_history.png',
      'assets/images/profile-user (3) 1.png',
    ];

    // Define tab labels
    final List<String> tabLabels = [
      'Cart Items',
      'Billing',
      'Home',
      'Order History',
      'Profile',
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 12,
            offset: Offset(0, -2), // Shadow on the upper side
          ),
        ],
      ),
      child: SizedBox(
        height: 80, // Increased height of bottom navigation bar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            imagePaths.length,
                (index) => InkWell(
              onTap: () => onTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 30, // Fixed height for the image container
                    width: 30, // Fixed width for the image container
                    child: Image.asset(
                      imagePaths[index],
                      color: currentIndex == index ? Colors.black : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tabLabels[index],
                    style: TextStyle(
                      fontSize: 13,
                      color: currentIndex == index ? Colors.black : Colors.black54,
                      fontWeight: currentIndex == index ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({Key? key, this.initialIndex = 2}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          GroceryCartPage(),
          CheckoutPage44(),
          LocationPage(),
          OrderHistoryPage2(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}