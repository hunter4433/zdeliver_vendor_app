import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentPage2 extends StatefulWidget {
  final double itemsTotal;
  final double discount;
  final double platformFee;
  final double deliveryCharge;
  final double grandTotal;
  final List<dynamic> items;

  const PaymentPage2({
    Key? key,
    required this.itemsTotal,
    required this.discount,
    required this.platformFee,
    required this.deliveryCharge,
    required this.grandTotal,
    required this.items,
  }) : super(key: key);

  @override
  State<PaymentPage2> createState() => _PaymentPage2State();
}

class _PaymentPage2State extends State<PaymentPage2> {
  bool isAcceptCashClicked = false;
  bool showBottomCard = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          if (showBottomCard) {
            setState(() {
              showBottomCard = false;
            });
          }
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button and title
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0, top: 16.0, bottom: 0.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, size: 28),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),

                    // Payment title
                     Padding(
                      padding: EdgeInsets.only(left: 20.0, top: 0.0),
                      child: Text(
                        'Payment',
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Subtitle
                     Padding(
                      padding: EdgeInsets.only(left: 20.0, top: 2.0),
                      child: Text(
                        'wait for customer to make payment',
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 19,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    // Light blue background starts here
                    Container(
                      margin: const EdgeInsets.only(top: 16.0),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0F8FF),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Payment status
                           Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Payment status : Incomplete',
                              style: GoogleFonts.leagueSpartan(
                                fontSize: 20,
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          // Accept Cash button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isAcceptCashClicked = !isAcceptCashClicked;
                                  showBottomCard = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isAcceptCashClicked ? Color(0xFF328616): Colors.white,
                                foregroundColor: isAcceptCashClicked ? Colors.white : Colors.black87,
                                padding: const EdgeInsets.symmetric(vertical: 14.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: const BorderSide(color: Colors.black54),
                                ),
                              ),
                              child:  Text(
                                'Accept Cash',
                                style: GoogleFonts.leagueSpartan(fontSize: 21,fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),

                          // Customer details card
                          Container(
                            margin: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Customer name
                                const Text(
                                  'Customer name',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Kartik Gadade',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Delivery address
                                const Text(
                                  'Cart delivery address',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Kailash boys hostel NIT\nHamirpur,177005, anu , hamirpur',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Date and Time
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            'Date',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '25/03/2025',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            'Time',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '11:30 PM',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
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

                          // Payment details card
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // To pay amount
                                Text(
                                  'To pay : Rs. ${widget.grandTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Bill Details
                                const Text(
                                  'Bill Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Items Total
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Items Total',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      'Rs. ${widget.itemsTotal.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),

                                // Dashed divider
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: CustomPaint(
                                    painter: DashedLinePainter(),
                                    size: Size(MediaQuery.of(context).size.width - 64, 1),
                                  ),
                                ),

                                // Display discount if applicable
                                if (widget.discount > 0) ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Discount',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        '- Rs. ${widget.discount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: CustomPaint(
                                      painter: DashedLinePainter(),
                                      size: Size(MediaQuery.of(context).size.width - 64, 1),
                                    ),
                                  ),
                                ],

                                // Platform fee
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: const [
                                        Text(
                                          'Platform fee',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(Icons.info_outline, size: 16, color: Colors.grey),
                                      ],
                                    ),
                                    Text(
                                      'Rs. ${widget.platformFee.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),

                                // Dashed divider
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: CustomPaint(
                                    painter: DashedLinePainter(),
                                    size: Size(MediaQuery.of(context).size.width - 64, 1),
                                  ),
                                ),

                                // Delivery charge
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: const [
                                        Text(
                                          'Delivery charge',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(Icons.info_outline, size: 16, color: Colors.grey),
                                      ],
                                    ),
                                    Text(
                                      'Rs. ${widget.deliveryCharge.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),

                                // Dashed divider
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: CustomPaint(
                                    painter: DashedLinePainter(),
                                    size: Size(MediaQuery.of(context).size.width - 64, 1),
                                  ),
                                ),

                                // Grand Total
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Grand Total',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Rs. ${widget.grandTotal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Add some space at the bottom to ensure scrollability
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom sliding card
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: showBottomCard ? 0 : -150,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  // Prevent tap from propagating to the parent GestureDetector
                  // This prevents the card from disappearing when clicked on itself
                },
                child: Container(
                  height: 120,
                  padding: const EdgeInsets.symmetric(horizontal: 44),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),

                  child: Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle cash collected button press
                          setState(() {
                            showBottomCard = false;
                            // Update payment status or navigate to next screen here
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3F2E78),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: const Text(
                          'Cash collected',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}