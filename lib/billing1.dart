import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrs_gorilla_vendor/billing2.dart';

import 'billing.dart';

class PaymentPage extends StatefulWidget {
  final int selectedItemsCount;
  final List<Product> selectedItems;

  const PaymentPage({
    Key? key,
    required this.selectedItemsCount,
    required this.selectedItems
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late List<Map<String, dynamic>> items;

  @override
  void initState() {
    super.initState();
    // Convert Product objects to the format used in PaymentPage
    items = widget.selectedItems.map((product) => {
      'name': product.name ,
      'price': product.price,
      'quantity': product.quantity,
      'image': product.image,
    }).toList();
  }

  double get itemsTotal {
    return items.fold(0, (total, item) => total + (item['price'] * item['quantity']));
  }

  double get discount => 40.0;
  double get platformFee => 8.0;
  double get deliveryCharge => 12.0;

  double get grandTotal => itemsTotal - discount + platformFee + deliveryCharge;

  void updateQuantity(int index, bool isIncrement) {
    setState(() {
      if (isIncrement) {
        items[index]['quantity']++;
      } else if (items[index]['quantity'] > 0) {
        items[index]['quantity']--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F8FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button and title section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0, 0, 20),
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back, size: 30),
                                padding: EdgeInsets.zero,
                                alignment: Alignment.centerLeft,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18.0),
                              child:  Text(
                                'Payment',
                                style: GoogleFonts.roboto(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
                              child:  Text(
                                'Review the order and scan the QR code on consumer side to proceed to payment.',
                                style: GoogleFonts.leagueSpartan(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Selected Items section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            'Selected Items',
                             style: GoogleFonts.leagueSpartan(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                           Text(
                            'Review your Order',
                             style: GoogleFonts.leagueSpartan(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Item list
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            separatorBuilder: (context, index) => const Divider(color: Color(0xFFF0F8FF), height: 25),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final totalItemPrice = item['price'] * item['quantity'];

                              return Row(
                                children: [
                                  // Item image
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        item['image'] != '' ? item['image'] : 'https://cdn.pixabay.com/photo/2016/08/11/08/43/potatoes-1585060_960_720.jpg',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.image,
                                            size: 40,
                                            color: Colors.grey[400],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Item details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'],
                                          style: GoogleFonts.leagueSpartan(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'Rs ${totalItemPrice.toStringAsFixed(0)}',
                                          style: GoogleFonts.leagueSpartan(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Quantity controls
                                  Container(
                                    height: 38,
                                    width: 38,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black87),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.remove, size: 26),
                                      onPressed: () => updateQuantity(index, false),
                                      color: Colors.black,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    child: Text(
                                      '${item['quantity']}',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 38,
                                    width: 38,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF328616),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.add, size: 26),
                                      onPressed: () => updateQuantity(index, true),
                                      color: Colors.white,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Price Card - Separate from vegetables card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                 Text(
                                  'To pay : ',
                                   style: GoogleFonts.leagueSpartan(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Rs. ${grandTotal.toStringAsFixed(0)}',
                                  style: GoogleFonts.leagueSpartan(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Rs ${discount.toStringAsFixed(0)} saved with Gorilla 20',
                            style: GoogleFonts.leagueSpartan(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Color(0xFF328616),
                            ),
                          ),
                          const SizedBox(height: 16),
                           Text(
                            'Bill Details',
                            style: GoogleFonts.leagueSpartan(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Items Total Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Items Total',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Rs. ${itemsTotal.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),

                          // Dashed divider
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: CustomPaint(
                              painter: DashedLinePainter(),
                              size: Size(MediaQuery.of(context).size.width - 32, 1),
                            ),
                          ),

                          // Discounts Row with info icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Discounts',
                                    style: TextStyle(fontSize: 16, color: Color(0xFF328616)),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey,
                                    ),
                                    child: const Icon(
                                      Icons.info,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                'Rs. ${discount.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16, color: Color(0xFF328616)),
                              ),
                            ],
                          ),

                          // Dashed divider
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: CustomPaint(
                              painter: DashedLinePainter(),
                              size: Size(MediaQuery.of(context).size.width - 32, 1),
                            ),
                          ),

                          // Platform fee Row with info icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Platform fee',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey,
                                    ),
                                    child: const Icon(
                                      Icons.info,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                'Rs. ${platformFee.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),

                          // Dashed divider
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: CustomPaint(
                              painter: DashedLinePainter(),
                              size: Size(MediaQuery.of(context).size.width - 32, 1),
                            ),
                          ),

                          // Delivery charge Row with info icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Delivery charge',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey,
                                    ),
                                    child: const Icon(
                                      Icons.info,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                'Rs. ${deliveryCharge.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),

                          // Dashed divider
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: CustomPaint(
                              painter: DashedLinePainter(),
                              size: Size(MediaQuery.of(context).size.width - 32, 1),
                            ),
                          ),

                          // Grand Total Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Grand Total',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Rs. ${grandTotal.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 150), // Add space for the fixed button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Fixed QR code button at the bottom
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 46.0, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.qr_code_scanner, color: Colors.white,size: 30,),
          label:  Text(
            'Scan QR code for payment',
            style: GoogleFonts.leagueSpartan(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3F2E78),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () {
            // Navigate to PaymentPage when QR code button is pressed
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentPage2(
                  itemsTotal: itemsTotal,
                  discount: discount,
                  platformFee: platformFee,
                  deliveryCharge: deliveryCharge,
                  grandTotal: grandTotal,
                  items: items,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Custom painter for dashed line
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5, dashSpace = 3, startX = 0;
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    while (startX < size.width) {
      canvas.drawLine(
          Offset(startX, 0),
          Offset(startX + dashWidth, 0),
          paint
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}