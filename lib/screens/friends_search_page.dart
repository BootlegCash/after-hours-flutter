import 'package:flutter/material.dart';
import '../core/friends_service.dart';
import '../widgets/friend_tile.dart';

class FriendsSearchPage extends StatefulWidget {
  const FriendsSearchPage({super.key});
  @override
  State<FriendsSearchPage> createState() => _FriendsSearchPageState();
}

class _FriendsSearchPageState extends State<FriendsSearchPage> {
  final qC = TextEditingController();
  List<dynamic> results = [];
  bool searching = false;
  String? error;

  Future<void> _search() async {
    setState(() {
      searching = true;
      error = null;
      results = [];
    });
    try {
      final r = await FriendsService.search(qC.text.trim());
      setState(() {
        results = r;
        searching = false;
      });
    } catch (e) {
      setState(() {
        error = '$e';
        searching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Find Friends')),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: qC,
              decoration: InputDecoration(
                hintText: 'Search username…',
                suffixIcon: IconButton(
                    icon: const Icon(Icons.search), onPressed: _search),
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          if (error != null)
            Padding(
                padding: const EdgeInsets.all(8),
                child: Text(error!, style: const TextStyle(color: Colors.red))),
          if (searching) const LinearProgressIndicator(),
          Expanded(
            child: ListView.separated(
              itemCount: results.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final p = results[i];
                final username = p['user']?['username'] ?? '';
                final display = p['display_name'] ?? username;
                return FriendTile(
                  title: display,
                  subtitle: '@$username  ·  ${p['rank']}',
                  trailing: FilledButton(
                    onPressed: () async {
                      await FriendsService.sendRequest(username);
                      if (context.mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request sent')));
                    },
                    child: const Text('Add'),
                  ),
                );
              },
            ),
          ),
        ]),
      );
}
