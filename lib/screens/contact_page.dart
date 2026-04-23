import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  final String displayName;
  final String username;
  final String supportEmail;
  final String instagramUrl;
  final String websiteUrl;

  const ContactUsPage({
    super.key,
    this.displayName = '',
    this.username = '',
    this.supportEmail = 'support@rankeddrinking.com',
    this.instagramUrl = 'https://instagram.com/afterhoursranked',
    this.websiteUrl = 'http://rankeddrinking.com',
  });

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  Future<void> _emailSupport(BuildContext context) async {
    final subject = Uri.encodeComponent(
      username.isNotEmpty
          ? 'After Hours Support - @$username'
          : 'After Hours Support',
    );

    final body = Uri.encodeComponent(
      "Hey After Hours team,\n\n"
      "${username.isNotEmpty ? "Username: @$username\n" : ""}"
      "${displayName.isNotEmpty ? "Name: $displayName\n" : ""}"
      "\nHow can we help?\n\n- \n\nThanks!",
    );

    final uri = Uri.parse('mailto:$supportEmail?subject=$subject&body=$body');

    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open email app')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text(
                'Need help?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                username.isNotEmpty
                    ? 'Support for @$username'
                    : 'Contact the After Hours team',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email Support'),
              subtitle: Text(supportEmail),
              onTap: () => _emailSupport(context),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Website'),
              subtitle: Text(websiteUrl),
              onTap: () => _openUrl(context, websiteUrl),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Instagram'),
              subtitle: Text(instagramUrl),
              onTap: () => _openUrl(context, instagramUrl),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Tip',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'If something is broken, include what you tapped, what you expected, and what happened.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
