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
  bool _saving = false;

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
      final data =
          await widget.apiService.fetchUserProfile(); // ✅ same as ProfilePage
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

  String _displayNameFromProfile(Map<String, dynamic> p) {
    // support multiple possible keys
    return (p['display_name'] ?? p['displayName'] ?? '').toString();
  }

  Future<void> _editDisplayName() async {
    if (profile == null) return;

    final current = _displayNameFromProfile(profile!);
    final controller = TextEditingController(text: current);

    final newName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change Display Name'),
        content: TextField(
          controller: controller,
          maxLength: 20,
          decoration: const InputDecoration(
            hintText: 'Enter new display name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName == null) return;
    final trimmed = newName.trim();

    if (trimmed.isEmpty) {
      _toast('Display name can’t be empty.');
      return;
    }
    if (trimmed.length < 2) {
      _toast('Display name is too short.');
      return;
    }

    // ✅ Update UI immediately (local)
    setState(() {
      profile = {...profile!, 'display_name': trimmed};
    });

    // OPTIONAL: If/when you add a backend endpoint + ApiService method,
    // call it here. For now you said you don't need hookup.
    //
    // setState(() => _saving = true);
    // try {
    //   await widget.apiService.updateDisplayName(trimmed);
    //   await _loadProfile(); // refresh from server
    //   _toast('Display name updated!');
    // } catch (_) {
    //   _toast('Could not save to server (local only).');
    // } finally {
    //   if (mounted) setState(() => _saving = false);
    // }

    _toast('Display name updated (local only).');
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0f0c29),
        appBar: AppBar(
          title: const Text('Your Information',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF1c1842),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.pinkAccent),
        ),
      );
    }

    if (profile == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0f0c29),
        appBar: AppBar(
          title: const Text('Your Information',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF1c1842),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Could not load your profile.',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadProfile,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final String username = (profile!['username'] ?? 'User').toString();
    final String displayName = _displayNameFromProfile(profile!);

    return Scaffold(
      backgroundColor: const Color(0xFF0f0c29),
      appBar: AppBar(
        title: const Text('Your Information',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1c1842),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.15)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Username (read-only)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.alternate_email,
                        color: Colors.cyanAccent),
                    title: const Text('Username',
                        style: TextStyle(color: Colors.white)),
                    subtitle: Text('@$username',
                        style: const TextStyle(color: Colors.white70)),
                  ),

                  Divider(color: Colors.white.withOpacity(0.12)),

                  // Display name (editable)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.badge_outlined,
                        color: Colors.pinkAccent),
                    title: const Text('Display Name',
                        style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                      displayName.isNotEmpty ? displayName : 'Not set',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : TextButton(
                            onPressed: _editDisplayName,
                            child: const Text('Edit'),
                          ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _saving ? null : _editDisplayName,
                      icon: const Icon(Icons.edit, color: Colors.white70),
                      label: const Text(
                        'Change Display Name',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Username cannot be changed.',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
