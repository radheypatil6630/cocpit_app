import 'package:flutter/material.dart';
import '../../models/story_model.dart';
import 'create_story_screen.dart';
import 'story_viewer.dart';

class StoryTray extends StatelessWidget {
  final List<StoryGroup> storyGroups;
  final VoidCallback? onRefresh;

  const StoryTray({
    super.key,
    required this.storyGroups,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Separate current user group from others
    StoryGroup? currentUserGroup;
    try {
      currentUserGroup = storyGroups.firstWhere((g) => g.isCurrentUser);
    } catch (e) {
      currentUserGroup = null;
    }

    final otherGroups = storyGroups.where((g) => !g.isCurrentUser).toList();
    // Sort: Unseen first
    otherGroups.sort((a, b) {
      final aUnseen = a.stories.any((s) => !s.hasViewed);
      final bUnseen = b.stories.any((s) => !s.hasViewed);
      if (aUnseen && !bUnseen) return -1;
      if (!aUnseen && bUnseen) return 1;
      return 0;
    });

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: 1 + otherGroups.length, // 1 for current user
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCurrentUserAvatar(context, currentUserGroup);
          }
          final group = otherGroups[index - 1];
          return _buildStoryAvatar(context, group);
        },
      ),
    );
  }

  Widget _buildCurrentUserAvatar(BuildContext context, StoryGroup? group) {
    final theme = Theme.of(context);
    final bool hasStories = group != null && group.stories.isNotEmpty;
    final bool hasUnseen = hasStories && group.stories.any((s) => !s.hasViewed);

    // If no group, we need a fallback avatar (maybe from user provider, but here we might just show a generic one or assume group exists with empty stories)
    // The API returns a group for current user even if empty (based on logic).
    final String? avatarUrl = group?.author.avatar;

    return GestureDetector(
      onTap: () {
        if (hasStories) {
            // Open viewer
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StoryViewer(
                  storyGroup: group!,
                ),
              ),
            ).then((_) => onRefresh?.call());
        } else {
           // Go to create story
           Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateStoryScreen()),
            ).then((_) => onRefresh?.call());
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: hasStories
                      ? Border.all(
                          color: hasUnseen ? theme.primaryColor : Colors.grey,
                          width: 2.5
                        )
                      : null,
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? NetworkImage(avatarUrl)
                        : const AssetImage('lib/images/profile.png') as ImageProvider,
                  ),
                ),
                if (!hasStories) // Show Add Icon
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                      ),
                      child: const Icon(Icons.add, size: 16, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              "Your Story",
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryAvatar(BuildContext context, StoryGroup group) {
    final theme = Theme.of(context);
    final bool hasUnseen = group.stories.any((s) => !s.hasViewed);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoryViewer(
              storyGroup: group,
            ),
          ),
        ).then((_) => onRefresh?.call());
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: hasUnseen ? theme.primaryColor : Colors.grey,
                  width: 2.5
                ),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: (group.author.avatar != null && group.author.avatar!.isNotEmpty)
                    ? NetworkImage(group.author.avatar!)
                    : const AssetImage('lib/images/profile.png') as ImageProvider,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 70,
              child: Text(
                group.author.name,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
