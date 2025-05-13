import 'package:flutter/material.dart';
import 'package:mrs_gorilla_vendor/order_history2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'bottom_nav.dart';

class OrderHistoryPage2 extends StatefulWidget {
  const OrderHistoryPage2({Key? key}) : super(key: key);

  @override
  State<OrderHistoryPage2> createState() => _OrderHistoryPage2State();
}

class _OrderHistoryPage2State extends State<OrderHistoryPage2> {
  bool isExpanded = false;
  bool isSortDropdownOpen = false;
  String selectedSortOption = 'Date - Descending'; // Default selected option
  bool isLoading = true;
  List<dynamic> orders = [];
  String errorMessage = '';

  final List<String> sortOptions = [
    'Alphabetically',
    'Date - Ascending',
    'Date - Descending',
    'Order size - price - ascending',
    'Order size - price - descending',
    'Order size - Items - ascending',
    'Order size - Items - descending',
  ];
  List<String> selectedSortOptions = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://3.111.39.222/api/v1/request/vendor/1'),
        headers: {
          'Content-Type': 'application/json',
          // Add any required authorization headers here
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            orders = data['requests'];
            isLoading = false;
          });
          print(orders);
        } else {
          setState(() {
            errorMessage = 'Failed to load orders';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F8FF),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button and title
                    Container(
                      color: Colors.white,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // IconButton(
                            //   icon: const Icon(Icons.arrow_back, size: 30),
                            //   padding: EdgeInsets.zero,
                            //   alignment: Alignment.centerLeft,
                            //   onPressed: () {
                            //     Navigator.pushReplacement(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) => MainScreen(
                            //           initialIndex: 2, // Or any specific index you want
                            //         ),
                            //       ),
                            //     );
                            //   },
                            // ),
                            const SizedBox(height: 8),
                            const Text(
                              'Order history',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Check your all past orders you delivered',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Search bar
                    Container(
                      color: Color(0xFFF0F8FF),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search Customer name',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade100, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                    ),

                    // Sort and Filter buttons
                    Container(
                      color: Color(0xFFF0F8FF),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSortDropdownOpen = !isSortDropdownOpen;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.sort),
                                            SizedBox(width: 8),
                                            Text(
                                              'Sort by',
                                              style: TextStyle(fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        isSortDropdownOpen
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.filter_alt),
                                          SizedBox(width: 8),
                                          Text(
                                            'Filter by',
                                            style: TextStyle(fontSize: 16),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Loading indicator or error message
                    if (isLoading)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: Color(0xFF328616)),
                        ),
                      )
                    else if (errorMessage.isNotEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            errorMessage,
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ),
                      )
                    else if (orders.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'No orders found',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                      else
                      // Order cards - We're mapping through the orders from the API
                        ...orders.map((order) => _buildOrderCard(order)).toList(),

                    // Add bottom padding to ensure there's space if dropdown is open
                    SizedBox(height: isSortDropdownOpen ? 250 : 20),
                  ],
                ),
              ),
            ),
          ),

          // Sort dropdown overlay - positioned with high z-index
          if (isSortDropdownOpen)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  isSortDropdownOpen = false;
                });
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                  Positioned(
                    top: 330,
                    left: 16,
                    right: MediaQuery.of(context).size.width / 4,
                    child: GestureDetector(
                      onTap: () {}, // Prevent taps on the dropdown from closing it
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: Column(
                            children: sortOptions.map((option) {
                              final isSelected = selectedSortOptions.contains(option);
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedSortOptions.remove(option);
                                    } else {
                                      selectedSortOptions.add(option);
                                    }
                                    // Dropdown stays open after selection
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        child: isSelected
                                            ? Container(
                                          margin: const EdgeInsets.all(3),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black,
                                          ),
                                        )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Method to build an order card for each order
  Widget _buildOrderCard(dynamic order) {
    // Get the items preview from the order
    List<dynamic> itemsPreview = order['items_preview'] ?? [];
    int totalLength= order['total_items'] ?? '';
    print('mohit here');
    print(totalLength);
    // Track if this specific order is expanded
    bool isThisOrderExpanded = false;

    // Function to toggle expansion for this specific order
    void toggleExpansion() {
      setState(() {
        isThisOrderExpanded = !isThisOrderExpanded;
      });
    }

    return Container(
      color: Color(0xFFF0F8FF),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer name and address
                Text(
                  order['user_name'] ?? 'Unknown Customer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Address: ${order['order_address'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),

                // Order details heading
                const Text(
                  'Order details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Display first two items or all if expanded
                if (itemsPreview.isNotEmpty)
                  Column(
                    children: [
                      // Always show the first item
                      _buildOrderItem(
                        itemsPreview[0]['item_name'] ?? 'Unknown Item',
                        'Rs ${itemsPreview[0]['price_per_unit'] ?? '0'}',
                        '${itemsPreview[0]['quantity'] ?? '0'} Kg',
                        itemsPreview[0]['image_url'],
                      ),

                      if (itemsPreview.length > 1) ...[
                        const Divider(),
                        // Show the second item
                        _buildOrderItem(
                          itemsPreview[1]['item_name'] ?? 'Unknown Item',
                          'Rs ${itemsPreview[1]['price_per_unit'] ?? '0'}',
                          '${itemsPreview[1]['quantity'] ?? '0'} Kg',
                          itemsPreview[1]['image_url'],
                        ),
                      ],


                      // Show more items if expanded
                      if (isThisOrderExpanded && totalLength > 2)
                        ...List.generate(itemsPreview.length - 2, (index) {
                          final itemIndex = index + 2;
                          if (itemIndex < itemsPreview.length) {
                            return Column(
                              children: [
                                const Divider(),
                                _buildOrderItem(
                                  itemsPreview[itemIndex]['item_name'] ?? 'Unknown Item',
                                  'Rs ${itemsPreview[itemIndex]['price_per_unit'] ?? '0'}',
                                  '${itemsPreview[itemIndex]['quantity'] ?? '0'} Kg',
                                  itemsPreview[itemIndex]['image_url'],
                                ),
                              ],
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        }),
                    ],
                  )
                else
                  Text('No items found in this order'),

                // Show "+X more" button if there are more than 2 items and not expanded
                if (totalLength > 2 && !isThisOrderExpanded)
                  GestureDetector(
                    onTap: toggleExpansion,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      child: Text(
                        '+${totalLength - 2} more',
                        style: TextStyle(
                          color: Color(0xFF328616),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                // Show less button when expanded
                if (isThisOrderExpanded && totalLength > 2)
                  GestureDetector(
                    onTap: toggleExpansion,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      child: const Text(
                        'Show less',
                        style: TextStyle(
                          color: Color(0xFF328616),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                // View full order button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsPage1(
                          orderId: order['id'],
                          // orderData: order,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF328616),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'View full order',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(String name, String price, String quantity, String? imageUrl) {
    return Row(
      children: [
        // Image - from API URL or asset as fallback
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/potato_png2391.png',
                  fit: BoxFit.cover,
                );
              },
            )
                : Image.asset(
              'assets/potato_png2391.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Item details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        // Quantity
        Text(
          quantity,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}