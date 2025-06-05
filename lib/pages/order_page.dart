import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/order_service.dart';
import '../models/Order.dart';
import '../ui/theme/app_theme.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  Order? _order;
  double? _estimatedTime;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orderService = Provider.of<OrderService>(context, listen: false);
      final order = await orderService.fetchOrderDetail(widget.orderId);
      final estimatedTime = await orderService.fetchEstimatedTime(order.branchId, widget.orderId);

      setState(() {
        _order = order;
        _estimatedTime = estimatedTime;
        _isLoading = false;
      });
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
        title: Text(
          'Order #${widget.orderId}',
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppTheme.errorColor,
                        size: 48,
                      ),
                      SizedBox(height: AppTheme.spacingM),
                      Text(
                        'Error: $_error',
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppTheme.spacingL),
                      ElevatedButton.icon(
                        onPressed: _loadOrderDetails,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: AppTheme.surfaceColor,
                        ),
                      ),
                    ],
                  ),
                )
              : _order == null
                  ? Center(
                      child: Text(
                        'Order not found',
                        style: TextStyle(
                          color: AppTheme.textPrimaryColor,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.all(AppTheme.spacingM),
                      children: [
                        // Order status
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(AppTheme.spacingM),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimaryColor,
                                  ),
                                ),
                                SizedBox(height: AppTheme.spacingS),
                                Text(
                                  _order!.status ?? 'Unknown',
                                  style: TextStyle(
                                    color: AppTheme.textSecondaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: AppTheme.spacingM),
                        // Estimated time
                        if (_estimatedTime != null)
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(AppTheme.spacingM),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Estimated Time',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                  SizedBox(height: AppTheme.spacingS),
                                  Text(
                                    '${_estimatedTime!.toStringAsFixed(2)} minutes',
                                    style: TextStyle(
                                      color: AppTheme.textSecondaryColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SizedBox(height: AppTheme.spacingM),
                        // Order type and payment
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(AppTheme.spacingM),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order Details',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimaryColor,
                                  ),
                                ),
                                SizedBox(height: AppTheme.spacingS),
                                Text(
                                  'Type: ${_order!.orderType.name}',
                                  style: TextStyle(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                                Text(
                                  'Payment: ${_order!.paymentMethod}',
                                  style: TextStyle(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                                if (_order!.seats != null)
                                  Text(
                                    'Seats: ${_order!.seats}',
                                    style: TextStyle(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                if (_order!.orderNumber != null)
                                  Text(
                                    'Order #: ${_order!.orderNumber}',
                                    style: TextStyle(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                if (_order!.tableNumber != null)
                                  Text(
                                    'Table #: ${_order!.tableNumber}',
                                    style: TextStyle(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: AppTheme.spacingM),
                        // Order items
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(AppTheme.spacingM),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Items',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimaryColor,
                                  ),
                                ),
                                SizedBox(height: AppTheme.spacingS),
                                if (_order!.items != null && _order!.items!.isNotEmpty)
                                  ..._order!.items!.map((item) {
                                    return ListTile(
                                      title: Text(
                                        "${item.quantity} x ${item.name}",
                                        style: TextStyle(
                                          color: AppTheme.textPrimaryColor,
                                        ),
                                      ),
                                      trailing: Text(
                                        '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  })
                                else
                                  Text(
                                    'No items in this order',
                                    style: TextStyle(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                Divider(color: AppTheme.textSecondaryColor.withOpacity(0.2)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimaryColor,
                                      ),
                                    ),
                                    Text(
                                      '\$${_order!.totalAmount.toStringAsFixed(2)}',
                                      style: TextStyle(
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
                        ),
                      ],
                    ),
    );
  }
}