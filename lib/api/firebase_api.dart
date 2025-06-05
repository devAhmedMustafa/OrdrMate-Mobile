import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:ordrmate/utils/ordrmate.api.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications(String userId) async {
    await _firebaseMessaging.requestPermission();
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      debugPrint("Firebase Messaging Token: $token");

      final response = await OrdrmateApi.post(
        "Customer/firebase-token",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: {
          "token": token,
          "userId": userId
        }
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