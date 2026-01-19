import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthService {
  static Future<void> saveTokens(String access, String refresh) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('access', access);
    await sp.setString('refresh', refresh);
  }

  static Future<void> clearTokens() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('access');
    await sp.remove('refresh');
  }

  static Future<bool> isLoggedIn() async {
    final sp = await SharedPreferences.getInstance();
    return (sp.getString('access') ?? '').isNotEmpty;
  }

  static Future<String?> login(String username, String password) async {
    final url = Uri.parse('${ApiClient.apiRoot}/token/');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (resp.statusCode == 200) {
      final m = jsonDecode(resp.body) as Map<String, dynamic>;
      await saveTokens(m['access'], m['refresh']);
      return null;
    }
    return 'Login failed: ${resp.body}';
  }

  static Future<String?> register({
    required String username,
    required String password,
    String? email,
    String? displayName,
  }) async {
    final resp = await ApiClient.post('/register/', {
      'username': username,
      'password': password,
      if (email != null && email.isNotEmpty) 'email': email,
      if (displayName != null && displayName.isNotEmpty)
        'display_name': displayName,
    });
    if (resp.statusCode == 201) {
      final m = jsonDecode(resp.body);
      await saveTokens(m['access'], m['refresh']);
      return null;
    }
    return 'Registration failed: ${resp.body}';
  }
}
