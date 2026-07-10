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
  final PageController _rankPageController = PageController(initialPage: 3000);
  int _selectedRankPage = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _rankPageController.dispose();
    super.dispose();
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

    final results = await Future.wait([
      widget.apiService.fetchUserProfile(),
      widget.apiService.fetchPeriodXpSummary(),
    ]);
    final data = results[0] as Map<String, dynamic>?;
    final periodXp = results[1] as Map<String, int>;
    if (data != null) {
      data['monthly_xp'] = periodXp['monthly_xp'] ?? 0;
      data['yearly_xp'] = periodXp['yearly_xp'] ?? 0;
    }
    if (!mounted) return;
    setState(() {
      profile = data;
      _loading = false;
    });
  }

  double? _nextThreshold(double xp, List<int> thresholds) {
    for (final threshold in thresholds) {
      if (xp < threshold) return threshold.toDouble();
    }
    return null;
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
    switch (rank.split(' ').first.toLowerCase()) {
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
      case 'steeze':
        return '👑';
      default:
        return '🏅';
    }
  }

  Color getRankColor(String rank) {
    final tier = rank.split(' ').first.toLowerCase();
    switch (tier) {
      case 'bronze':
        return Colors.amber;
      case 'silver':
        return Colors.grey[300]!;
      case 'gold':
        return Colors.yellow;
      case 'platinum':
        return Colors.cyan;
      case 'diamond':
        return Colors.blue;
      case 'steeze':
      case 'steez':
        return Colors.pinkAccent;
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
    final String monthlyRank =
        profile!['monthly_rank']?.toString() ?? 'Unranked';
    final String yearlyRank = profile!['yearly_rank']?.toString() ?? 'Unranked';
    final double xp = (profile!['xp'] as num?)?.toDouble() ?? 0.0;
    final double? xpNext = _nextThreshold(xp, const [
      400,
      800,
      1500,
      2500,
      4000,
      6500,
      10000,
      15000,
      22000,
      32000,
      45000,
      62000,
      82000,
      105000,
      135000,
      170000,
      210000,
    ]);
    final double monthlyXp =
        (profile!['monthly_xp'] as num?)?.toDouble() ?? 0.0;
    final double? monthlyXpNext =
        _nextThreshold(monthlyXp, const [200, 500, 1000, 2000, 3000]);
    final double yearlyXp = (profile!['yearly_xp'] as num?)?.toDouble() ?? 0.0;
    final double? yearlyXpNext =
        _nextThreshold(yearlyXp, const [800, 2000, 5000, 12000, 25000]);

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
        child: _buildProfileBody(username, rank, monthlyRank, yearlyRank, xp,
            xpNext, monthlyXp, monthlyXpNext, yearlyXp, yearlyXpNext),
      ),
    );
  }

  Widget _buildProfileBody(
      String username,
      String rank,
      String monthlyRank,
      String yearlyRank,
      double xp,
      double? xpNext,
      double monthlyXp,
      double? monthlyXpNext,
      double yearlyXp,
      double? yearlyXpNext) {
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
            _buildProfileCard(username, rank, monthlyRank, yearlyRank, xp,
                xpNext, monthlyXp, monthlyXpNext, yearlyXp, yearlyXpNext),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/calendar'),
                icon: const Icon(Icons.calendar_month_outlined,
                    color: Colors.pinkAccent),
                label: const Text('Rank Calendar',
                    style: TextStyle(color: Colors.pinkAccent)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.pinkAccent),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
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
      String username,
      String lifetimeRank,
      String monthlyRank,
      String yearlyRank,
      double xp,
      double? xpNext,
      double monthlyXp,
      double? monthlyXpNext,
      double yearlyXp,
      double? yearlyXpNext) {
    final ranks = [
      (
        label: 'This Month',
        rank: monthlyRank,
        xp: monthlyXp,
        next: monthlyXpNext
      ),
      (label: 'This Year', rank: yearlyRank, xp: yearlyXp, next: yearlyXpNext),
      (label: 'Lifetime', rank: lifetimeRank, xp: xp, next: xpNext),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
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
          SizedBox(
            height: 112,
            child: PageView.builder(
              controller: _rankPageController,
              onPageChanged: (index) =>
                  setState(() => _selectedRankPage = index % ranks.length),
              itemBuilder: (context, index) {
                final item = ranks[index % ranks.length];
                final label = item.label;
                final rank = item.rank;
                final pageXp = item.xp;
                final nextXp = item.next;
                final isMaxRank = nextXp == null;
                final pageProgress =
                    isMaxRank ? 1.0 : (pageXp / nextXp).clamp(0.0, 1.0);
                final color = getRankColor(rank);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(getRankBadge(rank),
                            style: const TextStyle(fontSize: 30)),
                        const SizedBox(width: 8),
                        Text(rank,
                            style: TextStyle(
                                fontSize: 22,
                                color: color,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 13),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: pageProgress,
                          minHeight: 10,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          color: Colors.pinkAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isMaxRank
                          ? '${pageXp.toInt()} XP total'
                          : '${pageXp.toInt()} / ${nextXp.toInt()} XP to next',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              ranks.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: index == _selectedRankPage ? 18 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: index == _selectedRankPage
                      ? Colors.pinkAccent
                      : Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
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
