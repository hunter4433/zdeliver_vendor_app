import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mrs_gorilla_vendor/wareHouse.dart';

import 'bottom_nav.dart';

class GroceryCartPage extends StatefulWidget {
  const GroceryCartPage({Key? key}) : super(key: key);

  @override
  State<GroceryCartPage> createState() => _GroceryCartPageState();
}

class _GroceryCartPageState extends State<GroceryCartPage> {
  bool isLoading = true;
  List<dynamic> cartItems = [];
  Map<String, dynamic> vendorInfo = {};
  String cartType = "";

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://3.111.39.222/api/cart/vendor/1/items'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          cartItems = data['items'] ?? [];
          vendorInfo = data['vendor'] ?? {};
          cartType = vendorInfo['cart_type'] ?? "";
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        // Handle error
        print('Failed to load cart items: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle exception
      print('Exception when fetching cart items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F8FF),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0,top: 70,right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current location',
                      style: TextStyle(
                        color: Color(0xFF4A8F3C),
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Neelkanth boys hostel, NIT Hamirpur, him..',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: const Icon(Icons.my_location, color: Color(0xFF4A8F3C), size: 30),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // First Card - Customized Cart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${cartType.isNotEmpty ? cartType.substring(0, 1).toUpperCase() + cartType.substring(1) : "Customized"} cart',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Order Details',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Text(
                            'Location : ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Kailash boys hostel, NIT hamirpur, himachal pradesh',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () {
                          // Open Google Maps
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              ClipRRect(
                                child: Image.asset(
                                  'assets/images/googleMap.png',
                                  height: 32,
                                  width: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'Open in Google maps',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward, color: Colors.black),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Second Card - Items in Cart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Items in cart',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // API items rendering
                      if (cartItems.isEmpty)
                        const Center(
                          child: Text(
                            'No items in cart',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      else
                        ...cartItems.map((item) => _buildCartItem(
                          item['image_url'] ?? '',
                          item['name'] ?? 'Unknown Item',
                          item['price_per_unit'] ?? '0.00',
                          item['unit'] ?? 'kg'
                        )).toList(),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Locate nearest Warehouse button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: InkWell(
                onTap: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NearestWarehousePage(
                       // Or any specific index you want
                      ),
                    ),
                  );
                  // Locate nearest warehouse
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDCC29),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, color: Colors.deepPurple, size: 30),
                      const SizedBox(width: 8),
                      const Text(
                        'Locate nearest Warehouse',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: Colors.deepPurple, size: 30),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(String imageUrl, String name, String price, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              height: 48,
              width: 48,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 48,
                  width: 48,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                );
              },
            )
                : Image.asset(
              'assests/oninon.png',
              height: 48,
              width: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '₹$price',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4A8F3C),
                      ),
                    ),
                    Text(
                      ' /$unit', // Or pass the unit from API if available
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}