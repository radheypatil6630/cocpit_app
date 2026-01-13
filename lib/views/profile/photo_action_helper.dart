import 'package:flutter/material.dart';
import '../fullscreen_image.dart';

class PhotoActionHelper {
  static void showPhotoActions({
    required BuildContext context,
    required String title,
    required String? imagePath,
    required String heroTag,
    required VoidCallback onUpdate,
    required VoidCallback onDelete,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final theme = Theme.of(context);

    if (isMobile) {
      showModalBottomSheet(
        context: context,
        backgroundColor: theme.colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => _buildMenu(context, title, imagePath, heroTag, onUpdate, onDelete),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: _buildMenu(context, title, imagePath, heroTag, onUpdate, onDelete),
          ),
        ),
      );
    }
  }

  static Widget _buildMenu(
    BuildContext context,
    String title,
    String? imagePath,
    String heroTag,
    VoidCallback onUpdate,
    VoidCallback onDelete,
  ) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: theme.textTheme.titleLarge,
          ),
        ),
        Divider(color: theme.dividerColor),
        _buildOptionItem(
          context: context,
          icon: Icons.visibility_outlined,
          title: "View Photo",
          onTap: () {
            Navigator.pop(context);
            if (imagePath != null && imagePath.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImage(imagePath: imagePath, tag: heroTag),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No image to view")),
              );
            }
          },
        ),
        _buildOptionItem(
          context: context,
          icon: Icons.edit_outlined,
          title: "Edit Photo",
          onTap: () {
            Navigator.pop(context);
            _showEditSubMenu(context, onUpdate, onDelete);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  static void _showEditSubMenu(BuildContext context, VoidCallback onUpdate, VoidCallback onDelete) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOptionItem(
            context: context,
            icon: Icons.cloud_upload_outlined,
            title: "Update Photo",
            onTap: () {
              Navigator.pop(context);
              _showUpdateOptions(context, onUpdate);
            },
          ),
          _buildOptionItem(
            context: context,
            icon: Icons.delete_outline,
            title: "Delete Photo",
            color: theme.colorScheme.error,
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, onDelete);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static void _showUpdateOptions(BuildContext context, VoidCallback onUpdate) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOptionItem(
            context: context,
            icon: Icons.camera_alt_outlined,
            title: "Take Photo",
            onTap: () {
              Navigator.pop(context);
              onUpdate();
            },
          ),
          _buildOptionItem(
            context: context,
            icon: Icons.image_outlined,
            title: "Upload from Gallery",
            onTap: () {
              Navigator.pop(context);
              onUpdate();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static void _showDeleteConfirmation(BuildContext context, VoidCallback onDelete) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text("Delete Photo", style: theme.textTheme.titleLarge),
        content: Text("Are you sure you want to remove this photo?", style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: theme.textTheme.bodySmall?.color)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: Text("Delete", style: TextStyle(color: theme.colorScheme.error)),
          ),
        ],
      ),
    );
  }

  static Widget _buildOptionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final displayColor = color ?? theme.textTheme.bodyLarge?.color ?? Colors.grey;
    return ListTile(
      leading: Icon(icon, color: displayColor),
      title: Text(title, style: TextStyle(color: displayColor, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}
