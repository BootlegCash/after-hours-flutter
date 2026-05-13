import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';
import 'package:after_hours/screens/friend_profile_page.dart';

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
  bool _hasSearched = false;
  final TextEditingController _searchController = TextEditingController();
  String? _myUsername;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFriends();
    _loadRequests();
    _loadMe();
  }

  Future<void> _loadMe() async {
    try {
      final me = await widget.apiService.fetchUserProfile();
      if (!mounted) return;
      setState(() => _myUsername = me?['username']?.toString());
    } catch (_) {}
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
    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _searchResults = [];
    });
    try {
      final results = await widget.apiService.searchUsers(query);
      setState(() => _searchResults = results);
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  String _usernameFromProfile(Map<String, dynamic> p) {
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

  String _rankFromProfile(Map<String, dynamic> p) =>
      (p['rank'] ?? 'Unranked').toString();

  int _xpFromProfile(Map<String, dynamic> p) {
    final v = p['xp'];
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v?.toString() ?? '0') ?? 0;
  }

  bool _canOpenProfile(String username) =>
      username.isNotEmpty && username != _myUsername;

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
    final success = await widget.apiService.sendFriendRequest(username);
    if (!mounted) return;
    if (success) {
      _showSnack('Request sent to @$username');
      _loadRequests();
    } else {
      _showSnack('Already sent a request to @$username');
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
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1c1842),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Friend',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Remove @$username from your friends?',
            style: const TextStyle(color: Colors.white60)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await widget.apiService.removeFriend(username);
      _showSnack('Removed @$username');
      _loadFriends();
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFF1c1842),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── SHARED WIDGETS ─────────────────────────────────────────

  Widget _avatar(String name) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.pinkAccent, Colors.cyanAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  Widget _emptyState(IconData icon, String title, String sub) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.15), size: 60),
          const SizedBox(height: 16),
          Text(title,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.45), fontSize: 15)),
          const SizedBox(height: 6),
          Text(sub,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.25), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _card({required Widget child, Color? borderColor}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: borderColor ?? Colors.white.withOpacity(0.08)),
      ),
      child: child,
    );
  }

  // ── BUILD ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0c29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1c1842),
        elevation: 0,
        title: const Text('Friends',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.pinkAccent,
          indicatorWeight: 3,
          labelColor: Colors.pinkAccent,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(icon: Icon(Icons.people_rounded), text: 'Friends'),
            Tab(icon: Icon(Icons.mail_rounded), text: 'Requests'),
            Tab(icon: Icon(Icons.search_rounded), text: 'Search'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildFriendsTab(),
            _buildRequestsTab(),
            _buildSearchTab(),
          ],
        ),
      ),
    );
  }

  // ── TAB 1: FRIENDS ─────────────────────────────────────────

  Widget _buildFriendsTab() {
    return RefreshIndicator(
      onRefresh: _onRefreshFriends,
      backgroundColor: const Color(0xFF1c1842),
      color: Colors.pinkAccent,
      child: FutureBuilder<List<dynamic>>(
        future: _friendsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.pinkAccent));
          }
          if (snapshot.hasError) {
            return _emptyState(Icons.wifi_off_rounded, 'Could not load friends',
                'Pull down to retry');
          }
          final friends = snapshot.data ?? [];
          if (friends.isEmpty) {
            return _emptyState(Icons.people_outline_rounded, 'No friends yet',
                'Search for people and send requests');
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: friends.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final p = friends[index] as Map<String, dynamic>;
              final username = _usernameFromProfile(p);
              final displayName = _displayNameFromProfile(p);
              final rank = _rankFromProfile(p);
              final xp = _xpFromProfile(p);

              return GestureDetector(
                onTap: _canOpenProfile(username)
                    ? () => _openProfile(username)
                    : null,
                child: _card(
                  child: Row(
                    children: [
                      _avatar(displayName),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(displayName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            const SizedBox(height: 2),
                            Text('@$username',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.45),
                                    fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('$rank · $xp XP',
                                style: const TextStyle(
                                    color: Colors.pinkAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_remove_alt_1_outlined,
                            color: Colors.redAccent, size: 20),
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

  // ── TAB 2: REQUESTS ────────────────────────────────────────

  Widget _buildRequestsTab() {
    return RefreshIndicator(
      onRefresh: _onRefreshRequests,
      backgroundColor: const Color(0xFF1c1842),
      color: Colors.pinkAccent,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.pinkAccent));
          }
          if (snapshot.hasError) {
            return _emptyState(Icons.wifi_off_rounded,
                'Could not load requests', 'Pull down to retry');
          }

          final data = snapshot.data ?? {};
          final received = (data['received'] ?? []) as List<dynamic>;
          final sent = (data['sent'] ?? []) as List<dynamic>;

          if (received.isEmpty && sent.isEmpty) {
            return _emptyState(Icons.mail_outline_rounded, 'No requests',
                'Send or receive friend requests here');
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              // RECEIVED
              if (received.isNotEmpty) ...[
                _sectionLabel('Received'),
                const SizedBox(height: 10),
                ...received.map((fr) {
                  final frMap = fr as Map<String, dynamic>;
                  final id = frMap['id'] as int;
                  final from = frMap['from_user'] as Map<String, dynamic>;
                  final username = _usernameFromProfile(from);
                  final displayName = _displayNameFromProfile(from);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: _card(
                      borderColor: Colors.cyanAccent.withOpacity(0.15),
                      child: Row(
                        children: [
                          _avatar(displayName),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(displayName,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                Text('@$username',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.45),
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => _rejectRequest(id),
                            child: const Text('Decline',
                                style: TextStyle(
                                    color: Colors.redAccent, fontSize: 13)),
                          ),
                          GestureDetector(
                            onTap: () => _acceptRequest(id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Colors.pinkAccent,
                                  Colors.cyanAccent
                                ]),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Text('Accept',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],

              // SENT
              if (sent.isNotEmpty) ...[
                _sectionLabel('Sent'),
                const SizedBox(height: 10),
                ...sent.map((fr) {
                  final frMap = fr as Map<String, dynamic>;
                  final to = frMap['to_user'] as Map<String, dynamic>;
                  final username = _usernameFromProfile(to);
                  final displayName = _displayNameFromProfile(to);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: _card(
                      child: Row(
                        children: [
                          _avatar(displayName),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(displayName,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                Text('@$username',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.45),
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.12)),
                            ),
                            child: Text('Pending',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.45),
                                    fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          );
        },
      ),
    );
  }

  // ── TAB 3: SEARCH ──────────────────────────────────────────

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _performSearch(),
              decoration: InputDecoration(
                hintText: 'Search by username...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                prefixIcon:
                    Icon(Icons.search, color: Colors.white.withOpacity(0.4)),
                suffixIcon: IconButton(
                  icon: _isSearching
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.pinkAccent))
                      : const Icon(Icons.arrow_forward_rounded,
                          color: Colors.pinkAccent),
                  onPressed: _isSearching ? null : _performSearch,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ),
        if (_isSearching)
          LinearProgressIndicator(
            backgroundColor: Colors.white.withOpacity(0.05),
            color: Colors.pinkAccent,
            minHeight: 2,
          ),
        Expanded(
          child: !_hasSearched
              ? _emptyState(Icons.person_search_rounded, 'Find your crew',
                  'Type a username and hit enter')
              : _searchResults.isEmpty
                  ? _emptyState(Icons.search_off_rounded, 'No users found',
                      'Try a different username')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final p = _searchResults[index] as Map<String, dynamic>;
                        final username = _usernameFromProfile(p);
                        final displayName = _displayNameFromProfile(p);
                        final rank = _rankFromProfile(p);
                        final xp = _xpFromProfile(p);

                        return GestureDetector(
                          onTap: _canOpenProfile(username)
                              ? () => _openProfile(username)
                              : null,
                          child: _card(
                            child: Row(
                              children: [
                                _avatar(displayName),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(displayName,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15)),
                                      const SizedBox(height: 2),
                                      Text('@$username',
                                          style: TextStyle(
                                              color: Colors.white
                                                  .withOpacity(0.45),
                                              fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Text('$rank · $xp XP',
                                          style: const TextStyle(
                                              color: Colors.pinkAccent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _sendRequestTo(username),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [
                                        Colors.pinkAccent,
                                        Colors.cyanAccent
                                      ]),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Text('Add',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label,
        style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 0.3));
  }
}
