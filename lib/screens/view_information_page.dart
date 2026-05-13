import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';

class ViewInformationPage extends StatefulWidget {
  final ApiService apiService;
  const ViewInformationPage({super.key, required this.apiService});

  @override
  State<ViewInformationPage> createState() => _ViewInformationPageState();
}

class _ViewInformationPageState extends State<ViewInformationPage> {
  Map<String, dynamic>? profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (widget.apiService.token == null) {
      if (!mounted) return;
      setState(() {
        profile = null;
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);

    try {
      final data = await widget.apiService.fetchUserProfile();
      if (!mounted) return;
      setState(() {
        profile = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        profile = null;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0c29),
      appBar: AppBar(
        title: const Text('Your Information',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1c1842),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
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
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.pinkAccent))
            : profile == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off_rounded,
                            color: Colors.white.withOpacity(0.3), size: 52),
                        const SizedBox(height: 16),
                        const Text('Could not load your profile.',
                            style: TextStyle(color: Colors.white60)),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _loadProfile,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Colors.pinkAccent,
                                Colors.cyanAccent
                              ]),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Text('Retry',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final username = (profile!['username'] ?? '').toString();
    final displayName =
        (profile!['display_name'] ?? profile!['displayName'] ?? '').toString();
    final email =
        (profile!['email'] ?? profile!['user']?['email'] ?? '').toString();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      children: [
        // Avatar header
        Center(
          child: Column(
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.pinkAccent, Colors.cyanAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.35),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                displayName.isNotEmpty ? displayName : username,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '@$username',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.45), fontSize: 14),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Info card
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            children: [
              _infoRow(
                icon: Icons.alternate_email_rounded,
                iconColor: Colors.cyanAccent,
                label: 'Username',
                value: '@$username',
                isFirst: true,
              ),
              _divider(),
              _infoRow(
                icon: Icons.badge_outlined,
                iconColor: Colors.pinkAccent,
                label: 'Display Name',
                value: displayName.isNotEmpty ? displayName : 'Not set',
              ),
              _divider(),
              _infoRow(
                icon: Icons.email_outlined,
                iconColor: Colors.amberAccent,
                label: 'Email',
                value: email.isNotEmpty ? email : 'Not available',
                isLast: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Note
        Center(
          child: Text(
            'To update your information, contact support.',
            style:
                TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5)),
                const SizedBox(height: 3),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: Colors.white.withOpacity(0.07),
      indent: 70,
      endIndent: 18,
    );
  }
}
