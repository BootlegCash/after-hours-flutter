import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';

class DrinkingSafelyPage extends StatelessWidget {
  final ApiService apiService;

  const DrinkingSafelyPage({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    final headlineStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.pinkAccent,
          fontWeight: FontWeight.bold,
        );

    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white70,
          height: 1.4,
        );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0f0c29),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Drinking Safely',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f0c29), Color(0xFF302b63)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text("Stay in Control", style: headlineStyle),
            const SizedBox(height: 8),
            Text(
              "After Hours is built to make nights more fun — not more dangerous. "
              "Use the app to keep track of how much you’re drinking so you can make smarter choices.",
              style: bodyStyle,
            ),
            const SizedBox(height: 24),
            _TipCard(
              icon: Icons.speed,
              title: "Know your pace",
              text:
                  "Space drinks out and alternate with water. If your drink counter is flying up, "
                  "it’s probably time to chill.",
            ),
            _TipCard(
              icon: Icons.local_taxi,
              title: "Never drink and drive",
              text:
                  "Plan a safe ride before you start drinking — rideshare, designated driver, or staying over. "
                  "If you’ve been drinking, driving is not an option.",
            ),
            _TipCard(
              icon: Icons.favorite,
              title: "Look out for your friends",
              text:
                  "Use the app together to check in on each other’s stats. If someone’s falling behind the safe line, "
                  "step in and help.",
            ),
            _TipCard(
              icon: Icons.local_drink,
              title: "Know your limits",
              text:
                  "Everyone’s tolerance is different. The app gives you numbers — listen to your body first.",
            ),
            _TipCard(
              icon: Icons.sos,
              title: "Emergency first",
              text:
                  "If someone is unresponsive, vomiting repeatedly, breathing strangely, or you’re just worried, "
                  "call emergency services right away. It’s always better to overreact than underreact.",
            ),
            const SizedBox(height: 24),
            Text("Important Reminder", style: headlineStyle),
            const SizedBox(height: 8),
            Text(
              "After Hours does not tell you if you are safe to drive or make decisions. "
              "It’s a tracker and a game — not a medical tool. Always choose the safest option.",
              style: bodyStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _TipCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        );
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white70,
          height: 1.4,
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1c1842),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.pinkAccent.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.pinkAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: titleStyle),
                const SizedBox(height: 6),
                Text(text, style: bodyStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
