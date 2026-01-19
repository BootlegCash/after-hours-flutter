import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';

class ProfilePage extends StatefulWidget {
  final ApiService apiService;
  const ProfilePage({super.key, required this.apiService});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with RouteAware {
  Map<String, dynamic>? profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (widget.apiService.token == null) {
      if (mounted) {
        setState(() {
          profile = null;
          _loading = false;
        });
      }
      return;
    }

    setState(() {
      _loading = true;
    });

    final data = await widget.apiService.fetchUserProfile();
    if (!mounted) return;
    setState(() {
      profile = data;
      _loading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // When returning from another page, refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  String getRankBadge(String rank) {
    switch (rank.toLowerCase()) {
      case 'bronze':
        return '🥉';
      case 'silver':
        return '🥈';
      case 'gold':
        return '🥇';
      case 'platinum':
        return '🔘';
      case 'diamond':
        return '💎';
      case 'steez':
        return '👑';
      default:
        return '❔';
    }
  }

  Color getRankColor(String rank) {
    switch (rank.toLowerCase()) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'platinum':
        return const Color(0xFFE5E4E2);
      case 'diamond':
        return const Color(0xFFB9F2FF);
      case 'steez':
        return Colors.purpleAccent;
      default:
        return Colors.pinkAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0f0c29),
        appBar: AppBar(
          title: const Text('Profile',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF1c1842),
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: const Center(
            child: CircularProgressIndicator(color: Colors.pinkAccent)),
      );
    }

    if (profile == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0f0c29),
        appBar: AppBar(
          title: const Text('Profile Error',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF1c1842),
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load profile.',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 10),
              const Text('Please ensure you are logged in.',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadProfile,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent),
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      );
    }

    final String username = profile!['username'] ?? 'User';
    final String rank = profile!['rank']?.toString() ?? 'Unranked';
    final double xp = (profile!['xp'] as num?)?.toDouble() ?? 0.0;
    final double xpNext =
        (profile!['xp_to_next_level'] as num?)?.toDouble() ?? xp + 1000;
    final double progress = (xpNext > xp && xpNext > 0)
        ? (xp / xpNext).clamp(0.0, 1.0)
        : (xpNext <= 0 && xp > 0 ? 1.0 : 0.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0f0c29),
      appBar: AppBar(
        title: Text('$username\'s Profile',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1c1842),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.pushNamed(context, '/settings')
                  .then((_) => _loadProfile());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        color: Colors.pinkAccent,
        child: _buildProfileBody(username, rank, xp, xpNext, progress),
      ),
    );
  }

  Widget _buildProfileBody(
      String username, String rank, double xp, double xpNext, double progress) {
    String beers = (profile!['beer'] as int? ?? 0).toString();
    String flocos = (profile!['floco'] as int? ?? 0).toString();
    String rum = (profile!['rum'] as int? ?? 0).toString();
    String whiskey = (profile!['whiskey'] as int? ?? 0).toString();
    String vodka = (profile!['vodka'] as int? ?? 0).toString();
    String tequila = (profile!['tequila'] as int? ?? 0).toString();
    String shotguns = (profile!['shotguns'] as int? ?? 0).toString();
    String snorkels = (profile!['snorkels'] as int? ?? 0).toString();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileCard(username, rank, xp, xpNext, progress),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAction(Icons.emoji_events_outlined, 'Achievements', () {
                  Navigator.pushNamed(context, '/achievements')
                      .then((_) => _loadProfile());
                }),
                _buildAction(Icons.calendar_today_outlined, 'Calendar', () {
                  Navigator.pushNamed(context, '/calendar')
                      .then((_) => _loadProfile());
                }),
              ],
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard('Beers', beers, Icons.sports_bar_outlined),
                _buildStatCard('Flocos', flocos, Icons.local_florist_outlined),
                _buildStatCard('Rum', rum, Icons.local_drink_outlined),
                _buildStatCard('Whiskey', whiskey, Icons.liquor_outlined),
                _buildStatCard('Vodka', vodka, Icons.wine_bar_outlined),
                _buildStatCard(
                    'Tequila', tequila, Icons.local_fire_department_outlined),
                _buildStatCard('Shotguns', shotguns, Icons.bolt_outlined),
                _buildStatCard('Snorkels', snorkels, Icons.waves_outlined),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
      String username, String rank, double xp, double xpNext, double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.15)
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(username,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(getRankBadge(rank), style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 8),
              Text(rank,
                  style: TextStyle(
                      fontSize: 22,
                      color: getRankColor(rank),
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Colors.white.withOpacity(0.1),
                color: Colors.pinkAccent,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rank.toLowerCase() == 'steez'
                ? 'MAX RANK'
                : '${xp.toInt()} / ${xpNext.toInt()} XP to next',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.12)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.pinkAccent.withOpacity(0.8), size: 32),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.cyanAccent.withOpacity(0.4), width: 1.5),
              ),
              child: Icon(icon, color: Colors.cyanAccent, size: 26),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
