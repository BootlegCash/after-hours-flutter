import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';

class AboutAppPage extends StatelessWidget {
  final ApiService apiService;
  const AboutAppPage({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0c29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0f0c29),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'About',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0f0c29),
              Color(0xFF302b63),
              Color(0xFF24243e),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // Hero section
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset(
                      'assets/icon/icon.png',
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.pinkAccent, Colors.cyanAccent],
                    ).createShader(bounds),
                    child: const Text(
                      "After Hours: Ranked",
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
                    "Track your night. Level up the vibe.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // What is it
            _SectionLabel(label: "What is After Hours?"),
            const SizedBox(height: 10),
            _Card(
              child: Text(
                "After Hours: Ranked is a social drinking companion built for the nights worth remembering. "
                "Log your drinks, earn XP, climb ranks, and compete with your crew — all in one place.",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.6),
              ),
            ),

            const SizedBox(height: 24),

            // Features
            _SectionLabel(label: "What you can do"),
            const SizedBox(height: 10),
            _FeatureCard(
              icon: Icons.emoji_events_rounded,
              iconColor: Colors.amberAccent,
              title: "Earn XP & climb ranks",
              text:
                  "Every drink logged earns you XP. Rise through Bronze, Silver, Gold, Platinum, Diamond, and Steeze.",
            ),
            _FeatureCard(
              icon: Icons.people_alt_rounded,
              iconColor: Colors.cyanAccent,
              title: "Compete with friends",
              text:
                  "Add your crew, see where everyone stands on the leaderboard, and talk trash on the feed.",
            ),
            _FeatureCard(
              icon: Icons.bar_chart_rounded,
              iconColor: Colors.pinkAccent,
              title: "Track your nights",
              text:
                  "See your stats over time — daily logs, streaks, and a full history of your sessions.",
            ),
            _FeatureCard(
              icon: Icons.nightlife_rounded,
              iconColor: Colors.purpleAccent,
              title: "Nightlife Feed",
              text:
                  "Post what you're up to, react to your friends, and keep the energy going all night.",
            ),

            const SizedBox(height: 24),

            // Ranks
            _SectionLabel(label: "The rank ladder"),
            const SizedBox(height: 10),
            _Card(
              child: Column(
                children: const [
                  _RankRow(
                      emoji: "🥉", rank: "Bronze", sub: "Just getting started"),
                  _RankRow(
                      emoji: "🥈", rank: "Silver", sub: "Finding your stride"),
                  _RankRow(emoji: "🥇", rank: "Gold", sub: "A regular"),
                  _RankRow(
                      emoji: "💎",
                      rank: "Platinum",
                      sub: "Committed to the bit"),
                  _RankRow(
                      emoji: "💠",
                      rank: "Diamond",
                      sub: "Practically a professional"),
                  _RankRow(
                      emoji: "🫧",
                      rank: "Steeze",
                      sub: "Legendary status",
                      isLast: true),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Note
            _SectionLabel(label: "A note from us"),
            const SizedBox(height: 10),
            _Card(
              child: Text(
                "After Hours is about good times and good decisions. "
                "If the app ever makes your nights less safe or less fun, step back, take a break, and put your health first. "
                "Drink responsibly and look out for your crew.",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.6),
              ),
            ),

            const SizedBox(height: 24),

            // Version
            Center(
              child: Text(
                "After Hours Media LLC  ·  v1.0.0",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.25), fontSize: 12),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: child,
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String text;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final String emoji;
  final String rank;
  final String sub;
  final bool isLast;

  const _RankRow({
    required this.emoji,
    required this.rank,
    required this.sub,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rank,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: Colors.white.withOpacity(0.07), height: 1),
      ],
    );
  }
}
