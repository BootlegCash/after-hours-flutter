import 'dart:convert';
import 'api_client.dart';

class FriendsService {
  static Future<List<dynamic>> listFriends() async {
    final r = await ApiClient.get('/friends/');
    if (r.statusCode != 200) {
      throw Exception('friends failed: ${r.statusCode} ${r.body}');
    }
    return jsonDecode(r.body) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> requests() async {
    final r = await ApiClient.get('/friends/requests/');
    if (r.statusCode != 200) {
      throw Exception('requests failed: ${r.statusCode} ${r.body}');
    }
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> search(String q) async {
    if (q.trim().length < 2) return [];
    final r = await ApiClient.get('/friends/search/?q=$q');
    if (r.statusCode != 200) {
      throw Exception('search failed: ${r.statusCode} ${r.body}');
    }
    return jsonDecode(r.body) as List<dynamic>;
  }

  static Future<void> sendRequest(String username) async {
    final r =
        await ApiClient.post('/friends/request/send/', {'username': username});
    if (r.statusCode != 201) {
      throw Exception('send request failed: ${r.statusCode} ${r.body}');
    }
  }

  static Future<void> cancelRequest(String username) async {
    final r = await ApiClient.post(
        '/friends/request/cancel/', {'username': username});
    if (r.statusCode != 200) {
      throw Exception('cancel request failed: ${r.statusCode} ${r.body}');
    }
  }

  static Future<void> accept(int requestId) async {
    final r = await ApiClient.post('/friends/request/$requestId/accept/', {});
    if (r.statusCode != 200) {
      throw Exception('accept failed: ${r.statusCode} ${r.body}');
    }
  }

  static Future<void> reject(int requestId) async {
    final r = await ApiClient.post('/friends/request/$requestId/reject/', {});
    if (r.statusCode != 200) {
      throw Exception('reject failed: ${r.statusCode} ${r.body}');
    }
  }

  static Future<void> removeFriend(String username) async {
    final r = await ApiClient.post('/friends/remove/', {'username': username});
    if (r.statusCode != 200) {
      throw Exception('remove failed: ${r.statusCode} ${r.body}');
    }
  }
}
