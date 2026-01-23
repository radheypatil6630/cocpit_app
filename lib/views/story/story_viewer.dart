import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../models/story_model.dart';
import '../../services/story_service.dart';

class StoryViewer extends StatefulWidget {
  final StoryGroup storyGroup;

  const StoryViewer({
    super.key,
    required this.storyGroup,
  });

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  VideoPlayerController? _videoController;

  late List<Story> _stories;
  int _currentIndex = 0;
  bool _isPaused = false;
  bool _isLoading = true; // For video buffering

  @override
  void initState() {
    super.initState();
    _sortStories();

    _pageController = PageController();
    _animController = AnimationController(vsync: this);

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });

    _loadStory(0);
  }

  void _sortStories() {
    final unseen = widget.storyGroup.stories.where((s) => !s.hasViewed).toList();
    final seen = widget.storyGroup.stories.where((s) => s.hasViewed).toList();

    unseen.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    seen.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    _stories = [...unseen, ...seen];

    if (_stories.isEmpty) {
        Future.microtask(() => Navigator.pop(context));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    _videoController?.removeListener(_onVideoUpdate);
    _videoController?.dispose();
    super.dispose();
  }

  void _onVideoUpdate() {
    if (_videoController == null || !_videoController!.value.isInitialized) return;

    final duration = _videoController!.value.duration.inMilliseconds;
    final position = _videoController!.value.position.inMilliseconds;

    if (duration > 0) {
      _animController.value = position / duration;
    }

    if (_videoController!.value.isCompleted) {
      _nextStory();
    }
  }

  Future<void> _loadStory(int index) async {
    setState(() {
      _currentIndex = index;
      _isLoading = true;
    });

    _videoController?.removeListener(_onVideoUpdate);
    _videoController?.dispose();
    _videoController = null;
    _animController.stop();
    _animController.reset();

    final story = _stories[index];

    // Report View
    if (!story.hasViewed && !widget.storyGroup.isCurrentUser) {
      StoryService.viewStory(story.storyId);
      setState(() {
        story.hasViewed = true;
      });
    }

    if (story.mediaType == 'video') {
       _videoController = VideoPlayerController.networkUrl(Uri.parse(story.mediaUrl));
       try {
         await _videoController!.initialize();
         if (!mounted) return;

         setState(() {
           _isLoading = false;
         });

         _videoController!.addListener(_onVideoUpdate);
         _videoController!.play();
       } catch (e) {
         print("Error loading video: $e");
         if (mounted) _nextStory();
       }
    } else {
      // Image
      setState(() {
        _isLoading = false;
      });
      _animController.duration = const Duration(seconds: 5);
      _animController.forward();
    }
  }

  void _nextStory() {
    if (_currentIndex < _stories.length - 1) {
      _loadStory(_currentIndex + 1);
    } else {
      Navigator.pop(context);
    }
  }

  void _prevStory() {
    if (_currentIndex > 0) {
      _loadStory(_currentIndex - 1);
    } else {
       _loadStory(_currentIndex);
    }
  }

  void _pause() {
    setState(() => _isPaused = true);
    _animController.stop();
    _videoController?.pause();
  }

  void _resume() {
    setState(() => _isPaused = false);
    if (_videoController != null && _videoController!.value.isInitialized) {
      _videoController!.play();
    } else {
      _animController.forward();
    }
  }

  void _onTapDown(TapDownDetails details) {
    _pause();
  }

  void _onTapUp(TapDownDetails details) {
    _resume();
    final width = MediaQuery.of(context).size.width;
    if (details.globalPosition.dx < width / 3) {
      _prevStory();
    } else {
      _nextStory(); // Also handles right tap
    }
  }

  Future<void> _deleteStory() async {
    _pause(); // Pause while confirming
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Story?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
       try {
         await StoryService.deleteStory(_stories[_currentIndex].storyId);
         // Remove from local list
         setState(() {
            _stories.removeAt(_currentIndex);
         });
         if (_stories.isEmpty) {
           Navigator.pop(context);
         } else {
           if (_currentIndex >= _stories.length) {
             _currentIndex = _stories.length - 1;
           }
           _loadStory(_currentIndex);
         }
       } catch (e) {
         _resume();
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to delete")));
       }
    } else {
      _resume();
    }
  }

  Future<void> _toggleLike() async {
    final story = _stories[_currentIndex];
    final newStatus = !story.hasLiked;
    // Optimistic update
    setState(() {
      story.hasLiked = newStatus;
      if (newStatus) story.likeCount++;
      else story.likeCount--;
    });

    try {
      await StoryService.reactToStory(story.storyId, 'true');
    } catch (e) {
      // Revert
      setState(() {
         story.hasLiked = !newStatus;
         if (!newStatus) story.likeCount++;
         else story.likeCount--;
      });
    }
  }

  Future<void> _showViewers() async {
    _pause();
    final story = _stories[_currentIndex];

    // Fetch viewers
    try {
      final viewers = await StoryService.getStoryDetails(story.storyId);

      if (!mounted) return;

      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Viewers (${viewers.length})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: viewers.isEmpty
                  ? const Center(child: Text("No views yet"))
                  : ListView.builder(
                      itemCount: viewers.length,
                      itemBuilder: (context, index) {
                        final v = viewers[index];
                        return ListTile(
                          leading: CircleAvatar(
                             backgroundImage: (v.avatarUrl != null) ? NetworkImage(v.avatarUrl!) : null,
                             child: (v.avatarUrl == null) ? const Icon(Icons.person) : null,
                          ),
                          title: Text(v.fullName),
                          trailing: v.reactionType == 'true' ? const Icon(Icons.favorite, color: Colors.red) : null,
                        );
                      },
                  ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to load viewers")));
    } finally {
      _resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_stories.isEmpty) return const SizedBox();

    final story = _stories[_currentIndex];
    final user = widget.storyGroup.author;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onLongPress: _pause,
          onLongPressUp: _resume,
          child: Stack(
            children: [
              // 1. Media
              Center(
                child: story.mediaType == 'video'
                  ? (_videoController != null && _videoController!.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        )
                      : const CircularProgressIndicator())
                  : Image.network(
                      story.mediaUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return const CircularProgressIndicator();
                      },
                    ),
              ),

              // 2. Overlay
              Column(
                children: [
                  // Progress Bars
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      children: List.generate(_stories.length, (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: AnimatedBuilder(
                              animation: _animController,
                              builder: (context, child) {
                                double value = 0.0;
                                if (index < _currentIndex) {
                                  value = 1.0;
                                } else if (index == _currentIndex) {
                                  value = _animController.value;
                                }
                                return LinearProgressIndicator(
                                  value: value,
                                  backgroundColor: Colors.white.withOpacity(0.3),
                                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                                  minHeight: 2,
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Header (User info + Close)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: (user.avatar != null && user.avatar!.isNotEmpty)
                              ? NetworkImage(user.avatar!)
                              : const AssetImage('lib/images/profile.png') as ImageProvider,
                        ),
                        const SizedBox(width: 10),
                        Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                         const SizedBox(width: 10),
                        // Time ago
                        Text(
                          _formatTimeAgo(story.createdAt),
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Footer (Description + Interactions)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (story.description != null && story.description!.isNotEmpty)
                          Text(
                             story.description!,
                             style: const TextStyle(color: Colors.white, fontSize: 16),
                             textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 10),

                        if (widget.storyGroup.isCurrentUser)
                           // Author View
                           Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               ElevatedButton.icon(
                                 onPressed: _showViewers,
                                 icon: const Icon(Icons.visibility),
                                 label: Text("${story.viewCount}"),
                                 style: ElevatedButton.styleFrom(backgroundColor: Colors.white24, foregroundColor: Colors.white),
                               ),
                               const SizedBox(width: 20),
                               IconButton(
                                 icon: const Icon(Icons.delete, color: Colors.white),
                                 onPressed: _deleteStory,
                               ),
                             ],
                           )
                        else
                           // Viewer View
                           Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               IconButton(
                                 icon: Icon(
                                   story.hasLiked ? Icons.favorite : Icons.favorite_border,
                                   color: story.hasLiked ? Colors.red : Colors.white,
                                   size: 30,
                                 ),
                                 onPressed: _toggleLike,
                               ),
                             ],
                           ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return "${diff.inMinutes}m";
    if (diff.inHours < 24) return "${diff.inHours}h";
    return "${diff.inDays}d";
  }
}
