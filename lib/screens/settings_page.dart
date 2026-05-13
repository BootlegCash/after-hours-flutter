import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';
import 'package:after_hours/screens/login_page.dart';

class SettingsPage extends StatelessWidget {
  final ApiService apiService;
  const SettingsPage({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0c29),
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1c1842),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            // ── ACCOUNT ──────────────────────────────────────
            _sectionLabel('Account'),
            const SizedBox(height: 10),
            _settingsCard(context, [
              _SettingsItem(
                icon: Icons.account_circle_outlined,
                iconColor: Colors.cyanAccent,
                title: 'Your Information',
                route: '/view-information',
              ),
              _SettingsItem(
                icon: Icons.lock_reset_outlined,
                iconColor: Colors.pinkAccent,
                title: 'Reset Password',
                route: '/reset-password',
              ),
            ]),

            const SizedBox(height: 24),

            // ── APP ───────────────────────────────────────────
            _sectionLabel('App'),
            const SizedBox(height: 10),
            _settingsCard(context, [
              _SettingsItem(
                icon: Icons.health_and_safety_outlined,
                iconColor: Colors.greenAccent,
                title: 'Drinking Safely',
                route: '/drinking-safely',
              ),
              _SettingsItem(
                icon: Icons.policy_outlined,
                iconColor: Colors.amberAccent,
                title: 'App Policies',
                route: '/policies',
              ),
              _SettingsItem(
                icon: Icons.info_outline,
                iconColor: Colors.cyanAccent,
                title: 'About After Hours',
                route: '/about-app',
              ),
            ]),

            const SizedBox(height: 24),

            // ── SUPPORT ───────────────────────────────────────
            _sectionLabel('Support'),
            const SizedBox(height: 10),
            _settingsCard(context, [
              _SettingsItem(
                icon: Icons.contact_mail_outlined,
                iconColor: Colors.purpleAccent,
                title: 'Contact Us',
                route: '/contact',
              ),
            ]),

            const SizedBox(height: 36),

            // ── LOGOUT ────────────────────────────────────────
            GestureDetector(
              onTap: () async {
                await apiService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => LoginPage(apiService: apiService),
                    ),
                    (route) => false,
                  );
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.redAccent.withOpacity(0.85),
                      Colors.red.shade900,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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

  Widget _settingsCard(BuildContext context, List<_SettingsItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isLast = i == items.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: () => Navigator.pushNamed(context, item.route),
                borderRadius: BorderRadius.vertical(
                  top: i == 0 ? const Radius.circular(18) : Radius.zero,
                  bottom: isLast ? const Radius.circular(18) : Radius.zero,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: item.iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, color: item.iconColor, size: 19),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white.withOpacity(0.25), size: 14),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: Colors.white.withOpacity(0.07),
                  indent: 68,
                  endIndent: 18,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String route;

  const _SettingsItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.route,
  });
}
