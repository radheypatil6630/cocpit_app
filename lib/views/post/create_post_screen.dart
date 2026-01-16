import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/post_service.dart';
import '../../services/secure_storage.dart';
import '../../services/profile_service.dart';

enum PostMode { text, image, video }

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController postCtrl = TextEditingController();

  PostMode mode = PostMode.text;
  bool isLoading = false;

  File? imageFile;
  File? videoFile;

  String? userName;
  String? avatarUrl;
  bool isLoadingUser = true;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ───────── USER ─────────
  Future<void> _loadUser() async {
    try {
      final data = await ProfileService().getMyProfile();
      if (!mounted) return;

      setState(() {
        userName = data?['user']?['name'] ?? "Unknown User";
        avatarUrl = data?['user']?['avatar'];
        isLoadingUser = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        userName = "Unknown User";
        avatarUrl = null;
        isLoadingUser = false;
      });
    }
  }

  // ───────── VALIDATION ─────────
  bool get canPost =>
      !isLoading &&
          (postCtrl.text.trim().isNotEmpty ||
              imageFile != null ||
              videoFile != null);

  // ───────── PICK IMAGE ─────────
  Future<void> pickImage() async {
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        imageFile = File(img.path);
        videoFile = null;
        mode = PostMode.image;
      });
    }
  }

  // ───────── PICK VIDEO ─────────
  Future<void> pickVideo() async {
    final vid = await picker.pickVideo(source: ImageSource.gallery);
    if (vid != null) {
      setState(() {
        videoFile = File(vid.path);
        imageFile = null;
        mode = PostMode.video;
      });
    }
  }

  // ───────── SUBMIT ─────────
  Future<void> submitPost() async {
    setState(() => isLoading = true);

    try {
      final token = await AppSecureStorage.getAccessToken();
      if (token == null) throw Exception("Session expired");

      await PostService.createPost(
        token: token,
        content: postCtrl.text.trim(),
        category: "Professional",
        postType: mode == PostMode.image
            ? "image"
            : mode == PostMode.video
            ? "video"
            : "text",
        imageFile: imageFile,
        videoFile: videoFile,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ───────── UI ─────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create post"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _author(),
                  const SizedBox(height: 16),
                  _postInput(),
                  if (imageFile != null) _imagePreview(),
                  if (videoFile != null) _videoPreview(),
                ],
              ),
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  // ───────── AUTHOR ─────────
  Widget _author() {
    if (isLoadingUser) {
      return const Row(
        children: [
          CircleAvatar(radius: 22),
          SizedBox(width: 12),
          Text("Loading..."),
        ],
      );
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundImage:
          avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          child: avatarUrl == null ? const Icon(Icons.person) : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName ?? "",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text("Post to Anyone", style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  // ───────── INPUT ─────────
  Widget _postInput() {
    return TextField(
      controller: postCtrl,
      maxLines: null,
      decoration: const InputDecoration(
        hintText: "What do you want to talk about?",
        border: InputBorder.none,
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  // ───────── IMAGE PREVIEW ─────────
  Widget _imagePreview() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(imageFile!, fit: BoxFit.cover),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: _removeButton(() {
              setState(() {
                imageFile = null;
                mode = PostMode.text;
              });
            }),
          ),
        ],
      ),
    );
  }

  // ───────── VIDEO PREVIEW ─────────
  Widget _videoPreview() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Stack(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.play_circle, size: 64),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: _removeButton(() {
              setState(() {
                videoFile = null;
                mode = PostMode.text;
              });
            }),
          ),
        ],
      ),
    );
  }

  Widget _removeButton(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: const CircleAvatar(
        radius: 14,
        backgroundColor: Colors.black54,
        child: Icon(Icons.close, size: 16, color: Colors.white),
      ),
    );
  }

  // ───────── BOTTOM BAR ─────────
  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration:
      const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey))),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.image), onPressed: pickImage),
          IconButton(icon: const Icon(Icons.videocam), onPressed: pickVideo),
          const Spacer(),
          ElevatedButton(
            onPressed: canPost ? submitPost : null,
            child: isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text("Post"),
          ),
        ],
      ),
    );
  }
}
