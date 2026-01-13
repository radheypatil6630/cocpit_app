import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/post_service.dart';
import '../../services/secure_storage.dart';
import 'package:flutter/foundation.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController postCtrl = TextEditingController();

  File? imageFile;
  File? videoFile;

  bool showPoll = false;
  final pollQCtrl = TextEditingController();
  final pollOpt1 = TextEditingController();
  final pollOpt2 = TextEditingController();

  Color get bg => Theme.of(context).scaffoldBackgroundColor;
  Color get card => Theme.of(context).colorScheme.surfaceContainer;
  Color get accent => Theme.of(context).primaryColor;

  bool get canPost {
    if (postCtrl.text.trim().isNotEmpty) return true;
    if (imageFile != null || videoFile != null) return true;
    if (showPoll &&
        pollQCtrl.text.isNotEmpty &&
        pollOpt1.text.isNotEmpty &&
        pollOpt2.text.isNotEmpty) return true;
    return false;
  }

  // ───────── IMAGE PICK ─────────
  Future<void> pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        imageFile = File(img.path);
        videoFile = null;
        showPoll = false;
      });
    }
  }

  // ───────── VIDEO PICK ─────────
  Future<void> pickVideo() async {
    final vid = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (vid != null) {
      setState(() {
        videoFile = File(vid.path);
        imageFile = null;
        showPoll = false;
      });
    }
  }

  // ───────── POLL ─────────
  void addPoll() {
    setState(() {
      showPoll = true;
      imageFile = null;
      videoFile = null;
    });
  }

  void removePoll() {
    setState(() {
      showPoll = false;
      pollQCtrl.clear();
      pollOpt1.clear();
      pollOpt2.clear();
    });
  }

  Future<bool> _confirmDiscard() async {
    if (canPost) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Discard post?"),
          content: const Text("You have unsaved changes. Are you sure you want to discard this post?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Discard", style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ],
        ),
      );
      return confirm ?? false;
    }
    return true;
  }

  // ───────── UI ─────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: theme.iconTheme.color),
            onPressed: () async {
              if (await _confirmDiscard()) {
                if (mounted) Navigator.pop(context);
              }
            },
          ),
          title: Text(
            "Create post",
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          _author(),
                          const SizedBox(height: 24),
                          _postInput(),
                          if (imageFile != null) _imagePreview(),
                          if (videoFile != null) _videoPreview(),
                          if (showPoll) _pollUI(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  _stickyActionBar(theme),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _author() {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
          child: Icon(Icons.person, color: theme.primaryColor),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sally Liang",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.public, size: 14, color: theme.textTheme.bodySmall?.color),
                  const SizedBox(width: 6),
                  Text("Anyone", style: theme.textTheme.bodySmall),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_drop_down, size: 16, color: theme.textTheme.bodySmall?.color),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _postInput() {
    final theme = Theme.of(context);
    return TextField(
      controller: postCtrl,
      maxLines: null,
      autofocus: true,
      style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18, height: 1.6),
      decoration: InputDecoration(
        hintText: "What do you want to share?",
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
          fontSize: 18,
        ),
        border: InputBorder.none,
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _imagePreview() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: kIsWeb
                ? Image.network(
                    imageFile!.path, // Flutter Web → blob URL
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    imageFile!, // Android / iOS
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: _removeButton(() => setState(() => imageFile = null)),
          ),
        ],
      ),
    );
  }

  Widget _videoPreview() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Stack(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(Icons.play_circle_fill, size: 64, color: theme.primaryColor),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: _removeButton(() => setState(() => videoFile = null)),
          ),
        ],
      ),
    );
  }

  Widget _pollUI() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Create a poll", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.close, size: 20, color: theme.iconTheme.color?.withValues(alpha: 0.6)),
                onPressed: removePoll,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            ],
          ),
          const SizedBox(height: 20),
          _pollField("Question", pollQCtrl),
          _pollField("Option 1", pollOpt1),
          _pollField("Option 2", pollOpt2),
        ],
      ),
    );
  }

  Widget _pollField(String hint, TextEditingController c) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5)),
          filled: true,
          fillColor: theme.scaffoldBackgroundColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _stickyActionBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        children: [
          _actionIcon(Icons.image_outlined, "Photo", pickImage),
          _actionIcon(Icons.videocam_outlined, "Video", pickVideo),
          _actionIcon(Icons.poll_outlined, "Poll", addPoll),
          _actionIcon(Icons.emoji_emotions_outlined, "Emoji", () {}),
          const Spacer(),
          ElevatedButton(
            onPressed: canPost ? () async {
              try {
                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );

                final token = await AppSecureStorage.getAccessToken();
                if (token == null) throw Exception("Session expired");

                await PostService.createPost(
                  token: token,
                  content: postCtrl.text,
                  category: "Professional",
                  postType: imageFile != null
                      ? "image"
                      : videoFile != null
                          ? "video"
                          : showPoll
                              ? "poll"
                              : "text",
                  imageFile: imageFile,
                  videoFile: videoFile,
                  pollOptions: showPoll ? [pollOpt1.text, pollOpt2.text] : null,
                  pollDuration: showPoll ? "1 week" : null,
                );

                if (mounted) {
                  Navigator.pop(context); // Close loading
                  Navigator.pop(context); // Close screen
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: accent.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            child: const Text("Post", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, String tooltip, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: accent, size: 28),
      tooltip: tooltip,
    );
  }

  Widget _removeButton(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        child: const Icon(Icons.close, size: 18, color: Colors.white),
      ),
    );
  }
}
