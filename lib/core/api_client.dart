import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'https://ranked-0xtx.onrender.com';
  static const String apiRoot = '$baseUrl/accounts/api';

  static Future<String?> _getAccess() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString('access');
  }

  static Future<Map<String, String>> _headers({bool json = true}) async {
    final token = await _getAccess();
    final h = <String, String>{};
    if (json) h['Content-Type'] = 'application/json';
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  static Future<http.Response> get(String path) async {
    final url = Uri.parse('$apiRoot$path');
    return http.get(url, headers: await _headers(json: false));
  }

  static Future<http.Response> post(
      String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$apiRoot$path');
    return http.post(url, headers: await _headers(), body: jsonEncode(body));
  }
}
