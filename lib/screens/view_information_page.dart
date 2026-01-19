import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';

class ViewInformationPage extends StatefulWidget {
  final ApiService apiService;
  const ViewInformationPage({super.key, required this.apiService});

  @override
  State<ViewInformationPage> createState() => _ViewInformationPageState();
}

class _ViewInformationPageState extends State<ViewInformationPage> {
  Map<String, dynamic>? _userInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    // Assuming your apiService.fetchUserProfile() gets basic info
    // You might need a new endpoint for more detailed user account info like email
    final data =
        await widget.apiService.fetchUserProfile(); // Re-using this for now
    if (mounted) {
      setState(() {
        _userInfo = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0c29),
      appBar: AppBar(
        title: const Text('Your Information',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1c1842),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.pinkAccent))
          : _userInfo == null
              ? const Center(
                  child: Text('Could not load user information.',
                      style: TextStyle(color: Colors.white)))
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildInfoTile(
                        'Username:', _userInfo!['username'] ?? 'N/A'),
                    _buildInfoTile(
                        'Email:', _userInfo!['email'] ?? 'N/A (Add to API)'),
                    _buildInfoTile(
                        'Display Name:',
                        _userInfo!['display_name'] ??
                            _userInfo!['username'] ??
                            'N/A'),
                    _buildInfoTile('Phone Number:', 'N/A (Add to API)'),
                  ],
                ),
    );
  }

  Widget _buildInfoTile(String title, String subtitle) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title,
            style: TextStyle(
                color: Colors.cyanAccent.withOpacity(0.8),
                fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
