import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';

class PoliciesPage extends StatelessWidget {
  final ApiService apiService;

  const PoliciesPage({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.pinkAccent,
          fontWeight: FontWeight.bold,
        );
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
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
          'App Policies',
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
            Text("How We Use After Hours", style: headerStyle),
            const SizedBox(height: 8),
            Text(
              "This is a simplified overview of how the app is meant to be used and how your data is handled. "
              "It’s not a legal document, but it sums up the important ideas.",
              style: bodyStyle,
            ),
            const SizedBox(height: 24),
            _PolicySection(
              title: "Age & Responsibility",
              body:
                  "After Hours is designed for adults of legal drinking age only. By using the app, you confirm that "
                  "you’re old enough to drink legally where you live and that you’ll use the app responsibly.",
              titleStyle: titleStyle,
              bodyStyle: bodyStyle,
            ),
            _PolicySection(
              title: "Content & Behavior",
              body:
                  "Don’t use the app to harass people, share hate, threats, or anything illegal. We want the feed and "
                  "friend system to stay fun, positive, and safe for everyone.",
              titleStyle: titleStyle,
              bodyStyle: bodyStyle,
            ),
            _PolicySection(
              title: "Data & Privacy",
              body:
                  "We store basic account details (like username, email, and drink stats) so the app can function. "
                  "We don’t sell your data. If we ever add more advanced analytics or sharing, we’ll clearly explain it first.",
              titleStyle: titleStyle,
              bodyStyle: bodyStyle,
            ),
            _PolicySection(
              title: "No Medical or Legal Advice",
              body:
                  "The app is a tracker and a game — it does not tell you if you’re sober, safe to drive, or okay to drink more. "
                  "Always use your own judgment and err on the side of caution.",
              titleStyle: titleStyle,
              bodyStyle: bodyStyle,
            ),
            _PolicySection(
              title: "Account Actions",
              body:
                  "We may limit or remove accounts that break these guidelines or abuse the app. In the future we may add tools "
                  "to let you download or delete your data.",
              titleStyle: titleStyle,
              bodyStyle: bodyStyle,
            ),
            const SizedBox(height: 24),
            Text("Simple Version", style: headerStyle),
            const SizedBox(height: 8),
            Text(
              "Don’t be a jerk, don’t do anything illegal, don’t drink and drive, and remember this app is for fun and awareness — "
              "not a guarantee of your safety.",
              style: bodyStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String body;
  final TextStyle? titleStyle;
  final TextStyle? bodyStyle;

  const _PolicySection({
    required this.title,
    required this.body,
    this.titleStyle,
    this.bodyStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1c1842),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.pinkAccent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          const SizedBox(height: 6),
          Text(body, style: bodyStyle),
        ],
      ),
    );
  }
}
