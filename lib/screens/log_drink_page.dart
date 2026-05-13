import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';
import 'package:after_hours/main_app_wrapper.dart';

class LogDrinkPage extends StatefulWidget {
  final ApiService apiService;
  const LogDrinkPage({super.key, required this.apiService});

  @override
  State<LogDrinkPage> createState() => _LogDrinkPageState();
}

class _LogDrinkPageState extends State<LogDrinkPage> {
  final Map<String, TextEditingController> controllers = {
    'Beer/Seltzer': TextEditingController(text: '0'),
    'Floco': TextEditingController(text: '0'),
    'Rum': TextEditingController(text: '0'),
    'Whiskey': TextEditingController(text: '0'),
    'Vodka': TextEditingController(text: '0'),
    'Tequila': TextEditingController(text: '0'),
    'Shotguns': TextEditingController(text: '0'),
    'Snorkels': TextEditingController(text: '0'),
  };

  bool isLoading = false;

  double calculateXP() {
    int beer = int.tryParse(controllers['Beer/Seltzer']!.text) ?? 0;
    int floco = int.tryParse(controllers['Floco']!.text) ?? 0;
    int rum = int.tryParse(controllers['Rum']!.text) ?? 0;
    int whiskey = int.tryParse(controllers['Whiskey']!.text) ?? 0;
    int vodka = int.tryParse(controllers['Vodka']!.text) ?? 0;
    int tequila = int.tryParse(controllers['Tequila']!.text) ?? 0;
    int shotguns = int.tryParse(controllers['Shotguns']!.text) ?? 0;
    int snorkels = int.tryParse(controllers['Snorkels']!.text) ?? 0;

    double alcoholMl = (beer * 17) +
        (floco * 43) +
        (rum * 9) +
        (whiskey * 14) +
        (vodka * 18) +
        (tequila * 23);

    double alcoholXP = alcoholMl * 0.75;
    double bonusXP = (shotguns * 5) + (snorkels * 15);
    double totalXP = alcoholXP + bonusXP;
    if (totalXP < 0) totalXP = 0;
    return totalXP.roundToDouble();
  }

  Future<void> _submitLog() async {
    FocusScope.of(context).unfocus();
    setState(() => isLoading = true);

    final data = {
      'beer': int.tryParse(controllers['Beer/Seltzer']!.text) ?? 0,
      'floco': int.tryParse(controllers['Floco']!.text) ?? 0,
      'rum': int.tryParse(controllers['Rum']!.text) ?? 0,
      'whiskey': int.tryParse(controllers['Whiskey']!.text) ?? 0,
      'vodka': int.tryParse(controllers['Vodka']!.text) ?? 0,
      'tequila': int.tryParse(controllers['Tequila']!.text) ?? 0,
      'shotguns': int.tryParse(controllers['Shotguns']!.text) ?? 0,
      'snorkels': int.tryParse(controllers['Snorkels']!.text) ?? 0,
    };

    final success = await widget.apiService.logDrinkFromMap(data);
    if (!mounted) return;
    setState(() => isLoading = false);

    if (success) {
      controllers.forEach((key, c) => c.text = '0');
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainAppWrapper(
              initialIndex: 4,
              apiService: widget.apiService,
            ),
          ),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Failed to log drinks. Try again.',
              style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1c1842),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  void _increment(TextEditingController c) {
    final val = int.tryParse(c.text) ?? 0;
    c.text = (val + 1).toString();
    setState(() {});
  }

  void _decrement(TextEditingController c) {
    final val = int.tryParse(c.text) ?? 0;
    if (val > 0) {
      c.text = (val - 1).toString();
      setState(() {});
    }
  }

  @override
  void dispose() {
    controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final xp = calculateXP();

    return Scaffold(
      backgroundColor: const Color(0xFF0f0c29),
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
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.pinkAccent, Colors.cyanAccent],
                          ).createShader(bounds),
                          child: const Text(
                            'Log Your Drinks',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap + or - to adjust each drink',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Drinks section
                  _sectionLabel('Drinks'),
                  const SizedBox(height: 10),
                  _drinkCard([
                    _DrinkRow('Beer/Seltzer', Icons.local_drink,
                        Colors.cyanAccent, controllers['Beer/Seltzer']!),
                    _DrinkRow('Floco', Icons.emoji_nature, Colors.pinkAccent,
                        controllers['Floco']!),
                    _DrinkRow('Rum', Icons.local_bar, Colors.cyanAccent,
                        controllers['Rum']!),
                    _DrinkRow('Whiskey', Icons.wine_bar, Colors.amberAccent,
                        controllers['Whiskey']!),
                    _DrinkRow('Vodka', Icons.liquor, Colors.blueAccent,
                        controllers['Vodka']!),
                    _DrinkRow('Tequila', Icons.local_fire_department,
                        Colors.greenAccent, controllers['Tequila']!),
                  ]),

                  const SizedBox(height: 20),

                  // Performance section
                  _sectionLabel('Performance'),
                  const SizedBox(height: 10),
                  _drinkCard([
                    _DrinkRow('Shotguns', Icons.sports_bar, Colors.orangeAccent,
                        controllers['Shotguns']!),
                    _DrinkRow('Snorkels', Icons.waves, Colors.lightBlueAccent,
                        controllers['Snorkels']!),
                  ]),

                  const SizedBox(height: 20),

                  // XP preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.pinkAccent.withOpacity(0.25)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Estimated XP',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13,
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 8),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.pinkAccent, Colors.cyanAccent],
                          ).createShader(bounds),
                          child: Text(
                            '${xp.toStringAsFixed(0)} XP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit button
                  GestureDetector(
                    onTap: isLoading ? null : _submitLog,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.pinkAccent, Colors.cyanAccent],
                        ),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pinkAccent.withOpacity(0.45),
                            blurRadius: 24,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text(
                                'LOG DRINK',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withOpacity(0.4),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _drinkCard(List<_DrinkRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final i = entry.key;
          final row = entry.value;
          final isLast = i == rows.length - 1;

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: row.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(row.icon, color: row.color, size: 19),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        row.label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    // Stepper
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _decrement(row.controller),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.remove,
                                color: Colors.white.withOpacity(0.6), size: 18),
                          ),
                        ),
                        SizedBox(
                          width: 44,
                          child: TextField(
                            controller: row.controller,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _increment(row.controller),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: row.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.add, color: row.color, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: Colors.white.withOpacity(0.07),
                  indent: 64,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _DrinkRow {
  final String label;
  final IconData icon;
  final Color color;
  final TextEditingController controller;

  const _DrinkRow(this.label, this.icon, this.color, this.controller);
}
