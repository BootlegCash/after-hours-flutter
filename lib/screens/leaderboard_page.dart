import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';
import 'package:after_hours/screens/friend_profile_page.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFF0f0c29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1c1842),
        elevation: 0,
        title: const Text(
          'Leaderboard',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.pinkAccent));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                color: Colors.white.withOpacity(0.3), size: 52),
            const SizedBox(height: 16),
            Text(_error!,
                style: const TextStyle(color: Colors.white60, fontSize: 15)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _loadLeaderboard,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Colors.pinkAccent, Colors.cyanAccent]),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text('Retry',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    }

    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined,
                color: Colors.white.withOpacity(0.15), size: 64),
            const SizedBox(height: 16),
            Text('No friends yet.',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.45), fontSize: 15)),
            const SizedBox(height: 6),
            Text('Add some and see who\'s on top.',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.25), fontSize: 13)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      backgroundColor: const Color(0xFF1c1842),
      color: Colors.pinkAccent,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final item = _entries[index];
          final bool isMe = item['is_me'] == true;
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
    // Medal colors for top 3
    Color? medalColor;
    if (position == 1) medalColor = const Color(0xFFFFD700);
    if (position == 2) medalColor = const Color(0xFFC0C0C0);
    if (position == 3) medalColor = const Color(0xFFCD7F32);

    return GestureDetector(
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isMe
              ? Colors.pinkAccent.withOpacity(0.12)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isMe
                ? Colors.pinkAccent.withOpacity(0.4)
                : Colors.white.withOpacity(0.08),
          ),
          boxShadow: isMe
              ? [
                  BoxShadow(
                    color: Colors.pinkAccent.withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            // Position badge
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: medalColor != null
                    ? medalColor.withOpacity(0.15)
                    : Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: medalColor != null
                      ? medalColor.withOpacity(0.5)
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Center(
                child: medalColor != null
                    ? Text(
                        position == 1
                            ? '🥇'
                            : position == 2
                                ? '🥈'
                                : '🥉',
                        style: const TextStyle(fontSize: 20),
                      )
                    : Text(
                        '#$position',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
              ),
            ),

            const SizedBox(width: 14),

            // Avatar
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isMe
                      ? [Colors.pinkAccent, Colors.cyanAccent]
                      : [
                          const Color(0xFF6C63FF),
                          const Color(0xFF3D3D8F),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Name + rank
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          displayName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.pinkAccent,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Text('YOU',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '@$username · $rank',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.45), fontSize: 12),
                  ),
                ],
              ),
            ),

            // XP
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  xp.toString(),
                  style: TextStyle(
                    color: isMe ? Colors.pinkAccent : Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                Text(
                  'XP',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.35), fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
