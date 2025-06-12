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

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  List<Order> _getReadyOrders() {
    return _orders.where((order) => 
      order.status?.toLowerCase() == 'ready' || 
      order.status?.toLowerCase() == 'delivered'
    ).toList();
  }

  List<Order> _getQueuedOrders() {
    return _orders.where((order) => 
      order.status?.toLowerCase() == 'queued' ||
      order.status?.toLowerCase() == 'inprogress'
    ).toList();
  }

  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'No orders found',
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final statusColor = _getStatusColor(order.status ?? 'unknown');
        return OrderCard(
          order: order,
          statusColor: statusColor,
        );
      },
    );
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

    final readyOrders = _getReadyOrders();
    final queuedOrders = _getQueuedOrders();

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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pending_actions),
                  SizedBox(width: 8),
                  Text('Queued Orders'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline),
                  SizedBox(width: 8),
                  Text('Ready Orders'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: _loadOrders,
            backgroundColor: AppTheme.surfaceColor,
            color: AppTheme.primaryColor,
            child: _buildOrderList(queuedOrders),
          ),
          RefreshIndicator(
            onRefresh: _loadOrders,
            backgroundColor: AppTheme.surfaceColor,
            color: AppTheme.primaryColor,
            child: _buildOrderList(readyOrders),
          ),
        ],
      ),
    );
  }
}