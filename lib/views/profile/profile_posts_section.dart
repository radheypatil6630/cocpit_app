import 'package:flutter/material.dart';
import 'profile_models.dart';

class ProfileLatestPostsSection extends StatelessWidget {
  final List<UserPost> posts;
  final String userName;
  final VoidCallback onSeeAllPosts;

  const ProfileLatestPostsSection({
    super.key,
    required this.posts,
    required this.userName,
    required this.onSeeAllPosts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Activity",
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: onSeeAllPosts,
                child: Text("See all", style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "500 followers",
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          ...posts.take(2).map((post) => _postItem(context, post)).toList(),
        ],
      ),
    );
  }

  Widget _postItem(BuildContext context, UserPost post) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.thumb_up_off_alt, size: 14, color: theme.primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    "${post.likes} likes",
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "• ${post.comments} comments",
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(color: theme.dividerColor),
      ],
    );
  }
}

class AllPostsScreen extends StatelessWidget {
  final List<UserPost> posts;
  final String userName;

  const AllPostsScreen({super.key, required this.posts, required this.userName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("All Posts"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: posts.length,
        itemBuilder: (context, index) => _fullPostItem(context, posts[index]),
      ),
    );
  }

  Widget _fullPostItem(BuildContext context, UserPost post) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                child: Text(userName[0], style: TextStyle(color: theme.primaryColor)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userName, style: theme.textTheme.titleSmall),
                  Text(post.date, style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(post.content, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.favorite, color: theme.colorScheme.secondary, size: 16),
                  const SizedBox(width: 4),
                  Text("${post.likes}", style: theme.textTheme.bodySmall),
                ],
              ),
              Text("${post.comments} comments • ${post.shares} shares", style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
