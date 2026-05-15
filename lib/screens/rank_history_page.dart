import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';

class RankHistoryPage extends StatefulWidget {
  final ApiService apiService;
  const RankHistoryPage({super.key, required this.apiService});

  @override
  State<RankHistoryPage> createState() => _RankHistoryPageState();
}

class _RankHistoryPageState extends State<RankHistoryPage> {
  List<Map<String, dynamic>>? _history;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await widget.apiService.fetchRankHistory();
    if (!mounted) return;
    setState(() {
      _history = data;
      _loading = false;
    });
  }

  Color _rankColor(String rank) {
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

  static const _monthNames = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0c29),
      appBar: AppBar(
        title: const Text('Rank History',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1c1842),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
          : _history == null || _history!.isEmpty
              ? const Center(
                  child: Text('No rank history yet.',
                      style: TextStyle(color: Colors.white70, fontSize: 16)))
              : RefreshIndicator(
                  onRefresh: _load,
                  color: Colors.pinkAccent,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _history!.length,
                    itemBuilder: (context, index) {
                      final entry = _history![index];
                      final rank = entry['rank']?.toString() ?? 'Unranked';
                      final year = entry['year'] ?? 0;
                      final month = entry['month'] as int? ?? 0;
                      final xp = entry['xp'] ?? 0;
                      final monthLabel = (month >= 1 && month <= 12)
                          ? _monthNames[month]
                          : '?';
                      final color = _rankColor(rank);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.05),
                              Colors.white.withOpacity(0.12),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$monthLabel $year',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text('$xp XP',
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 13)),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: color.withOpacity(0.4)),
                              ),
                              child: Text(rank,
                                  style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
