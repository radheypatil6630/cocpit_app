import 'package:flutter/material.dart';
import '../fullscreen_image.dart';

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic>? user;
  final String profileImage;
  final String? coverImage;
  final VoidCallback onMenuPressed;
  final VoidCallback onCameraPressed;
  final VoidCallback onCoverCameraPressed;
  final Color backgroundColor;
  final bool isReadOnly;

  const ProfileHeader({
    super.key,
    this.user,
    required this.profileImage,
    this.coverImage,
    required this.onMenuPressed,
    required this.onCameraPressed,
    required this.onCoverCameraPressed,
    required this.backgroundColor,
    this.isReadOnly = false,
  });

  bool _isNetworkImage(String path) {
    return path.startsWith('http');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String resolvedProfileImage =
    user?['avatar_url']?.toString().isNotEmpty == true
        ? user!['avatar_url']
        : profileImage;

    final String? resolvedCoverImage =
    user?['cover_url']?.toString().isNotEmpty == true
        ? user!['cover_url']
        : coverImage;

    ImageProvider? _imageProvider(String path) {
      if (path.isEmpty) return null;
      return _isNetworkImage(path)
          ? NetworkImage(path)
          : AssetImage(path) as ImageProvider;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ================= COVER PHOTO =================
        GestureDetector(
          onTap: () {
            if (resolvedCoverImage != null && resolvedCoverImage.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImage(
                    imagePath: resolvedCoverImage!,
                    tag: 'cover_hero',
                  ),
                ),
              );
            }
          },
          child: Hero(
            tag: 'cover_hero',
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: resolvedCoverImage == null || resolvedCoverImage.isEmpty
                    ? LinearGradient(
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withValues(alpha: 0.7),
                  ],
                )
                    : null,
                image: resolvedCoverImage != null &&
                    resolvedCoverImage.isNotEmpty
                    ? DecorationImage(
                  image: _imageProvider(resolvedCoverImage)!,
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8, top: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isReadOnly) ...[
                          IconButton(
                            icon: Icon(Icons.camera_alt_outlined,
                                color: colorScheme.onPrimary),
                            onPressed: onCoverCameraPressed,
                          ),
                          IconButton(
                            icon: Icon(Icons.menu,
                                color: colorScheme.onPrimary),
                            onPressed: onMenuPressed,
                          ),
                        ] else
                          const BackButton(color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // ================= PROFILE PHOTO =================
        Positioned(
          bottom: -50,
          left: 20,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (resolvedProfileImage.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenImage(
                          imagePath: resolvedProfileImage,
                          tag: 'profile_hero',
                        ),
                      ),
                    );
                  }
                },
                child: Hero(
                  tag: 'profile_hero',
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 65,
                      backgroundImage:
                      _imageProvider(resolvedProfileImage),
                      backgroundColor:
                      colorScheme.surfaceContainerHighest,
                      child: resolvedProfileImage.isEmpty
                          ? Icon(Icons.person,
                          size: 60,
                          color: colorScheme.onSurface
                              .withValues(alpha: 0.5))
                          : null,
                    ),
                  ),
                ),
              ),
              if (!isReadOnly)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onCameraPressed,
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withValues(alpha: 0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border:
                        Border.all(color: backgroundColor, width: 3),
                      ),
                      child: Icon(Icons.camera_alt_outlined,
                          color: colorScheme.onPrimary),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
