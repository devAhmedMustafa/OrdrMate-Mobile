import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/order_service.dart';
import '../ui/theme/app_theme.dart';

class InvoicePage extends StatefulWidget {
  final String orderId;

  const InvoicePage({
    super.key,
    required this.orderId,
  });

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  bool _isLoading = true;
  String? _error;
  OrderInvoice? _invoice;

  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orderService = Provider.of<OrderService>(context, listen: false);
      final invoice = await orderService.fetchOrderInvoice(widget.orderId);

      setState(() {
        _invoice = invoice;
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
        title: const Text(
          'Order Invoice',
          style: TextStyle(
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
                      Text(
                        'Error: $_error',
                        style: const TextStyle(
                          color: AppTheme.textPrimaryColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      ElevatedButton(
                        onPressed: _loadInvoice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: AppTheme.surfaceColor,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _invoice == null
                  ? const Center(
                      child: Text(
                        'Order not paid',
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Restaurant and Order Info
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
                                  Text(
                                    _invoice!.restaurantName,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingS),
                                  Text(
                                    _invoice!.branchAddress,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingM),
                                  Text(
                                    'Order #${_invoice!.orderNumber}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingS),
                                  Text(
                                    'Date: ${_invoice!.orderDate}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          // Customer Info
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
                                    'Customer Information',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingS),
                                  Text(
                                    _invoice!.customerName,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          // Order Items
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
                                    'Order Items',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingS),
                                  ..._invoice!.items.map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "${item.quantity} x ${item.name}",
                                              style: const TextStyle(
                                                color: AppTheme.textPrimaryColor,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  Divider(color: AppTheme.textSecondaryColor.withOpacity(0.2)),
                                  // Total
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
                                        _invoice!.totalAmount,
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
                          const SizedBox(height: AppTheme.spacingM),
                          // Payment Info
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
                                    'Payment Information',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingS),
                                  Text(
                                    'Method: ${_invoice!.paymentMethod}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                  Text(
                                    'Status: ${_invoice!.isPaid}',
                                    style: TextStyle(
                                      color: _invoice!.isPaid == "Paid"
                                          ? const Color(0xFF4CAF50)
                                          : AppTheme.secondaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
} 