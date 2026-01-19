import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';
import 'package:after_hours/screens/friend_profile_page.dart'; // ✅ NEW

class FeedPage extends StatefulWidget {
  final ApiService apiService;

  const FeedPage({super.key, required this.apiService});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _posts = [];
  bool _isPosting = false; // ✅ for composer button state

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final data = await widget.apiService.fetchFeed();

    if (!mounted) return;

    if (data == null) {
      setState(() {
        _loading = false;
        _error = 'Could not load feed.';
      });
    } else {
      setState(() {
        _loading = false;
        _posts = data;
      });
    }
  }

  /// ✅ Compose dialog (same design), but pushed UP when keyboard opens
  Future<void> _openCreatePostSheet() async {
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

        return SafeArea(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            // 👇 This is the whole fix: add bottom padding = keyboard height (+ a little extra)
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 12,
              bottom: bottomInset + 24,
            ),
            child: Align(
              // 👇 Keeps it slightly higher even when keyboard is NOT open
              alignment: const Alignment(0, -0.20),
              child: Material(
                color: Colors.transparent,
                child: SingleChildScrollView(
                  // 👇 Prevents overflow on smaller screens / landscape
                  child: Container(
                    width: MediaQuery.of(ctx).size.width * 0.9,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E).withOpacity(0.96),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Header
                        Row(
                          children: [
                            const Text(
                              'New Post',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.white70),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// Text field
                        TextField(
                          controller: controller,
                          autofocus: true,
                          maxLines: 5,
                          maxLength: 280,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "What’s happening tonight?",
                            hintStyle: const TextStyle(color: Colors.white60),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.06),
                            counterStyle:
                                const TextStyle(color: Colors.white54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.25),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// Post button
                        Row(
                          children: [
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _isPosting
                                  ? null
                                  : () async {
                                      final content = controller.text.trim();
                                      if (content.isEmpty) {
                                        Navigator.of(ctx).pop();
                                        return;
                                      }

                                      setState(() {
                                        _isPosting = true;
                                      });

                                      final res =
                                          await widget.apiService.createPost(
                                        content,
                                      );

                                      if (!mounted) return;

                                      setState(() {
                                        _isPosting = false;
                                      });

                                      Navigator.of(ctx).pop();

                                      if (res != null) {
                                        setState(() {
                                          _posts.insert(
                                            0,
                                            Map<String, dynamic>.from(res),
                                          );
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Post created ✅'),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Failed to create post ❌'),
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pinkAccent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                shadowColor: Colors.pinkAccent.withOpacity(0.5),
                                elevation: 8,
                              ),
                              child: _isPosting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Post',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleLike(int index) async {
    final post = _posts[index];
    final int postId = post['id'] as int;

    final res = await widget.apiService.toggleLikePost(postId);
    if (!mounted || res == null) return;

    setState(() {
      _posts[index]['is_liked'] = res['liked'];
      _posts[index]['like_count'] = res['like_count'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Nightlife Feed',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: _buildBody(),

          /// ✅ Twitter-style floating compose button
          floatingActionButton: FloatingActionButton(
            onPressed: _openCreatePostSheet,
            backgroundColor: Colors.pinkAccent,
            child: const Icon(Icons.edit, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadFeed,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "No posts yet.\nBe the first to share your night.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _openCreatePostSheet,
              child: const Text('Create Post'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFeed,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _buildPostCard(post, index);
        },
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, int index) {
    final user = post['user'] as Map<String, dynamic>? ?? {};
    final profileUser = user['user'] as Map<String, dynamic>? ?? {};
    final String displayName = user['display_name'] as String? ??
        profileUser['username'] as String? ??
        'User';
    final String username = profileUser['username'] as String? ?? '';
    final String? myUsername = widget.apiService.currentUsername;
    final String rank = user['rank'] as String? ?? '';
    final String content = post['content'] as String? ?? '';
    final String createdAt = post['created_at'] as String? ?? '';
    final int likeCount = post['like_count'] as int? ?? 0;
    final bool isLiked = post['is_liked'] == true;

    final String initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1c1842),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.pinkAccent.withOpacity(0.4),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  // ✅ Make name + username clickable
                  child: InkWell(
                    onTap: (username.isEmpty || username == myUsername)
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FriendProfilePage(
                                  apiService: widget.apiService,
                                  username: username,
                                ),
                              ),
                            );
                          },
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '@$username • $rank',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  _formatTime(createdAt),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Content
            Text(
              content,
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 10),

            // Actions
            Row(
              children: [
                InkWell(
                  onTap: () => _toggleLike(index),
                  borderRadius: BorderRadius.circular(999),
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.pinkAccent : Colors.white70,
                        size: 22,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        likeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String _formatTime(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inSeconds < 60) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';

      // fallback date
      return '${dt.month}/${dt.day}/${dt.year % 100}';
    } catch (_) {
      return '';
    }
  }
}
