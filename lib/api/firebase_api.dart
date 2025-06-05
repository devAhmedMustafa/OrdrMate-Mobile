import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final String _baseUrl = "http://10.0.2.2:5126/api";

  Future<void> initNotifications(String userId) async {
    await _firebaseMessaging.requestPermission();
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      debugPrint("Firebase Messaging Token: $token");

      final response = await http.post(
        Uri.parse("$_baseUrl/Customer/firebase-token"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "token": token,
          "userId": userId
        })
      );

      if (response.statusCode == 200) {
        debugPrint("Firebase Messaging Token sent successfully");
      } else {
        debugPrint("Failed to send Firebase Messaging Token: ${response.statusCode}");
      }

    } else {
      debugPrint("Failed to get Firebase Messaging Token");
    }
  }
}