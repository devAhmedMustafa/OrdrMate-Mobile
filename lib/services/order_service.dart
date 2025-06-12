import 'dart:convert';
import 'package:ordrmate/utils/ordrmate.api.dart';
import '../models/Branch.dart';
import '../models/Order.dart';
import 'auth_service.dart';
import 'package:flutter/foundation.dart';

class OrderService extends ChangeNotifier {

  final AuthService _authService;

  OrderService(this._authService);

  Future<List<Branch>> getRestaurantBranches(String restaurantId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await OrdrmateApi.get(
        'Branch/restaurant/$restaurantId',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Branch.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load branches');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: '+ e.toString());
    }
  }

  Future<String> placeOrder(Order order) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await OrdrmateApi.post(
        'Order/',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: order.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to place order : ${response.statusCode}');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('orderIntentId') && data.containsKey('redirectUrl')) {
        return OrderIntentResponse.fromJson(data).redirectUrl;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<List<Order>> fetchOrders() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await OrdrmateApi.get(
        'Order/customer',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      }
      else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  Future<Order> fetchOrderDetail(String orderId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await OrdrmateApi.get(
        'Order/detailed/$orderId',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return Order.fromJson(data);
      } else {
        debugPrint('Failed to load order details: ${response.statusCode}');
        throw Exception('Failed to load order details');
      }
    } catch (e) {
      debugPrint('Error fetching order details: $e');
      throw Exception('Error fetching order details');
    }
  }

  Future<double?> fetchEstimatedTime(String branchId, String orderId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await OrdrmateApi.get(
        'Order/branch/$branchId/estimated_time/$orderId',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        // Safely cast to double? to handle potential null from API, and use the correct key
        return data['estimatedTime'] as double?;
      } else {
        debugPrint('Failed to load estimated time: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching estimated time: $e');
      return null;
    }
  }

  Future<OrderInvoice?> fetchOrderInvoice(String orderId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await OrdrmateApi.put(
        'Order/pick/$orderId',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        final dynamic data = json.decode(response.body);
        return OrderInvoice.fromJson(data);
      }
      else if (response.statusCode == 404) {
        debugPrint('Order not found: ${response.statusCode}');
        return null;
      }
      else {
        debugPrint('Failed to load order invoice: ${response.statusCode}');
        throw Exception('Failed to load order invoice');
      }
    } catch (e) {
      debugPrint('Error fetching order invoice: $e');
      throw Exception('Error fetching order invoice');
    }
  }
}

class OrderIntentResponse {
  final String id;
  final String redirectUrl;

  OrderIntentResponse({
    required this.id,
    required this.redirectUrl,
  });

  factory OrderIntentResponse.fromJson(Map<String, dynamic> json) {
    return OrderIntentResponse(
      id: json['orderIntentId'] as String,
      redirectUrl: json['redirectUrl'] as String,
    );
  }
}

class OrderInvoice {
  final String orderId;
  final String orderNumber;
  final String customerName;
  final String restaurantName;
  final String branchAddress;
  final String totalAmount;
  final String paymentMethod;
  final String orderType;
  final String orderDate;
  final String isPaid;
  final List<OrderItem> items;

  OrderInvoice({
    required this.orderId,
    required this.orderNumber,
    required this.customerName,
    required this.restaurantName,
    required this.branchAddress,
    required this.totalAmount,
    required this.paymentMethod,
    required this.orderType,
    required this.orderDate,
    required this.isPaid,
    required this.items,
  });

  factory OrderInvoice.fromJson(Map<String, dynamic> json) {
    return OrderInvoice(
      orderId: json['orderId'] as String,
      orderNumber: json['orderNumber'] as String,
      customerName: json['customerName'] as String,
      restaurantName: json['restaurantName'] as String,
      branchAddress: json['branchAddress'] as String,
      totalAmount: json['totalAmount'] as String,
      paymentMethod: json['paymentMethod'] as String,
      orderType: json['orderType'] as String,
      orderDate: json['orderDate'] as String,
      isPaid: json['isPaid'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}

