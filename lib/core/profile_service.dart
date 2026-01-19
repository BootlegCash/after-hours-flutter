import 'dart:convert';
import 'api_client.dart';

class ProfileService {
  static Future<Map<String, dynamic>> me() async {
    final r = await ApiClient.get('/profile/');
    if (r.statusCode != 200) {
      throw Exception('profile failed: ${r.statusCode} ${r.body}');
    }
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> friendProfile(String username) async {
    final r = await ApiClient.get('/friends/$username/');
    if (r.statusCode != 200) {
      throw Exception('friend profile failed: ${r.statusCode} ${r.body}');
    }
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  static Future<void> updateDisplayName(String name) async {
    final r = await ApiClient.post('/profile/update/', {'display_name': name});
    if (r.statusCode != 200) {
      throw Exception('update failed: ${r.statusCode} ${r.body}');
    }
  }
}
