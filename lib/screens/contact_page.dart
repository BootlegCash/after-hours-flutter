import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart'; // import 'package:url_launcher/url_launcher.dart'; // For later use

class ContactPage extends StatelessWidget {
  final ApiService apiService;
  const ContactPage({super.key, required this.apiService});

  // final String _contactEmail = 'YOUR_CONTACT_EMAIL_HERE';

  // Future<void> _launchContactEmail() async {
  //   final Uri emailLaunchUri = Uri(
  //     scheme: 'mailto',
  //     path: _contactEmail,
  //     query: 'subject=App Feedback/Support', // Pre-fill subject
  //   );
  //   if (!await launchUrl(emailLaunchUri)) {
  //     throw Exception('Could not launch $emailLaunchUri');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0c29),
      appBar: AppBar(
        title: const Text('Contact Us', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1c1842),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Get in touch!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: _launchContactEmail,
            //   child: const Text('Send us an Email'),
            // ),
            Text(
              '(Contact method to be implemented)',
              style: TextStyle(color: Colors.white70),
            )
          ],
        ),
      ),
    );
  }
}
