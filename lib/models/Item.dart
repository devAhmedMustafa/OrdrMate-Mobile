
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:ordrmate/utils/ordrmate.api.dart';

class Item {
  final String id;
  final String name;
  final String? description;
  final double price;
  String? imageUrl;
  final String? imageFilename;
  final String category;
  final String restaurantId;

  Item({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.imageFilename,
    required this.category,
    required this.restaurantId,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    var item = Item(
      id: json['id'].toString(),
      name: json['name'] as String,
      description: json['description'] as String?,
      price: double.parse(json['price'].toString()),
      imageFilename: json['imageUrl'] as String?,
      category: json['category'] as String,
      restaurantId: json['restaurantId'].toString(),
    );
    
    if (item.imageFilename != null){
      OrdrmateApi.get('upload/presigned-url/${item.imageFilename}').then((response) {
        if (response.statusCode == 200) {
          final dynamic data = jsonDecode(response.body);

          var url = data['fileUrl'] as String?;
          if (url != null) {
            if (url.contains('localhost') || url.contains('127.0.0.1')) {
              url = url.replaceFirst('localhost', '10.0.2.2').replaceFirst('127.0.0.1', '10.0.2.2');
            }
          }

          item.imageUrl = url;
        } else {
          debugPrint('Error fetching image URL: ${response.statusCode}');
        }
      }).catchError((error) {
        debugPrint('Error fetching image URL: $error');
      });
    }
    
    return item;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageFilename,
      'category': category,
      'restaurantId': restaurantId,
    };
  }
}