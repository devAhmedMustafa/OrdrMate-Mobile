import 'package:flutter/material.dart';
import 'package:ordrmate/components/payment_webview.dart';
import 'package:ordrmate/enums/payment_methods.dart';
import 'package:ordrmate/providers/cart_provider.dart';
import 'package:ordrmate/services/auth_service.dart';
import 'package:ordrmate/services/restaurant_service.dart';
import 'package:provider/provider.dart';
import '../models/Branch.dart';
import '../models/Order.dart';
import '../services/order_service.dart';
import '../models/CartItem.dart';
import '../ui/components/app_button.dart';
import '../ui/components/app_card.dart';
import '../ui/theme/app_theme.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> items;
  final Branch selectedBranch;

  const CheckoutPage({
    super.key,
    required this.items,
    required this.selectedBranch,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isLoading = false;
  bool _gettingMinWaitingTime = false;

  String? _error;
  OrderType _orderType = OrderType.takeaway;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  int _seats = 1;

  double minWaitingTimeForDineIn = 1.0;
  int minWaitingCountForDineIn = 0;
  int bestTableNumber = 0;

  Future<void> _placeOrder() async {

    if (_orderType == OrderType.dineIn && bestTableNumber == -1) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orderService = Provider.of<OrderService>(context, listen: false);
      final order = Order(
        id: '',
        // This will be set by the server
        branchId: widget.selectedBranch.id,
        items: widget.items.map((item) => item.toOrderItem()).toList(),
        createdAt: DateTime.now(),
        orderType: _orderType,
        paymentMethod: paymentMethodToString(_paymentMethod),
        tableNumber: (_orderType == OrderType.dineIn && bestTableNumber != -1) ? bestTableNumber : null,
      );

      var redirectUrl = await orderService.placeOrder(order);

      if (!mounted) return;

      // Check if redirect URL is not empty (Not cash payment)
      if (redirectUrl.isNotEmpty) {
        final paymentResult = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (context) => PaymentWebView(paymentUrl: redirectUrl),
          ),
        );

        if (paymentResult == null || !paymentResult) {
          setState(() {
            _isLoading = false;
            _error = 'Payment failed or cancelled';
          });
          return;
        }
      }

      // Clean up the cart after placing the order
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.clearCart(widget.selectedBranch.restaurantId);
      Navigator.of(context).pop(true); // Return true to indicate success
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<TableWaitingTimeResponse> _getMinWaitingTime() async {
    setState(() {
      _gettingMinWaitingTime = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final restaurantService = RestaurantService(authService);
      final tableWaiting = await restaurantService.getMinWaitingTimeForFreeTable(
        widget.selectedBranch.id,
        _seats,
      );
      setState(() {
        minWaitingTimeForDineIn = tableWaiting.waitingTime;
        minWaitingCountForDineIn = tableWaiting.waitingCount;
        bestTableNumber = tableWaiting.tableNumber;
      });

      return tableWaiting;
    } catch (e) {

      setState(() {
        _error = e.toString();
      });

      throw Exception('Failed to fetch minimum waiting time: $e');
    }

    finally {
        setState(() {
          _gettingMinWaitingTime = false;
        });
      }
    }

  @override
  void initState() {
    super.initState();
    _getMinWaitingTime().then((waiting){
      setState(() {
        minWaitingTimeForDineIn = waiting.waitingTime;
        minWaitingCountForDineIn = waiting.waitingCount;
        bestTableNumber = waiting.tableNumber;
      });
    }).catchError((error) {
      setState(() {
        _error = error.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(color: AppTheme.textPrimaryColor),
        ),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppTheme.errorColor,
                        size: 48,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Text(
                        'Error: $_error',
                        style: const TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      AppButton(
                        text: 'Retry',
                        onPressed: _placeOrder,
                        icon: Icons.refresh,
                        isSecondary: true,
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  children: [

                    // Order type selection
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Type',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          RadioListTile<OrderType>(
                            title: const Text(
                              'Takeaway',
                              style: TextStyle(color: AppTheme.textPrimaryColor),
                            ),
                            value: OrderType.takeaway,
                            groupValue: _orderType,
                            activeColor: AppTheme.primaryColor,
                            onChanged: (value) {
                              setState(() {
                                _orderType = value!;
                              });
                            },
                          ),
                          RadioListTile<OrderType>(
                            title: const Text(
                              'Dine In',
                              style: TextStyle(color: AppTheme.textPrimaryColor),
                            ),
                            value: OrderType.dineIn,
                            groupValue: _orderType,
                            activeColor: AppTheme.primaryColor,
                            onChanged: (value) {
                              setState(() {
                                _orderType = value!;
                              });
                            },
                          ),
                          if (_orderType == OrderType.dineIn) ...[
                            const SizedBox(height: AppTheme.spacingM),
                            const Text(
                              'Number of Seats',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingS),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (_seats > 1) {
                                      setState(() {
                                        _seats--;
                                        _getMinWaitingTime();
                                      });
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                                Text(
                                  '$_seats',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimaryColor,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _seats++;
                                      _getMinWaitingTime();
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacingM),
                            if (_gettingMinWaitingTime)
                              const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryColor,
                                ),
                              )
                            else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: AppTheme.spacingM),
                                  Text(
                                    '$minWaitingCountForDineIn reservations in queue',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondaryColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                const SizedBox(height: AppTheme.spacingS),
                                Text(
                                  'Estimated waiting time: ${minWaitingTimeForDineIn.ceil()} minutes',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacingS),
                                if (bestTableNumber == -1)
                                  const Text(
                                    'No free tables available at the moment',
                                    style: TextStyle(
                                      color: AppTheme.errorColor,
                                      fontSize: 14,
                                    ),
                                  )
                                else
                                  Text(
                                    'Best available table number: $bestTableNumber',
                                    style: const TextStyle(
                                      color: AppTheme.textPrimaryColor,
                                      fontSize: 14,
                                    ),
                                  ),

                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingM),

                    // Payment method selection

                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Method',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          RadioListTile<PaymentMethod>(
                            title: const Text(
                              'Cash',
                              style: TextStyle(color: AppTheme.textPrimaryColor),
                            ),
                            value: PaymentMethod.cash,
                            groupValue: _paymentMethod,
                            activeColor: AppTheme.primaryColor,
                            onChanged: (value) {
                              setState(() {
                                _paymentMethod = value!;
                              });
                            },
                          ),
                          RadioListTile<PaymentMethod>(
                            title: const Text(
                              'Credit/Debit Card',
                              style: TextStyle(color: AppTheme.textPrimaryColor),
                            ),
                            value: PaymentMethod.card,
                            groupValue: _paymentMethod,
                            activeColor: AppTheme.primaryColor,
                            onChanged: (value) {
                              setState(() {
                                _paymentMethod = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingM),

                    // Order summary
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Summary',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          ...widget.items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimaryColor,
                                      ),
                                    ),
                                    Text(
                                      '${item.quantity} x \$${item.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          const Divider(color: AppTheme.textSecondaryColor),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                              Text(
                                '\$${widget.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity)).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    // Branch information
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pickup Location',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                          Text(
                            widget.selectedBranch.restaurantName,
                            style: const TextStyle(
                              color: AppTheme.textPrimaryColor,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.selectedBranch.address,
                            style: const TextStyle(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: AppButton(
            text: 'Place Order',
            icon: Icons.check_circle_outline,
            onPressed: _isLoading ? () {} : () => _placeOrder(),
            isLoading: _isLoading,
          ),
        ),
      ),
    );
  }
}