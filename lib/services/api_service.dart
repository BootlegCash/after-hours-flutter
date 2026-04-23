import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'https://ranked-0xtx.onrender.com';

  // ✅ Web-gate key (Render ENV: APP_GATE_KEY)
  static const String _appGateKey = 'ah_9f8d2c1b6a3e4f7a8c0d_very_secret';

  String? token;
  String? currentUsername;
  VoidCallback? onAuthStateChanged;

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  String get _accountsApiBase => '$baseUrl/accounts/api';

  // ================================================================
  // INTERNAL HELPERS (ALWAYS INCLUDE X-APP-KEY)
  // ================================================================

  Map<String, String> _baseHeaders() {
    return {
      'X-APP-KEY': _appGateKey,
    };
  }

  Map<String, String> _authHeaders() {
    return {
      ..._baseHeaders(),
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, String> _authJsonHeaders() {
    return {
      ..._baseHeaders(),
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, String> _authFormHeaders() {
    return {
      ..._baseHeaders(),
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, String> _jsonHeaders() {
    return {
      ..._baseHeaders(),
      'Content-Type': 'application/json',
    };
  }

  Map<String, String> _formHeaders() {
    return {
      ..._baseHeaders(),
      'Content-Type': 'application/x-www-form-urlencoded',
    };
  }

  // ================================================================
  // AUTH: LOGIN
  // ================================================================

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$_accountsApiBase/token/');
    developer.log('Attempting login for $username', name: 'ApiService.login');

    try {
      final response = await http.post(
        url,
        headers: _formHeaders(), // ✅ includes X-APP-KEY
        body: {
          'username': username,
          'password': password,
        },
      );

      developer.log(
        'Login response: ${response.statusCode} ${response.body}',
        name: 'ApiService.login',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        token = data['access'];
        onAuthStateChanged?.call();
        return true;
      }
    } catch (e) {
      developer.log('Login error: $e', name: 'ApiService.login', error: e);
    }

    return false;
  }

  // ================================================================
  // AUTH: REGISTER
  // ================================================================

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String password2,
    required String displayName,
  }) async {
    final url = Uri.parse('$_accountsApiBase/register/');
    developer.log('Attempting register for $username',
        name: 'ApiService.register');

    try {
      final response = await http.post(
        url,
        headers: _jsonHeaders(), // ✅ includes X-APP-KEY
        body: jsonEncode({
          'username': username,
          'email': email,
          'password1': password,
          'password2': password2,
          'display_name': displayName,
        }),
      );

      developer.log(
        'Register response: ${response.statusCode} ${response.body}',
        name: 'ApiService.register',
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      developer.log('Register error: $e',
          name: 'ApiService.register', error: e);
      return {'success': false, 'error': 'Network error'};
    }
  }

  // ================================================================
  // PROFILE
  // ================================================================

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    if (token == null) return null;

    final url = Uri.parse('$_accountsApiBase/profile/');

    try {
      final response = await http.get(url, headers: _authHeaders());

      developer.log(
        'Profile fetch: ${response.statusCode} ${response.body}',
        name: 'ApiService.fetchUserProfile',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['username'] is String) {
          currentUsername = data['username'] as String;
        }
        return Map<String, dynamic>.from(data as Map);
      }
    } catch (e) {
      developer.log('Fetch profile error: $e',
          name: 'ApiService.fetchUserProfile', error: e);
    }

    return null;
  }

  // Public / friend profile (by username)
  Future<Map<String, dynamic>?> fetchFriendProfile(String username) async {
    if (token == null) return null;
    final url = Uri.parse('$_accountsApiBase/friends/$username/');

    try {
      final resp = await http.get(url, headers: _authHeaders());
      developer.log(
        'fetchFriendProfile($username): ${resp.statusCode} ${resp.body}',
        name: 'ApiService.fetchFriendProfile',
      );

      if (resp.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(resp.body) as Map);
      }
    } catch (e) {
      developer.log(
        'fetchFriendProfile error: $e',
        name: 'ApiService.fetchFriendProfile',
        error: e,
      );
    }
    return null;
  }

  // ================================================================
  // DRINK LOGGING
  // ================================================================

  Future<bool> logDrinkFromMap(Map<String, dynamic> data) async {
    if (token == null) {
      developer.log('logDrinkFromMap: No token available',
          name: 'ApiService.logDrinkFromMap');
      return false;
    }

    final url = Uri.parse('$_accountsApiBase/log_drink/');
    developer.log('Logging drink data: $data',
        name: 'ApiService.logDrinkFromMap');

    try {
      final body = data.map((key, value) => MapEntry(key, value.toString()));

      final response = await http.post(
        url,
        headers: _authFormHeaders(),
        body: body,
      );

      developer.log(
        'logDrinkFromMap response: ${response.statusCode} ${response.body}',
        name: 'ApiService.logDrinkFromMap',
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      developer.log('logDrinkFromMap error: $e',
          name: 'ApiService.logDrinkFromMap', error: e);
      return false;
    }
  }

  // ================================================================
  // LOGOUT
  // ================================================================

  Future<void> logout() async {
    token = null;
    currentUsername = null;
    onAuthStateChanged?.call();
  }

  // ================================================================
  // FRIENDS SYSTEM
  // ================================================================

  Future<List<dynamic>> fetchFriends() async {
    final url = Uri.parse('$_accountsApiBase/friends/');
    final resp = await http.get(url, headers: _authJsonHeaders());

    developer.log('fetchFriends: ${resp.statusCode} ${resp.body}',
        name: 'ApiService.friends');

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (data is List) return data;
      throw Exception('Unexpected friends list response');
    }

    throw Exception('Failed to load friends: ${resp.statusCode}');
  }

  Future<Map<String, dynamic>> fetchFriendRequests() async {
    final url = Uri.parse('$_accountsApiBase/friends/requests/');
    final resp = await http.get(url, headers: _authJsonHeaders());

    developer.log('fetchFriendRequests: ${resp.statusCode} ${resp.body}',
        name: 'ApiService.friendRequests');

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data;
    }

    throw Exception('Failed to load requests: ${resp.statusCode}');
  }

  Future<List<dynamic>> searchUsers(String query) async {
    final url = Uri.parse('$_accountsApiBase/friends/search/?q=$query');
    final resp = await http.get(url, headers: _authJsonHeaders());

    developer.log('searchUsers: ${resp.statusCode} ${resp.body}',
        name: 'ApiService.searchUsers');

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (data is List) return data;
      throw Exception('Unexpected search result type');
    }

    throw Exception('Search failed: ${resp.statusCode}');
  }

  Future<bool> sendFriendRequest(String username) async {
    if (token == null) return false;

    final url = Uri.parse('$_accountsApiBase/friends/request/send/');

    try {
      final resp = await http.post(
        url,
        headers: _authJsonHeaders(),
        body: jsonEncode({'username': username}),
      );

      developer.log('sendFriendRequest: ${resp.statusCode} ${resp.body}',
          name: 'ApiService.sendRequest');

      return resp.statusCode == 200 || resp.statusCode == 201;
    } catch (e) {
      developer.log(
        'sendFriendRequest error: $e',
        name: 'ApiService.sendRequest',
        error: e,
      );
      return false;
    }
  }

  Future<void> acceptFriendRequest(int requestId) async {
    final url =
        Uri.parse('$_accountsApiBase/friends/request/$requestId/accept/');

    final resp = await http.post(url, headers: _authHeaders());

    developer.log('acceptFriendRequest: ${resp.statusCode} ${resp.body}',
        name: 'ApiService.accept');

    if (resp.statusCode != 200) {
      throw Exception('Failed to accept request');
    }
  }

  Future<void> rejectFriendRequest(int requestId) async {
    final url =
        Uri.parse('$_accountsApiBase/friends/request/$requestId/reject/');

    final resp = await http.post(url, headers: _authHeaders());

    developer.log('rejectFriendRequest: ${resp.statusCode} ${resp.body}',
        name: 'ApiService.reject');

    if (resp.statusCode != 200) {
      throw Exception('Failed to reject request');
    }
  }

  Future<bool> removeFriend(String username) async {
    if (token == null) return false;

    final url = Uri.parse('$_accountsApiBase/friends/remove/');

    try {
      final resp = await http.post(
        url,
        headers: _authJsonHeaders(),
        body: jsonEncode({'username': username}),
      );

      developer.log('removeFriend: ${resp.statusCode} ${resp.body}',
          name: 'ApiService.removeFriend');

      return resp.statusCode == 200;
    } catch (e) {
      developer.log(
        'removeFriend error: $e',
        name: 'ApiService.removeFriend',
        error: e,
      );
      return false;
    }
  }

  // ================================================================
  // LEADERBOARD
  // ================================================================

  Future<List<Map<String, dynamic>>?> fetchLeaderboard() async {
    if (token == null) return null;

    final url = Uri.parse('$_accountsApiBase/leaderboard/');
    try {
      final response = await http.get(
        url,
        headers: _authHeaders(),
      );

      developer.log(
        'Leaderboard response: ${response.statusCode} ${response.body}',
        name: 'ApiService.fetchLeaderboard',
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map<Map<String, dynamic>>(
                  (e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      }
    } catch (e) {
      developer.log(
        'Leaderboard error: $e',
        name: 'ApiService.fetchLeaderboard',
        error: e,
      );
    }
    return null;
  }

  // ================================================================
  // FEED
  // ================================================================

  Future<List<Map<String, dynamic>>?> fetchFeed() async {
    if (token == null) return null;

    final url = Uri.parse('$_accountsApiBase/feed/');
    try {
      final resp = await http.get(url, headers: _authHeaders());
      developer.log(
        'fetchFeed: ${resp.statusCode} ${resp.body}',
        name: 'ApiService.fetchFeed',
      );

      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        if (decoded is List) {
          return decoded
              .map<Map<String, dynamic>>(
                  (e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      }
    } catch (e) {
      developer.log(
        'fetchFeed error: $e',
        name: 'ApiService.fetchFeed',
        error: e,
      );
    }
    return null;
  }

  Future<Map<String, dynamic>?> createPost(String content) async {
    if (token == null) return null;

    final url = Uri.parse('$_accountsApiBase/feed/create/');
    try {
      final resp = await http.post(
        url,
        headers: _authJsonHeaders(),
        body: jsonEncode({'content': content}),
      );

      developer.log(
        'createPost: ${resp.statusCode} ${resp.body}',
        name: 'ApiService.createPost',
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return Map<String, dynamic>.from(jsonDecode(resp.body) as Map);
      }
    } catch (e) {
      developer.log(
        'createPost error: $e',
        name: 'ApiService.createPost',
        error: e,
      );
    }
    return null;
  }

  Future<Map<String, dynamic>?> toggleLikePost(int postId) async {
    if (token == null) return null;

    final url = Uri.parse('$_accountsApiBase/posts/$postId/like/');
    try {
      final resp = await http.post(
        url,
        headers: _authHeaders(),
      );

      developer.log(
        'toggleLikePost: ${resp.statusCode} ${resp.body}',
        name: 'ApiService.toggleLikePost',
      );

      if (resp.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(resp.body) as Map);
      }
    } catch (e) {
      developer.log(
        'toggleLikePost error: $e',
        name: 'ApiService.toggleLikePost',
        error: e,
      );
    }
    return null;
  }
}
