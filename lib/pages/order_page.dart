import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/order_service.dart';
import '../models/Order.dart';
import '../ui/theme/app_theme.dart';
import 'invoice_page.dart';

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
          'Order - ${_order?.orderType == OrderType.takeaway ? 'Takeaway ${_order?.orderNumber}' : 'Table ${_order?.tableNumber}'}',
          style: const TextStyle(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
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
                  ? const Center(
                      child: Text(
                        'Order not found',
                        style: TextStyle(
                          color: AppTheme.textPrimaryColor,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.all(AppTheme.spacingM),
                            children: [
                              // Order status
                              Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppTheme.spacingM),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Status',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: AppTheme.spacingS),
                                      Text(
                                        _order!.status ?? 'Unknown',
                                        style: const TextStyle(
                                          color: AppTheme.textSecondaryColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingM),
                              // Estimated time
                              if (_estimatedTime != null)
                                Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(AppTheme.spacingM),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Estimated Time',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: AppTheme.spacingS),
                                        Text(
                                          '${_estimatedTime!.toStringAsFixed(2)} minutes',
                                          style: const TextStyle(
                                            color: AppTheme.textSecondaryColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: AppTheme.spacingM),
                              // Order details
                              Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppTheme.spacingM),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Order Details',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: AppTheme.spacingS),
                                      Text(
                                        'Type: ${_order!.orderType.name}',
                                        style: const TextStyle(
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                      Text(
                                        'Payment: ${_order!.paymentMethod}',
                                        style: const TextStyle(
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                      if (_order!.seats != null)
                                        Text(
                                          'Seats: ${_order!.seats}',
                                          style: const TextStyle(
                                            color: AppTheme.textSecondaryColor,
                                          ),
                                        ),
                                      if (_order!.orderNumber != null)
                                        Text(
                                          'Order #: ${_order!.orderNumber}',
                                          style: const TextStyle(
                                            color: AppTheme.textSecondaryColor,
                                          ),
                                        ),
                                      if (_order!.tableNumber != null)
                                        Text(
                                          'Table #: ${_order!.tableNumber}',
                                          style: const TextStyle(
                                            color: AppTheme.textSecondaryColor,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingM),
                              // Order items
                              Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppTheme.spacingM),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Items',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: AppTheme.spacingS),
                                      if (_order!.items != null && _order!.items!.isNotEmpty)
                                        ..._order!.items!.map((item) {
                                          return ListTile(
                                            title: Text(
                                              "${item.quantity} x ${item.name}",
                                              style: const TextStyle(
                                                color: AppTheme.textPrimaryColor,
                                              ),
                                            ),
                                            trailing: Text(
                                              '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: AppTheme.primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        })
                                      else
                                        const Text(
                                          'No items in this order',
                                          style: TextStyle(
                                            color: AppTheme.textSecondaryColor,
                                          ),
                                        ),
                                      Divider(color: AppTheme.textSecondaryColor.withOpacity(0.2)),

                                      // Total amount
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
                                            '\$${_order!.totalAmount.toStringAsFixed(2)}',
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
                              ),
                            ],
                          ),
                        ),
                        if (_order!.status?.toLowerCase() == 'ready')
                          Padding(
                            padding: const EdgeInsets.all(AppTheme.spacingM),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InvoicePage(orderId: _order!.id),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.receipt_long),
                                label: const Text('Pick Order'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: AppTheme.surfaceColor,
                                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
    );
  }
}