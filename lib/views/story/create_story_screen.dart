import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../services/story_service.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  File? _mediaFile;
  bool _isVideo = false;
  VideoPlayerController? _videoController;
  final TextEditingController _captionController = TextEditingController();
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _videoController?.dispose();
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(ImageSource source, {bool isVideo = false}) async {
    final XFile? pickedFile = isVideo
        ? await _picker.pickVideo(source: source, maxDuration: const Duration(seconds: 30))
        : await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        _isVideo = isVideo;
      });

      if (_isVideo) {
        _videoController = VideoPlayerController.file(_mediaFile!)
          ..initialize().then((_) {
            setState(() {});
            _videoController!.play();
            _videoController!.setLooping(true);
          });
      }
    }
  }

  Future<void> _uploadStory() async {
    if (_mediaFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      await StoryService.createStory(
        file: _mediaFile!,
        title: "Story", // Default title as it's not very relevant for UI
        description: _captionController.text,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload: $e")),
        );
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _mediaFile == null ? _buildPicker(context) : _buildPreview(context),
      floatingActionButton: _mediaFile != null && !_isUploading
          ? FloatingActionButton(
              onPressed: _uploadStory,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.send, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildPicker(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pickerButton(Icons.camera_alt, "Camera", () => _pickMedia(ImageSource.camera)),
          const SizedBox(height: 20),
          _pickerButton(Icons.videocam, "Video", () => _pickMedia(ImageSource.camera, isVideo: true)),
          const SizedBox(height: 20),
          _pickerButton(Icons.photo_library, "Gallery", () => _pickMedia(ImageSource.gallery)),
        ],
      ),
    );
  }

  Widget _pickerButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: _isVideo
              ? (_videoController != null && _videoController!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  : const CircularProgressIndicator())
              : Image.file(_mediaFile!),
        ),
        Positioned(
          bottom: 80,
          left: 20,
          right: 20,
          child: TextField(
            controller: _captionController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: "Add a caption...",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.black45,
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
        ),
        if (_isUploading)
          Container(
            color: Colors.black54,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
