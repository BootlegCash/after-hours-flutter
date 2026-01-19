import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart'; // import 'package:url_launcher/url_launcher.dart'; // For later use

class FeedbackPage extends StatelessWidget {
  final ApiService apiService;
  const FeedbackPage({super.key, required this.apiService});

  // final String _feedbackUrl = 'YOUR_FEEDBACK_URL_HERE'; // e.g., a Google Form

  // Future<void> _launchFeedbackUrl() async {
  //   if (!await launchUrl(Uri.parse(_feedbackUrl))) {
  //     throw Exception('Could not launch $_feedbackUrl');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0c29),
      appBar: AppBar(
        title:
            const Text('Send Feedback', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1c1842),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'We value your feedback!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: _launchFeedbackUrl,
            //   child: const Text('Open Feedback Form'),
            // ),
            Text(
              '(Feedback link/form to be implemented)',
              style: TextStyle(color: Colors.white70),
            )
          ],
        ),
      ),
    );
  }
}
