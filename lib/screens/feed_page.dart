import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';
import 'package:after_hours/screens/friend_profile_page.dart';

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
  bool _isPosting = false;

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

  Future<void> _openCreatePostSheet() async {
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (ctx) {
        return SafeArea(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Align(
              alignment: const Alignment(0, -0.2),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1c1842),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.25),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'New Post',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.of(ctx).pop(),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.close,
                                  color: Colors.white.withOpacity(0.6),
                                  size: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller,
                        autofocus: true,
                        maxLines: 5,
                        maxLength: 280,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "What's happening tonight?",
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.35)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          counterStyle:
                              TextStyle(color: Colors.white.withOpacity(0.35)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                                color: Colors.pinkAccent, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Spacer(),
                          GestureDetector(
                            onTap: _isPosting
                                ? null
                                : () async {
                                    final content = controller.text.trim();
                                    if (content.isEmpty) {
                                      Navigator.of(ctx).pop();
                                      return;
                                    }
                                    setState(() => _isPosting = true);
                                    final res = await widget.apiService
                                        .createPost(content);
                                    if (!mounted) return;
                                    setState(() => _isPosting = false);
                                    Navigator.of(ctx).pop();
                                    if (res != null) {
                                      setState(() => _posts.insert(
                                          0, Map<String, dynamic>.from(res)));
                                      _showSnack('Posted!');
                                    } else {
                                      _showSnack('Failed to post. Try again.');
                                    }
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Colors.pinkAccent,
                                  Colors.cyanAccent
                                ]),
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.pinkAccent.withOpacity(0.35),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: _isPosting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text(
                                      'Post',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
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

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFF1c1842),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0c29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1c1842),
        elevation: 0,
        title: const Text(
          'Nightlife Feed',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
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
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreatePostSheet,
        backgroundColor: Colors.pinkAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.pinkAccent));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                color: Colors.white.withOpacity(0.3), size: 52),
            const SizedBox(height: 16),
            Text(_error!,
                style: const TextStyle(color: Colors.white60, fontSize: 15)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _loadFeed,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Colors.pinkAccent, Colors.cyanAccent]),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text('Retry',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.nightlife_rounded,
                color: Colors.white.withOpacity(0.15), size: 64),
            const SizedBox(height: 16),
            Text('No posts yet.',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.45), fontSize: 15)),
            const SizedBox(height: 6),
            Text('Be the first to share your night.',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.25), fontSize: 13)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _openCreatePostSheet,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Colors.pinkAccent, Colors.cyanAccent]),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text('Create Post',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFeed,
      backgroundColor: const Color(0xFF1c1842),
      color: Colors.pinkAccent,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
        itemCount: _posts.length,
        itemBuilder: (context, index) => _buildPostCard(_posts[index], index),
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
    final bool isMe = username == myUsername;

    final String initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              GestureDetector(
                onTap: (username.isEmpty || isMe)
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FriendProfilePage(
                              apiService: widget.apiService,
                              username: username,
                            ),
                          ),
                        ),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.pinkAccent, Colors.cyanAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Name + rank
              Expanded(
                child: GestureDetector(
                  onTap: (username.isEmpty || isMe)
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FriendProfilePage(
                                apiService: widget.apiService,
                                username: username,
                              ),
                            ),
                          ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.pinkAccent,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Text('YOU',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rank.isNotEmpty ? '@$username · $rank' : '@$username',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // Time
              Text(
                _formatTime(createdAt),
                style: TextStyle(
                    color: Colors.white.withOpacity(0.35), fontSize: 11),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Content
          Text(
            content,
            style:
                const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
          ),

          const SizedBox(height: 14),

          // Divider
          Divider(color: Colors.white.withOpacity(0.07), height: 1),

          const SizedBox(height: 10),

          // Like button
          GestureDetector(
            onTap: () => _toggleLike(index),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    key: ValueKey(isLiked),
                    color: isLiked
                        ? Colors.pinkAccent
                        : Colors.white.withOpacity(0.4),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  likeCount.toString(),
                  style: TextStyle(
                      color: isLiked
                          ? Colors.pinkAccent
                          : Colors.white.withOpacity(0.4),
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
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
      return '${dt.month}/${dt.day}/${dt.year % 100}';
    } catch (_) {
      return '';
    }
  }
}
