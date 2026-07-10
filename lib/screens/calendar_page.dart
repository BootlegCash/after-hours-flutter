import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';

class CalendarPage extends StatefulWidget {
  final ApiService apiService;
  const CalendarPage({super.key, required this.apiService});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  static const _months = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late DateTime _visibleMonth;
  List<Map<String, dynamic>> _history = const [];
  List<Map<String, dynamic>> _drinkHistory = const [];
  String _currentMonthlyRank = 'Bronze';
  int _currentMonthlyXp = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      widget.apiService.fetchRankHistory(),
      widget.apiService
          .fetchDrinkHistory(_visibleMonth.year, _visibleMonth.month),
      widget.apiService.fetchUserProfile(),
    ]);
    if (!mounted) return;
    setState(() {
      _history = results[0] as List<Map<String, dynamic>>? ?? const [];
      _drinkHistory = results[1] as List<Map<String, dynamic>>;
      final profile = results[2] as Map<String, dynamic>?;
      _currentMonthlyRank = profile?['monthly_rank']?.toString() ?? 'Bronze';
      _currentMonthlyXp = (profile?['monthly_xp'] as num?)?.toInt() ?? 0;
      _loading = false;
    });
  }

  DateTime? _entryDate(Map<String, dynamic> entry) {
    final value = entry['date'] ??
        entry['logged_at'] ??
        entry['created_at'] ??
        entry['timestamp'];
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  int _amount(Map<String, dynamic> entry, String key) {
    final nested = entry['drinks'];
    final value = entry[key] ?? (nested is Map ? nested[key] : null);
    return value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  }

  Map<String, int> _drinksForDate(DateTime date) {
    const keys = [
      'beer',
      'floco',
      'rum',
      'whiskey',
      'vodka',
      'tequila',
      'shotguns',
      'snorkels',
    ];
    final totals = {for (final key in keys) key: 0};
    for (final entry in _drinkHistory) {
      final logged = _entryDate(entry);
      if (logged != null &&
          logged.year == date.year &&
          logged.month == date.month &&
          logged.day == date.day) {
        for (final key in keys) {
          totals[key] = totals[key]! + _amount(entry, key);
        }
      }
    }
    return totals;
  }

  int _xpForDate(DateTime date) {
    var total = 0;
    for (final entry in _drinkHistory) {
      final logged = _entryDate(entry);
      if (logged != null &&
          logged.year == date.year &&
          logged.month == date.month &&
          logged.day == date.day) {
        total += _amount(entry, 'xp');
      }
    }
    return total;
  }

  Map<String, dynamic>? get _visibleEntry {
    for (final entry in _history) {
      final year = int.tryParse(entry['year']?.toString() ?? '');
      final month = int.tryParse(entry['month']?.toString() ?? '');
      if (year == _visibleMonth.year && month == _visibleMonth.month) {
        return entry;
      }
    }
    return null;
  }

  Color _rankColor(String rank) {
    switch (rank.split(' ').first.toLowerCase()) {
      case 'bronze':
        return Colors.amber;
      case 'silver':
        return Colors.grey.shade300;
      case 'gold':
        return Colors.yellow;
      case 'platinum':
        return Colors.cyan;
      case 'diamond':
        return Colors.blueAccent;
      case 'steez':
      case 'steeze':
        return Colors.pinkAccent;
      default:
        return Colors.white54;
    }
  }

  String _rankBadge(String rank) {
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
        return '—';
    }
  }

  Future<void> _changeMonth(int amount) async {
    setState(() {
      _visibleMonth =
          DateTime(_visibleMonth.year, _visibleMonth.month + amount);
      _loading = true;
    });
    final history = await widget.apiService
        .fetchDrinkHistory(_visibleMonth.year, _visibleMonth.month);
    if (!mounted) return;
    setState(() {
      _drinkHistory = history;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final entry = _visibleEntry;
    final now = DateTime.now();
    final isCurrentMonth =
        _visibleMonth.year == now.year && _visibleMonth.month == now.month;
    final rank = entry?['rank']?.toString() ??
        (isCurrentMonth ? _currentMonthlyRank : 'Bronze');
    final xp = entry?['xp'] ?? (isCurrentMonth ? _currentMonthlyXp : 0);
    final color = _rankColor(rank);

    return Scaffold(
      backgroundColor: const Color(0xFF0f0c29),
      appBar: AppBar(
        title: const Text('Rank Calendar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1c1842),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: Colors.pinkAccent,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(12, 18, 12, 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _changeMonth(-1),
                          icon: const Icon(Icons.chevron_left_rounded),
                          color: Colors.white70,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                  '${_months[_visibleMonth.month]} ${_visibleMonth.year}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 7),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: _loading
                                    ? const SizedBox(
                                        key: ValueKey('loading'),
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.pinkAccent))
                                    : Row(
                                        key: ValueKey(
                                            '${_visibleMonth.year}-${_visibleMonth.month}-$rank'),
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(_rankBadge(rank),
                                              style: const TextStyle(
                                                  fontSize: 18)),
                                          const SizedBox(width: 6),
                                          Text(rank,
                                              style: TextStyle(
                                                  color: color,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700)),
                                          if (xp != null) ...[
                                            const Text('  •  ',
                                                style: TextStyle(
                                                    color: Colors.white30)),
                                            Text('$xp XP',
                                                style: const TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 12)),
                                          ],
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _changeMonth(1),
                          icon: const Icon(Icons.chevron_right_rounded),
                          color: Colors.white70,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildMonthGrid(),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Tap any day to see your drink breakdown.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthGrid() {
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final days = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leading = firstDay.weekday % 7;
    final cells = ((leading + days + 6) ~/ 7) * 7;
    final today = DateTime.now();

    return Column(
      children: [
        Row(
          children: [
            for (final day in ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
              Expanded(
                child: Center(
                  child: Text(day,
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, childAspectRatio: 1),
          itemCount: cells,
          itemBuilder: (context, index) {
            final day = index - leading + 1;
            if (day < 1 || day > days) return const SizedBox.shrink();
            final isToday = today.year == _visibleMonth.year &&
                today.month == _visibleMonth.month &&
                today.day == day;
            final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
            final drinks = _drinksForDate(date);
            final dayXp = _xpForDate(date);
            final hasDrinks = drinks.values.any((amount) => amount > 0);
            return Center(
              child: InkWell(
                onTap: () => _showDayDetails(date, drinks, dayXp),
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: 38,
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              isToday ? Colors.pinkAccent : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text('$day',
                            style: TextStyle(
                                color: isToday ? Colors.white : Colors.white70,
                                fontWeight: isToday
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ),
                      if (hasDrinks)
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Colors.cyanAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showDayDetails(DateTime date, Map<String, int> drinks, int dayXp) {
    const items = [
      ('beer', 'Beer / Seltzer', Icons.sports_bar_outlined),
      ('floco', 'Flocos', Icons.local_florist_outlined),
      ('rum', 'Rum', Icons.local_drink_outlined),
      ('whiskey', 'Whiskey', Icons.liquor_outlined),
      ('vodka', 'Vodka', Icons.wine_bar_outlined),
      ('tequila', 'Tequila', Icons.local_fire_department_outlined),
      ('shotguns', 'Shotguns', Icons.bolt_outlined),
      ('snorkels', 'Snorkels', Icons.waves_outlined),
    ];
    final total = drinks.values.fold<int>(0, (sum, amount) => sum + amount);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.72),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Color(0xFF24204d),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 18),
              Text('${_months[date.month]} ${date.day}, ${date.year}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(dayXp == 0 ? 'No XP gained' : '$dayXp XP gained',
                  style: TextStyle(
                      color: dayXp == 0 ? Colors.white54 : Colors.cyanAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 18),
              if (total == 0)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Icon(Icons.local_bar_outlined,
                      color: Colors.white24, size: 52),
                )
              else
                Flexible(
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.25,
                    children: [
                      for (final item in items)
                        _dayDrinkTile(item.$2, drinks[item.$1] ?? 0, item.$3),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dayDrinkTile(String label, int amount, IconData icon) {
    final active = amount > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: active
            ? Colors.pinkAccent.withOpacity(0.12)
            : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: active
                ? Colors.pinkAccent.withOpacity(0.35)
                : Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: active ? Colors.pinkAccent : Colors.white24, size: 21),
          const SizedBox(width: 9),
          Expanded(
            child: Text(label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: active ? Colors.white70 : Colors.white38,
                    fontSize: 11)),
          ),
          Text('$amount',
              style: TextStyle(
                  color: active ? Colors.white : Colors.white38,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
