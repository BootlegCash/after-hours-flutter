import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';

class AboutAppPage extends StatelessWidget {
  final ApiService apiService;

  const AboutAppPage({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.pinkAccent,
          fontWeight: FontWeight.bold,
        );
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white70,
          height: 1.4,
        );
    final chipTextStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
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
          'About After Hours',
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
            Center(
              child: Column(
                children: [
                  const Icon(Icons.local_bar,
                      size: 52, color: Colors.pinkAccent),
                  const SizedBox(height: 12),
                  Text(
                    "After Hours: Ranked",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Track your night. Level up the vibe.",
                    style: bodyStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text("What is this app?", style: headerStyle),
            const SizedBox(height: 8),
            Text(
              "After Hours: Ranked is a social drinking companion. It lets you log what you’re drinking, earn XP, "
              "climb ranks, and compete with friends — all while keeping an eye on how much you’ve actually had.",
              style: bodyStyle,
            ),
            const SizedBox(height: 20),
            Text("Core features", style: headerStyle),
            const SizedBox(height: 12),
            _FeatureRow(
              icon: Icons.sports_esports,
              title: "Gamified drinking",
              text:
                  "Earn XP for each drink, unlock new tiers, and see where you stand on the leaderboard.",
            ),
            _FeatureRow(
              icon: Icons.group,
              title: "Friends & social feed",
              text:
                  "Add friends, see their ranks, and share what you’re up to on the Nightlife Feed.",
            ),
            _FeatureRow(
              icon: Icons.insights,
              title: "Awareness, not pressure",
              text:
                  "The app gives you numbers and streaks so you’re more aware of your habits — not to push you to drink more.",
            ),
            const SizedBox(height: 20),
            Text("Built with", style: headerStyle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TechChip(label: "Flutter", textStyle: chipTextStyle),
                _TechChip(label: "Django", textStyle: chipTextStyle),
                _TechChip(label: "REST API", textStyle: chipTextStyle),
                _TechChip(label: "PostgreSQL", textStyle: chipTextStyle),
              ],
            ),
            const SizedBox(height: 24),
            Text("Why it exists", style: headerStyle),
            const SizedBox(height: 8),
            Text(
              "This started as a way to make tracking drinks with friends actually fun — not a boring notes app. "
              "Instead of guessing how much you had last night, you can see your stats, your progress, and your memories.",
              style: bodyStyle,
            ),
            const SizedBox(height: 24),
            Text("A final note", style: headerStyle),
            const SizedBox(height: 8),
            Text(
              "After Hours is about good times and good decisions. If the app ever makes your nights less safe or less fun, "
              "step back, take a break, and put your health first.",
              style: bodyStyle,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _FeatureRow({
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
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
                const SizedBox(height: 4),
                Text(text, style: bodyStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  final TextStyle? textStyle;

  const _TechChip({required this.label, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1c1842),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pinkAccent.withOpacity(0.4)),
      ),
      child: Text(label, style: textStyle),
    );
  }
}
