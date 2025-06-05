
import 'package:flutter/cupertino.dart';
import 'package:ordrmate/models/Item.dart';

enum OrderType {
  dineIn(0),
  takeaway(1);

  final int value;
  const OrderType(this.value);

  String get name {
    switch (this) {
      case OrderType.dineIn:
        return 'DineIn';
      case OrderType.takeaway:
        return 'Takeaway';
    }
  }

  static OrderType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'dinein':
        return OrderType.dineIn;
      case 'takeaway':
        return OrderType.takeaway;
      default:
        throw ArgumentError('Invalid order type: $value');
    }
  }
}

class OrderItem {
  final String itemId;
  final String name;
  final double price;
  final int quantity;
  final Item? item;

  OrderItem({
    required this.itemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.item,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemId: json['itemId'] as String,
      name: json['item']['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      item: json['item'] != null
          ? Item.fromJson(json['item'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Order {
  final String id;
  final String branchId;
  final List<OrderItem>? items;
  final String? status;
  final DateTime createdAt;
  final OrderType orderType;
  final String paymentMethod;
  final int? seats;
  final String? restaurantName;
  final bool isPaid;
  final int? orderNumber;
  final int? tableNumber;
  final double totalAmount;

  Order({
    required this.id,
    required this.branchId,
    required this.createdAt,
    required this.orderType,
    required this.paymentMethod,
    this.status,
    this.items,
    this.seats,
    this.restaurantName,
    this.isPaid = false,
    this.orderNumber,
    this.tableNumber,
    double? totalAmount,
  }) : totalAmount = totalAmount ?? items?.fold(0.0, (sum, item) => sum! + (item.price * item.quantity)) ?? 0.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branchId': branchId,
      'items': items?.map((item) => item.toJson()).toList(),
      'orderType': orderType.value,
      'paymentMethod': paymentMethod,
      'seats': seats,
      'totalAmount': totalAmount,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['orderId'] as String,
      branchId: json['branchId'] as String,
      status: json['orderStatus'] as String,
      createdAt: DateTime.parse(json['orderDate'] as String),
      orderType: OrderType.fromString(
        (json['orderType'] as String).toLowerCase()
      ),
      items: (json['orderItems'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      paymentMethod: json['paymentMethod'] as String,
      seats: json['seats'] as int?,
      restaurantName: json['restaurantName'] as String?,
      isPaid: json['isPaid'] as bool? ?? false,
      orderNumber: json['orderNumber'] as int?,
      tableNumber: json['tableNumber'] as int?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
    );
  }
}