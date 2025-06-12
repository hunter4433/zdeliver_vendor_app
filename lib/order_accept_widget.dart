import 'package:flutter/material.dart';

class OrderAcceptWidget extends StatefulWidget {
  final Map<String, dynamic> orderDetails;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final int secondsLeft;
  final double progress;

  const OrderAcceptWidget({
    super.key,
    required this.orderDetails,
    required this.onAccept,
    required this.onDecline,
    required this.secondsLeft,
    required this.progress,
  });

  @override
  State<OrderAcceptWidget> createState() => _OrderAcceptWidgetState();
}

class _OrderAcceptWidgetState extends State<OrderAcceptWidget>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late Animation<Offset> _cardOffsetAnimation;
  bool addressLoading = true;

  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonColorAnimation;

  String? savedAddress;

  @override
  void initState() {
    super.initState();

    // Card slide-up animation
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start from bottom
      end: Offset.zero, // End at original position
    ).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOutQuart,
      ),
    );

    // Button color animation
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 47000),
      vsync: this,
    );

    _buttonColorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_buttonAnimationController);

    // Start card animation as soon as widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cardAnimationController.forward().then((_) {
        // Start button animation after card animation completes
        _buttonAnimationController.forward();
      });
    });
    print(
      'OrderAcceptWidget initialized with order details: ${widget.orderDetails}',
    );
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure the widget is still mounted before accessing widget properties
    if (!mounted) return const SizedBox.shrink();
    return SlideTransition(
      position: _cardOffsetAnimation,
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.fromLTRB(8, 0, 8, 80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        elevation: 8,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location: ',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 25),
                  Expanded(
                    child: Text(
                      widget.orderDetails['data']['address'] ??
                          'Unknown location',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Order type: ',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 6),
                  Text(
                    widget.orderDetails['data']['cart_type'] ??
                        'Unknown cart type',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  // Text(
                  //   'Trip fare: ',
                  //   style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  // ),
                  // SizedBox(width: 26),
                  Text(
                    widget.secondsLeft.toString() + ' seconds left',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 24),
              // Animated button
              AnimatedBuilder(
                animation: _buttonColorAnimation,
                builder: (context, child) {
                  return ClipRect(
                    child: InkWell(
                      onTap: () => widget.onAccept(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Container(
                          color: Colors.white,
                          width: double.infinity,
                          height: 50,
                          child: Stack(
                            children: [
                              // Base button
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(0xFF49C71F),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              // Animated darker overlay
                              Container(
                                width:
                                    MediaQuery.of(context).size.width *
                                    _buttonColorAnimation.value,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(0xFF328616),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                    topRight:
                                        _buttonColorAnimation.value == 1.0
                                            ? Radius.circular(12)
                                            : Radius.zero,
                                    bottomRight:
                                        _buttonColorAnimation.value == 1.0
                                            ? Radius.circular(12)
                                            : Radius.zero,
                                  ),
                                ),
                              ),
                              // Button text
                              Center(
                                child: Text(
                                  'Accept',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 2),
              // Decline button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: ElevatedButton(
                  onPressed: widget.onDecline,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,

                    elevation: 0,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Decline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
