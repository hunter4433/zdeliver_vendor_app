import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'billing1.dart';
import 'bottom_nav.dart';

class CheckoutPage44 extends StatefulWidget {
  const CheckoutPage44({Key? key}) : super(key: key);

  @override
  _CheckoutPage44State createState() => _CheckoutPage44State();
}

class _CheckoutPage44State extends State<CheckoutPage44> {
  List<Product> products = [];
  bool isLoading = true;
  String errorMessage = '';
  int selectedItemsCount = 0;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('http://3.111.39.222/api/cart/vendor/1/items'),
        headers: {
          'Content-Type': 'application/json',
          // Add any other required headers
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['items'] != null) {
          final items = jsonData['items'] as List;

          setState(() {
            products = items.map((item) => Product(
              id: item['id'],
              name: item['name'],
              price: double.tryParse(item['price_per_unit'].toString()) ?? 0.0,
              image: item['image_url'] ?? '',
            )).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'No items found';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load products: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F8FF),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(115), // Increased height further
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0, // Shadow at the bottom
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(22, 16, 22, 8), // Padding on all sides
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Checkout',
                    style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2), // More space between heading and subheading
                  Text(
                    'Create bill of the items bought and scan the QR of consumer for the full payment',
                    style: GoogleFonts.leagueSpartan(
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                      fontSize: 18, // Keeping original font size
                    ),
                    maxLines: 3, // Allow up to 3 lines to ensure full visibility
                  ),
                ],
              ),
            ),
          ),
          toolbarHeight: 100, // Match the PreferredSize height
        ),
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            children: [

              Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            'Select Items',
                            style: GoogleFonts.leagueSpartan(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Select Items and quantity bought by consumer',
                            style: GoogleFonts.leagueSpartan(
                              fontSize: 18,fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Product list
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              // Product image
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    products[index].image,
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
                              const SizedBox(width: 16),
                              // Product details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      products[index].name,
                                      style: GoogleFonts.leagueSpartan(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Rs ${products[index].price.toInt()}/',
                                            style: GoogleFonts.leagueSpartan(
                                              fontSize: 20,fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Kg',
                                            style: GoogleFonts.leagueSpartan(
                                              fontSize: 20,fontWeight: FontWeight.w500,
                                              color: Colors.orange[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Add button
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    if (products[index].quantity == 0) {
                                      products[index].quantity = 1;
                                      selectedItemsCount++;
                                    } else {
                                      products[index].quantity = 0;
                                      selectedItemsCount--;
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF2F2F2F)
                                  ,
                                  minimumSize: const Size(80, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  products[index].quantity > 0 ? 'Added' : 'Add',
                                  style: GoogleFonts.leagueSpartan(fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        child: ElevatedButton(
          onPressed: selectedItemsCount > 0
              ? () {
            // Filter only selected products (quantity > 0)
            List<Product> selectedProducts = products
                .where((product) => product.quantity > 0)
                .toList();

            // Navigate to the payment page with selected products
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PaymentPage(
                  selectedItemsCount: selectedItemsCount,
                  selectedItems: selectedProducts,
                ),
              ),
            );
          }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: Colors.white, width: 2),
            ),
            minimumSize: const Size(double.infinity, 64),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$selectedItemsCount ${selectedItemsCount == 1 ? 'item' : 'items'} added',
                style: GoogleFonts.leagueSpartan(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                   Text(
                    'View order/payment',
                    style: GoogleFonts.leagueSpartan(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Product {
  final int id;
  final String name;
  final double price;
  final String image;
  int quantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 0,
  });
}