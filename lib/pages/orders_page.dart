import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/order_service.dart';
import '../models/Order.dart';
import '../components/order_card.dart';
import '../ui/theme/app_theme.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orderService = Provider.of<OrderService>(context, listen: false);
      final orders = await orderService.fetchOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppTheme.secondaryColor; // Light Orange
      case 'confirmed':
        return const Color(0xFF4CAF50); // Green
      case 'preparing':
        return const Color(0xFF2196F3); // Blue
      case 'ready':
        return AppTheme.primaryColor; // Purple
      case 'delivered':
        return const Color(0xFF4CAF50); // Green
      case 'cancelled':
        return AppTheme.errorColor; // Red
      default:
        return AppTheme.primaryColor; // Default purple
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: $_error',
                style: TextStyle(
                  color: AppTheme.textPrimaryColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              ElevatedButton(
                onPressed: _loadOrders,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.surfaceColor,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_orders.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Text(
            'No orders found',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Orders',
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        backgroundColor: AppTheme.surfaceColor,
        color: AppTheme.primaryColor,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          itemCount: _orders.length,
          itemBuilder: (context, index) {
            final order = _orders[index];
            final statusColor = _getStatusColor(order.status ?? 'unknown');

            return OrderCard(
              order: order,
              statusColor: statusColor,
            );
          },
        ),
      ),
    );
  }
}