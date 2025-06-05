import "package:http/http.dart" as http;
import "package:flutter/foundation.dart";
import 'dart:convert';

class OrdrmateApi {

  static const String _baseUrl = kReleaseMode
      ? "https://ordrmate.starplusgames.com/api"
      : "http://10.0.2.2:5126/api";

  static Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    final uri = Uri.parse("$_baseUrl/$endpoint");
    return await http.get(uri, headers: headers);
  }

  static Future<http.Response> post(String endpoint, {Map<String, String>? headers, Object? body}) async {
    final uri = Uri.parse("$_baseUrl/$endpoint");
    return await http.post(uri, headers: headers, body: jsonEncode(body));
  }

}