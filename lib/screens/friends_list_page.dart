import 'package:flutter/material.dart';
import '../core/friends_service.dart';
import '../widgets/friend_tile.dart';
import 'friend_profile_page.dart';

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});
  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  List<dynamic> friends = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await FriendsService.listFriends();
      setState(() {
        friends = items;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = '$e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Friends')),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      itemCount: friends.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final p = friends[i];
                        final username = p['user']?['username'] ?? '';
                        final display = p['display_name'] ?? username;
                        return FriendTile(
                          title: display,
                          subtitle:
                              '@$username  ·  ${p['rank']}  ·  XP ${p['xp']}',
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle),
                            onPressed: () async {
                              await FriendsService.removeFriend(username);
                              _load();
                            },
                          ),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      FriendProfilePage(username: username))),
                        );
                      },
                    ),
                  ),
      );
}
