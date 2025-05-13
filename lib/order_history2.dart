import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderDetailsPage1 extends StatefulWidget {
  final int orderId;

  OrderDetailsPage1({required this.orderId }); // Default to order ID 2 if not provided

  @override
  _OrderDetailsPage1State createState() => _OrderDetailsPage1State();
}

class _OrderDetailsPage1State extends State<OrderDetailsPage1> {
  bool isLoading = true;
  Map<String, dynamic> orderData = {};
  List<dynamic> orderItems = [];

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://3.111.39.222/api/v1/request/${widget.orderId}'),
      );
      print('bdcjk');
      print(response.body);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true ) {
          setState(() {
            orderData = jsonResponse['request'];
            orderItems = jsonResponse['items'] ?? [];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No order details found')),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load order details')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F8FF),
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 21),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 80),
                    children: [
                      // Customer details card
                      Card(
                        color: Colors.white,
                        margin: const EdgeInsets.all(12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Customer Name',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                orderData['user_name'] ?? 'Amresh Kumar Singh',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 12),

                              const Text(
                                'Cart delivered at',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                orderData['order_address'] ?? 'Hs no. 15 shardanaganagri, mirajgaon road, karhat',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Date',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black54,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        '11/03/2025',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 100),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Time',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black54,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        '11:30 AM',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),

                      // Items purchased card
                      Card(
                        color: Colors.white,
                        margin: const EdgeInsets.all(12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Order Details',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Map items from API response or use hardcoded items if none are available
                              ..._buildOrderItems(),
                            ],
                          ),
                        ),
                      ),

                      // Payment details card
                      Container(
                        margin: const EdgeInsets.fromLTRB(12, 15, 12, 0),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Payment Status : Complete",
                              style: TextStyle(
                                color: Color(0xFF4A8F3C),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Paid : ${orderData['total_price'] ?? '120'}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "Paid through UPI/PhonePay",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              "Transaction ID : HSJXXD345",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              "Date : 12/12/25",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              "Time : 12:30 PM",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Bill Details",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Items Total",
                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                ),
                                Text(
                                  "Rs. 140.00",
                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                ),
                              ],
                            ),
                            Container(
                              width: double.infinity,
                              height: 1,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: CustomPaint(
                                painter: DashPainter(color: Colors.grey),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Discounts",
                                      style: TextStyle(
                                        color: Color(0xFF4A8F3C),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(Icons.info_outline, size: 16, color: Colors.grey),
                                  ],
                                ),
                                const Text(
                                  "Rs. 40.00",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF4A8F3C),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: double.infinity,
                              height: 1,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: CustomPaint(
                                painter: DashPainter(color: Colors.grey),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Platform fee",
                                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(Icons.info_outline, size: 16, color: Colors.grey),
                                  ],
                                ),
                                const Text(
                                  "Rs. 8.00",
                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                ),
                              ],
                            ),
                            Container(
                              width: double.infinity,
                              height: 1,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: CustomPaint(
                                painter: DashPainter(color: Colors.grey),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Delivery charge",
                                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(Icons.info_outline, size: 16, color: Colors.grey),
                                  ],
                                ),
                                const Text(
                                  "Rs. 12.00",
                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                ),
                              ],
                            ),
                            Container(
                              width: double.infinity,
                              height: 1,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: CustomPaint(
                                painter: DashPainter(color: Colors.grey),
                              ),
                            ),
                             Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Grand Total",
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                                ),
                                Text(
                                  "${orderData['total_price']}",
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOrderItems() {
    // If we have items from API, use them
    if (orderItems.isNotEmpty) {
      List<Widget> itemWidgets = [];
      for (var item in orderItems) {
        itemWidgets.add(
          buildItemRow(
            item['image_url']  ??  'assests/oninon.png',
            item['item_name'] ?? 'Item',
            item['quantity'] ?? '1',
            'Rs. ${item['price_per_unit'] ?? '0'}',
          ),
        );
        itemWidgets.add(const SizedBox(height: 12));
      }
      return itemWidgets;
    }
    // Otherwise use the hardcoded items as in your original code
    else {
      return [
        buildItemRow('assests/oninon.png', 'Onion', '1 Kg', 'Rs. 65'),
        const SizedBox(height: 12),
        buildItemRow('assests/potato_png2391.png', 'Cauliflower', '2 Kg', 'Rs. 80'),
        const SizedBox(height: 12),
        buildItemRow('assests/color-capsicum.png', 'Brinjal', '1 Kg', 'Rs. 70'),
        const SizedBox(height: 12),
        buildItemRow('assests/Frame 605.png', 'Carrot', '2 Kg', 'Rs. 120'),
        const SizedBox(height: 12),
        buildItemRow('assests/oninon.png', 'Bottle gourd', '1 Kg', 'Rs. 50'),
      ];
    }
  }

  // Helper method to build item rows
  Widget buildItemRow(String imagePath, String name, String quantity, String price) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: imagePath.startsWith('http')
                  ? NetworkImage(imagePath) as ImageProvider
                  : AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Text(
          quantity,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class DashPainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  DashPainter({
    required this.color,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}