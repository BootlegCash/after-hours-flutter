import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';
import '../core/friends_service.dart';
import '../widgets/friend_tile.dart';
import 'package:after_hours/screens/friend_profile_page.dart';

class FriendRequestsPage extends StatefulWidget {
  final ApiService apiService;

  const FriendRequestsPage({
    super.key,
    required this.apiService,
  });

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  Map<String, dynamic>? data;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _openProfile(String username) {
    if (username.trim().isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FriendProfilePage(
          apiService: widget.apiService,
          username: username,
        ),
      ),
    );
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final m = await FriendsService.requests();
      if (!mounted) return;
      setState(() {
        data = m;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = '$e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rec = (data?['received'] ?? []) as List<dynamic>;
    final sent = (data?['sent'] ?? []) as List<dynamic>;

    return Scaffold(
      appBar: AppBar(title: const Text('Friend Requests')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'Received',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...rec.map((r) {
                        final fromUser =
                            r['from_user'] as Map<String, dynamic>?;
                        final username =
                            fromUser?['user']?['username']?.toString() ?? '';
                        final title =
                            fromUser?['display_name'] ?? username.isNotEmpty
                                ? username
                                : 'User';

                        return InkWell(
                          onTap: () => _openProfile(username),
                          child: FriendTile(
                            title: title,
                            subtitle: '@$username',
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check_circle),
                                  onPressed: () async {
                                    await FriendsService.accept(r['id']);
                                    await _load();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel),
                                  onPressed: () async {
                                    await FriendsService.reject(r['id']);
                                    await _load();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'Sent',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...sent.map((r) {
                        final toUser = r['to_user'] as Map<String, dynamic>?;
                        final username =
                            toUser?['user']?['username']?.toString() ?? '';
                        final title = toUser?['display_name'] ??
                            (username.isNotEmpty ? username : 'User');

                        return InkWell(
                          onTap: () => _openProfile(username),
                          child: FriendTile(
                            title: title,
                            subtitle: '@$username • pending',
                            trailing: IconButton(
                              icon: const Icon(Icons.undo),
                              onPressed: () async {
                                if (username.isNotEmpty) {
                                  await FriendsService.cancelRequest(username);
                                  await _load();
                                }
                              },
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}
