import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';
import 'package:after_hours/screens/friend_profile_page.dart'; // ✅ NEW

class LeaderboardPage extends StatefulWidget {
  final ApiService apiService;

  const LeaderboardPage({super.key, required this.apiService});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final data = await widget.apiService.fetchLeaderboard();

    if (!mounted) return;

    if (data == null) {
      setState(() {
        _loading = false;
        _error = 'Could not load leaderboard.';
      });
    } else {
      setState(() {
        _loading = false;
        _entries = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Friends Leaderboard',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadLeaderboard,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_entries.isEmpty) {
      return const Center(
        child: Text(
          "No friends yet.\nAdd some and see who's on top.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final item = _entries[index];
          final bool isMe = (item['is_me'] == true);
          final int position = item['position'] ?? (index + 1);
          final String displayName =
              (item['display_name'] as String?) ?? 'User';
          final String username = item['username'] as String? ?? '';
          final String rank = item['rank'] as String? ?? 'Bronze';
          final int xp = item['xp'] as int? ?? 0;

          return _buildRow(
            position: position,
            displayName: displayName,
            username: username,
            rank: rank,
            xp: xp,
            isMe: isMe,
          );
        },
      ),
    );
  }

  Widget _buildRow({
    required int position,
    required String displayName,
    required String username,
    required String rank,
    required int xp,
    required bool isMe,
  }) {
    final Color accent =
        isMe ? Colors.pinkAccent : const Color(0xFF6C63FF); // neon-ish

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1c1842),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isMe
            ? [
                BoxShadow(
                  color: accent.withOpacity(0.6),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
      ),
      child: ListTile(
        // ✅ tap to open friend profile, but NOT for yourself
        onTap: (isMe || username.isEmpty)
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FriendProfilePage(
                      apiService: widget.apiService,
                      username: username,
                    ),
                  ),
                );
              },
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: accent,
          child: Text(
            '#$position',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                displayName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (isMe)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'YOU',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          '@$username • $rank',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'XP',
              style: TextStyle(fontSize: 10, color: Colors.white54),
            ),
            Text(
              xp.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
