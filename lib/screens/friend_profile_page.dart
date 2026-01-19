import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';

class FriendProfilePage extends StatefulWidget {
  final ApiService apiService;
  final String username;

  const FriendProfilePage({
    super.key,
    required this.apiService,
    required this.username,
  });

  @override
  State<FriendProfilePage> createState() => _FriendProfilePageState();
}

class _FriendProfilePageState extends State<FriendProfilePage> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  bool _friendActionLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await widget.apiService.fetchFriendProfile(widget.username);
      if (!mounted) return;

      if (res == null) {
        setState(() {
          _loading = false;
          _error = 'Could not load profile.';
        });
      } else {
        setState(() {
          _loading = false;
          _data = res;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load profile.';
      });
    }
  }

  Future<void> _toggleFriendship() async {
    if (_data == null) return;
    final username = _data!['username'] as String? ?? '';
    if (username.isEmpty) return;

    setState(() => _friendActionLoading = true);

    bool success = false;
    bool areFriends = _data!['are_friends'] == true;

    if (areFriends) {
      // remove friend
      success = await widget.apiService.removeFriend(username);
    } else {
      // send request
      success = await widget.apiService.sendFriendRequest(username);
    }

    if (!mounted) return;

    setState(() => _friendActionLoading = false);

    if (success) {
      // re-fetch profile so are_friends is fresh
      _loadProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            areFriends ? 'Friend removed.' : 'Friend request sent.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Action failed. Try again.')),
      );
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
            title: Text(
              _data?['display_name'] ?? _data?['username'] ?? 'Profile',
            ),
          ),
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.pinkAccent),
      );
    }
    if (_error != null || _data == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error ?? 'Error loading profile.',
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final d = _data!;
    final displayName = d['display_name'] as String? ?? d['username'] ?? 'User';
    final username = d['username'] as String? ?? '';
    final rank = d['rank'] as String? ?? 'Bronze';
    final xp = (d['xp'] as num? ?? 0).toDouble();
    final nextXp = (d['next_rank_xp'] as num? ?? 0).toDouble();
    final totalDrinks = d['total_drinks'] as int? ?? 0;
    final areFriends = d['are_friends'] == true;

    final beer = d['beer'] as int? ?? 0;
    final floco = d['floco'] as int? ?? 0;
    final rum = d['rum'] as int? ?? 0;
    final whiskey = d['whiskey'] as int? ?? 0;
    final vodka = d['vodka'] as int? ?? 0;
    final tequila = d['tequila'] as int? ?? 0;

    final shotguns = d['shotguns'] as int? ?? 0;
    final snorkels = d['snorkels'] as int? ?? 0;

    final xpToNext = (nextXp - xp).clamp(0, double.infinity);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // TOP CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1c1842),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@$username',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.amberAccent.withOpacity(0.8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🏅 ', style: TextStyle(fontSize: 16)),
                          Text(
                            rank,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${xp.toStringAsFixed(1)} XP',
                      style: const TextStyle(
                          color: Colors.pinkAccent,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: nextXp > 0 ? (xp / nextXp).clamp(0, 1) : 0,
                    minHeight: 8,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                    backgroundColor: Colors.white10,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${xp.toStringAsFixed(1)} XP  •  ${xpToNext.toStringAsFixed(1)} XP to next level',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Drinks: $totalDrinks',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // DRINK STATS GRID
          _sectionTitle('Drink Stats'),
          const SizedBox(height: 10),
          _statsGrid([
            _DrinkStat('Beer/Seltzers', beer, '', '🍺'),
            _DrinkStat('Flocos', floco, '', '🍻'),
            _DrinkStat('Rum Shots', rum, '', '🌴🍹'),
            _DrinkStat('Whiskey Shots', whiskey, '', '🥃'),
            _DrinkStat('Vodka Shots', vodka, '', '🇷🇺🍸'),
            _DrinkStat('Tequila Shots', tequila, '', '🍋‍🟩🍸'),
          ]),

          const SizedBox(height: 24),

          // PERFORMANCE: only Shotguns + Snorkels
          _sectionTitle('Performance'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _smallPerfCard(
                  title: 'Shotguns',
                  emoji: '💥',
                  value: shotguns,
                  subtitle: '+5 XP each',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _smallPerfCard(
                  title: 'Snorkels',
                  emoji: '🏄‍♂️',
                  value: snorkels,
                  subtitle: '+15 XP each',
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // FRIEND BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _friendActionLoading ? null : _toggleFriendship,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    areFriends ? Colors.redAccent : Colors.pinkAccent,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _friendActionLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      areFriends ? 'Remove Friend' : 'Add Friend',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.cyanAccent,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _statsGrid(List<_DrinkStat> items) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: items.map((e) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1c1842),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${e.emoji} ${e.count}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                e.label,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                e.subtitle,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _smallPerfCard({
    required String title,
    required String emoji,
    required int value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1c1842),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$emoji $value',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _DrinkStat {
  final String label;
  final int count;
  final String subtitle;
  final String emoji;

  _DrinkStat(this.label, this.count, this.subtitle, this.emoji);
}
