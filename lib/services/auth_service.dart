import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ordrmate/api/firebase_api.dart';
import 'package:ordrmate/utils/ordrmate.api.dart';

class AuthService with ChangeNotifier {

  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '95702205905-fr389s3p13uah303bmlufajpp42f1nuq.apps.googleusercontent.com',
    scopes: [
      'email',
      'profile'
    ]
  );

  // Flutter Secure Storage instance
  final _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool _isAuthenticated = false;

  AuthService(statusController);

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  Future<Map<String, dynamic>?> signInWithGoogle() async {

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception("Google sign-in cancelled.");
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception("Google sign-in failed: No ID token.");
      }

      final response = await OrdrmateApi.post(
        "customer",
        headers: {"Content-Type": "application/json",},
        body: {'idToken': idToken},
      );

      if (response.statusCode == 200){
        final data = jsonDecode(response.body);

        final String? token = data['token'];
        final String? userId = data['userId'];
        final String? email = data['email'];

        if (token == null || userId == null || email == null) {
          throw Exception("Google sign-in failed: Invalid response.");
        }

        if (kReleaseMode) {
          await FirebaseApi().initNotifications(userId);
        }

        await _storage.write(key: 'auth_token', value: token);
        await _storage.write(key: 'user_id', value: userId);
        await _storage.write(key: 'email', value: email);


        _isAuthenticated = true;

        return data;
      } else {
        throw Exception("Google sign-in failed: ${response.statusCode} ${response.reasonPhrase}");
      }

    }
    catch(e) {
      if (kDebugMode) {
        print("Error during Google sign-in: $e");
      }
      rethrow;
    }
  }

  Future<void> signOut() async {

    try {
      await _googleSignIn.signOut();
      await _storage.deleteAll();

      _isAuthenticated = false;

    } catch (e) {
      if (kDebugMode) {
        print("Error during sign-out: $e");
      }
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: 'auth_token');
    } catch (e) {
      if (kDebugMode) {
        print("Error reading token from storage: $e");
      }
      return null;
    }
  }

  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: 'user_id');
    } catch (e) {
      if (kDebugMode) {
        print("Error reading user ID from storage: $e");
      }
      return null;
    }
  }

  Future<String?> getEmail() async {
    try {
      return await _storage.read(key: 'email');
    } catch (e) {
      debugPrint("Error reading email from storage: $e");
      return null;
    }
  }

  Future<void> checkAuthStatus() async {

    try {
      final token = await getToken();
      if (token != null) {
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
        debugPrint("Error checking authentication status: $e");
    }
  }

}