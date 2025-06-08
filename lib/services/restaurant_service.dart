import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:ordrmate/models/Branch.dart';
import 'package:ordrmate/models/Item.dart';
import 'package:ordrmate/models/Restaurant.dart';
import 'package:ordrmate/models/Category.dart';
import 'package:ordrmate/services/auth_service.dart';
import 'package:ordrmate/utils/ordrmate.api.dart';

class RestaurantService {

  final AuthService _authService;

  RestaurantService(this._authService);

  Future<List<Branch>> getAllBranches() async {
    final response = await OrdrmateApi.get('Branch/all');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((branch) => Branch.fromJson(branch)).toList();
    } else {
      throw Exception('Failed to load branches');
    }
  }

  Future<Restaurant> getRestaurantDetails(String restaurantId) async {
    try {
      final response = await OrdrmateApi.get('Restaurant/$restaurantId');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Restaurant.fromJson(jsonData);
      } else {
        throw Exception('Failed to load restaurant details');
      }
    } catch (e) {
      throw Exception('Error fetching restaurant details: $e');
    }
  }

  Future<BranchInfo> getBranchInfo(String branchId) async {
    try {
      final response = await OrdrmateApi.get('Branch/info/$branchId');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return BranchInfo.fromJson(jsonData);
      } else {
        throw Exception('Failed to load branch info');
      }
    } catch (e) {
      throw Exception('Error fetching branch info: $e');
    }
  }

  Future<List<Item>> getRestaurantItems(String restaurantId) async {
    try {
      final response = await OrdrmateApi.get('Item/restaurant/$restaurantId');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Item.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load restaurant items');
      }
    } catch (e) {
      throw Exception('Error fetching restaurant items: $e');
    }
  }

  Future<List<Category>> getRestaurantCategories(String restaurantId) async {
    try {
      final response = await OrdrmateApi.get('Restaurant/categories/$restaurantId');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((category) => Category.fromJson(category)).toList();
      } else {
        throw Exception('Failed to load restaurant categories');
      }
    } catch (e) {
      throw Exception('Error fetching restaurant categories: $e');
    }
  }

  Future<TableWaitingTimeResponse> getMinWaitingTimeForFreeTable(String branchId, int seats) async {
    try {
      final token = await _authService.getToken();
      final response = await OrdrmateApi.get('Table/min_waiting_time/$branchId/$seats', headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final tableWaitingTime = TableWaitingTimeResponse.fromJson(jsonData);
        return tableWaitingTime;
      } else {
        throw Exception('Failed to load minimum waiting time for free table');
      }
    } catch (e) {
      throw Exception('Error fetching minimum waiting time for free table: $e');
    }
  }

}

class TableWaitingTimeResponse {
  final int tableNumber;
  final double waitingTime;
  final int waitingCount;

  TableWaitingTimeResponse({
    required this.tableNumber,
    required this.waitingCount,
    required this.waitingTime,
  });

  factory TableWaitingTimeResponse.fromJson(Map<String, dynamic> json) {
    return TableWaitingTimeResponse(
      tableNumber: json['tableNumber'] as int,
      waitingCount: json['waitingCount'] as int,
      waitingTime: json['waitingTime'] as double,
    );
  }
}