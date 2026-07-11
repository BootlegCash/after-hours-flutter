import 'dart:async';
import 'package:flutter/material.dart';
import '../core/friends_service.dart';

class FriendsSearchPage extends StatefulWidget {
  const FriendsSearchPage({super.key});

  @override
  State<FriendsSearchPage> createState() => _FriendsSearchPageState();
}

class _FriendsSearchPageState extends State<FriendsSearchPage> {
  final _controller = TextEditingController();
  List<dynamic> _results = [];
  bool _searching = false;
  bool _hasSearched = false;
  int _searchVersion = 0;
  Timer? _searchDebounce;
  String? _error;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search({bool dismissKeyboard = true}) async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    final version = ++_searchVersion;

    if (dismissKeyboard) FocusScope.of(context).unfocus();

    setState(() {
      _searching = true;
      _error = null;
      _results = [];
      _hasSearched = true;
    });

    try {
      final r = await FriendsService.search(query);
      if (!mounted || version != _searchVersion) return;
      setState(() {
        _results = r;
        _searching = false;
      });
    } catch (e) {
      if (!mounted || version != _searchVersion) return;
      setState(() {
        _error = '$e';
        _searching = false;
      });
    }
  }

  void _onQueryChanged(String value) {
    _searchDebounce?.cancel();
    _searchVersion++;
    if (_hasSearched || _results.isNotEmpty || _searching) {
      setState(() {
        _hasSearched = false;
        _results = [];
        _searching = false;
        _error = null;
      });
    }
    if (value.trim().isEmpty) return;
    _searchDebounce = Timer(
      const Duration(milliseconds: 250),
      () => _search(dismissKeyboard: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0c29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0f0c29),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Find Friends',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0f0c29),
              Color(0xFF302b63),
              Color(0xFF24243e),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.search,
                  onChanged: _onQueryChanged,
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    hintText: 'Search by username...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                    prefixIcon: Icon(Icons.search,
                        color: Colors.white.withOpacity(0.4)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded,
                          color: Colors.pinkAccent),
                      onPressed: _search,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ),

            // Loading bar
            if (_searching)
              LinearProgressIndicator(
                backgroundColor: Colors.white.withOpacity(0.05),
                color: Colors.pinkAccent,
                minHeight: 2,
              ),

            // Results
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    // Error
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded,
                color: Colors.white.withOpacity(0.3), size: 48),
            const SizedBox(height: 12),
            Text(
              "Something went wrong.",
              style:
                  TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
            ),
          ],
        ),
      );
    }

    // No search yet
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_rounded,
                color: Colors.white.withOpacity(0.15), size: 64),
            const SizedBox(height: 16),
            Text(
              "Search for a username",
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Hit enter or tap the arrow to search.",
              style: TextStyle(
                color: Colors.white.withOpacity(0.25),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    // No results
    if (!_searching && _results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                color: Colors.white.withOpacity(0.2), size: 56),
            const SizedBox(height: 14),
            Text(
              "No users found.",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.45), fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              "Try a different username.",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.25), fontSize: 13),
            ),
          ],
        ),
      );
    }

    // Results list
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: _results.length,
      separatorBuilder: (_, __) =>
          Divider(color: Colors.white.withOpacity(0.07), height: 1),
      itemBuilder: (context, i) {
        final p = _results[i];
        final username = p['user']?['username'] ?? '';
        final display = p['display_name'] ?? username;
        final rank = p['rank'] ?? '';

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.pinkAccent, Colors.cyanAccent],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    display.isNotEmpty ? display[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Name + username + rank
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      display,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@$username',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 12,
                      ),
                    ),
                    if (rank.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        rank,
                        style: const TextStyle(
                          color: Colors.pinkAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Add button
              GestureDetector(
                onTap: () async {
                  await FriendsService.sendRequest(username);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Request sent to @$username'),
                        backgroundColor: Colors.pinkAccent.withOpacity(0.8),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.pinkAccent, Colors.cyanAccent],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text(
                    "Add",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
