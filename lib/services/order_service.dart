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
      } else {
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