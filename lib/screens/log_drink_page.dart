import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';
import 'package:after_hours/main_app_wrapper.dart'; // ✅ make sure this exists

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
  String message = '';

  /// ✅ Use the same logic as Django:
  ///   alcohol_ml = (beer*17 + floco*43 + rum*9 + whiskey*14 + vodka*18 + tequila*23)
  ///   alcohol_xp = alcohol_ml * 0.75
  ///   total_xp = alcohol_xp + shotguns*5 + snorkels*15  (thrown_up assumed 0 here)
  ///   round: .5 goes up, .4 goes down (standard rounding)
  double calculateXP() {
    int beer = int.tryParse(controllers['Beer/Seltzer']!.text) ?? 0;
    int floco = int.tryParse(controllers['Floco']!.text) ?? 0;
    int rum = int.tryParse(controllers['Rum']!.text) ?? 0;
    int whiskey = int.tryParse(controllers['Whiskey']!.text) ?? 0;
    int vodka = int.tryParse(controllers['Vodka']!.text) ?? 0;
    int tequila = int.tryParse(controllers['Tequila']!.text) ?? 0;
    int shotguns = int.tryParse(controllers['Shotguns']!.text) ?? 0;
    int snorkels = int.tryParse(controllers['Snorkels']!.text) ?? 0;

    // ml of pure alcohol (mirrors backend calculate_alcohol_drank)
    double alcoholMl = (beer * 17) +
        (floco * 43) +
        (rum * 9) +
        (whiskey * 14) +
        (vodka * 18) +
        (tequila * 23);

    // base XP from alcohol
    double alcoholXP = alcoholMl * 0.75;

    // bonuses (no thrown_up input on this screen, so penalty = 0)
    double bonusXP = (shotguns * 5) + (snorkels * 15);

    double totalXP = alcoholXP + bonusXP;

    if (totalXP < 0) totalXP = 0;

    // .5 goes up, .4 goes down → standard rounding to nearest int
    return totalXP.roundToDouble();
  }

  Future<void> _submitLog() async {
    setState(() {
      isLoading = true;
      message = '';
    });

    final data = {
      'beer': int.tryParse(controllers['Beer/Seltzer']!.text) ?? 0,
      'floco': int.tryParse(controllers['Floco']!.text) ?? 0,
      'rum': int.tryParse(controllers['Rum']!.text) ?? 0,
      'whiskey': int.tryParse(controllers['Whiskey']!.text) ?? 0,
      'vodka': int.tryParse(controllers['Vodka']!.text) ?? 0,
      'tequila': int.tryParse(controllers['Tequila']!.text) ?? 0,
      'shotguns': int.tryParse(controllers['Shotguns']!.text) ?? 0,
      'snorkels': int.tryParse(controllers['Snorkels']!.text) ?? 0,
      // thrown_up is 0 here – you’re not logging it on this screen
    };

    final success = await widget.apiService.logDrinkFromMap(data);

    if (!mounted) return;

    setState(() {
      isLoading = false;
      message = success ? '✅ Drinks logged!' : '❌ Failed to log drinks';
    });

    if (success) {
      // ✅ Reset inputs
      controllers.forEach((key, controller) {
        controller.text = '0';
      });

      // ✅ Navigate to Profile page (tab 4 in MainAppWrapper)
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainAppWrapper(
              initialIndex: 4, // 0=Feed, 1=Friends, 2=Log, 3=Ranks, 4=Profile
              apiService: widget.apiService,
            ),
          ),
          (route) => false,
        );
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

  Widget _buildRow(
    String label,
    IconData icon,
    Color color,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          // Label + icon
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // - [  input  ] +
          Expanded(
            flex: 4,
            child: Row(
              children: [
                // minus button
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.white70,
                  onPressed: () => _decrement(controller),
                ),

                // numeric field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: color.withOpacity(0.7),
                        width: 1.5,
                      ),
                      color: Colors.black.withOpacity(0.2),
                    ),
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        hintText: '0',
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),

                // plus button
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.white70,
                  onPressed: () => _increment(controller),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final xp = calculateXP();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Log Your Drinks',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Colors.cyanAccent, Colors.purpleAccent],
                        ).createShader(
                          const Rect.fromLTWH(0, 0, 300, 70),
                        ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildRow(
                  'Beer/Seltzer',
                  Icons.local_drink,
                  Colors.cyanAccent,
                  controllers['Beer/Seltzer']!,
                ),
                _buildRow(
                  'Floco',
                  Icons.emoji_nature,
                  Colors.pinkAccent,
                  controllers['Floco']!,
                ),
                _buildRow(
                  'Rum',
                  Icons.local_bar,
                  Colors.cyanAccent,
                  controllers['Rum']!,
                ),
                _buildRow(
                  'Whiskey',
                  Icons.wine_bar,
                  Colors.amberAccent,
                  controllers['Whiskey']!,
                ),
                _buildRow(
                  'Vodka',
                  Icons.liquor,
                  Colors.blueAccent,
                  controllers['Vodka']!,
                ),
                _buildRow(
                  'Tequila',
                  Icons.local_fire_department,
                  Colors.greenAccent,
                  controllers['Tequila']!,
                ),
                _buildRow(
                  'Shotguns',
                  Icons.sports_bar,
                  Colors.orangeAccent,
                  controllers['Shotguns']!,
                ),
                _buildRow(
                  'Snorkels',
                  Icons.waves,
                  Colors.lightBlueAccent,
                  controllers['Snorkels']!,
                ),

                const SizedBox(height: 16),

                // XP card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.pinkAccent.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Estimated XP',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${xp.toStringAsFixed(0)} XP',
                        style: const TextStyle(
                          color: Colors.pinkAccent,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Center(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitLog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'LOG DRINK',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                if (message.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: message.startsWith('✅')
                            ? Colors.greenAccent
                            : Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
