import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';
import 'package:after_hours/screens/login_page.dart'; // Import to navigate directly

class SettingsPage extends StatelessWidget {
  final ApiService apiService;
  const SettingsPage({super.key, required this.apiService});

  Widget _buildSettingsTile(
      BuildContext context, String title, IconData icon, String routeName) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.cyanAccent.withOpacity(0.7)),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white.withOpacity(0.5),
          size: 16,
        ),
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0c29),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1c1842),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          _buildSettingsTile(
            context,
            'View Your Information',
            Icons.account_circle_outlined,
            '/view-information',
          ),
          _buildSettingsTile(
            context,
            'Reset Password',
            Icons.lock_reset_outlined,
            '/reset-password',
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white24, indent: 16, endIndent: 16),
          const SizedBox(height: 10),
          _buildSettingsTile(
            context,
            'Drinking Safely',
            Icons.health_and_safety_outlined,
            '/drinking-safely',
          ),
          _buildSettingsTile(
            context,
            'App Policies',
            Icons.policy_outlined,
            '/policies',
          ),
          _buildSettingsTile(
            context,
            'About After Hours',
            Icons.info_outline,
            '/about-app',
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white24, indent: 16, endIndent: 16),
          const SizedBox(height: 10),
          // _buildSettingsTile(
          //   context,
          //   'Send Feedback',
          //   Icons.feedback_outlined,
          //   '/feedback',
          // ),
          _buildSettingsTile(
            context,
            'Contact Us',
            Icons.contact_mail_outlined,
            '/contact',
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent.withOpacity(0.8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                await apiService.logout();
                if (context.mounted) {
                  // ✅ Clear entire stack and go to LoginPage
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => LoginPage(apiService: apiService),
                    ),
                    (route) => false,
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
