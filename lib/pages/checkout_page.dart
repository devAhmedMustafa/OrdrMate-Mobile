import 'package:flutter/material.dart';
import 'package:ordrmate/providers/cart_provider.dart';
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
  String? _error;
  OrderType _orderType = OrderType.takeaway;
  String _paymentMethod = 'cash';
  int _seats = 1;

  Future<void> _placeOrder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orderService = Provider.of<OrderService>(context, listen: false);
      final order = Order(
        id: '', // This will be set by the server
        branchId: widget.selectedBranch.id,
        items: widget.items.map((item) => item.toOrderItem()).toList(),
        createdAt: DateTime.now(),
        orderType: _orderType,
        paymentMethod: _paymentMethod,
      );

      await orderService.placeOrder(order);

      if (mounted) {
        // Clean up the cart after placing the order
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        cartProvider.clearCart(widget.selectedBranch.restaurantId);
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
            onPressed: _isLoading ? () {} : () => _placeOrder(),
            isLoading: _isLoading,
          ),
        ),
      ),
    );
  }
}