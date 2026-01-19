import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';
import 'package:after_hours/screens/friend_profile_page.dart'; // ✅ NEW

class FriendsPage extends StatefulWidget {
  final ApiService apiService;

  const FriendsPage({super.key, required this.apiService});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Future<List<dynamic>>? _friendsFuture;
  Future<Map<String, dynamic>>? _requestsFuture;
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  String? _myUsername; // ✅ used to block opening your own profile

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFriends();
    _loadRequests();
    _loadMe(); // ✅
  }

  Future<void> _loadMe() async {
    try {
      final me = await widget.apiService.fetchUserProfile();
      if (!mounted) return;
      setState(() {
        _myUsername = me?['username']?.toString();
      });
    } catch (_) {
      // ignore
    }
  }

  void _loadFriends() {
    setState(() {
      _friendsFuture = widget.apiService.fetchFriends();
    });
  }

  void _loadRequests() {
    setState(() {
      _requestsFuture = widget.apiService.fetchFriendRequests();
    });
  }

  Future<void> _onRefreshFriends() async {
    _loadFriends();
    await _friendsFuture;
  }

  Future<void> _onRefreshRequests() async {
    _loadRequests();
    await _requestsFuture;
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await widget.apiService.searchUsers(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  String _usernameFromProfile(Map<String, dynamic> p) {
    // profile.user.username OR sometimes profile.username
    try {
      return (p['user']?['username'] ?? p['username'] ?? '').toString();
    } catch (_) {
      return '';
    }
  }

  String _displayNameFromProfile(Map<String, dynamic> p) {
    return (p['display_name'] ??
            p['user']?['username'] ??
            p['username'] ??
            'User')
        .toString();
  }

  String _rankFromProfile(Map<String, dynamic> p) {
    return (p['rank'] ?? 'Unranked').toString();
  }

  int _xpFromProfile(Map<String, dynamic> p) {
    final v = p['xp'];
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v?.toString() ?? '0') ?? 0;
  }

  bool _canOpenProfile(String username) {
    if (username.isEmpty) return false;
    if (_myUsername != null && username == _myUsername)
      return false; // ✅ no self
    return true;
  }

  void _openProfile(String username) {
    if (!_canOpenProfile(username)) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FriendProfilePage(
          apiService: widget.apiService,
          username: username,
        ),
      ),
    );
  }

  Future<void> _sendRequestTo(String username) async {
    try {
      await widget.apiService.sendFriendRequest(username);
      _showSnack('Friend request sent to $username');
      _loadRequests();
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  Future<void> _acceptRequest(int id) async {
    try {
      await widget.apiService.acceptFriendRequest(id);
      _showSnack('Friend request accepted');
      _loadFriends();
      _loadRequests();
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  Future<void> _rejectRequest(int id) async {
    try {
      await widget.apiService.rejectFriendRequest(id);
      _showSnack('Friend request rejected');
      _loadRequests();
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  Future<void> _removeFriend(String username) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1c1842),
        title:
            const Text('Remove Friend', style: TextStyle(color: Colors.white)),
        content: Text(
          'Remove $username from your friends?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove',
                style: TextStyle(color: Colors.pinkAccent)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await widget.apiService.removeFriend(username);
      _showSnack('Removed $username');
      _loadFriends();
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0c29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1c1842),
        title: const Text(
          'Friends',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.pinkAccent,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Friends'),
            Tab(icon: Icon(Icons.mail), text: 'Requests'),
            Tab(icon: Icon(Icons.search), text: 'Search'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendsTab(),
          _buildRequestsTab(),
          _buildSearchTab(),
        ],
      ),
    );
  }

  // ---------- TAB 1: FRIENDS ----------
  Widget _buildFriendsTab() {
    return RefreshIndicator(
      onRefresh: _onRefreshFriends,
      backgroundColor: const Color(0xFF1c1842),
      color: Colors.pinkAccent,
      child: FutureBuilder<List<dynamic>>(
        future: _friendsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ListView(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Error loading friends:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            );
          }
          final friends = snapshot.data ?? [];
          if (friends.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 40),
                Center(
                  child: Text(
                    'No friends yet.\nSearch and send some requests!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: friends.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final p = friends[index] as Map<String, dynamic>;
              final username = _usernameFromProfile(p);
              final displayName = _displayNameFromProfile(p);
              final rank = _rankFromProfile(p);
              final xp = _xpFromProfile(p);

              return InkWell(
                onTap: _canOpenProfile(username)
                    ? () => _openProfile(username)
                    : null,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1c1842),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.pinkAccent.withOpacity(0.2),
                        child:
                            const Icon(Icons.person, color: Colors.pinkAccent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '@$username',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$rank • $xp XP',
                              style: const TextStyle(
                                  color: Colors.pinkAccent, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_remove_alt_1_outlined,
                            color: Colors.redAccent),
                        onPressed: () => _removeFriend(username),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ---------- TAB 2: REQUESTS ----------
  Widget _buildRequestsTab() {
    return RefreshIndicator(
      onRefresh: _onRefreshRequests,
      backgroundColor: const Color(0xFF1c1842),
      color: Colors.pinkAccent,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ListView(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Error loading requests:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            );
          }
          final data = snapshot.data ?? {};
          final received = (data['received'] ?? []) as List<dynamic>;
          final sent = (data['sent'] ?? []) as List<dynamic>;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Received',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (received.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'No incoming requests.',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              else
                ...received.map((fr) {
                  final frMap = fr as Map<String, dynamic>;
                  final id = frMap['id'] as int;
                  final from = frMap['from_user'] as Map<String, dynamic>;
                  final username = _usernameFromProfile(from);
                  final displayName = _displayNameFromProfile(from);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1c1842),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '@$username',
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => _rejectRequest(id),
                          child: const Text('Reject',
                              style: TextStyle(color: Colors.redAccent)),
                        ),
                        const SizedBox(width: 4),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                          ),
                          onPressed: () => _acceptRequest(id),
                          child: const Text('Accept'),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 24),
              const Text(
                'Sent',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (sent.isEmpty)
                const Text(
                  'No outgoing requests.',
                  style: TextStyle(color: Colors.white54),
                )
              else
                ...sent.map((fr) {
                  final frMap = fr as Map<String, dynamic>;
                  final to = frMap['to_user'] as Map<String, dynamic>;
                  final username = _usernameFromProfile(to);
                  final displayName = _displayNameFromProfile(to);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1c1842),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '@$username',
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          'Pending',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  // ---------- TAB 3: SEARCH ----------
  Widget _buildSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search by username...',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF1c1842),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: _isSearching
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search, color: Colors.pinkAccent),
                onPressed: _isSearching ? null : _performSearch,
              ),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _searchResults.isEmpty
                ? const Center(
                    child: Text(
                      'Search for a username to send a friend request.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.separated(
                    itemCount: _searchResults.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final p = _searchResults[index] as Map<String, dynamic>;
                      final username = _usernameFromProfile(p);
                      final displayName = _displayNameFromProfile(p);
                      final rank = _rankFromProfile(p);
                      final xp = _xpFromProfile(p);

                      return InkWell(
                        onTap: _canOpenProfile(username)
                            ? () => _openProfile(username)
                            : null,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1c1842),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor:
                                    Colors.pinkAccent.withOpacity(0.2),
                                child: const Icon(Icons.person,
                                    color: Colors.pinkAccent),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '@$username',
                                      style: const TextStyle(
                                          color: Colors.white54, fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$rank • $xp XP',
                                      style: const TextStyle(
                                          color: Colors.pinkAccent,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),

                              // ✅ keep button clickable without triggering the row tap
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pinkAccent,
                                ),
                                onPressed: () => _sendRequestTo(username),
                                child: const Text('Add'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
