import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:ordrmate/utils/ordrmate.api.dart';

class Restaurant {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? description;
  final String? logoUrl;
  final String? coverImageUrl;
  String? logoImage;
  String? coverImage;

  Restaurant({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.description,
    this.logoUrl,
    this.coverImageUrl,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    var restaurant = Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
    );

    if (restaurant.logoUrl != null) {
      OrdrmateApi.get('upload/presigned-url/${restaurant.logoUrl}').then((
          response) {
        if (response.statusCode == 200) {
          final dynamic data = jsonDecode(response.body);
          var url = data['fileUrl'] as String?;
          if (url != null) {
            if (url.contains('localhost') || url.contains('127.0.0.1')) {
              url = url.replaceFirst('localhost', '10.0.2.2').replaceFirst(
                  '127.0.0.1', '10.0.2.2');
            }
          }

          restaurant.logoImage = url;
        } else {
          debugPrint('Error fetching logo image URL: ${response.statusCode}');
        }
      }).catchError((error) {
        debugPrint('Error fetching logo image URL: $error');
      });
    }

    if (restaurant.coverImageUrl != null) {
      OrdrmateApi.get('upload/presigned-url/${restaurant.coverImageUrl}').then((
          response) {
        if (response.statusCode == 200) {
          final dynamic data = jsonDecode(response.body);
          var url = data['fileUrl'] as String?;
          if (url != null) {
            if (url.contains('localhost') || url.contains('127.0.0.1')) {
              url = url.replaceFirst('localhost', '10.0.2.2').replaceFirst(
                  '127.0.0.1', '10.0.2.2');
            }
          }

          restaurant.coverImage = url;
        } else {
          debugPrint('Error fetching logo image URL: ${response.statusCode}');
        }
      }).catchError((error) {
        debugPrint('Error fetching logo image URL: $error');
      });
    }

    return restaurant;
  }
}